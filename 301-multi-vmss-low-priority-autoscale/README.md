### Deploy Hybrid priority Scale Sets ###
 The following template deploys a low-priority scale set and a regular-priority scale set under one Standard load balancer:

1. A low priority VM Scale Set with the eviction policy set to delete, multi-placement groups, and autoscale integration.
2. A second regular VM Scale Set serving as a safety net for the case where low priority instances can't be created.
3. A standard load balancer on top of both scale sets serving as a single point of entry for incoming web traffic as well as NAT (for SSH).

 <a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F301-multi-vmss-low-priority-autoscale%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F301-multi-vmss-low-priority-autoscale%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>