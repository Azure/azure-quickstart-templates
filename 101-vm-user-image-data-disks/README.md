# Create a Virtual Machine from a User Image

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-vm-user-image-data-disks%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-vm-user-image-data-disks%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

Prerequisite - The VHD images to be used for OS and data disks must be in an Azure Resource Manager storage account.

This template allows you to create a Virtual Machines from user specified images for OS and Data disks. The disks used for your VM will be based on copies of the images you specify in the template parameters. This template also deploys a Virtual Network, Public IP addresses and a Network Interface in a user specified resource group.

