# Integration Patterns - Message Router - Logic App

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-integrationpatterns-messagerouter-logicapp%2Fazuredeploy.json" target="_blank">
<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-integrationpatterns-messagerouter-logicapp%2Fazuredeploy.json" target="_blank">
<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.png"/>
</a>

## Solution overview and deployed resources

This template deploys a solution which shows how we can set up the <a href="http://www.enterpriseintegrationpatterns.com/patterns/messaging/MessageRouter.html" target="_blank">Message Router pattern</a> using a Logic App. The Logic App receives a message through a web endpoint, and sends the message to a GitHub Gists endpoint with a filename based on the contents of the message. In the response the URL of the Gist file is returned.

The following resources are deployed as part of the solution.

+ **Logic App**

To test the Logic App, grab the endpoint of the Request shape in the Logic App, and use a tool like PostMan to POST a message to the endpoint. The message to be sent in should be in the following format.

```json
{
	"Address":"Wilhelminakade 175",
	"City":"Rotterdam",
	"Name":"Eldert Grootenboer"
}
```

`Tags: Logic Apps, Integration Patterns, Logic App, Message Router, LogicApps, IntegrationPatterns`