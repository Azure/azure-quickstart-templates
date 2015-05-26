# Very simple deployment of a Linux VM and Redis Cache

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Flinux-vm-with-cache%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a><a  target="_blank">


Built by: [vflorusso](https://github.com/vflorusso)

This template allows you to deploy a simple Linux VM using a few different options for the Ubuntu Linux version, using the latest patched version on a D1 VM Size. 
This will also deploy a Redis Cache of the standard size in the same region using the Microsoft.Cache.1.0.4 from Template Gallery.

Below are the parameters that the template expects: 

| Name   | Description    |
|:--- |:---|
| newStorageAccountName  | Unique DNS Name for the Storage Account where the Virtual Machine's disks will be placed. |
| adminUsername  | Username for the Virtual Machine  |
| adminPassword  | Password for the Virtual Machine  |
| dnsNameForPublicIP  | Unique DNS Name for the Public IP used to access the Virtual Machine. |
| ubuntuOSVersion  | The Ubuntu version for the VM. This will pick a fully patched image of this given Ubuntu version. Allowed values: 12.04.2-LTS, 12.04.3-LTS, 12.04.4-LTS, 12.04.5-LTS, 12.10, 14.04.2-LTS, 14.10, 15.04 |
| location  | Location where the VM and the Cache Cluster will be created. |
| cacheName  | Name of the Azure Redis Cache. |
