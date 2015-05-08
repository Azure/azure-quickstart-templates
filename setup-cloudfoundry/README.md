# Setup Micro Bosh Deployment VM

<a href="https://azuredeploy.net/" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

This template allows you to setup cloud foundry development environment. It will create a vm with public ip address, storage account, virtual network, network security group, 3 reserved public ip 
After that please follow the guidance of how to setup bosh

Below are the parameters that the template expects

| Name   | Description    |
|:--- |:---|
| newStorageAccountName  | Unique DNS Name for the Storage Account where the Virtual Machine's disks will be placed. |
| adminUsername  | Username for the Virtual Machines  |
| adminPassword  | Password for the Virtual Machine  |
| location | location where the resources will be deployed |
| vmSize | Size of the Virtual Machine |
| vmName | Name of Virtual Machine |