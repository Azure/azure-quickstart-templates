# Windows VM deployment with a variable number of data disks

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-vm-windows-copy-datadisks%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-vm-windows-copy-datadisks%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template allows you to deploy a simple VM and specify the number of data disks at deploy time using a parameter.  Note that the number and size of data disks is bound by the VM size, this sample does not attempt to enforce those rules beyond the size used in this sample.

Docs are <a href="https://docs.microsoft.com/en-us/azure/virtual-machines/virtual-machines-windows-sizes" target="_blank">here</a> if you want the details.

