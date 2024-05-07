---
description: This template demonstrates how to create an API Management instance with additional locations. The primary location is the same as location of the resource group. For additional locations, the template shows NorthCentralUs and East US2. The primary location should be different from additional locations.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: api-management-create-with-multiregion
languages:
- bicep
- json
---
# Create a multiregion Premium tier API Management instance

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.apimanagement/api-management-create-with-multiregion/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.apimanagement/api-management-create-with-multiregion/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.apimanagement/api-management-create-with-multiregion/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.apimanagement/api-management-create-with-multiregion/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.apimanagement/api-management-create-with-multiregion/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.apimanagement/api-management-create-with-multiregion/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.apimanagement/api-management-create-with-multiregion/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.apimanagement%2Fapi-management-create-with-multiregion%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.apimanagement%2Fapi-management-create-with-multiregion%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.apimanagement%2Fapi-management-create-with-multiregion%2Fazuredeploy.json)

This template demonstrates how to create a Premium tier API Management instance with additional locations.

Make sure that the location of the resource group is not same as one of the additional Locations.
- The template deploys 3 units of the Premium tier. Consider the cost before deploying the template.
- The template disables all unsecure SSL/TLS protocols and ciphers.
- The template also restricts control plane calls to not expose secrets to users with read-only permission on the API Management instances.
- The template exposes a property `disableGateway` on the API Management instance which can be used to remove a region out of gateway rotation.

If you're new to Azure API Management, see:

- [Azure API Management service](https://azure.microsoft.com/services/api-management/)
- [Azure API Management documentation](https://docs.microsoft.com/azure/api-management/)
- [Azure API Management deployment in multiple regios](https://docs.microsoft.com/azure/api-management/api-management-howto-deploy-multi-region)
- [Azure API Management Configure protocols and ciphers](https://docs.microsoft.com/azure/api-management/api-management-howto-manage-protocols-ciphers)
- [Quickstart templates](https://azure.microsoft.com/resources/templates/?resourceType=Microsoft.Apimanagement)

`Tags: API, API Management, Azure API Management, Microsoft.ApiManagement/service`
