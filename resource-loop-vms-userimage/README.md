# Deploy 'n' Virtual Machines from a user image using Resource Loops

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FDrewm3%2Fazure-quickstart-templates%2Fmaster%2Fresource-loop-vms-userimage%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

This template allows you to create 'N' number of Virtual Machines from a User image based on the 'numberOfInstances' parameter specified during the template deployment. This template also deploys a Virtual Network, 'N' number of Public IP addresses/Network Inerfaces/Virtual Machines.

Prerequisite: The Storage Account with the User Image VHD should already exist in the same resource group.

Note: The Recommended limit of number of disks per Storage Account is 40.

Below are the parameters that the template expects

| Name   | Description    |
|:--- |:---|
| userImageStorageAccountName  | Name of the Storage Account where the User Image disk is placed. |
| userImageStorageContainerName  | Name of the Container Name in the Storage Account where the User Image disk is placed. |
| userImageVhdName  | Name of the User Image VHD file. |
| osType  | Specify the type of the OS of the User Image (Windows|Linux) |
| adminUsername  | Username for the Virtual Machines  |
| adminPassword  | Password for the Virtual Machine  |
| vmNamePrefix  | VM Name Prefix for the Virtual Machine Instances |
| subscriptionId  | Subscription ID where the template will be deployed |
| numberOfInstances  | Number of Virtual Machine instances to create  |
| region | Region where the resources will be deployed |
| virtualNetworkName | Name of Virtual Network |
| vmSize | Size of the Virtual Machine |
