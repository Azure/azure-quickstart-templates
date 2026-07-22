
// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

//==============================================================================
// Parameters
//==============================================================================

@description('Required. Name of the hub. Used to ensure unique resource names.')
param hubName string

@description('Optional. Address space for the workload. A /26 is required for the workload. Default: "10.20.30.0/26".')
param virtualNetworkAddressPrefix string = '10.20.30.0/26'

@description('Optional. Azure location where all resources should be created. See https://aka.ms/azureregions. Default: (resource group location).')
param location string = resourceGroup().location

@description('Optional. Tags to apply to all resources.')
param tags object = {}

@description('Optional. Tags to apply to resources based on their resource type. Resource type specific tags will be merged with tags for all resources.')
param tagsByResource object = {}

//------------------------------------------------------------------------------
// Variables
//------------------------------------------------------------------------------

var safeHubName = replace(replace(toLower(hubName), '-', ''), '_', '')
// cSpell:ignore vnet
var vNetName = '${safeHubName}-vnet-${location}'
var nsgName = '${vNetName}-nsg'

// Workaround https://github.com/Azure/bicep/issues/1853
var finopsHubSubnetName = 'private-endpoint-subnet'
var scriptSubnetName = 'script-subnet'
var dataExplorerSubnetName = 'dataExplorer-subnet'

var subnets = [
  {
    name: finopsHubSubnetName
    properties: {
      addressPrefix: cidrSubnet(virtualNetworkAddressPrefix, 28, 0)
      networkSecurityGroup: {
        id: nsg.id
      }
      serviceEndpoints: [
        {
          service: 'Microsoft.Storage'
        }
      ]
    }
  }
  {
    name: scriptSubnetName
    properties: {
      addressPrefix: cidrSubnet(virtualNetworkAddressPrefix, 28, 1)
      networkSecurityGroup: {
        id: nsg.id
      }
      delegations: [
        {
          name: 'Microsoft.ContainerInstance/containerGroups'
          properties: {
            serviceName: 'Microsoft.ContainerInstance/containerGroups'
          }
        }
      ]
      serviceEndpoints: [
        {
          service: 'Microsoft.Storage'
        }
      ]
    }
  }
  {
    name: dataExplorerSubnetName
    properties: {
      addressPrefix: cidrSubnet(virtualNetworkAddressPrefix, 27, 1)
      networkSecurityGroup: {
        id: nsg.id
      }
    }
  }
]

//------------------------------------------------------------------------------
// Resources
//------------------------------------------------------------------------------

resource nsg 'Microsoft.Network/networkSecurityGroups@2023-11-01' = {
  name: nsgName
  location: location
  tags: union(tags, tagsByResource[?'Microsoft.Storage/networkSecurityGroups'] ?? {})
  properties: {
    securityRules: [
      {
        name: 'AllowVnetInBound'
        properties: {
          priority: 100
          direction: 'Inbound'
          access: 'Allow'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'VirtualNetwork'
        }
      }
      {
        name: 'AllowAzureLoadBalancerInBound'
        properties: {
          priority: 200
          direction: 'Inbound'
          access: 'Allow'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: 'AzureLoadBalancer'
          destinationAddressPrefix: '*'
        }
      }
      {
        name: 'DenyAllInBound'
        properties: {
          priority: 4096
          direction: 'Inbound'
          access: 'Deny'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
      {
        name: 'AllowVnetOutBound'
        properties: {
          priority: 100
          direction: 'Outbound'
          access: 'Allow'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'VirtualNetwork'
        }
      }
      {
        name: 'AllowInternetOutBound'
        properties: {
          priority: 200
          direction: 'Outbound'
          access: 'Allow'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: 'Internet'
        }
      }
      {
        name: 'DenyAllOutBound'
        properties: {
          priority: 4096
          direction: 'Outbound'
          access: 'Deny'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}

resource vNet 'Microsoft.Network/virtualNetworks@2023-11-01' = {
  name: vNetName
  location: location
  tags: union(tags, tagsByResource[?'Microsoft.Storage/virtualNetworks'] ?? {})
  properties: {
    addressSpace: {
      addressPrefixes: [virtualNetworkAddressPrefix]
    }
    subnets: subnets
  }
  resource finopsHubSubnet 'subnets' existing = {
    name: finopsHubSubnetName
  }
  resource scriptSubnet 'subnets' existing = {
    name: scriptSubnetName
  }
  resource dataExplorerSubnet 'subnets' existing = {
    name: dataExplorerSubnetName
  }
}

//------------------------------------------------------------------------------
// Outputs
//------------------------------------------------------------------------------

output vNetId string = vNet.id
output vNetName string = vNet.name
output vNetAddressSpace array = vNet.properties.addressSpace.addressPrefixes
output vNetSubnets array = vNet.properties.subnets
output finopsHubSubnetId string = vNet::finopsHubSubnet.id
output scriptSubnetId string = vNet::scriptSubnet.id
output dataExplorerSubnetId string = vNet::dataExplorerSubnet.id
