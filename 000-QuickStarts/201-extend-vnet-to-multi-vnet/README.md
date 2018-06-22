# Extend an existing Azure VNET to a Multi-VNET Configuration

This template allows you to extend an existing single VNET environment to a Multi-VNET environment that extends across two datacenter regions using VNET-to-VNET gateways

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-extend-vnet-to-multi-vnet%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-extend-vnet-to-multi-vnet%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template extends an existing single VNET environment to a Multi-VNET environment by deploying these Azure resources:

+ Second VNET in a different Azure datacenter region
+ VNET gateways on existing and second VNET
+ VNET gateway connections to establish a routable VNET-to-VNET connection between existing and second VNET

## Special Notes

To be successful in extending to a Multi-VNET configuration using this template, pay particular attention to these special items:

+ Use the resource group of the existing VNET for this template deployment
+ Prior to running this template deployment, create a subnet named "GatewaySubnet" on the existing VNET with a minimum /29 address prefix

## Template Parameters

Modify parameters file to change default values.
