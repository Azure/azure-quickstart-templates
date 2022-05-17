# Create an Azure Web PubSub instance using Bicep

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/azure-web-pubsub/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/azure-web-pubsub/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/azure-web-pubsub/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/azure-web-pubsub/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/azure-web-pubsub/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/azure-web-pubsub/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/azure-web-pubsub/BicepVersion.svg)


[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts/microsoft.web/azure-web-pubsub%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts/microsoft.web/azure-web-pubsub%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts/microsoft.web/azure-web-pubsub%2Fazuredeploy.json)

This template deploys a simple instance of Azure Web PubSub service in a new or existing resource group.

## Prerequisites

If you don't have an [Azure subscription](/azure/guides/developer/azure-developer-guide#understanding-accounts-subscriptions-and-billing), create an [Azure free account](https://azure.microsoft.com/free/?ref=microsoft.com&utm_source=microsoft.com&utm_medium=docs&utm_campaign=visualstudio) before you begin.


## Resources created in this template

- `Microsoft.Resources/resourceGroups@2021-04-10`
  - Can use an existing resource group or create a new group
- `Microsoft.SignalRService/webPubSub@2021-10-01`
  - Defaults: Free tier, 1 unit
  - Live trace: disabled
  - Connectivity and messaging logs: enabled
  - TLS clientCertEnabled: disabled

## Parameters


|Parameter name  |Description  |
|---------|---------|
|wpsName     |      The name of the new Web PubSub instance. Required.   |
|wpsLocation     |   The region where the new Web PubSub instance will be created. Required.     |
|wpsUnitCount     |    The number of units to allocate. Optional, defaults to one (1) unit. Allowed values: 1,2,5,10,20,50,100. Free tier allows only one unit.    |
|wpsSkuName     |   Optional, defaults to "Free_F1". Allowed values: Standard_S1, Free_F1.     |
|wpsPricingTier    |  Optional, defaults to "Free". Allowed values: Free, Standard.     |
|groupName    | Resource group name for deployment. Required. If groupName matches an existing resource group, the template will attempt to deploy to it. If groupName doesn't exist, the template will attempt to create it in the region specified by wpsLocation. |


## Output

- what is the output? client url, hostname, &c

## Resources and next steps

**TODO** - PUT A BUNCH OF SOOPER-HELPFUL LINKS HERE 
- web pubsub **TODO add a backlog task** to link the target pubsub articles back to this template
    - quickstarts
    - tutorials
- about templates
- about bicep
- 


`Tags: Web PubSub, Bicep, real-time messaging, publish-subscribe`