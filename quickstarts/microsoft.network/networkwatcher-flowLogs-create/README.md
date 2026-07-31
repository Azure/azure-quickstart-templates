---
description: This template creates a virtual network flow log resource.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: networkwatcher-flowLogs-create
languages:
- json
- bicep
---
# Enable Virtual Network Flow Logs

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/networkwatcher-flowLogs-create/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/networkwatcher-flowLogs-create/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/networkwatcher-flowLogs-create/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/networkwatcher-flowLogs-create/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/networkwatcher-flowLogs-create/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/networkwatcher-flowLogs-create/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/networkwatcher-flowLogs-create/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.network%2Fnetworkwatcher-flowLogs-create%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.network%2Fnetworkwatcher-flowLogs-create%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.network%2Fnetworkwatcher-flowLogs-create%2Fazuredeploy.json)

This template deploys a **virtual network flow log resource** inside the Network Watcher resource group.

## Overview

This template enables a new virtual network flow log resource of type `Microsoft.Network/networkWatchers/flowLogs` for an existing virtual network. For more information, see [Virtual network flow logs overview](https://learn.microsoft.com/azure/network-watcher/vnet-flow-logs-overview).

The flow logs resource is enabled in the (hidden) NetworkWatcherRG resource group that contains the Network Watcher service and related resources. The logs are written to a storage account which is also deployed by the template.

Useful links:

* [Create, change, enable, disable, or delete virtual network flow logs](https://learn.microsoft.com/azure/network-watcher/vnet-flow-logs-manage)
* [Network Watcher deployment model](https://learn.microsoft.com/azure/network-watcher/frequently-asked-questions#what-is-the-network-watcher-deployment-model)
* [What is NetworkWatcherRG?](https://learn.microsoft.com/azure/network-watcher/frequently-asked-questions#what-is-networkwatcherrg)
* [Permissions needed to use Network Watcher](https://learn.microsoft.com/azure/network-watcher/frequently-asked-questions#which-permissions-are-needed-to-use-network-watcher)

## Prerequisites

Network Watcher must be enabled for your subscription. Network Watcher is enabled by default unless you explicitly disable it.

You need the resource ID of an existing virtual network. The virtual network must be in the same region as the Network Watcher instance.

`Tags: Network Watcher, virtual network flow logs, Microsoft.Storage/storageAccounts, Microsoft.Resources/deployments, Microsoft.Network/networkWatchers/flowLogs, JSON, Microsoft.Network/virtualNetworks`
