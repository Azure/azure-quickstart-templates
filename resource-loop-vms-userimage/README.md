# Deploy 'n' Virtual Machines from a user image using Resource Loops

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fresource-loop-vms-userimage%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

This template allows you to create 'N' number of Virtual Machines from a User image based on the 'numberOfInstances' parameter specified during the template deployment. This template also deploys a Virtual Network, 'N' number of Public IP addresses/Network Inerfaces/Virtual Machines.

Prerequisite: The Storage Account with the User Image VHD should already exist in the same resource group.

Note: The Recommended limit of number of disks per Storage Account is 40.
