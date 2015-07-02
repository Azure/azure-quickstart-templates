# Create Virtual Machines using Resource Loops

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fresource-loop-vms-vnet-aset%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

This template allows you to create 'N' number of Virtual Machines in an availability set based on the 'numberOfInstances' parameter specified during the template deployment. This template also deploys a Storage Account, Virtual Network, 'N' number of Public IP addresses/Network Inerfaces/Virtual Machines.

Note: The Recommended limit of number of disks per Storage Account is 40.

Below are the parameters that the template expects

| Name   | Description    |
|:--- |:---|
| newStorageAccountName  | Unique DNS Name for the Storage Account where the Virtual Machine's disks will be placed. |
| adminUsername  | Username for the Virtual Machines  |
| adminPassword  | Password for the Virtual Machine  |
| numberOfInstances  | Number of Virtual Machine instances to create  |
| region | Region where the resources will be deployed |
| vmSize | Size of the Virtual Machine |
| imagePublisher | Name of Image Publisher |
| imageOffer | Name of Image Publisher offer |
| imageSKU | Name of SKU for the selected offer |
