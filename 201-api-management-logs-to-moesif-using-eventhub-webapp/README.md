Analyze access logs from Azure API Management using [Moesif API Analytics](https://www.moesif.com/?language=azure-api-management) without any code changes or redeploy. The integration also provides visibility into rejected requests that never reach your underlying service.

The integration works by logging API calls to an Azure EventHub. An Azure WebJob reads the event hub and sends to Moesif
[More info on this integration](https://www.moesif.com/implementation/log-http-calls-from-azure-api-management?platform=azure-management).

## How to install

### 1. Start Azure Resource Deployment

Click the below button to start a Custom deployment with the Moesif Azure Resource Template.

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FMoesif%2Fazure-quickstart-templates%2Fmaster%2F201-api-management-logs-to-moesif-using-eventhub-webapp%2Fazuredeploy.json)

### 2. Configure Parameters

Within the Azure Custom Deployment, set the following properties:

![Create a Custom Deployment in Azure](https://www.moesif.com/docs/images/docs/integration/azure-api-management-create-custom-deployment.png)

* Set Moesif Application Id to the one displayed after logging into your Moesif account. You can create a free one on [Moesif's website](https://www.moesif.com/?language=azure-api-management)
* Set _Existing Apim Resource Group_ to the resource group containing your Azure APIM.
* Set _Existing Apim Name_ to the name of your Azure APIM instance.

Then, click _Review+create_ and create the template to start deployment. 

### 3. Add XML Policy

Within the Azure portal, go to your existing Azure API Management instance.
Add the below XML policy to all products or APIs that you want logged to Moesif. 

More info on editing policies available on the [Azure docs](https://docs.microsoft.com/en-us/azure/api-management/set-edit-policies)

```xml
<policies>
  <inbound>
      <set-variable name="message-id" value="@(Guid.NewGuid())" />
      <log-to-eventhub logger-id="moesif-log-to-event-hub" partition-id="0">
      @{
          var requestLine = string.Format("{0} {1} HTTP/1.1\r\n",
                                                      context.Request.Method,
                                                      context.Request.Url.Path + context.Request.Url.QueryString);

          var body = context.Request.Body?.As<string>(true);
          if (body != null && body.Length > 1024)
          {
              body = body.Substring(0, 1024);
          }

          var headers = context.Request.Headers
                               .Where(h => h.Key != "Authorization" && h.Key != "Ocp-Apim-Subscription-Key")
                               .Select(h => string.Format("{0}: {1}", h.Key, String.Join(", ", h.Value)))
                               .ToArray<string>();

          var headerString = (headers.Any()) ? string.Join("\r\n", headers) + "\r\n" : string.Empty;

          return "request:"   + context.Variables["message-id"] + "\n"
                              + requestLine + headerString + "\r\n" + body;
      }
  </log-to-eventhub>
  </inbound>
  <backend>
      <forward-request follow-redirects="true" />
  </backend>
  <outbound>
      <log-to-eventhub logger-id="moesif-log-to-event-hub" partition-id="1">
      @{
          var statusLine = string.Format("HTTP/1.1 {0} {1}\r\n",
                                              context.Response.StatusCode,
                                              context.Response.StatusReason);

          var body = context.Response.Body?.As<string>(true);
          if (body != null && body.Length > 1024)
          {
              body = body.Substring(0, 1024);
          }

          var headers = context.Response.Headers
                                          .Select(h => string.Format("{0}: {1}", h.Key, String.Join(", ", h.Value)))
                                          .ToArray<string>();

          var headerString = (headers.Any()) ? string.Join("\r\n", headers) + "\r\n" : string.Empty;

          return "response:"  + context.Variables["message-id"] + "\n"
                              + statusLine + headerString + "\r\n" + body;
     }
  </log-to-eventhub>
  </outbound>
</policies>
```

That's it! API logs should start showing up after a few minutes.

## Manual creation

If you want to create the resources directly, follow [Microsoft's documentation](https://docs.microsoft.com/en-us/azure/api-management/api-management-log-to-eventhub-sample) on configuring Moesif. The example WebJob is available [on GitHub](https://github.com/Moesif/ApimEventProcessor).

