# Simple deployment of an Ubuntu VM with OS Patching extension

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2thomas1206%2Fazure-quickstart-templates%2Fmaster%2Fvm-ospatching%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

Built by: [Thomas Shao](https://github.com/thomas1206)

This template uses the Azure Linux OSPatching extension to deploy an Linux VM. Azure Linux OSPatching extension enables the Azure VM administrators to automate the VM OS updates with the customized configurations.

You can use the OSPatching extension to configure OS updates for your virtual machines, including:

1. Specify how often and when to install OS patches
2. Specify what patches to install
3. Configure the reboot behavior after updates

Below are the parameters that the template expects

| Name   | Description    |
|:--- |:---|
| newStorageAccountName  | Unique DNS Name for the Storage Account where the Virtual Machine's disks will be placed. |
| location | The location where the Virtual Machine will be deployed |
| adminUsername  | Username for the Virtual Machine  |
| adminPassword  | Password for the Virtual Machine  |
| dnsNameForPublicIP  | Unique DNS Name for the Public IP used to access the Virtual Machine. |
| ubuntuOSVersion  | The Ubuntu version for deploying the OS Patching extension. This will pick a fully patched image of this given Ubuntu version. Allowed values: 14.04.2-LTS, 14.04-DAILY, 15.04, 14.10. |
| rebootAfterPatch | The reboot behavior after patching |
| dayOfWeek | The patching date (of the week)You can specify multiple days in a week. |
| startTime | Start time of patching |
| category" | Type of patches to install |
