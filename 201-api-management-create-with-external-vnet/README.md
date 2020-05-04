# Azure API Management Service

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/201-api-management-create-with-external-vnet/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/201-api-management-create-with-external-vnet/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/201-api-management-create-with-external-vnet/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/201-api-management-create-with-external-vnet/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/201-api-management-create-with-external-vnet/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/201-api-management-create-with-external-vnet/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fazure%2Fazure-quickstart-templates%2Fmaster%2F201-api-management-create-with-external-vnet%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-api-management-create-with-external-vnet%2Fazuredeploy.json)

This template shows an example of how to deploy an Azure API Management service within your own virtual network's subnet in External Mode. This way clients from Internet can connect to the ApiManagement service proxy gateway. Being within the Virtual Network, the proxy gateway can connect to your Backend visible only within your Virtual private network. The template also deploys a NSG, which is based on the documentation here https://docs.microsoft.com/en-us/azure/api-management/api-management-using-with-vnet#a-namenetwork-configuration-issues-acommon-network-configuration-issues


