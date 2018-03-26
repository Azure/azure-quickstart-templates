This template creates a VNet with 3 subnets:
* **Frontend** - _FESubnet / 10.0.0.0/24_
* **Application** - _AppSubnet / 10.0.1.0/24_
* **Database** - _DBSubnet / 10.0.2.0/24_

It also creates three Network Security Groups - one per subnet:
* **Frontend** - _FE_NSG_
* **Application** - _App_NSG_
* **Database** - _DB_NSG_

Each NSG is then associated with a subnet:
* _FESubnet_ to _FE_NSG_
* _AppSubnet_ to _App_NSG_
* _DBSubnet_ to _DB_NSG_

It creates DMZ rules for the App subnet to expose endpoints to the Internet. It secures the App subnet and the Database subnet with appropriate rules. It blocks Outbound Internet access to VMs in the App and Database subnets. It opens up the Database Subnet only on port 1433 the App Subnet.

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-nsg-dmz-in-vnet%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-nsg-dmz-in-vnet%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>
