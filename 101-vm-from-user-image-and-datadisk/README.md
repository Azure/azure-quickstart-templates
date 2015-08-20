# Create a Virtual Machine from a User Image

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fiandow%2Fazure-quickstart-templates%2Fmaster%2F101-vm-from-user-image%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

Prerequisite - The Storage Account with the User Image VHD should already exist in the same resource group.

This template allows you to create a Virtual Machines from user specified images for OS and Data disks. This template also deploys a Virtual Network, Public IP addresses and a Network Interface.

Below are the parameters that the template expects

| Name   | Description    |
|:--- |:---|
| vmName | Name of the Virtual Machine |
| userImageStorageAccountName  | Name of the Storage Account where the User Image disk is placed. |
| userImageStorageContainerName  | Name of the Container Name in the Storage Account where the User Image disk is placed. |
| userImageVhdName  | Name of the user OS Image VHD file. |
| userDataImageVhdName  | Name of the user Data Image VHD file. |
| osType  | Specify the type of the OS of the User Image (Windows|Linux) |
| adminUsername  | Username for the Virtual Machines  |
| adminPassword  | Password for the Virtual Machine  |
| dnsNameForPublicIP  | Unique DNS Name for the Public IP used to access the Virtual Machine. |
| vmSize | Size of the Virtual Machine |
| 
