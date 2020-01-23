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



This template deploys a **NSG Flow Logs resource** in Network Watcher.

## Overview

This template enables the NSG Flow Logs on an existing NSG. The logs are stored in the provided storage account.
It deploys a new resource of type "Microsoft.Network/networkWatchers/flowLogs".



## Prerequisites

1. Network Watcher must be enabled for your subscription. Network Watcher is enabled by default, so unless you have disabled it, this should not be an issue.
2. You must have an existing NSG to log traffic from.
3. You must have a working Storage account for storing the logs.



`Tags: Network Watcher, NSG Flow Logs`
