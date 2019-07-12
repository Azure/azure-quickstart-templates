# Azure Network Security Group Analytics

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Foms-azurensg-solution%2Fazuredeploy.json" target="_blank">
<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Foms-azurensg-solution%2Fazuredeploy.json" target="_blank">
<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.png"/>
</a>

This template deploys **Azure Network Security Group analytics solution** on an Azure Log Analytics workspace. 

Note: The Microsoft recommended solution for Network Analytics is [Traffic Analytics](https://docs.microsoft.com/azure/networking/network-monitoring-overview#traffic-analytics) 

`Tags: Azure Network Security Group, OMS Log Analytics, Monitoring`

The Azure Network Security Group analytics solution provides visualizations and insights into your Azure NSG Logs:
* NetworkSecurityGroupEvent
* NetworkSecurityGroupRuleCounter

## Configuration

Perform the following steps to configure the Azure Network Security Group analytics solution for your workspaces.

1. Enable the Azure Network Security Group analytics solution from<BR> <a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Foms-azurensg-solution%2Fazuredeploy.json" target="_blank">
<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/>
</a><BR>
2. Follow steps to Enable diagnostics logging for the Network Security Group:
(https://docs.microsoft.com/en-us/azure/virtual-network/virtual-network-nsg-manage-log) 

After you configure the solution, data should start flowing to your workspace within 15 minutes.

## Using the solution

After you click the **Azure Network Security Group analytics** tile on the Overview, you can view summaries of your logs and then drill in to details for the following categories:

* Network security group blocked flows
  * Network security group rules with blocked flows
  * MAC addresses with blocked flows
* Network security group allowed flows
  * Network security group rules with allowed flows
  * MAC addresses with allowed flows

![image of Azure Network Security Group analytics dashboard](images/log-analytics-nsg01.png)

![image of Azure Network Security Group analytics dashboard](images/log-analytics-nsg02.png)

On the **Azure Network Security Group analytics** dashboard, review the summary information in one of the blades, and then click one to view detailed information on the log search page.

On any of the log search pages, you can view results by time, detailed results, and your log search history. You can also filter by facets to narrow the results.