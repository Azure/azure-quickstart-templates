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

## Sample overview and deployed resources

This template creates a virtual network flow log for an existing virtual network. The flow log is deployed to the resource group that contains the Network Watcher instance for the virtual network's region.

The following resources are deployed as part of the solution.

### Microsoft.Network

- **Network Watcher**: Uses the regional Network Watcher instance that owns the flow log resource.
- **Virtual network flow log**: Records IP traffic for the existing virtual network and sends the data to the deployed storage account.

### Microsoft.Storage

- **Storage account**: Stores the virtual network flow log data.

## Prerequisites

- Network Watcher must be enabled in the region of the virtual network. Network Watcher is enabled by default unless you explicitly disable it.
- The `Microsoft.Insights` resource provider must be registered in the subscription.
- An existing virtual network is required. The virtual network must be in the same region as the Network Watcher instance.
- The deployment must target the resource group that contains the regional Network Watcher instance. By default, Azure creates Network Watcher instances in `NetworkWatcherRG`, but the resource group and instance names can be customized.
- The deploying account must have the permissions required to create a flow log and storage account in the Network Watcher resource group.

## Deployment steps

Select **Deploy to Azure** or **Deploy to Azure US Gov** at the beginning of this document. In the Azure portal:

1. Select the resource group that contains the Network Watcher instance for the virtual network's region.
1. For **Existing VNet**, enter the full resource ID of the virtual network.
1. Set **Location** to the virtual network's region.
1. If your Network Watcher instance uses a custom name, update **Network Watcher Name**.
1. Review the remaining flow log and storage account settings, and then deploy the template.

## Useful links

- [Virtual network flow logs overview](https://learn.microsoft.com/azure/network-watcher/vnet-flow-logs-overview)
- [Create, change, enable, disable, or delete virtual network flow logs](https://learn.microsoft.com/azure/network-watcher/vnet-flow-logs-manage)
- [Register the Microsoft.Insights provider](https://learn.microsoft.com/azure/network-watcher/vnet-flow-logs-manage#register-insights-provider)
- [Network Watcher deployment model](https://learn.microsoft.com/azure/network-watcher/frequently-asked-questions#what-is-the-network-watcher-deployment-model-)
- [What is NetworkWatcherRG?](https://learn.microsoft.com/azure/network-watcher/frequently-asked-questions#what-is-networkwatcherrg-)
- [Azure RBAC permissions required to use Network Watcher](https://learn.microsoft.com/azure/network-watcher/rbac-permissions)

`Tags: Network Watcher, virtual network flow logs, Microsoft.Storage/storageAccounts, Microsoft.Resources/deployments, Microsoft.Network/networkWatchers/flowLogs, JSON, Microsoft.Network/virtualNetworks`
