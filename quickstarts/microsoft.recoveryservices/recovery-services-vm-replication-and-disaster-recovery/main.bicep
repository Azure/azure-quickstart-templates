
@description('Location for all resources.')
param location string = resourceGroup().location


// Required parameters
@description('Location of the recovery service Vault for disaster recovery')
param replicationLocation string = 'eastus'

@description('Virtual network resource name.')
param virtualNetworkName string
@description('Virtual network resource Address Space.')
param virtualNetworkAddressSpace string = '10.100.0.0/16'
@description('Virtual network resource Subnet 1 name.')
param subnetName1 string
@description('Virtual network resource Subnet 2 name.')
param subnetName2 string
@description('Virtual network resource Subnet 1 Address Prefix.')
param subnetAddressPrefix1 string = '10.100.0.0/24'
@description('Virtual network resource Subnet 2 Address Prefix.')
param subnetAddressPrefix2 string = '10.100.1.0/24'
@description('Storage account name')
param storageAccountName string = 'storage${uniqueString(subscription().id)}'
@description('Azure recovery service vault name')
param recoveryServiceVaultName string = 'rsv-${uniqueString(subscription().id)}'
param replicationPolicyName string = 'DailyPolicy-${uniqueString(resourceGroup().id)}'


@description('Set to true is disaster recovery vm replication should be enabled on the VM')
param disasterRecoveryEnabled bool = false

@description('Provide the virtual network ID for replication secondary region')
param recoveryNetworkId string = 'none'

@description('Resource ID of the Virtual machine that needs replication')
param virtualMachineId string = 'none'

@description('Resource group ID of where the virtual machine will be replicated to')
param recoveryResourceGroupId string = 'none'
var blobPrivateDnsZoneName = 'privatelink.blob.${environment().suffixes.storage}'
var filePrivateDnsZoneName = 'privatelink.file.${environment().suffixes.storage}'
var queuePrivateDnsZoneName = 'privatelink.queue.${environment().suffixes.storage}'
var roleDefinitionContributorId = resourceId('Microsoft.Authorization/roleDefinitions', 'b24988ac-6180-42a0-ab88-20f7382dd24c')
var roleDefinitionStorageBlobDataContributorId = resourceId('Microsoft.Authorization/roleDefinitions', 'ba92f5b4-2d11-453d-a403-e96b0029c9fe')
var rsvPrivateDnsZoneName = 'privatelink.siterecovery.windowsazure.com'
var instanceType = 'A2A'


resource virtualNetwork 'Microsoft.Network/virtualNetworks@2024-01-01' = {
  name: virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [virtualNetworkAddressSpace]
    }
  }
}

resource computeSubnet 'Microsoft.Network/virtualNetworks/subnets@2024-01-01' = {
  parent: virtualNetwork
  name: subnetName1
  properties: {
    addressPrefix: subnetAddressPrefix1
    privateEndpointNetworkPolicies: 'Enabled'
  }
}

resource privateEndpointSubnet 'Microsoft.Network/virtualNetworks/subnets@2024-01-01' = {
  parent: virtualNetwork
  name: subnetName2
  properties: {
    addressPrefix: subnetAddressPrefix2
    privateEndpointNetworkPolicies: 'Enabled'
  }

  dependsOn: [
    computeSubnet
  ]
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: toLower(storageAccountName)
  location: location
  sku: {
    name: 'Standard_GRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
    allowBlobPublicAccess: false
    minimumTlsVersion: 'TLS1_2'
    supportsHttpsTrafficOnly: true
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Deny'
    }
  }
}

resource blobPrivateDnsZone 'Microsoft.Network/privateDnsZones@2024-06-01' = {
  name: blobPrivateDnsZoneName
  location: 'global'
}

resource filePrivateDnsZone 'Microsoft.Network/privateDnsZones@2024-06-01' = {
  name: filePrivateDnsZoneName
  location: 'global'
}

resource queuePrivateDnsZone 'Microsoft.Network/privateDnsZones@2024-06-01' = {
  name: queuePrivateDnsZoneName
  location: 'global'
}

resource blobPrivateDnsZoneNameVnetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2024-06-01' = {
  parent: blobPrivateDnsZone
  name: 'link_to_${toLower(split(virtualNetwork.id, '/')[8])}'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: virtualNetwork.id
    }
  }
}

resource filePrivateDnsZoneNameVnetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2024-06-01' = {
  parent: filePrivateDnsZone
  name: 'link_to_${toLower(split(virtualNetwork.id, '/')[8])}'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: virtualNetwork.id
    }
  }
}

resource queuePrivateDnsZoneNameVnetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2024-06-01' = {
  parent: queuePrivateDnsZone
  name: 'link_to_${toLower(split(virtualNetwork.id, '/')[8])}'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: virtualNetwork.id
    }
  }
}

resource blobPrivateEndpoint 'Microsoft.Network/privateEndpoints@2024-01-01' = {
  name: '${storageAccount.name}-blob-pe'
  location: location
  properties: {
    privateLinkServiceConnections: [
      {
        name: '${storageAccount.name}-blob-pe'
        properties: {
          privateLinkServiceId: storageAccount.id
          groupIds: [
            'blob'
          ]
        }
      }
    ]
    subnet: {
      id: privateEndpointSubnet.id
    }
  }
}

resource filePrivateEndpoint 'Microsoft.Network/privateEndpoints@2024-01-01' = {
  name: '${storageAccount.name}-file-pe'
  location: location
  properties: {
    privateLinkServiceConnections: [
      {
        name: '${storageAccount.name}-file-pe'
        properties: {
          privateLinkServiceId: storageAccount.id
          groupIds: [
            'file'
          ]
        }
      }
    ]
    subnet: {
      id: privateEndpointSubnet.id
    }
  }
}

resource queuePrivateEndpoint 'Microsoft.Network/privateEndpoints@2024-01-01' = {
  name: '${storageAccount.name}-queue-pe'
  location: location
  properties: {
    privateLinkServiceConnections: [
      {
        name: '${storageAccount.name}-queue-pe'
        properties: {
          privateLinkServiceId: storageAccount.id
          groupIds: [
            'queue'
          ]
        }
      }
    ]
    subnet: {
      id: privateEndpointSubnet.id
    }
  }
}

resource blobPrivateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2024-01-01' = {
  parent: blobPrivateEndpoint
  name: 'blob'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'dnsConfig'
        properties: {
          privateDnsZoneId: blobPrivateDnsZone.id
        }
      }
    ]
  }
}

resource filePrivateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2024-01-01' = {
  parent: filePrivateEndpoint
  name: 'file'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'dnsConfig'
        properties: {
          privateDnsZoneId: filePrivateDnsZone.id
        }
      }
    ]
  }
}

resource queuePrivateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2024-01-01' = {
  parent: queuePrivateEndpoint
  name: 'queue'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'dnsConfig'
        properties: {
          privateDnsZoneId: queuePrivateDnsZone.id
        }
      }
    ]
  }
}

resource recoveryServiceVault 'Microsoft.RecoveryServices/vaults@2024-04-30-preview' = {
  name: recoveryServiceVaultName
  location: replicationLocation
  identity: {
    type: 'SystemAssigned'
  }
  sku: {
    name: 'RS0'
    tier: 'Standard'
  }
  properties: {
    redundancySettings: {
      crossRegionRestore: 'Disabled'
      standardTierStorageRedundancy: 'GeoRedundant'
    }
    publicNetworkAccess: 'Enabled'
  }
}

resource roleAssignmentContributor 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: storageAccount
  name: guid(resourceGroup().id, storageAccount.id, 'Contributor')
  properties: {
    roleDefinitionId: roleDefinitionContributorId
    principalType: 'ServicePrincipal'
    principalId: recoveryServiceVault.identity.principalId
  }
}

resource roleAssignmentStorageBlobDataContributor 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: storageAccount
  name: guid(resourceGroup().id, storageAccount.id, 'Storage Blob Data Contributor')
  properties: {
    roleDefinitionId: roleDefinitionStorageBlobDataContributorId
    principalType: 'ServicePrincipal'
    principalId: recoveryServiceVault.identity.principalId
  }
}

resource rsvPrivateDnsZone 'Microsoft.Network/privateDnsZones@2024-06-01' = {
  name: rsvPrivateDnsZoneName
  location: 'global'
}

resource rsvPrivateDnsZoneNameVnetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2024-06-01' = {
  parent: rsvPrivateDnsZone
  name: 'link_to_${toLower(split(virtualNetwork.id, '/')[8])}'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: virtualNetwork.id
    }
  }
}

resource rsvPrivateEndpoint 'Microsoft.Network/privateEndpoints@2024-01-01' = {
  name: '${recoveryServiceVault.name}-rsv-pe'
  location: location
  properties: {
    privateLinkServiceConnections: [
      {
        name: '${recoveryServiceVault.name}-rsv-pe'
        properties: {
          privateLinkServiceId: recoveryServiceVault.id
          groupIds: [
            'AzureSiteRecovery'
          ]
        }
      }
    ]
    subnet: {
      id: privateEndpointSubnet.id
    }
  }
}

resource rsvPrivateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2024-01-01' = {
  parent: rsvPrivateEndpoint
  name: 'AzureSiteRecovery'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'dnsConfig'
        properties: {
          privateDnsZoneId: rsvPrivateDnsZone.id
        }
      }
    ]
  }
}

resource replicationPolicies 'Microsoft.RecoveryServices/vaults/replicationPolicies@2024-04-01' = {
  parent: recoveryServiceVault
  name: replicationPolicyName
  properties: {
    providerSpecificInput: {
      instanceType: instanceType
      appConsistentFrequencyInMinutes: 4 * 60
      crashConsistentFrequencyInMinutes: 5
      multiVmSyncStatus: 'Enable'
      recoveryPointHistory: 24 * 60
    }
  }
}

resource primaryRSVFabric 'Microsoft.RecoveryServices/vaults/replicationFabrics@2024-04-01' = {
  parent: recoveryServiceVault
  name: 'Primary-Fabric'
  properties: {
    customDetails: {
      instanceType: 'Azure'
      location: location
    }
  }
}

resource secondaryRSVFabric 'Microsoft.RecoveryServices/vaults/replicationFabrics@2024-04-01' = {
  parent: recoveryServiceVault
  name: 'Secondary-Fabric'
  properties: {
    customDetails: {
      instanceType: 'Azure'
      location: recoveryServiceVault.location
    }
  }
}

resource primaryRSVFabricProtectionContainers 'Microsoft.RecoveryServices/vaults/replicationFabrics/replicationProtectionContainers@2024-04-01' = {
  parent: primaryRSVFabric
  name: 'Primary-Protection-Container'
  properties: {
    providerSpecificInput: [
      {
        instanceType: instanceType
      }
    ]
  }
}

resource secondaryRSVFabricProtectionContainers 'Microsoft.RecoveryServices/vaults/replicationFabrics/replicationProtectionContainers@2024-04-01' = {
  parent: secondaryRSVFabric
  name: 'Secondary-Protection-Container'
  properties: {
    providerSpecificInput: [
      {
        instanceType: instanceType
      }
    ]
  }
}

resource protectionContainerMappings 'Microsoft.RecoveryServices/vaults/replicationFabrics/replicationProtectionContainers/replicationProtectionContainerMappings@2024-04-01' = {
  parent: primaryRSVFabricProtectionContainers
  name: 'Primary-Container-Mapping'
  properties: {
    policyId: replicationPolicies.id
    providerSpecificInput: {
      instanceType: instanceType
    }
    targetProtectionContainerId: secondaryRSVFabricProtectionContainers.id
  }
}

resource primaryReplicationNetworkMappings 'Microsoft.RecoveryServices/vaults/replicationFabrics/replicationNetworks/replicationNetworkMappings@2024-04-01' = if(disasterRecoveryEnabled) {
  name: format('{0}/{1}/{2}/{3}',recoveryServiceVault.name, primaryRSVFabric.name, 'azureNetwork', 'Source-Network-Mapping')
  properties: {
    fabricSpecificDetails: {
      instanceType: 'AzureToAzure'
      primaryNetworkId: virtualNetwork.id
    }
    recoveryFabricName: secondaryRSVFabric.name
    recoveryNetworkId: recoveryNetworkId
  }
}

resource secondaryReplicationNetworkMappings 'Microsoft.RecoveryServices/vaults/replicationFabrics/replicationNetworks/replicationNetworkMappings@2024-04-01' = if(disasterRecoveryEnabled) {
  name: format('{0}/{1}/{2}/{3}',recoveryServiceVault.name, secondaryRSVFabric.name, 'azureNetwork', 'Target-Network-Mapping')
  properties: {
    fabricSpecificDetails: {
      instanceType: 'AzureToAzure'
      primaryNetworkId: recoveryNetworkId
    }
    recoveryFabricName: primaryRSVFabric.name
    recoveryNetworkId: virtualNetwork.id
  }
}

resource virtualMachine 'Microsoft.Compute/virtualMachines@2024-07-01' existing = if(disasterRecoveryEnabled) {
  scope: az.resourceGroup(split(virtualMachineId, '/')[4])
  name: split(virtualMachineId, '/')[8]
}

resource replicationProtectedItems 'Microsoft.RecoveryServices/vaults/replicationFabrics/replicationProtectionContainers/replicationProtectedItems@2024-04-01' = if(disasterRecoveryEnabled) {
  parent: primaryRSVFabricProtectionContainers
  name: virtualMachine.name
  properties: {
    policyId: replicationPolicies.id
    providerSpecificDetails: {
      instanceType: instanceType
      autoProtectionOfDataDisk: 'Enabled'
      fabricObjectId: virtualMachine.id
      recoveryResourceGroupId: recoveryResourceGroupId
      recoveryContainerId: secondaryRSVFabricProtectionContainers.id
      recoveryAzureNetworkId: recoveryNetworkId
      recoverySubnetName: computeSubnet.name
      vmManagedDisks: [
        {
          diskId: virtualMachine.id
          primaryStagingAzureStorageAccountId: storageAccount.id
          recoveryReplicaDiskAccountType: virtualMachine.properties.storageProfile.osDisk.managedDisk.storageAccountType
          recoveryTargetDiskAccountType: virtualMachine.properties.storageProfile.osDisk.managedDisk.storageAccountType
          recoveryResourceGroupId: recoveryResourceGroupId
        }
      ]
    }
  }

  dependsOn: [
    protectionContainerMappings
    primaryReplicationNetworkMappings
    secondaryReplicationNetworkMappings
  ]
}
