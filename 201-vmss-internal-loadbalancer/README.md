# Deployment of a VM Scale Set of Linux VMs behind an load balancer with NAT rules

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-vmss-internal-loadbalancer/PublicLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-vmss-internal-loadbalancer/PublicDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-vmss-internal-loadbalancer/FairfaxLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-vmss-internal-loadbalancer/FairfaxDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-vmss-internal-loadbalancer/BestPracticeResult.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-vmss-internal-loadbalancer/CredScanResult.svg" />&nbsp;

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-vmss-internal-loadbalancer%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-vmss-internal-loadbalancer%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.png"/>
</a>

This template allows you to deploy a VM Scale Set of Linux VMs using the latest patched version of Ubuntu Linux 15.10 or 14.04.4-LTS. These VMs are behind an load balancer with NAT rules. Because the load balancer is internal, you must first ssh into the jumpbox, then ssh from there into a specific VM behind the load balancer. To connect from the load balancer to a VM in the scale set, you would go to the Azure Portal, find the load balancer of your scale set, examine the NAT rules, then connect using the NAT rule you want. For example, if there is a NAT rule on port 50000, you could use the following command from the jumpbox:

ssh -p 50000 {username}@{public-ip-address}

PARAMETER RESTRICTIONS
======================

vmssName must be 3-61 characters in length. It should also be globally unique across all of Azure. If it isn't globally unique, it is possible that this template will still deploy properly, but we don't recommend relying on this pseudo-probabilistic behavior.
instanceCount must be 100 or less.


