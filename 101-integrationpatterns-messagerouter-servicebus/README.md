# Integration Patterns - Message Router - Service Bus

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-integrationpatterns-messagerouter-servicebus%2Fazuredeploy.json" target="_blank">
<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-integrationpatterns-messagerouter-servicebus%2Fazuredeploy.json" target="_blank">
<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.png"/>
</a>

## Solution overview and deployed resources

This template deploys a solution which shows how we can set up the <a href="http://www.enterpriseintegrationpatterns.com/patterns/messaging/MessageRouter.html" target="_blank">Message Router pattern</a> using a Service Bus Topic. The topic expects a message with a property called *Priority*. The message is then routed to the *Log* subscription as well as the subscription belonging with the given priority.

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