---
description: This template enables you to deploy an Azure Relay namespace with standard SKU, a WcfRealy entity and authorization rules for both the namespace and WcfRealy.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: azure-relay-create-authrule-namespace-and-wcfrelay
languages:
- json
---
# Create an Azure Relay namespace with SAS Policies and WCF

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.relay/azure-relay-create-authrule-namespace-and-wcfrelay/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.relay/azure-relay-create-authrule-namespace-and-wcfrelay/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.relay/azure-relay-create-authrule-namespace-and-wcfrelay/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.relay/azure-relay-create-authrule-namespace-and-wcfrelay/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.relay/azure-relay-create-authrule-namespace-and-wcfrelay/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.relay/azure-relay-create-authrule-namespace-and-wcfrelay/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.relay%2Fazure-relay-create-authrule-namespace-and-wcfrelay%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.relay%2Fazure-relay-create-authrule-namespace-and-wcfrelay%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.relay%2Fazure-relay-create-authrule-namespace-and-wcfrelay%2Fazuredeploy.json)

This template creates an Azure Relay namespace, a WcfRealy and authorization rules for both the namespace and WcfRealy.

`Tags: Microsoft.Relay/Namespaces, WcfRelays, authorizationRules, Microsoft.Relay/namespaces/authorizationRules`
