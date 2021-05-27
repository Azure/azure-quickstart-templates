# Multi tier VNet with NSGs and DMZ

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/nsg-dmz-in-vnet/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/nsg-dmz-in-vnet/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/nsg-dmz-in-vnet/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/nsg-dmz-in-vnet/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/nsg-dmz-in-vnet/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/nsg-dmz-in-vnet/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.network%2Fnsg-dmz-in-vnet%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.network%2Fnsg-dmz-in-vnet%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.network%2Fnsg-dmz-in-vnet%2Fazuredeploy.json)

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
