---
description: This template demonstrates how to create an instance of Azure API Management in the Premium tier within your virtual network's subnet in internal mode and configure recommended NSG rules on the subnet. The instance is deployed to two availability zones. The template also configures a public IP address from your subscription.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: api-management-create-with-internal-vnet-publicip
languages:
- bicep
- json
---
# Deploy API Management in internal VNet with public IP

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.apimanagement/api-management-create-with-internal-vnet-publicip/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.apimanagement/api-management-create-with-internal-vnet-publicip/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.apimanagement/api-management-create-with-internal-vnet-publicip/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.apimanagement/api-management-create-with-internal-vnet-publicip/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.apimanagement/api-management-create-with-internal-vnet-publicip/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.apimanagement/api-management-create-with-internal-vnet-publicip/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.apimanagement/api-management-create-with-internal-vnet-publicip/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.apimanagement%2Fapi-management-create-with-internal-vnet-publicip%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.apimanagement%2Fapi-management-create-with-internal-vnet-publicip%2Fazuredeploy.json)

This template shows an example of how to deploy an Azure API Management service within your own virtual network's subnet in [internal mode](https://docs.microsoft.com/azure/api-management/api-management-using-with-internal-vnet).
In internal mode, The subnet is locked down with no client access from the internet. The gateway, developer portal, legacy developer portal, and Git endpoints are only accessible from within the virtual network. Being within the virtual network, the gateway can connect to your backends that are accessible only within your virtual network.
- The template creates a Premium tier API Management instance that is deployed to two [availability zones](https://docs.microsoft.com/azure/api-management/zone-redundancy). You may choose to deploy the API Management instance in the Developer tier; however, availability zones are not supported in that tier.
- The template deploys a virtual network and a dedicated subnet that hosts the API Management service.
- The template obtains a Standard SKU public IP address from the customer's subscription.
- The template also deploys a network security group on the API Management subnet, which is based on [recommended configurations](https://aka.ms/apim-vnet-common-issues).
- The template disables all unsecure ciphers and SSL/TLS protocols.

`Tags: Microsoft.Network/networkSecurityGroups, Microsoft.Network/publicIPAddresses, Microsoft.Network/virtualNetworks, Microsoft.ApiManagement/service`
