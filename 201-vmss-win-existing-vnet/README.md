# Deploy a VM Scale Set into an existing vnet and subnet

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-vmss-win-existing-vnet%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-vmss-win-existing-vnet%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template deploys a Windows 2016-Datacenter based VM Scale Set into an existing resource group, vnet and subnet. 

This is a bare-bones scale set deployment into an existing subnet that does not create any additional resources. To connect to the VMs in this scale set, look at the private IP addresses of the scale set VMs, and connect from existing resources in the VNet. If you need to connect to these VMs externally, your existing VNet will need a load balancer/gateway or jumpbox resource to connect into.

PARAMETER RESTRICTIONS
======================

vmssName must be 3-61 characters in length. It should also be unique across the VNet.

instanceCount must be 100 or less.

Do not deploy this scale set into a new resource group - it will only work in an existing resource group which contains a VNet and subnet.
