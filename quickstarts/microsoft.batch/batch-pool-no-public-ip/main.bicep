@description('Name of the Batch account')
param accountName string = 'mytestaccount'

@description('Name of the virtual network')
param vnetName string = 'mytest-vnet'

@description('Name of the VM SKU used by the Batch pool')
param vmSize string = 'Standard_D1_v2'

@description('Location for all resources - Azure Batch simplified node communication pools available in specific region, refer the documenation to select the supported region for this deployment. For more information see https://docs.microsoft.com/en-us/azure/batch/simplified-compute-node-communication#supported-regions')
param location string = resourceGroup().location

var nodeManagementPrivateEndpointName = '${accountName}-node-pe'
var privateDnsZoneName = 'privatelink.batch.azure.com'
var subnetName = 'default'
var poolName = 'no-public-ip-pool'
var nsgName = 'deny-internet-outbound'

resource batchAccount 'Microsoft.Batch/batchAccounts@2022-06-01' = {
  name: accountName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    publicNetworkAccess: 'Enabled'
    networkProfile: {
      accountAccess: {
        defaultAction: 'Deny'
        ipRules: [
          {
            action: 'Allow'
            value: '0.0.0.0/0'
          }
        ]
      }
      nodeManagementAccess: {
        defaultAction: 'Deny'
      }
    }
  }
}

resource privateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: privateDnsZoneName
  location: 'global'
}

resource nsg 'Microsoft.Network/networkSecurityGroups@2022-01-01' = {
  name: nsgName
  location: location
  properties: {
    securityRules: [
      {
        name: 'DenyInternetOutbound'
        properties: {
          access: 'Deny'
          protocol: '*'
          direction: 'Outbound'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: 'Internet'
          destinationPortRange: '*'
          priority: 200
        }
      }
    ]
  }
}

resource vnet 'Microsoft.Network/virtualNetworks@2022-01-01' = {
  name: vnetName
  location: location
  dependsOn: [
    nsg
  ]
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: '10.0.0.0/24'
          networkSecurityGroup: {
            id: resourceId('Microsoft.Network/networkSecurityGroups', nsgName)
          }
          privateEndpointNetworkPolicies: 'Disabled'
        }
      }
    ]
  }
}

resource vnetDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: '${privateDnsZoneName}/${vnetName}'
  location: 'global'
  dependsOn: [
    privateDnsZone
    vnet
  ]
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: resourceId('Microsoft.Network/virtualNetworks', vnetName)
    }
  }
}

resource nodeManagementPrivateEndpoint 'Microsoft.Network/privateEndpoints@2022-01-01' = {
  name: nodeManagementPrivateEndpointName
  location: location
  dependsOn: [
    batchAccount
    vnet
  ]
  properties: {
    privateLinkServiceConnections: [
      {
        name: nodeManagementPrivateEndpointName
        properties: {
          privateLinkServiceId: resourceId('Microsoft.Batch/batchAccounts', accountName)
          groupIds: [
            'nodeManagement'
          ]
        }
      }
    ]
    subnet: {
      id: resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, subnetName)
    }
  }
}

resource privateEndpointDnsIntegration 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2020-11-01' = {
  name: '${nodeManagementPrivateEndpointName}/default'
  dependsOn: [
    nodeManagementPrivateEndpoint
    privateDnsZone
  ]
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'private-dns-zone-integration'
        properties: {
          privateDnsZoneId: resourceId('Microsoft.Network/privateDnsZones', privateDnsZoneName)
        }
      }
    ]
  }
}

resource batchPool 'Microsoft.Batch/batchAccounts/pools@2022-06-01' = {
  name: '${accountName}/${poolName}'
  dependsOn: [
    batchAccount
    nodeManagementPrivateEndpoint
    vnet
  ]
  properties: {
    vmSize: vmSize
    interNodeCommunication: 'Disabled'
    taskSlotsPerNode: 4
    taskSchedulingPolicy: {
      nodeFillType: 'Pack'
    }
    deploymentConfiguration: {
      virtualMachineConfiguration: {
        imageReference: {
          publisher: 'canonical'
          offer: 'ubuntuserver'
          sku: '18.04-lts'
          version: 'latest'
        }
        nodeAgentSkuId: 'batch.node.ubuntu 18.04'
      }
    }
    networkConfiguration: {
      subnetId: resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, subnetName)
      publicIPAddressConfiguration: {
        provision: 'NoPublicIPAddresses'
      }
    }
    scaleSettings: {
      fixedScale: {
        targetDedicatedNodes: 1
        targetLowPriorityNodes: 0
        resizeTimeout: 'PT15M'
      }
    }
  }
}
