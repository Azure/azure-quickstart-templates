# ExpressRoute private peering and ExpressRoute gateway

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/expressroute-private-peering-vnet/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/expressroute-private-peering-vnet/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/expressroute-private-peering-vnet/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/expressroute-private-peering-vnet/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/expressroute-private-peering-vnet/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/expressroute-private-peering-vnet/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.network%2Fexpressroute-private-peering-vnet%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.network%2Fexpressroute-private-peering-vnet%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.network%2Fexpressroute-private-peering-vnet%2Fazuredeploy.json)

To learn more about how to deploy the template, see the [quickstart](https://docs.microsoft.com/azure/expressroute/quickstart-create-expressroute-vnet-template) article.

This template makes the following actions:

- Create an ExpressRoute circuit.
- Configure private peering on the ExpressRoute circuit.
- Deploy a virtual network with two subnets. A subnet to connect Azure VMs and a gateway subnet to host an ExpressRoute gateway.
- Deploy an ExpressRoute gateway in the gateway subnet.
- Create and apply a network security group (NSG) to the Azure VMs subnet.

## Note

The deployment leaves the ExpressRoute circuit with `circuitProvisioningState` property in `Enabled` and `serviceProviderProvisioningState` property in `NotProvisioned`. After running the template, you have to work with your ExpressRoute provider to complete the provisioning process of ExpressRoute circuit. In case of ExpressRoute Direct port pair, follow the steps shown in the [article](https://docs.microsoft.com/azure/expressroute/expressroute-howto-erdirect).
You can create a connection, to link the ExpressRoute circuit to the ExpressRoute gateway, only when the `serviceProviderProvisioningState` will be in `Provisioned` state.

```
tags: ExpressRoute, private peering, VNet, ARM template
```
