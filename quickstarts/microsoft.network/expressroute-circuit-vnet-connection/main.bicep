@description('The type of gateway to deploy. For connecting to ExpressRoute circuits, the gateway must be of type ExpressRoute. Other types are Vpn.')
@allowed([
  'ExpressRoute'
])
param gatewayType string = 'ExpressRoute'

@description('The type of connection. For connecting to ExpressRoute circuits, the connectionType must be of type ExpressRoute. Other types are IPsec and Vnet2Vnet.')
@allowed([
  'ExpressRoute'
])
param connectionType string = 'ExpressRoute'

@description('The name of the virtual network to create.')
param virtualNetworkName string

@description('The address space in CIDR notation for the new virtual network.')
param virtualNetworkAddressPrefix string

@description('The name of the first subnet in the new virtual network.')
param subnetName string

@description('The name of the subnet where Gateway is to be deployed. This must always be named GatewaySubnet.')
@allowed([
  'GatewaySubnet'
])
param gatewaySubnetName string = 'GatewaySubnet'

@description('The address range in CIDR notation for the first subnet.')
param subnetPrefix string

@description('The address range in CIDR notation for the Gateway subnet. For ExpressRoute enabled Gateways, this must be minimum of /28.')
param gatewaySubnetPrefix string

@description('The resource name given to the public IP attached to the gateway.')
param gatewayPublicIPName string

@description('The resource name given to the ExpressRoute gateway.')
param gatewayName string

@description('The resource name given to the Connection which links VNet Gateway to ExpressRoute circuit.')
param connectionName string

@description('The name of the ExpressRoute circuit with which the VNet Gateway needs to connect. The Circuit must be already created successfully and must have its circuitProvisioningState property set to \'Enabled\', and serviceProviderProvisioningState property set to \'Provisioned\'. The Circuit must also have a BGP Peering of type AzurePrivatePeering.')
param circuitName string

@description('Location for all resources.')
param location string = resourceGroup().location

var gatewaySubnetRef = resourceId('Microsoft.Network/virtualNetworks/subnets/', virtualNetwork.name, gatewaySubnetName)
var routingWeight = 3

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2021-02-01' = {
  name: virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        virtualNetworkAddressPrefix
      ]
    }
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: subnetPrefix
        }
      }
      {
        name: gatewaySubnetName
        properties: {
          addressPrefix: gatewaySubnetPrefix
        }
      }
    ]
  }
}

resource publicIP 'Microsoft.Network/publicIPAddresses@2021-02-01' = {
  name: gatewayPublicIPName
  location: location
  properties: {
    publicIPAllocationMethod: 'Dynamic'
  }
}

resource virtualNetworkGateway 'Microsoft.Network/virtualNetworkGateways@2021-02-01' = {
  name: gatewayName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'vnetGatewayConfig'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: gatewaySubnetRef
          }
          publicIPAddress: {
            id: publicIP.id
          }
        }
      }
    ]
    gatewayType: gatewayType
  }
}

resource connection 'Microsoft.Network/connections@2021-02-01' = {
  name: connectionName
  location: location
  properties: {
    virtualNetworkGateway1: {
      id: virtualNetworkGateway.id
      properties: {}
    }
    peer: {
      id: resourceId('Microsoft.Network/expressRouteCircuits', circuitName)
    }
    connectionType: connectionType
    routingWeight: routingWeight
  }
}
