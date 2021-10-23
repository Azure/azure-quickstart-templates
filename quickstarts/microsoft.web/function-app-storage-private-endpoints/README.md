# Function App with Azure Storage private endpoints

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/function-app-storage-private-endpoints/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/function-app-storage-private-endpoints/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/function-app-storage-private-endpoints/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/function-app-storage-private-endpoints/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/function-app-storage-private-endpoints/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/function-app-storage-private-endpoints/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/function-app-storage-private-endpoints/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.web%2Ffunction-app-storage-private-endpoints%2Fazuredeploy.json)  [![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.web%2Ffunction-app-storage-private-endpoints%2Fazuredeploy.json)

This sample Azure Resource Manager template deploys an Azure Function App that communicates with the Azure Storage account referenced by the [AzureWebJobsStorage](https://docs.microsoft.com/azure/azure-functions/functions-app-settings#azurewebjobsstorage) and [WEBSITE_CONTENTAZUREFILECONNECTIONSTRING](https://docs.microsoft.com/azure/azure-functions/functions-app-settings#website_contentazurefileconnectionstring) app settings, [via private endpoints](https://docs.microsoft.com/en-us/azure/azure-functions/functions-networking-options#private-endpoints). 

![Function App with Storage Private Endpoints](/quickstarts/microsoft.web/function-app-storage-private-endpoints/images/function-app-storage-private-endpoints.jpg) 

### Azure Function App

The Function App uses the AzureWebJobsStorage and WEBSITE_CONTENTAZUREFILECONNECTIONSTRING app settings to connect to a private endpoint-secured Storage Account.

### Elastic Premium Plan

The Azure Function app provisioned in this sample uses an [Azure Functions Elastic Premium plan](https://docs.microsoft.com/azure/azure-functions/functions-premium-plan#features). 

### Azure Storage account

The Storage account that the Function uses for operation and for file contents. 


### Virtual Network

Azure resources in this sample either integrate with or are placed within a virtual network. The use of private endpoints keeps network traffic contained with the virtual network.

The sample uses two subnets:

- Subnet for Azure Function virtual network integration.  This subnet is delegated to the Function App.
- Subnet for private endpoints.  Private IP addresses are allocated from this subnet.

### Private Endpoints

[Azure Private Endpoints](https://docs.microsoft.com/azure/private-link/private-endpoint-overview) are used to connect to specific Azure resources using a private IP address  This ensures that network traffic remains within the designated virtual network, and access is available only for specific resources.  This sample configures private endpoints for the following Azure resources:

- [Azure Storage](https://docs.microsoft.com/azure/storage/common/storage-private-endpoints)
  - Azure File storage
  - Azure Blob storage
  - Azure Queue storage
  - Azure Table storage
  
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
