# Deploy a Windows VM and execute a custom PowerShell script.

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Ftcsatheesh%2Fazure-quickstart-templates%2Fmaster%2Fwindows-vm-custom-script%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

Based on the 101-simple-windows-vm template built by: [coreysa](https://github.com/coreysa)

This template allows you to deploy a simple Windows VM and execute a custom powershell script using the custom script extension. Note the script must be in stored in a azure blob storage.

Below are the parameters that the template expects:

| Name   | Description    |
|:--- |:---|
| newStorageAccountName  | Unique DNS Name for the Storage Account where the Virtual Machine's disks will be placed. |
| adminUsername  | Username for the Virtual Machine  |
| adminPassword  | Password for the Virtual Machine  |
| dnsNameForPublicIP  | Unique DNS Name for the Public IP used to access the Virtual Machine. |
| windowsOSVersion  | The Windows version for the VM. This will pick a fully patched image of this given Windows version. Allowed values: 2008-R2-SP1, 2012-Datacenter, 2012-R2-Datacenter, Windows-Server-Technical-Preview |
| scriptFile  | The script file that will be downloaded and executed. The file must be in azure blob storage |
| scriptName  | Name of the script to execute   |
