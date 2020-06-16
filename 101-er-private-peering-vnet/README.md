# ExpressRoute private peering and connection with VNet
![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/101-er-private-peering-vnet/PublicLastTestDate.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/101-er-private-peering-vnet/FairfaxLastTestDate.svg)


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