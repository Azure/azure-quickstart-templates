# Zabbix Monitoring Cluster

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/zabbix-monitoring-cluster/PublicLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/zabbix-monitoring-cluster/PublicDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/zabbix-monitoring-cluster/FairfaxLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/zabbix-monitoring-cluster/FairfaxDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/zabbix-monitoring-cluster/BestPracticeResult.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/zabbix-monitoring-cluster/CredScanResult.svg" />&nbsp;

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fzabbix-monitoring-cluster%2Fazuredeploy.json" target="_blank">
<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fzabbix-monitoring-cluster%2Fazuredeploy.json" target="_blank">
<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.png"/>
</a>

This template deploys a cluster and sets up a zabbix monitor server for cluster monitoring.

`Tags: monitoring, zabbix`

## Notes

The 'azuredeploy.json' template deployment will trigger two sub deployments:
- 'nested/clusterNodes.json'

    It will create a VM cluster for monitoring.

- 'nested/monitoringSolution.json'

    It will create a monitoring server VM with zabbix server installed, and then install zabbix agent on all existing VMs.

For monitoring existing VM cluster, you can deploy the template 'nested/monitoringSolution.json' in your existing resource group directly.

## Deployed resources

The cluster would contain 2 VMs by default, you can change this by editing 'clusterVmCount' parameter.

The cluster VM name would be prefixed with the 'clusterResourcePrefix' parameter.

The monitoring VM would have the name of 'monitorVmName' parameter.

After deployment, there following VMs will be created in the resource group.

- {clusterResourcePrefix}vm1
- {clusterResourcePrefix}vm2
- {monitorVmName}

You can access the zabbix monitoring portal via the URI provided by 'serverPublicEndpoint' parameter in output section.

Default 'Username/Password' for the portal is 'Admin/zabbix'. 

## Supported Distros:

Monitoring Server: Ubuntu 14.04 LTS

Monitoring Agent: Ubuntu 14.04 LTS, Ubuntu 16.04 LTS, CentOS 7.1

