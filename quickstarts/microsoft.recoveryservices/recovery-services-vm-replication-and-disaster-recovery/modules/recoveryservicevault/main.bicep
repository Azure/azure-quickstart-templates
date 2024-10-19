param location string

param recoveryServiceVaultName string
param disasterRecoveryEnabled bool
param virtualNetworkId string
param recoveryNetworkId string
param recoverySubnetName string
param subnetId string
param replicationPolicyName string = 'DailyPolicy-${uniqueString(resourceGroup().id)}'
param replicationLocation string
param recoveryResourceGroupId string
param virtualMachineId string
param virtualMachineName string
param virtualMachineDiskId string
param virtualMachineDiskSku string
param storageAccountId string

var roleDefinitionContributorId = resourceId('Microsoft.Authorization/roleDefinitions', 'b24988ac-6180-42a0-ab88-20f7382dd24c')
var roleDefinitionStorageBlobDataContributorId = resourceId('Microsoft.Authorization/roleDefinitions', 'ba92f5b4-2d11-453d-a403-e96b0029c9fe')
var rsvPrivateDnsZoneName = 'privatelink.siterecovery.windowsazure.com'
var instanceType = 'A2A'


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
  name: guid(resourceGroup().id, storageAccountId, 'Contributor')
  properties: {
    roleDefinitionId: roleDefinitionContributorId
    principalType: 'ServicePrincipal'
    principalId: recoveryServiceVault.identity.principalId
  }
}

resource roleAssignmentStorageBlobDataContributor 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, storageAccountId, 'Storage Blob Data Contributor')
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
  name: 'link_to_${toLower(split(virtualNetworkId, '/')[8])}'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: virtualNetworkId
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
      id: subnetId
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

resource primaryProtectionContainerMappings 'Microsoft.RecoveryServices/vaults/replicationFabrics/replicationProtectionContainers/replicationProtectionContainerMappings@2024-04-01' = {
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

resource secondaryProtectionContainerMappings 'Microsoft.RecoveryServices/vaults/replicationFabrics/replicationProtectionContainers/replicationProtectionContainerMappings@2024-04-01' = {
  parent: secondaryRSVFabricProtectionContainers
  name: 'Secondary-Container-Mapping'
  properties: {
    policyId: replicationPolicies.id
    providerSpecificInput: {
      instanceType: instanceType
    }
    targetProtectionContainerId: primaryRSVFabricProtectionContainers.id
  }
}

resource primaryReplicationNetworkMappings 'Microsoft.RecoveryServices/vaults/replicationFabrics/replicationNetworks/replicationNetworkMappings@2024-04-01' = if(disasterRecoveryEnabled) {
  name: format('{0}/{1}/{2}/{3}',recoveryServiceVault.name, primaryRSVFabric.name, 'azureNetwork', 'Source-Network-Mapping')
  properties: {
    fabricSpecificDetails: {
      instanceType: 'AzureToAzure'
      primaryNetworkId: virtualNetworkId
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
    recoveryNetworkId: virtualNetworkId
  }
}

resource replicationProtectedItems 'Microsoft.RecoveryServices/vaults/replicationFabrics/replicationProtectionContainers/replicationProtectedItems@2024-04-01' = if(disasterRecoveryEnabled) {
  parent: primaryRSVFabricProtectionContainers
  name: virtualMachineName
  properties: {
    policyId: replicationPolicies.id
    providerSpecificDetails: {
      instanceType: instanceType
      autoProtectionOfDataDisk: 'Enabled'
      fabricObjectId: virtualMachineId
      recoveryResourceGroupId: recoveryResourceGroupId
      recoveryContainerId: secondaryRSVFabricProtectionContainers.id
      recoveryAzureNetworkId: recoveryNetworkId
      recoverySubnetName: recoverySubnetName
      vmManagedDisks: [
        {
          diskId: virtualMachineDiskId
          primaryStagingAzureStorageAccountId: storageAccountId
          recoveryReplicaDiskAccountType: virtualMachineDiskSku
          recoveryTargetDiskAccountType: virtualMachineDiskSku
          recoveryResourceGroupId: recoveryResourceGroupId
        }
      ]
    }
  }

  dependsOn: [
    primaryProtectionContainerMappings
    secondaryProtectionContainerMappings
    primaryReplicationNetworkMappings
    secondaryReplicationNetworkMappings
  ]
}

output recoveryServiceVaultIdentityPrincipalId string = recoveryServiceVault.identity.principalId
