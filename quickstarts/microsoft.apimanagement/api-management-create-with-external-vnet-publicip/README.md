# Azure API Management Service

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.apimanagement/api-management-create-with-external-vnet-publicip/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.apimanagement/api-management-create-with-external-vnet-publicip/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.apimanagement/api-management-create-with-external-vnet-publicip/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.apimanagement/api-management-create-with-external-vnet-publicip/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.apimanagement/api-management-create-with-external-vnet-publicip/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.apimanagement/api-management-create-with-external-vnet-publicip/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.apimanagement%2Fapi-management-create-with-external-vnet-publicip%2Fazuredeploy.json)

[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.apimanagement%2Fapi-management-create-with-external-vnet-publicip%2Fazuredeploy.json)

This template shows an example of how to deploy an Azure API Management service within your own virtual network's subnet in External Mode. 
The instance is deployed into 2 Zones and the Public IP of the instance comes from the Customers subscription.
This way clients from Internet can connect to the ApiManagement service proxy gateway. Being within the Virtual Network, the proxy gateway can connect to your Backend accessible only within your Virtual private network. 

- The template also deploys a NSG, which is based on the documentation here https://aka.ms/apim-vnet-common-issues
- The template deploys a Virtual Network and a dedicated subnet, which will be used to host the API Management service.
- The template disables all unsecure Ciphers and SSL/TLS protocols.
- The template gets a Standard SKU Public IP from Customers subscription.
- The template creates a Premium SKU Api Management to leverage Availability Zones. Customer is choose to deploy API Management in Developer SKU, but then Availability Zones will not be supported.
