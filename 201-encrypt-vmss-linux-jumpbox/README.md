# This template deploys VM Scale Set of Linux VMs with a jumpbox and enables encryption on Linux VMSS

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fazure%2Fazure-quickstart-templates%2Fmaster%2F201-encrypt-vmss-linux-jumpbox%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2Fazure%2Fazure-quickstart-templates%2Fmaster%2F201-encrypt-vmss-linux-jumpbox%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template allows you to deploy a simple VM Scale Set of Linux VMs using the latest image version.  This template also deploys a jumpbox with a public IP address in the same virtual network. You can connect to the jumpbox via this public IP address, then connect from there to VMs in the scale set via private IP addresses. This template enables encryption on the VM Scale Set of Linux VMs.


PARAMETER RESTRICTIONS
======================

vmssName must be 3-61 characters in length. It should also be globally unique across all of Azure. If it isn't globally unique, it is possible that this template will still deploy properly, but we don't recommend relying on this pseudo-probabilistic behavior.
instanceCount must be 100 or less.
