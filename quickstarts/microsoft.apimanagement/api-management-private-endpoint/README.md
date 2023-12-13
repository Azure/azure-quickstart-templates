---
description: This template will create an API Management service, a virtual network and a private endpoint exposing the API Management service to the virtual network.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: api-management-private-endpoint
languages:
- bicep
- json
---
# Create an API Management service with a private endpoint

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.apimanagement/api-management-private-endpoint/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.apimanagement/api-management-private-endpoint/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.apimanagement/api-management-private-endpoint/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.apimanagement/api-management-private-endpoint/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.apimanagement/api-management-private-endpoint/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.apimanagement/api-management-private-endpoint/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.apimanagement/api-management-private-endpoint/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.apimanagement%2Fapi-management-private-endpoint%2Fazuredeploy.json)

[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.apimanagement%2Fapi-management-private-endpoint%2Fazuredeploy.json)

This template will create a virtual network, an API Management service and a private endpoint exposing the Api Management service to the virtual network.

Below are the parameters which can be user configured in the parameters file including:

- **Location:** Select where the resource should be created (default is target resource group's location).
- **Virtual Network Name:** Enter a name for the virtual network.
- **Public Network Access:** Select whether public traffic is allowed to access the account (default is Enabled). When value is set to Disabled, public network traffic is blocked even before the private endpoint is created.
- **ApiManagementServiceName:** Enter a name for the api management service
- **PublisherName:** Enter of the publisher who is the owner of the api management service
- **PublisherEmail:** Email of the publisher to notify api management service setup
- **Private Endpoint Name:** Enter a name for the private endpoint.

`Tags: Azure API Management, API Management, Private Endpoint, Microsoft.Network/virtualNetworks, Microsoft.ApiManagement/service, SystemAssigned, Microsoft.Network/privateEndpoints, Microsoft.Network/privateDnsZones, Microsoft.Network/privateDnsZones/virtualNetworkLinks, Microsoft.Network/privateEndpoints/privateDnsZoneGroups`
