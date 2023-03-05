---
description: This template creates a NSG Flow log on an existing NSG with traffic analytics
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: nsg-flow-logs-with-traffic-analytics
languages:
- json
- bicep
---
# NSG Flow Logs with traffic analytics

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/nsg-flow-logs-with-traffic-analytics/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/nsg-flow-logs-with-traffic-analytics/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/nsg-flow-logs-with-traffic-analytics/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/nsg-flow-logs-with-traffic-analytics/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/nsg-flow-logs-with-traffic-analytics/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/nsg-flow-logs-with-traffic-analytics/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/nsg-flow-logs-with-traffic-analytics/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.network%2Fnsg-flow-logs-with-traffic-analytics%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.network%2Fnsg-flow-logs-with-traffic-analytics%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.network%2Fnsg-flow-logs-with-traffic-analytics%2Fazuredeploy.json)

This module will create a NSG flow log for an existing Network Security Group.

You can optionally enable traffic analytics.

`Tags: bicep, network, NSG, flowlog, Microsoft.Resources/deployments, Microsoft.Network/networkWatchers/flowLogs, JSON, Microsoft.Storage/storageAccounts, Microsoft.Network/networkSecurityGroups, Microsoft.Network/virtualNetworks`