# Deployment of a Premium Windows VM with Diagnostics Extension

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-premium-storage-windows-vm-diagnostics-extension%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

Built by: [kenazk](https://github.com/kenazk)

This template allows you to deploy a Premium Windows VM using a few different options for the Windows version, using the latest patched version. In addition, it will provision the Diagnostics Extension on your behlf in a new, non-Premium Storage Account. 

Below are the parameters that the template expects: 

| Name   | Description    |
|:--- |:---|
| location | Location to deploy to | 
| newStorageAccountName  | Unique DNS Name for the Storage Account where the Virtual Machine's disks will be placed. |
| vmDiagnosticsStorageAccountName | Unique DNS name for the Storage Account where the Virtual Machine's diagnostics are placed. | 
| adminUsername  | Username for the Virtual Machine  |
| adminPassword  | Password for the Virtual Machine  |
| dnsNameForPublicIP  | Unique DNS Name for the Public IP used to access the Virtual Machine. |
| windowsOSVersion  | The Windows version for the VM. This will pick a fully patched image of this given Windows version. Allowed values: 2008-R2-SP1, 2012-Datacenter, 2012-R2-Datacenter, Windows-Server-Technical-Preview |
