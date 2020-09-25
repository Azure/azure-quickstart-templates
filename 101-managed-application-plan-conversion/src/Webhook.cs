using PlanConversionAgent.Definitions;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.Documents.Client;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Text;
using System.Threading.Tasks;
using ErrorEventArgs = Newtonsoft.Json.Serialization.ErrorEventArgs;
using Microsoft.AspNetCore.Http.Extensions;

namespace PlanConversionAgent
{
    public static class Webhook
    {
        public const string DatabaseName = "Applications";
        public const string CollectionName = "Operation";

        [FunctionName("Webhook")]
        public static async Task<IActionResult> Run(
            [HttpTrigger(AuthorizationLevel.Anonymous, "post", Route = "planUpdate")] HttpRequest req,
            [CosmosDB(
                databaseName: DatabaseName,
                collectionName: CollectionName,
                ConnectionStringSetting = "CosmosDBConnectionString")] DocumentClient documentClient,
            ILogger log,
            ExecutionContext context)
        {
            // Authorize the request based on the sig parameter
            var sig = req.Query["sig"];

            var config = new ConfigurationBuilder()
                .SetBasePath(context.FunctionAppDirectory)
                .AddJsonFile("local.settings.json", optional: true, reloadOnChange: true)
                .AddEnvironmentVariables()
                .Build();

            if (!config["URL_SIGNATURE"].Equals(sig, StringComparison.OrdinalIgnoreCase))
            {
                log.LogError($"Unexpected or missing 'sig' parameter value '{sig}'");
                return new UnauthorizedResult();
            }

            using (var streamReader = new StreamReader(req.Body))
            {
                var requestBody = await streamReader
                    .ReadToEndAsync()
                    .ConfigureAwait(continueOnCapturedContext: false);

                log.LogTrace($"Plan Update Notification payload: {requestBody}");

                var deserializationErrors = new List<string>();

                var notificationDefinition = JsonConvert.DeserializeObject<PlanUpdateNotificationDefinition>(
                    value: requestBody,
                    settings: new JsonSerializerSettings
                    {
                        Error = delegate (object sender, ErrorEventArgs args)
                        {
                            deserializationErrors.Add(args.ErrorContext.Error.Message);
                            args.ErrorContext.Handled = true;
                        }
                    });

                if (notificationDefinition == null || deserializationErrors.Any())
                {
                    return new BadRequestObjectResult($"Failed to deserialize request body. Errors: {String.Join(';', deserializationErrors)}");
                }

                if (!config["CURRENT_PLAN"].Equals(notificationDefinition.CurrentPlan.Name, StringComparison.OrdinalIgnoreCase) ||
                    !config["NEW_PLAN"].Equals(notificationDefinition.NewPlan.Name, StringComparison.OrdinalIgnoreCase))
                {
                    return new BadRequestObjectResult($"Plan update not supported from {notificationDefinition.CurrentPlan.Name} to {notificationDefinition.NewPlan.Name}.");
                }

                var applicationId = notificationDefinition.ApplicationId.Replace("/", "|");
                FeedOptions queryOptions = new FeedOptions
                {
                    MaxItemCount = -1,
                    EnableCrossPartitionQuery = true
                };

                // Check if plan update is already in-progress for this application.
                var operationDetail = documentClient.CreateDocumentQuery<OperationEntry>(
                   UriFactory.CreateDocumentCollectionUri(DatabaseName, CollectionName), queryOptions)
                 .Where(x => x.applicationId == applicationId)
                 .Take(1)
                 .AsEnumerable()
                 .FirstOrDefault();

                if (operationDetail != null)
                {
                    log.LogTrace($"Plan update is already in-progress.");

                    var operationResult = new AcceptedResult
                    {
                        Location = GetLocationUri((new Uri(req.GetEncodedUrl())).GetLeftPart(UriPartial.Authority), operationDetail.id)
                    };

                    log.LogTrace($"Returned location is {operationResult.Location}.");

                    return operationResult;
                }

                log.LogTrace($"Starting plan update.");

                var response = await
                    Webhook.GetAsync(uri: Webhook.GetManagedAppUri(notificationDefinition.ApplicationId), config: config, log: log)
                    .ConfigureAwait(continueOnCapturedContext: false);

                if (response?.IsSuccessStatusCode != true)
                {
                    log.LogError($"Failed to get managed application {notificationDefinition.ApplicationId}.");
                    return new StatusCodeResult(404);
                }

                var mrg = await Webhook.GetManagedResourceGroup(response: response, config: config).ConfigureAwait(continueOnCapturedContext: false);

                log.LogTrace($"Managed resource group for application is: {mrg}.");

                var deploymentUri = Webhook.GetDeploymentUri(resourceGroupId: mrg, deploymentName: Guid.NewGuid().ToString());

                var deploymentDefinition = Webhook.GetDeploymentDefinition();

                deploymentDefinition = deploymentDefinition
                    .Replace("mainTemplate", config["MAIN_TEMPLATE"])
                    .Replace("parametersTemplate", config["PARAMETERS_TEMPLATE"]);

                log.LogTrace($"Deployment definition is: {deploymentDefinition}.");

                var deploymentResponse = await
                    Webhook.PutAsync(uri: deploymentUri, body: deploymentDefinition, config: config, log: log)
                    .ConfigureAwait(continueOnCapturedContext: false);

                if (deploymentResponse?.IsSuccessStatusCode != true)
                {
                    log.LogError($"Failed to deploy template. {deploymentResponse.StatusCode}");
                    return new StatusCodeResult(500);
                }

                log.LogTrace($"Template deployment state is Accepted.");

                var operationId = Guid.NewGuid().ToString();

                var operationEntry = new OperationEntry
                {
                    id = operationId,
                    applicationId = notificationDefinition.ApplicationId.Replace("/", "|"), // CosmosDB does not support forward slashes in the id.
                    deploymentTrackingUri = deploymentUri
                };

                await documentClient
                    .UpsertDocumentAsync(UriFactory.CreateDocumentCollectionUri(DatabaseName, CollectionName), operationEntry)
                    .ConfigureAwait(continueOnCapturedContext: false);

                log.LogTrace($"Successfully inserted the operation entry in CosmosDB for deployment {deploymentUri}");

                var result = new AcceptedResult
                {
                    Location = Webhook.GetLocationUri((new Uri(req.GetEncodedUrl())).GetLeftPart(UriPartial.Authority), operationId)
                };

                log.LogTrace($"Returned location uri is {result.Location}.");

                return result;
            }
        }

        [FunctionName("GetOperationStatus")]
        public static async Task<IActionResult> GetOperationStatus(
            [HttpTrigger(AuthorizationLevel.Anonymous, "get", Route = "operation/{operationId}")] HttpRequest req,
            [CosmosDB(
                databaseName: DatabaseName,
                collectionName: CollectionName,
                ConnectionStringSetting = "CosmosDBConnectionString")] DocumentClient documentClient,
            ILogger log,
            ExecutionContext context)
        {
            var config = new ConfigurationBuilder()
                .SetBasePath(context.FunctionAppDirectory)
                .AddJsonFile("local.settings.json", optional: true, reloadOnChange: true)
                .AddEnvironmentVariables()
                .Build();

            var operationId = req.Path.ToString().Split('/').Last();

            FeedOptions queryOptions = new FeedOptions
            {
                MaxItemCount = -1,
                EnableCrossPartitionQuery = true
            };

            var operationEntry = documentClient.CreateDocumentQuery<OperationEntry>(
               UriFactory.CreateDocumentCollectionUri(DatabaseName, CollectionName), queryOptions)
             .Where(x => x.id == operationId)
             .Take(1)
             .AsEnumerable()
             .FirstOrDefault();

            if (operationEntry == null)
            {
                log.LogTrace($"Operation not found.");
                return new StatusCodeResult(404);
            }

            var response = await
                Webhook.GetAsync(uri: operationEntry.deploymentTrackingUri, config: config, log: log)
                .ConfigureAwait(continueOnCapturedContext: false);

            var operationResponse = response.Content.ReadAsStringAsync().Result;

            var status = "Failed";

            if (operationResponse.Contains("Succeeded"))
            {
                status = "Succeeded";
            }
            else if (operationResponse.Contains("Running") || operationResponse.Contains("Accepted"))
            {
                status = "Running";
            }

            var operationResult = new AsyncOperationResult
            {
                Status = status
            };

            return new OkObjectResult(operationResult);
        }

        /// <summary>
        /// Returns managed application uri.
        /// </summary>
        private static string GetManagedAppUri(string applicationId)
        {
            return string.Format(
                "{0}{1}?api-version={2}",
                "https://management.azure.com",
                applicationId,
                "2019-07-01");
        }

        /// <summary>
        /// Returns deployment uri.
        /// </summary>
        private static string GetDeploymentUri(string resourceGroupId, string deploymentName)
        {
            return string.Format(
                "{0}{1}/providers/Microsoft.Resources/deployments/{2}?api-version={3}",
                "https://management.azure.com",
                resourceGroupId,
                deploymentName,
                "2019-10-01");
        }

        /// <summary>
        /// Returns location uri.
        /// </summary>
        private static string GetLocationUri(string host, string operationId)
        {
            return string.Format(
                "{0}/api/operation/{1}",
                host,
                operationId);
        }

        /// <summary>
        /// Returns deployment definition.
        /// </summary>
        private static string GetDeploymentDefinition()
        {
            return @"{
                    ""properties"": {
                        ""mode"": ""Incremental"",
                        ""templateLink"": {
                            ""uri"": ""mainTemplate"" ,
                            ""contentVersion"": ""1.0.0.0""
                        },
                        ""parametersLink"": {
                            ""uri"": ""parametersTemplate"" ,
                            ""contentVersion"": ""1.0.0.0""
                        }
                    }
                }";
        }

        /// <summary>
        /// Returns managed resource group.
        /// </summary>
        private static async Task<string> GetManagedResourceGroup(HttpResponseMessage response, IConfigurationRoot config)
        {
            if (Webhook.IsLocalRun(config))
            {
                return "/subscriptions/subscriptionId/resourcegroups/resourceGroupName";
            }

            var responseContent = await response.Content.ReadAsStringAsync()
                .ConfigureAwait(continueOnCapturedContext: false);

            var deserializationErrors = new List<string>();

            var application = JsonConvert.DeserializeObject<Application>(
                value: responseContent,
                settings: new JsonSerializerSettings
                {
                    Error = delegate (object sender, ErrorEventArgs args)
                    {
                        deserializationErrors.Add(args.ErrorContext.Error.Message);
                        args.ErrorContext.Handled = true;
                    }
                });

            return application.Properties.ManagedResourceGroupId;
        }

        /// <summary>
        /// PUT operation.
        /// </summary>
        private static async Task<HttpResponseMessage> PutAsync(string uri, string body, IConfigurationRoot config, ILogger log)
        {
            if (Webhook.IsLocalRun(config))
            {
                return new HttpResponseMessage(HttpStatusCode.OK);
            }

            var httpClient = HttpClientFactory.Create();
            var token = Webhook.GetToken(httpClient, config, log).ConfigureAwait(continueOnCapturedContext: false);
            httpClient.DefaultRequestHeaders.Add("Authorization", $"Bearer {token}");

            return await
                httpClient.PutAsync(uri, new StringContent(JsonConvert.SerializeObject(body), Encoding.UTF8, "application/json")).ConfigureAwait(continueOnCapturedContext: false);
        }

        /// <summary>
        /// GET operation.
        /// </summary>
        private static async Task<HttpResponseMessage> GetAsync(string uri, IConfigurationRoot config, ILogger log)
        {
            log.LogTrace($"Invoking GET on {uri}.");

            if (Webhook.IsLocalRun(config))
            {
                var response = new HttpResponseMessage(HttpStatusCode.OK)
                {
                    Content = new StringContent("Succeeded")
                };

                return response;
            }

            var httpClient = HttpClientFactory.Create();
            var token = Webhook.GetToken(httpClient, config, log).ConfigureAwait(continueOnCapturedContext: false);
            httpClient.DefaultRequestHeaders.Add("Authorization", $"Bearer {token}");
            var request = new HttpRequestMessage(HttpMethod.Get, $"{uri}");

            return await httpClient.SendAsync(request).ConfigureAwait(continueOnCapturedContext: false);
        }

        /// <summary>
        /// Gets the token for the attached user-assigned managed identity.
        /// </summary>
        private static async Task<string> GetToken(HttpClient httpClient, IConfigurationRoot config, ILogger log)
        {
            if (Webhook.IsLocalRun(config))
            {
                return "token";
            }

            // TOKEN_RESOURCE and MSI_CLIENT_ID come from the configs.
            using (var request = new HttpRequestMessage(HttpMethod.Get, $"{config["MSI_ENDPOINT"]}/?resource={config["TOKEN_RESOURCE"]}&clientId={config["MSI_CLIENT_ID"]}&api-version=2017-09-01"))
            {
                request.Headers.Add("Secret", config["MSI_SECRET"]);
                var response = await httpClient.SendAsync(request).ConfigureAwait(continueOnCapturedContext: false);
                if (response?.IsSuccessStatusCode != true)
                {
                    log.LogError("Failed to get token for user-assigned MSI. Please check that all the config flags are set properly and the MSI is attached.");
                }
                var responseBody = await response.Content.ReadAsStringAsync().ConfigureAwait(continueOnCapturedContext: false);
                return JsonConvert.DeserializeObject<TokenDefinition>(responseBody).Access_token;
            }
        }

        /// <summary>
        /// Returns whether the function is running locally.
        /// </summary>
        private static bool IsLocalRun(IConfigurationRoot config)
        {
            return config["LOCAL_RUN"]?.Equals("true", StringComparison.OrdinalIgnoreCase) == true;
        }
    }
}
