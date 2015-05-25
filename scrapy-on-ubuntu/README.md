# Install Scrapy on a Ubuntu Virtual Machine using Custom Script Linux Extension

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fscrapy-on-ubuntu%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

This template deploys Scrapy on a Ubuntu Virtual Machine. This template also deploys a Storage Account, Virtual Network, Public IP addresses and a Network Interface.

Below are the parameters that the template expects

| Name   | Description    |
|:--- |:---|
| newStorageAccountName  | Unique DNS Name for the Storage Account where the Virtual Machine's disks will be placed. |
| adminUsername  | Username for the Virtual Machines  |
| adminPassword  | Password for the Virtual Machine  |
| dnsNameForPublicIP  | Unique DNS Name for the Public IP used to access the Virtual Machine. |
| imagePublisher  | Image Publisher  |
| imageOffer  | Image Offer  |
| imageSKU  | Image SKU  |
| location | location where the resources will be deployed |
| virtualNetworkName | Name of Virtual Network |
| vmSize | Size of the Virtual Machine |
| vmName | Name of Virtual Machine |
| publicIPAddressName | Name of Public IP Address Name |
| nicName | Name of Network Interface |
| spiderName | Name of the spider |
| spiderUri | Name of the uri |
