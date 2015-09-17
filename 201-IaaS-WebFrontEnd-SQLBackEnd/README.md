# Virtual Network with two Subnets

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2FACOM-TestVNet-VMs%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2FACOM-TestVNet-VMs%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template allows you to create a Virtual Network with two subnets, Windows Server VMs in one subnet, and SQL Server 2014 VMs on another subnet.

Below are the parameters that the template expects.

| Name   | Description    |
|:--- |:---|
| stdStorageName | Name for the standard storage account used to store vhds |
| stdStorageType | Type of storage for the standard storage account, defaults to Standard_LRS |
| prmStorageName | Name for the premium storage account used to store SSD vhds |
| prmStorageType | Type of storage for the premium storage account, defaults to Premium_LRS |
| vnetName | Name for the new virtual network |
| vnetPrefix | Address prefix for the Virtual Network specified in CIDR format |
| frontEndSubnetName | Name for first subnet |
| frontEndSubnetPrefix | Prefix for the Subnet-1 specified in CIDR format |
| backEndSubnetName | Name for second subnet |
| webCount | Number of VMs in the front end subnet |
| sqlCount | Number of VMs in the back end subnet |
| frontEndNSGName | Name of the NSG used for the front end subnet |
| backEndNSGName | Name of the NSG used for the back end subnet |

For more information on the scenario built wth this template, visit [this page](https://azure.microsoft.com/documentation/articles/virtual-networks-create-nsg-arm-template)