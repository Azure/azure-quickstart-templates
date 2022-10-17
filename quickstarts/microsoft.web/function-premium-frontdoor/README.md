---
description: This template allows you to deploy an azure premium function protected and published by Azure Frontdoor premium. The conenction between Azure Frontdoor and Azure Functions is protected by Azure Private Link.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: function-premium-frontdoor
languages:
- json
- bicep
---
# Function App secured by Azure Frontdoor

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/function-premium-frontdoor/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/function-premium-frontdoor/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/function-premium-frontdoor/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/function-premium-frontdoor/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/function-premium-frontdoor/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/function-premium-frontdoor/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/function-premium-frontdoor/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.web%2Ffunction-premium-frontdoor%2Fazuredeploy.json)

[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.web%2Ffunction-premium-frontdoor%2Fazuredeploy.json)   

 




### Azure Function App

The Function App is restricted to disallow public network access

### Elastic Premium Plan

The Azure Function app provisioned in this sample uses an [Azure Functions Elastic Premium plan](https://docs.microsoft.com/azure/azure-functions/functions-premium-plan#features). The Premium Plan is required to use networking features

### Azure Frontdoor Premium

Azure (Frontdoor)[https://learn.microsoft.com/en-us/azure/frontdoor/front-door-overview] Premium is used to connect securly through Azure Private Link Service to Azure Function. A managed web application firewall policy is provisioned to protected against certain attacks.

### Virtual Network

An Azure Virtual Network is provisioned to isolate network traffic to the storage account and potentially other data services (e.g. SQL Server)

Two Subnets are created:

- Subnet for Azure Function virtual network integration. This subnet is delegated to the Function App.
- Subnet for private endpoints of the data services (in this case just storage). Private IP addresses are allocated from this subnet.

### Private Endpoints

[Azure Private Endpoints](https://docs.microsoft.com/azure/private-link/private-endpoint-overview) are used to connect to specific Azure resources using a private IP address. This ensures that network traffic remains within the designated virtual network, and access is available only for specific resources.  This sample configures private endpoints for the following Azure resources:

- [Azure Storage](https://docs.microsoft.com/azure/storage/common/storage-private-endpoints)
  - Azure File storage
  - Azure Blob storage

### Private DNS Zones

Using a private endpoint to connect to Azure resources means connecting to a private IP address instead of the public endpoint.  Existing Azure services are configured to use existing DNS to connect to the public endpoint.  The DNS configuration will need to be overridden to connect to the private endpoint.

A private DNS zone will be created for each Azure resource configured with a private endpoint.  A DNS A record is created for each private IP address associated with the private endpoint.

The following DNS zones are created in this sample:

- privatelink.queue.core.windows.net
- privatelink.blob.core.windows.net
- privatelink.table.core.windows.net
- privatelink.file.core.windows.net

### Application Insights

[Application Insights](https://docs.microsoft.com/azure/azure-monitor/app/app-insights-overview) is used to [monitor the Azure Function](https://docs.microsoft.com/azure/azure-functions/functions-monitoring).

## Post deployment steps

The Azure Frontdoor Private Link request needs to be approved inside the networking settings of Azure Function 
![Azure Function Networking Section](/images/function-network-settings.png)

Inside the Networking tab select Azure Private Endpoints and approve the request
![Azure Functions Networking - approve private endpoint request](/images/function-private-endpoint-approval.png)

You could also approve the private link using the [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/network/private-endpoint-connection?view=azure-cli-latest#az-network-private-endpoint-connection-approve)

`Tags: FunctionApp, Microsoft.Web/serverfarms, Microsoft.Network/virtualNetworks, Microsoft.Web/sites, Microsoft.Storage/storageAccounts`