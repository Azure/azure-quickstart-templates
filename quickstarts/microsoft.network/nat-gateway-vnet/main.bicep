@description('Name of the virtual network')
param vnetName string = 'myVnet'

@description('Name of the subnet for virtual network')
param subnetName string = 'mySubnet'

@description('Address space for virtual network')
param vnetAddressSpace string = '192.168.0.0/16'

@description('Subnet prefix for virtual network')
param vnetSubnetPrefix string = '192.168.0.0/24'

@description('Name of the NAT gateway resource')
param natGatewayName string = 'myNATgateway'

@description('dns of the public ip address, leave blank for no dns')
param publicIpDns string = 'gw-${uniqueString(resourceGroup().id)}'

@description('Location of resources')
param location string = resourceGroup().location

var publicIpName = '${natGatewayName}-ip'
var publicIpAddresses = [
  {
    id: publicIp.id
  }
]

resource publicIp 'Microsoft.Network/publicIPAddresses@2020-06-01' = {
  name: publicIpName
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
    idleTimeoutInMinutes: 4
    dnsSettings: {
      domainNameLabel: publicIpDns
    }
  }
}

resource natGateway 'Microsoft.Network/natGateways@2020-06-01' = {
  name: natGatewayName
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    idleTimeoutInMinutes: 4
    publicIpAddresses: !empty(publicIpDns) ? publicIpAddresses : null
  }
}

resource vnet 'Microsoft.Network/virtualNetworks@2020-06-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressSpace
      ]
    }
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: vnetSubnetPrefix
          natGateway: {
            id: natGateway.id
          }
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
    ]
    enableDdosProtection: false
    enableVmProtection: false
  }
}


