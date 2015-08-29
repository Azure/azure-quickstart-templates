# A Visual Studio Development VM

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fvisual-studio-dev-vm%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

Built by: [dtzar](https://github.com/dtzar)

This template creates a Visual Studio 2013 or 2015 VM from the base gallery VM images available.  It creates the VM in a new vnet, storage account, nic, and public ip with the new compute stack.
By default, it will deploy Visual Studio 2015 with Azure SDK 2.7 on Windows Server 2012 with a DS2 size on top of a new premium storage account.

Below are the parameters in the template you should or need to change from the defaults: 

| Name   | Description    |
|:--- |:---|
| storageName | Unique DNS Name for the Storage Account where the Virtual Machine's disks will be placed. |
| vmAdminUserName  | Username for the Virtual Machine  |
| vmAdminPassword  | Password for the Virtual Machine  |
| vmIPPublicDnsName  | Unique DNS Name for the Public IP used to access the Virtual Machine.
