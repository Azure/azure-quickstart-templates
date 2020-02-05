# Create an NSG Flow Logs resource in Network Watcher

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-networkwatcher-flowLogs-create/PublicLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-networkwatcher-flowLogs-create/PublicDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-networkwatcher-flowLogs-create/FairfaxLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-networkwatcher-flowLogs-create/FairfaxDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-networkwatcher-flowLogs-create/BestPracticeResult.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-networkwatcher-flowLogs-create/CredScanResult.svg" />&nbsp;

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-networkwatcher-flowLogs-create%2Fazuredeploy.json" target="_blank">
<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-networkwatcher-flowLogs-create%2Fazuredeploy.json" target="_blank">
<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.png"/>
</a>


This template deploys an **NSG Flow Logs resource** inside the Network Watcher resource group.

## Overview

This template enables a new NSG Flow Logs resource (type "Microsoft.Network/networkWatchers/flowLogs").
The Flow Logs resource is enabled in the (hidden) NetworkWatcherRG resource group that contains the Network Watcher service and related resources. The logs are written to a storage account which is also deployed by the template.

Useful links
* [Enable NSG Flow logs through an ARM template](https://docs.microsoft.com/azure/network-watcher/network-watcher-nsg-flow-logging-azure-resource-manager)
* [Network Watcher Deployment model](https://docs.microsoft.com/azure/network-watcher/frequently-asked-questions#what-is-the-Network-Watcher-deployment-model)
* [What is the NetworkWatcherRG](https://docs.microsoft.com/azure/network-watcher/frequently-asked-questions#what-is-the-NetworkWatcherRG)
* [Permissions needed to deploy to NetworkWatcherRG ](https://docs.microsoft.com/azure/network-watcher/frequently-asked-questions#which-permissions-are-needed-to-use-network-watcher)


## Prerequisites

Network Watcher must be enabled for your subscription. Network Watcher is enabled by default, so unless you have disabled it, this should not be an issue.


`Tags: Network Watcher, NSG Flow Logs`
