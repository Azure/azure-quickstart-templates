# Deploy Azure Bastion in an Azure Virtual Network

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/101-azure-bastion-nsg/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/101-azure-bastion-nsg/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/101-azure-bastion-nsg/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/101-azure-bastion-nsg/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/101-azure-bastion-nsg/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/101-azure-bastion-nsg/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-azure-bastion-nsg%2Fazuredeploy.json)  [![Deploy To AzureGov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-azure-bastion-nsg%2Fazuredeploy.json)  [![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-azure-bastion-nsg%2Fazuredeploy.json)



This template will deploy Azure Bastion in a new or existing Azure Virtual Network, along with dependent resources such as the AzureBastionSubnet, Public Ip Address for Azure Bastion, and Network Security Group rules.

This template deploys resources in the same Resource Group and Azure region as the Virtual Network.

Note that Azure Bastion is currently in Public Preview status.  As a result, please reference the <a href="https://docs.microsoft.com/en-us/azure/bastion/bastion-overview" target="_blank">Azure Bastion documentation to confirm that you are deploying to an enabled Azure region and that you have onboarded to participating in the Public Preview.

```
Tags: ``bastion``


