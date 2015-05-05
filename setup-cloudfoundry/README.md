# Create a Virtual Machine from an Image

<a href="https://azuredeploy.net/" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

This template allows you to setup cloud foundry development envrioment. It will create a vm with public ipaddress,storage account, virutal network, network security group, 3 reserverd public ip address. 
After deployment finished, You can access the vm by ssh <adminUsername>@<dnsNameForPublicIP>.<locaion>.cloudapp.azure.com

Below are the parameters that the template expects

| Name   | Description    |
|:--- |:---|
| newStorageAccountName  | Unique DNS Name for the Storage Account where the Virtual Machine's disks will be placed. |
| adminUsername  | Username for the Virtual Machines  |
| adminPassword  | Password for the Virtual Machine  |
| dnsNameForPublicIP  | Unique DNS Name for the Public IP used to access the Virtual Machine. |
| location | location where the resources will be deployed |
| vmSize | Size of the Virtual Machine |
| vmName | Name of Virtual Machine |
|stemcellUri|SAS URI point to a stemcell vhd,will be used to create microbosh|
