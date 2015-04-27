# Very simple deployment of an Ubuntu Server VM

<a href="https://deploy.azure.com/?repository=https://github.com/Azure/azure-quickstart-templates/tree/master/101-simple-ubuntu-vm" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

Built by: [squillace](https://github.com/squillace)

This template allows you to deploy a simple Ubuntu Server 14.10 VM using a few different options for the Ubuntu Server version, using the latest patched version. This will deploy in West US on a D1 VM Size.

Below are the parameters that the template expects: 

| Name   | Description    |
|:--- |:---|
| newStorageAccountName  | Unique DNS Name for the Storage Account where the Virtual Machine's disks will be placed. |
| adminUsername  | Username for the Virtual Machine  |
| adminPassword  | Password for the Virtual Machine  |
| dnsNameForPublicIP  | Unique DNS Name for the Public IP used to access the Virtual Machine. |
| ubuntuSkuVersion  | The Ubuntu version for the VM. This will pick a fully patched image of this given Ubuntu version.  |
