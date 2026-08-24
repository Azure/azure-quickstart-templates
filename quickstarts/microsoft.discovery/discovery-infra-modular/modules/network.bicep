// Networking module: virtual network with the six subnets a Microsoft Discovery
// deployment expects. Skip this module and pass your own subnet IDs to main.bicep
// (deployNetwork = false) if you already have a landing-zone network.

import { discoverySubnetIds } from 'types.bicep'

@description('Azure region for the virtual network.')
param location string = resourceGroup().location

@description('Name of the virtual network.')
@minLength(2)
@maxLength(64)
param vnetName string = 'discovery-vnet'

@description('Address space for the virtual network.')
param vnetAddressPrefix string = '10.0.0.0/16'

@description('Address prefix for the Supercomputer node pool subnet.')
param nodePoolSubnetPrefix string = '10.0.1.0/24'

@description('Address prefix for the AKS system subnet used by the Supercomputer.')
param aksSubnetPrefix string = '10.0.2.0/24'

@description('Address prefix for the Workspace subnet (delegated to Microsoft.App/environments).')
param workspaceSubnetPrefix string = '10.0.3.0/24'

@description('Address prefix for the private endpoint subnet.')
param privateEndpointSubnetPrefix string = '10.0.4.0/24'

@description('Address prefix for the agent subnet.')
param agentSubnetPrefix string = '10.0.5.0/24'

@description('Address prefix for the search subnet.')
param searchSubnetPrefix string = '10.0.6.0/24'

var appEnvironmentDelegation = [
  {
    name: 'Microsoft.App.environments'
    properties: {
      serviceName: 'Microsoft.App/environments'
    }
  }
]

var storageServiceEndpoint = [
  {
    service: 'Microsoft.Storage'
  }
]

resource vnet 'Microsoft.Network/virtualNetworks@2024-05-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
    subnets: [
      {
        name: 'supercomputerNodepoolSubnet'
        properties: {
          addressPrefix: nodePoolSubnetPrefix
          serviceEndpoints: storageServiceEndpoint
        }
      }
      {
        name: 'aksSubnet'
        properties: {
          addressPrefix: aksSubnetPrefix
          serviceEndpoints: storageServiceEndpoint
        }
      }
      {
        name: 'workspaceSubnet'
        properties: {
          addressPrefix: workspaceSubnetPrefix
          delegations: appEnvironmentDelegation
          serviceEndpoints: storageServiceEndpoint
        }
      }
      {
        name: 'privateEndpointSubnet'
        properties: {
          addressPrefix: privateEndpointSubnetPrefix
        }
      }
      {
        name: 'agentSubnet'
        properties: {
          addressPrefix: agentSubnetPrefix
          delegations: appEnvironmentDelegation
          serviceEndpoints: storageServiceEndpoint
        }
      }
      {
        name: 'searchSubnet'
        properties: {
          addressPrefix: searchSubnetPrefix
          delegations: appEnvironmentDelegation
        }
      }
    ]
  }
}

@description('Resource ID of the virtual network.')
output vnetId string = vnet.id

@description('Resource IDs of the six Discovery subnets.')
output subnetIds discoverySubnetIds = {
  nodePoolSubnetId: '${vnet.id}/subnets/supercomputerNodepoolSubnet'
  aksSubnetId: '${vnet.id}/subnets/aksSubnet'
  workspaceSubnetId: '${vnet.id}/subnets/workspaceSubnet'
  privateEndpointSubnetId: '${vnet.id}/subnets/privateEndpointSubnet'
  agentSubnetId: '${vnet.id}/subnets/agentSubnet'
  searchSubnetId: '${vnet.id}/subnets/searchSubnet'
}
