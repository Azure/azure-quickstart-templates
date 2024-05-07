@description('Name of the Batch account')
param accountName string

@description('Name of the virtual network')
param vnetName string

@description('Name of the VM SKU used by the Batch pool')
param vmSize string = 'Standard_D1_v2'

@description('Location for all resources - Azure Batch simplified node communication pools available in specific region, refer the documenation to select the supported region for this deployment. For more information see https://docs.microsoft.com/en-us/azure/batch/simplified-compute-node-communication#supported-regions')
param location string = resourceGroup().location

var nodeManagementPrivateEndpointName = '${accountName}-node-pe'
var privateDnsZoneName = 'privatelink.batch.azure.com'
var subnetName = 'default'
var poolName = 'no-public-ip-pool'
var nsgName = 'deny-internet-outbound'

resource batchAccount 'Microsoft.Batch/batchAccounts@2022-10-01' = {
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

resource nsg 'Microsoft.Network/networkSecurityGroups@2022-05-01' = {
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

resource vnet 'Microsoft.Network/virtualNetworks@2022-05-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
  }

  resource subnet 'subnets' = {
    name: subnetName
    properties: {
      addressPrefix: '10.0.0.0/24'
      networkSecurityGroup: {
        id: nsg.id
      }
      privateEndpointNetworkPolicies: 'Disabled'
    }
  }
}

resource vnetDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: vnetName
  location: 'global'
  parent: privateDnsZone
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnet.id
    }
  }
}

resource nodeManagementPrivateEndpoint 'Microsoft.Network/privateEndpoints@2022-05-01' = {
  name: nodeManagementPrivateEndpointName
  location: location
  properties: {
    privateLinkServiceConnections: [
      {
        name: nodeManagementPrivateEndpointName
        properties: {
          privateLinkServiceId: batchAccount.id
          groupIds: [
            'nodeManagement'
          ]
        }
      }
    ]
    subnet: {
      id: vnet::subnet.id
    }
  }
}

resource privateEndpointDnsIntegration 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2022-05-01' = {
  name: 'default'
  parent: nodeManagementPrivateEndpoint
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'private-dns-zone-integration'
        properties: {
          privateDnsZoneId: privateDnsZone.id
        }
      }
    ]
  }
}

resource batchPool 'Microsoft.Batch/batchAccounts/pools@2022-10-01' = {
  name: poolName
  parent: batchAccount
  dependsOn: [
    nodeManagementPrivateEndpoint
  ]
  properties: {
    vmSize: vmSize
    targetNodeCommunicationMode: 'Simplified'
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
      subnetId: vnet::subnet.id
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
