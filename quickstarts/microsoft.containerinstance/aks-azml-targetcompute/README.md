---
description: This template allows you to deploy an entreprise compliant AKS cluster which can be attached to Azure ML
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: aks-azml-targetcompute
languages:
- json
---
# Deploy an AKS cluster for Azure ML
![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.containerinstance/aks-azml-targetcompute/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.containerinstance/aks-azml-targetcompute/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.containerinstance/aks-azml-targetcompute/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.containerinstance/aks-azml-targetcompute/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.containerinstance/aks-azml-targetcompute/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.containerinstance/aks-azml-targetcompute/CredScanResult.svg)

## Description
The template allows us to deploy an AKS cluster that can be easily integrated with entreprise-grade devops process and fulfill the condition to be attached with Azure ML as compute target resources. AKS cluster in this template is MSI ( Managed Service Identity ) enabled and also has at least one system pool ( latest definition at Azure documentation )

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.containerinstance%2Faks-azml-targetcompute%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.containerinstance%2Faks-azml-targetcompute%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.containerinstance%2Faks-azml-targetcompute%2Fazuredeploy.json)

`Tags: aks, azureml, msi, devops, Microsoft.ContainerService/managedClusters, SystemAssigned, VirtualMachineScaleSets, Microsoft.ContainerService/managedClusters/agentPools`
