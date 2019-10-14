# Elasticsearch, X-Pack, VM Scale Sets and Managed Disks

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/elasticsearch-vmss/PublicLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/elasticsearch-vmss/PublicDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/elasticsearch-vmss/FairfaxLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/elasticsearch-vmss/FairfaxDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/elasticsearch-vmss/BestPracticeResult.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/elasticsearch-vmss/CredScanResult.svg" />&nbsp;

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Felasticsearch-vmss%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Felasticsearch-vmss%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.png"/>
</a>

This template deploys an Elasticsearch cluster on Virtual Machines using a Scale Set and managed disks. The template provisions 3 dedicated master nodes, which are in their own availability set with locally attached disks, while the data nodes live in a scale set and use managed disks.

X-Pack is installed on all nodes, and Kibana is installed on the Master-eligible nodes. 

##Notes
Warning! X-Pack security is disabled, and HTTPS is not enabled. The load balancer allows traffic to port 5601 from all sources, so consider updating the network security group to lock this down, or enable X-Pack security, HTTPS and role-based logins. 

