# Very simple deployment of an Linux VM with a single empty Data Disk and VM Diagnostic extension

<a href="https://azuredeploy.net/" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

This template allows you to create a Linux Virtual Machine from a specified image during the template deployment. It also attaches an empty data disk. This template also deploys a Storage Account, Virtual Network, Public IP addresses and a Network Interface.

Below are the parameters that the template expects.

| Name   | Description    |
|:--- |:---|
| newStorageAccountName  | Unique DNS Name for the Storage Account where the Virtual Machine's disks will be placed. |
| adminUsername  | Username for the Virtual Machines  |
| adminPassword  | Password for the Virtual Machine  |
| dnsNameForPublicIP  | Unique DNS Name for the Public IP used to access the Virtual Machine. |
| vmSize | Size of the Virtual Machine |
