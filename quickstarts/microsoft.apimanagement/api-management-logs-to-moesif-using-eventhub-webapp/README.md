# Moesif API Analytics for Azure API Management
![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.apimanagement/api-management-logs-to-moesif-using-eventhub-webapp/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.apimanagement/api-management-logs-to-moesif-using-eventhub-webapp/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.apimanagement/api-management-logs-to-moesif-using-eventhub-webapp/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.apimanagement/api-management-logs-to-moesif-using-eventhub-webapp/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.apimanagement/api-management-logs-to-moesif-using-eventhub-webapp/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.apimanagement/api-management-logs-to-moesif-using-eventhub-webapp/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.apimanagement%2Fapi-management-logs-to-moesif-using-eventhub-webapp%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.apimanagement%2Fapi-management-logs-to-moesif-using-eventhub-webapp%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.apimanagement%2Fapi-management-logs-to-moesif-using-eventhub-webapp%2Fazuredeploy.json)    

Log and monitor API traffic from Azure API Management using [Moesif API Analytics](https://www.moesif.com/?language=azure-api-management) in a few minutes without any code changes or restarts. The integration also provides visibility into rejected requests that never reach your underlying service.

## How it works

This solution is deployed using an [Azure Resource Manager Template](https://azure.microsoft.com/en-us/resources/templates/201-api-management-logs-to-moesif-using-eventhub-webapp/). An XML Policy configures an APIM logger to send API logs to an Azure EventHub. An Azure WebJob reads from the EventHub and sends to Moesif for data processing.
[More info on this integration](https://www.moesif.com/implementation/log-http-calls-from-azure-api-management?platform=azure-management).

![Architecture Diagram Logging API Calls from Azure API Management](https://docs.moesif.com/images/docs/integration/azure-api-management-logging-architecture-diagram.png)

## How to install

### 1. Start Azure Resource Deployment

Click the below button to start a Custom deployment with the Moesif Azure Resource Template.

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.apimanagement%2Fapi-management-logs-to-moesif-using-eventhub-webapp%2Fazuredeploy.json)

### 2. Configure Parameters

Within the Azure Template Deployment panel, set the following properties:

![Create a Custom Deployment in Azure](https://docs.moesif.com/images/docs/integration/azure-api-management-create-custom-deployment.png)

* Set _Resource group_ to the same resource group that contains your exiting Azure APIM instance. This ensures the APIM logger, `moesif-log-to-event-hub`, is automatically created for you. 

* Set _Moesif Application Id_ to the one displayed after logging into your Moesif account. You can create a free one on [Moesif's website](https://www.moesif.com/?language=azure-api-management)

* Set _Existing Api Mgmt Name_ to the name of your Azure APIM instance. If blank, you will need to manually create the [APIM logger](https://docs.microsoft.com/en-us/azure/api-management/api-management-log-to-eventhub-sample#policy-declaration). 

Once done, click the _Review+create_ button at the bottom and finish the template creation wizard. 

> Occasionally, Azure reports a failed deployment due to slow propagation of new DNS settings even though everything was deployed successfully. We recommend proceeding with rest of process. If you still have issues after last step, [view troubleshooting](#troubleshooting).

### 3. Add XML Policy

Within the Azure portal, navigate to your existing Azure API Management instance.
Then, add the below XML policies to all products or APIs that you want API logging enabled. 

> It's recommended to add the XML policy globally for all APIs. Then, use Moesif [dynamic sampling](https://www.moesif.com/docs/platform/dynamic-sampling/) if you want to create rules that selectively sample or suppress data collection. Rules are dynamically enabled based on specific customer behaviors, regex rules, and more.

More info on editing APIM policies is available on the [Azure docs](https://docs.microsoft.com/en-us/azure/api-management/set-edit-policies)

```xml
<policies>
    <inbound>
        <set-variable name="message-id" value="@(Guid.NewGuid())" />
        <log-to-eventhub logger-id="moesif-log-to-event-hub" partition-id="0">@{
          var body = context.Request.Body?.As<string>(true);
          var MAX_BODY_SIZE_FOR_EH = 145000;
          var origBodyLen = (null != body) ? body.Length : 0;
          if (MAX_BODY_SIZE_FOR_EH < origBodyLen){
              body = body.Remove(MAX_BODY_SIZE_FOR_EH);
          }
          var headers = context.Request.Headers
                               .Where(h => h.Key != "Ocp-Apim-Subscription-Key")
                               .Select(h => string.Format("{0}: {1}", h.Key, String.Join(", ", h.Value).Replace("\"", "\\\"")))
                               .ToArray<string>();
          var headerString = (headers.Any()) ? string.Join(";;", headers) : string.Empty;
          var messageId = context.Variables["message-id"];
          var jwtToken = context.Request.Headers.GetValueOrDefault("Authorization","").AsJwt();
          var userId = (context.User != null && context.User.Id != null) ? context.User.Id : (jwtToken != null && jwtToken.Subject != null ? jwtToken.Subject : null);
          var companyId = "";
          var cru = new JObject();
          if (context.User != null) {
            cru.Add("Email", context.User.Email);
            cru.Add("Id", context.User.Id);
            cru.Add("FirstName", context.User.FirstName);
            cru.Add("LastName", context.User.LastName);
          }
          var crus = System.Convert.ToBase64String(Encoding.UTF8.GetBytes(cru.ToString()));
          var requestBody = (body != null ? System.Convert.ToBase64String(Encoding.UTF8.GetBytes(body)) : null);
          string metadata = $@"";
          var request = $@"
                    ""event_type"": ""request"",
                    ""message-id"": ""{messageId}"",
                    ""method"": ""{context.Request.Method}"",
                    ""ip_address"": ""{context.Request.IpAddress}"",
                    ""uri"": ""{context.Request.OriginalUrl}"",
                    ""user_id"": ""{userId}"",
                    ""contextRequestUser"": ""{crus}"",
                    ""company_id"": ""{companyId}"",
                    ""request_headers"": ""{headerString}"",
                    ""request_body"": ""{requestBody}"",
                    ""metadata"": ""{metadata}""
                ";
            return "{" + request + "}";
      }</log-to-eventhub>
    </inbound>
    <backend>
        <forward-request follow-redirects="true" />
    </backend>
    <outbound>
        <log-to-eventhub logger-id="moesif-log-to-event-hub" partition-id="1">@{
          var body = context.Response.Body?.As<string>(true);
          var MAX_BODY_SIZE_FOR_EH = 145000;
          var origBodyLen = (null != body) ? body.Length : 0;
          if (MAX_BODY_SIZE_FOR_EH < origBodyLen){
              body = body.Remove(MAX_BODY_SIZE_FOR_EH);
          }
          var headers = context.Response.Headers
                                          .Select(h => string.Format("{0}: {1}", h.Key, String.Join(", ", h.Value).Replace("\"", "\\\"")))
                                          .ToArray<string>();
          var headerString = (headers.Any()) ? string.Join(";;", headers): string.Empty;
          var messageId = context.Variables["message-id"];
          var responseBody = (body != null ? System.Convert.ToBase64String(Encoding.UTF8.GetBytes(body)) : null);
          var response = $@"
                    ""event_type"": ""response"",
                    ""orig_body_len"": ""{origBodyLen}"",
                    ""message-id"": ""{messageId}"",
                    ""status_code"": ""{context.Response.StatusCode}"",
                    ""response_headers"": ""{headerString}"",
                    ""response_body"": ""{responseBody}""
                    ";
          return "{" + response + "}";
     }</log-to-eventhub>
    </outbound>
    <on-error>
        <base />
    </on-error>
</policies>
```

That's it. Once the XML is added to your APIs, the logs should start showing up in Moesif. 

## Configuration Options

The below fields in the XML policy can be modified by you to meet your requirements. XML Policies support a number of [context variables](https://docs.microsoft.com/en-us/azure/api-management/api-management-policy-expressions#ContextVariables) which you can also leverage.

### User Id
_String_, The field `user_id` identifies who the user is making the API and enables Moesif to associate API calls to user profiles. The default XML policy extracts the user id from the `context.User.Id` or the Subject of the JWT Token. If you are a B2B company, this can be used simultaneously with company id to track API Usage both at the individual user-level and also account-level. See [identifying customers in Moesif](https://www.moesif.com/docs/getting-started/identify-customers/) for more info.

### User Metadata
_String_, The field `contextRequestUser` allows you to store additional user metadata as part of the [user's profile in Moesif](https://www.moesif.com/docs/getting-started/users/). By default, the XML policy also saves Email, FirstName, and LastName from Azure's `context.User` object. Any fields can be stored. Keep in mind `contextRequestUser` is expecting a base64 encoded string.

### Company Id
_String_, The field `company_id` identifies which company is making the API and enables Moesif to associate API calls to company profiles. The default XML policy does not set this field. See [identifying customers in Moesif](https://www.moesif.com/docs/getting-started/identify-customers/) for more info.

### Event Metadata
_String_, A JSON string that allows you to add custom metadata that will be associated with the API call. For example, you may want to store the `context.Api.Name` or `context.Api.Version` with the API calls by reading from the [context variables](https://docs.microsoft.com/en-us/azure/api-management/api-management-policy-expressions#ContextVariables). The `metadata` field must be a JSON encoded string. 

## Manual deployment

The individual components can be deployed directly if needed. 

### WebJob

The WebJob is deployed as part of the overall deployment.
To re-deploy the WebJob:
1. Download the [run.bat](https://raw.githubusercontent.com/Moesif/ApimEventProcessor/v1/azure-app-service-webjobs/run.bat) script to your computer.
2. Within the Azure Portal, go to your WebApp and select the WebJobs panel. 
 -- If there is an existing WebJob, stop it and remove it.
3. Click the _+Add_ button to create a new job. Give it a name, set type to _continuous_ and upload the `run.bat` you previously downloaded. 

Once created, the script will clone the [ApimEventProcessor repo 'v1' branch](https://github.com/Moesif/Apimeventprocessor/tree/v1), run `dotnet build`, and starts the worker.

### APIM Logger

If the name of an existing Azure API Management is not specified during deployment, you will need to add the `log-to-eventhub` logger to your Azure API Management service manually. To do so, utilize the [`nested/microsoft.apimanagement/service/loggers.json` ARM template](nested/microsoft.apimanagement/service/loggers.json) or view [Microsoft docs](https://docs.microsoft.com/en-us/azure/api-management/api-management-howto-log-event-hubs)

More info on configuring Moesif is available on [Microsoft's documentation](https://docs.microsoft.com/en-us/azure/api-management/api-management-log-to-eventhub-sample).

## Steps performed by the Azure Resource Template
This template performs the following tasks

- Create Azure Eventhub and policies for Send and Listen.
- If the name of an existing Azure API Management instance is provided, the template creates a new [log-to-eventhub](https://docs.microsoft.com/en-us/azure/api-management/api-management-howto-log-event-hubs) with the name `moesif-log-to-event-hub`.
- Create an Azure Storage Account to periodically checkpoint the EventHub read location.
- Create an Azure WebApp and configures the environment variables required by [ApimEventProcessor](https://github.com/Moesif/Apimeventprocessor/tree/v1).
- Deploys [ApimEventProcessor](https://github.com/Moesif/Apimeventprocessor/tree/v1) as a Webjob on the WebApp.

## Troubleshooting

- It is possible that the final step of deployment `app-service-webjob-msdeploy` reports a failed deployment with error such as `conflict` or `BadRequest` or `GatewayTimeout`. Despite these initial errors reported by deployment, it is possible that the WebJob deployment within Azure App Service may succeed automatically after 5-10 minutes without further user action. At the end of this template deployment, you may view detailed logs in your App Service/Activity log.
- Ensure the `log-to-eventhub` logger is created
- Ensure the `policy` is set on Api Management Apis
- Ensure App Service configuration contains correct environment variables. View your App Service/Settings/Configuration/Application settings
- Review the logs of App Service Webjob named `azure-api-mgmt-logs-2-moesif` and ensure it is running. View your App Service/Settings/WebJobs 

## Updating the integration

If you need to update [Moesif/ApimEventProcessor](https://github.com/Moesif/Apimeventprocessor/tree/v1) and don't want to redeploy the entire template, you can follow these steps:

Before starting, make sure you fork the repo [ApimEventProcessor](https://github.com/Moesif/Apimeventprocessor/tree/v1), so it's in your GitHub account. 

1. Log into your Azure Portal and navigate to the resource group holding your Moesif resources. 

2. Select the WebApp and then click the Deployment Center panel on the left side. 
   
3. This will open the deployment panel as shown below, you'll want to click on GitHub.

![Redeploy Webjob GitHub](https://docs.moesif.com/images/docs/integration/azure-api-management-redeploy-github.png)
   
4. Click on _App Service build service_ (via Kudu) deployment

![Redeploy Webjob Kudu](https://docs.moesif.com/images/docs/integration/azure-api-management-redeploy-kudu.png)

5.  Select the repo you forked earlier and finish the walkthrough. 

Deployment may take a few minutes. Double check your XML policy if there are any changes.

`Tags: Azure API Management, API Management, EventHub, Event Hub, API Gateway, Monitoring, Analytics, Observability, Logs, Logging, API Monitoring, API Analytics, API Logs, API Logging, Moesif, Kong, Tyk, Envoy, WebApp, WebJob, App`
