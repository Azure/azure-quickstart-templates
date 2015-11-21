# Manually Scale In Or Out The Number Of VMs In An Existing Scale Set

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-scale-existing-vmss%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a><a  target="_blank">

This template allows you to manually scale in or out the number of VMs in an existing Scale Set. The capacity specified will be the new capacity of the scale set. Make sure the VM Sku in this template matches the VM Sku you originally deployed the Scale Set with. Otherwise, subsequent scale operations (e.g. autoscale) will use the VM Sku specified in this templates.

PARAMETER RESTRICTIONS
======================

existingVMSSName must be the name of an EXISTING scale set