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

// The custom resource class, which stores generic request data.
public class CustomResource : TableEntity
{
    public string Data { get; set; }
}

public static async Task<HttpResponseMessage> Run(HttpRequestMessage req, ILogger log, CloudTable tableStorage)
{
    // Get the unique Azure resource id from request headers.
    var azureResourceId = ResourceId.FromString(req.Headers.GetValues("x-ms-customproviders-requestpath").First());

    // Create the Partition Key and Row Key
    var partitionKey = $"{azureResourceId.SubscriptionId}:{azureResourceId.ResourceGroupName}:{azureResourceId.Parent.Name}";
    var rowKey = $"{azureResourceId.Name}";

    log.LogInformation($"The Custom Provider Function received a request '{req.Method}' for resource '{azureResourceId.Id}' PartitionKey=[{partitionKey}] RowKey=[{rowKey}].");

    // Attempt to retrieve the Existing Stored Value
    var tableQuery = TableOperation.Retrieve<CustomResource>(partitionKey, rowKey);
    var existingCustomResource = (CustomResource)(await tableStorage.ExecuteAsync(tableQuery)).Result;

    switch (req.Method)
    {
        // Request to add an instance of the custom Azure resource.
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

            // Return the response with the newly created resource.
            var createResponse = req.CreateResponse(HttpStatusCode.OK);
            createResponse.Content = new StringContent(myCustomResource.ToString(), System.Text.Encoding.UTF8, "application/json");
            return createResponse;

        // Request to remove an instance of the custom Azure resource.
        case HttpMethod m when m == HttpMethod.Delete:

            // Delete the resource from storage.
            if (existingCustomResource != null) {
                var deleteOperation = TableOperation.Delete(existingCustomResource);
                await tableStorage.ExecuteAsync(deleteOperation);
            }

            return req.CreateResponse(
                existingCustomResource != null ? HttpStatusCode.OK : HttpStatusCode.NoContent);

        // Request to retrieve an instance of the custom Azure resource.
        default:
            var retrieveResponse = req.CreateResponse(
                existingCustomResource != null ? HttpStatusCode.OK : HttpStatusCode.NotFound);

            retrieveResponse.Content = existingCustomResource != null ?
                 new StringContent(existingCustomResource.Data, System.Text.Encoding.UTF8, "application/json"):
                 null;

            return retrieveResponse;
    }
}