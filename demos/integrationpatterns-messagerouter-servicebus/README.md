# Integration Patterns - Message Router - Service Bus

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/demos/integrationpatterns-messagerouter-servicebus/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/demos/integrationpatterns-messagerouter-servicebus/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/demos/integrationpatterns-messagerouter-servicebus/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/demos/integrationpatterns-messagerouter-servicebus/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/demos/integrationpatterns-messagerouter-servicebus/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/demos/integrationpatterns-messagerouter-servicebus/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fintegrationpatterns-messagerouter-servicebus%2Fazuredeploy.json)  
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fintegrationpatterns-messagerouter-servicebus%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fintegrationpatterns-messagerouter-servicebus%2Fazuredeploy.json)



## Solution overview and deployed resources

This template deploys a solution which shows how we can set up the <a href="http://www.enterpriseintegrationpatterns.com/patterns/messaging/MessageRouter.html" target="_blank">Message Router pattern using a Service Bus Topic. The topic expects a message with a property called *Priority*. The message is then routed to the *Log* subscription as well as the subscription belonging with the given priority.

The following resources are deployed as part of the solution.

+ **Service Bus Namespace**
+ **Service Bus Topic**
+ **Service Bus Topic Subscriptions**
+ **Service Bus Topic Subscriptions Rules**

To test, grab the connection string of the Service Bus namespace, and use a tool like Service Bus Explorer to send a message to the topic. The message to be sent in should be in the following format, and with a property called *Priority*, with value *High*, *Normal* or *Low*.

```json
{
	"Address":"Wilhelminakade 175",
	"City":"Rotterdam",
	"Name":"Eldert Grootenboer"
}
```

`Tags: Service Bus, Integration Patterns, Service Bus Topics, Message Router, ServiceBus, IntegrationPatterns`


