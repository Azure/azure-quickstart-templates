# Deployment of a Premium Windows VM

<a href="https://deploy.azure.com/?repository=https://github.com/Azure/azure-quickstart-templates/tree/master/201-premium-windows-vm" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

Built by: [kenazk](https://github.com/kenazk)

This template allows you to deploy a Premium Windows VM using a few different options for the Windows version, using the latest patched version.

Below are the parameters that the template expects: 

| Name   | Description    |
|:--- |:---|
| location | Location to deploy to | 
| newStorageAccountName  | Unique DNS Name for the Storage Account where the Virtual Machine's disks will be placed. |
| adminUsername  | Username for the Virtual Machine  |
| adminPassword  | Password for the Virtual Machine  |
| dnsNameForPublicIP  | Unique DNS Name for the Public IP used to access the Virtual Machine. |
| windowsOSVersion  | The Windows version for the VM. This will pick a fully patched image of this given Windows version. Allowed values: 2008-R2-SP1, 2012-Datacenter, 2012-R2-Datacenter, Windows-Server-Technical-Preview |
