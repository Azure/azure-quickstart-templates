# Extend an existing Azure VNET to a Multi-VNET Configuration

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/extend-vnet-to-multi-vnet/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/extend-vnet-to-multi-vnet/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/extend-vnet-to-multi-vnet/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/extend-vnet-to-multi-vnet/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/extend-vnet-to-multi-vnet/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/extend-vnet-to-multi-vnet/CredScanResult.svg)

This template allows you to extend an existing single VNET environment to a Multi-VNET environment that extends across two datacenter regions using VNET-to-VNET gateways

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.network%2Fextend-vnet-to-multi-vnet%2Fazuredeploy.json)  
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.network%2Fextend-vnet-to-multi-vnet%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.network%2Fextend-vnet-to-multi-vnet%2Fazuredeploy.json)

This template extends an existing single VNET environment to a Multi-VNET environment by deploying these Azure resources:

+ Second VNET in a different Azure datacenter region
+ VNET gateways on existing and second VNET
+ VNET gateway connections to establish a routable VNET-to-VNET connection between existing and second VNET

## Special Notes

To be successful in extending to a Multi-VNET configuration using this template, pay particular attention to these special items:

+ Use the resource group of the existing VNET for this template deployment
+ Prior to running this template deployment, create a subnet named "GatewaySubnet" on the existing VNET with a minimum /29 address prefix

## Template Parameters

Modify parameters file to change default values.


