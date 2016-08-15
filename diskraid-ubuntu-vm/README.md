# Create Ubuntu vm data disk raid0

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdiskraid-ubuntu-vm%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdiskraid-ubuntu-vm%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This is a simple template that deploys an Ubuntu Virtual Machine with multiple disks attached, and uses mdadm script to create a raid0 volume with all attached data disks.

This template also deploys a Storage Account, Virtual Network, Public IP addresses, and a Network Interface.
