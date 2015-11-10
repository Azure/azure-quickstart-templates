# A Windows VM with the Azure diagnostics extension which enables monitoring and diagnostics capabilities 

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-simple-windows-vm-monitoring-diagnostics%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

Built by: [sbtron](https://github.com/sbtron)

This template allows you to deploy a simple Windows VM along with the diagnostics extension which enables monitoring and diagnostics for the VM. For more information see [Azure Diagnostics Extension in a resource manager template](http://azure.microsoft.com/documentation/articles/virtual-machines-extensions-diagnostics-windows-template). 

Below are the parameters that the template expects: 

| Name   | Description    |
|:--- |:---|
| newStorageAccountName  | Unique DNS Name for the Storage Account where the Virtual Machine's disks will be placed. |
| adminUsername  | Username for the Virtual Machine  |
| adminPassword  | Password for the Virtual Machine  |
| dnsNameForPublicIP  | Unique DNS Name for the Public IP used to access the Virtual Machine. |
| windowsOSVersion  | The Windows version for the VM. This will pick a fully patched image of this given Windows version. Allowed values: 2008-R2-SP1, 2012-Datacenter, 2012-R2-Datacenter, Windows-Server-Technical-Preview |
| diagnosticsStorageAccountName  | The name of the storage account where diagnostics data will be transferred |
| diagnosticsStorageResourceGroup  | The resource group name for the diagnostics storage account |