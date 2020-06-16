# ExpressRoute private peering and connection with VNet


[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-er-linked-to-vnet%2Fazuredeploy.json)  [![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-er-linked-to-vnet%2Fazuredeploy.json)


This template makes the following actions:
* configure private peering in pre-existing ExpressRoute circuit
* deploy a Virtual Network with two subnets, one subnet to connect Azure VMs and a GatewaySubnet to contain an ExpressRoute Gateway
* deploy an ExpressRoute gateway in the GatewaySubnet
* create and apply a NSG to the Azure VMs subnet 
* create a connection, to link the ExpressRoute circuit to the ExpressRoute Gateway

## Prerequisite
* The ExpressRoute circuit exists, with *circuitProvisioningState* property in **'Enabled'** and *serviceProviderProvisioningState* property in **'Provisioned'** 
* The ARM template requires a mandatory assignment of the parameters to reference the pre-existing ExpressRoute circuit: the resource group and Expressroute circuit name. 

```
tags: ExpressRoute, private peering, VNet, ARM template
```