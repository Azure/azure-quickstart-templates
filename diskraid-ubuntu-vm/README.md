# Create Ubuntu vm data disk raid0

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FDrewm3%2Fazure-quickstart-templates%2Fmaster%2Fdiskraid-ubuntu-vm%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

This is a simple template that deploys an Ubuntu Virtual Machine with multiple disks attached, and uses mdadm script to create a raid0 volume with all attached data disks.

This template also deploys a Storage Account, Virtual Network, Public IP addresses, and a Network Interface.

Below are the parameters that the template expects

| Name   | Description    |
|:--- |:---|
| storageAccountName  | Unique DNS Name for the Storage Account where the Virtual Machine's disks will be placed |
| adminUsername  | Username for the Virtual Machines  |
| adminPassword  | Password for the Virtual Machine  |
| dnsName  | Unique DNS Name for the Public IP (dnsName.westus.cloudapp.azure.com) |
| region | region where the resources will be deployed |
| virtualNetworkName | Name of Virtual Network |
| vmSize | Size of the Virtual Machine Instance |
| dataDiskSize | The size of each data disk attached in Gb (default 200GB) |
