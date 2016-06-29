# Create Virtual Machine Scale Sets using Resource Loops

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fhuangpf%2Fazure-quickstart-templates%2Fdev%2F201-vmss-copy-index-loops%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2Fhuangpf%2Fazure-quickstart-templates%2Fdev%2F201-vmss-copy-index-loops%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template allows you to create 'N' number of Virtual Machine Scale Sets based on the 'numberOfInstances' parameter specified during the template deployment.

Note: The Recommended limit of number of disks per Storage Account is 40.

PARAMETER RESTRICTIONS
======================

vmssName must be 3-61 characters in length. It should also be globally unique across all of Azure. If it isn't globally unique, it is possible that this template will still deploy properly, but we don't recommend relying on this pseudo-probabilistic behavior.
instanceCount must be 100 or less.
