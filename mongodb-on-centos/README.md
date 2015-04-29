# Install Mongo DB on a CentOS Virtual Machine using Custom Script Linux Extension

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FDrewm3%2Fazure-quickstart-templates%2Fmaster%2Fmongodb-on-centos%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

This template deploys Mongo DB on a CentOS Virtual Machine. This template also deploys a Storage Account, Virtual Network, Public IP addresses and a Network Interface.

Note: Cent OS disables Username/Password on Azure SKUs by default. This template will be updated with SSH Keys for the VMs soon.

Below are the parameters that the template expects

| Name   | Description    |
|:--- |:---|
| newStorageAccountName  | Unique DNS Name for the Storage Account where the Virtual Machine's disks will be placed. |
| adminUsername  | Username for the Virtual Machines  |
| adminPassword  | Password for the Virtual Machine  |
| dnsNameForPublicIP  | Unique DNS Name for the Public IP used to access the Virtual Machine. |
| subscriptionId  | Subscription ID where the template will be deployed |
| imagePublisher | Image Publisher for the OS disk, eg., Canonical |
| imageOffer | Image Offer for the OS disk eg., UbuntuServer |
| imageSKU | Image SKU for the OS disk  eg., 14.10-DAILY|
| location | location where the resources will be deployed |
| virtualNetworkName | Name of Virtual Network |
| vmSize | Size of the Virtual Machine |
| vmName | Name of Virtual Machine |
| publicIPAddressName | Name of Public IP Address Name |
| nicName | Name of Network Interface |
