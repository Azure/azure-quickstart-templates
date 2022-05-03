# Integration Patterns - Message Router - Logic App

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/demos/integrationpatterns-messagerouter-logicapp/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/demos/integrationpatterns-messagerouter-logicapp/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/demos/integrationpatterns-messagerouter-logicapp/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/demos/integrationpatterns-messagerouter-logicapp/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/demos/integrationpatterns-messagerouter-logicapp/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/demos/integrationpatterns-messagerouter-logicapp/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fintegrationpatterns-messagerouter-logicapp%2Fazuredeploy.json)  
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)]( https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fintegrationpatterns-messagerouter-logicapp%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fintegrationpatterns-messagerouter-logicapp%2Fazuredeploy.json)



## Solution overview and deployed resources

This template deploys a solution which shows how we can set up the <a href="http://www.enterpriseintegrationpatterns.com/patterns/messaging/MessageRouter.html" target="_blank">Message Router pattern using a Logic App. The Logic App receives a message through a web endpoint, and sends the message to a GitHub Gists endpoint with a filename based on the contents of the message. In the response the URL of the Gist file is returned.

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


