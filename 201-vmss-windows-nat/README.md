# Simple deployment of a VM Scale Set of Windows VMs behind a load balancer with NAT rules

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-vmss-windows-nat%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-vmss-windows-nat%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template allows you to deploy a simple VM Scale Set of Windows VMs using the latest patched version of several Windows versions. These VMs are behind a load balancer with NAT rules that let you connect to vm i by connecting via rdp on port 50000 + i of the public IP in the deployment. For example, to connect to the 0th VM, you could RDP into {public-ip-address}:50000.

PARAMETER RESTRICTIONS
======================

vmssName must be 9 characters in length or shorter. It should also be globally unique across all of Azure. If it isn't globally unique, it is possible that this template will still deploy properly, but we don't recommend relying on this pseudo-probabilistic behavior.
instanceCount must be 100 or less.
