#r "Newtonsoft.Json"
#r "Microsoft.WindowsAzure.Storage"
#r "../bin/Microsoft.Azure.Management.ResourceManager.Fluent.dll"

using System;
using System.Net;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Configuration;
using System.Text;
using System.Threading;
using System.Globalization;
using System.Collections.Generic;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Host;
using Microsoft.WindowsAzure.Storage.Table;
using Microsoft.Azure.Management.ResourceManager.Fluent.Core;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

// Custom Resource Table Entity
public class CustomResource : TableEntity
{
    public string Data { get; set; }
}

// Webhook for the Azure Function
public static async Task<HttpResponseMessage> Run(HttpRequestMessage req, ILogger log, CloudTable tableStorage)
{
    // Get the unique Azure request path from request headers.
    var requestPath = req.Headers.GetValues("x-ms-customproviders-requestpath").First();

    log.LogInformation($"The Custom Provider Function received a request '{req.Method}' for resource '{requestPath}'.");

    // Determines if it is a collection level call or action.
    var isResourceRequest = requestPath.Split('/').Length % 2 == 1;
    var azureResourceId = isResourceRequest ? 
        ResourceId.FromString(requestPath) :
        ResourceId.FromString($"{requestPath}/");

    // Create the Partition Key and Row Key
    var partitionKey = $"{azureResourceId.SubscriptionId}:{azureResourceId.ResourceGroupName}:{azureResourceId.Parent.Name}";
    var rowKey = $"{azureResourceId.FullResourceType.Replace('/', ':')}:{azureResourceId.Name}";

    // Attempt to retrieve the Existing Stored Value
    var tableQuery = TableOperation.Retrieve<CustomResource>(partitionKey, rowKey);
    var existingCustomResource = isResourceRequest ? 
        (CustomResource)(await tableStorage.ExecuteAsync(tableQuery)).Result :
        null;

    switch (req.Method)
    {
        // Action request for an custom action.
        case HttpMethod m when m == HttpMethod.Post && !isResourceRequest:
            var myCustomActionRequest = JObject.Parse(await req.Content.ReadAsStringAsync());

            var actionResponse = req.CreateResponse(HttpStatusCode.OK);
            actionResponse.Content = new StringContent(myCustomActionRequest.ToString(), System.Text.Encoding.UTF8, "application/json");
            return actionResponse;

        // Enumerate request for all custom reousces.
        case HttpMethod m when m == HttpMethod.Get && !isResourceRequest:
            var enumerationQuery = new TableQuery<CustomResource>().Where(
                TableQuery.CombineFilters(
                    TableQuery.GenerateFilterCondition("PartitionKey", QueryComparisons.Equal, partitionKey),
                    TableOperators.And,
                    TableQuery.GenerateFilterCondition("RowKey", QueryComparisons.GreaterThan, rowKey)));
            
            var customResources = (await tableStorage.ExecuteQuerySegmentedAsync(enumerationQuery, null))
                .ToList().Select(customResource => JToken.Parse(customResource.Data));

            var enumerationResponse = req.CreateResponse(HttpStatusCode.OK);
            enumerationResponse.Content = new StringContent(new JObject(new JProperty("value", customResources)).ToString(), System.Text.Encoding.UTF8, "application/json");
            return enumerationResponse;

        // Retrieve request for a custom resource.
        case HttpMethod m when m == HttpMethod.Get:
            var retrieveResponse = req.CreateResponse(
                existingCustomResource != null ? HttpStatusCode.OK : HttpStatusCode.NotFound);

            retrieveResponse.Content = existingCustomResource != null ?
                 new StringContent(existingCustomResource.Data, System.Text.Encoding.UTF8, "application/json"):
                 null;

            return retrieveResponse;

        // Create request for a custom resource.
        case HttpMethod m when m == HttpMethod.Put:

            // Construct the new resource from the request body and adds the Azure Resource Manager fields.
            var myCustomResource = JObject.Parse(await req.Content.ReadAsStringAsync());
            myCustomResource["name"] = azureResourceId.Name;
            myCustomResource["type"] = azureResourceId.FullResourceType;
            myCustomResource["id"] = azureResourceId.Id;

            // Save the resource into storage.
            var insertOperation = TableOperation.InsertOrReplace(
                new CustomResource
                {
                    PartitionKey = partitionKey,
                    RowKey = rowKey,
                    Data = myCustomResource.ToString(),
                });
            await tableStorage.ExecuteAsync(insertOperation);

            var createResponse = req.CreateResponse(HttpStatusCode.OK);
            createResponse.Content = new StringContent(myCustomResource.ToString(), System.Text.Encoding.UTF8, "application/json");
            return createResponse;

        // Remove request for a custom resource.
        case HttpMethod m when m == HttpMethod.Delete:

            // Delete the resource from storage.
            if (existingCustomResource != null) {
                var deleteOperation = TableOperation.Delete(existingCustomResource);
                await tableStorage.ExecuteAsync(deleteOperation);
            }

            return req.CreateResponse(
                existingCustomResource != null ? HttpStatusCode.OK : HttpStatusCode.NoContent);

        // Invalid request recieved.
        default:
            return req.CreateResponse(HttpStatusCode.BadRequest);
    }
}