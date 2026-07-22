// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

//==============================================================================
// Parameters
//==============================================================================

@description('Required. Name of the hub. Used to ensure unique resource names.')
param hubName string

@description('Required. Suffix to add to the KeyVault instance name to ensure uniqueness.')
param uniqueSuffix string

@description('Optional. Location for all resources.')
param location string = resourceGroup().location

@description('Optional. Array of access policies object.')
param accessPolicies array = []

@description('Optional. Create and store a key for a remote storage account.')
@secure()
param storageAccountKey string

@description('Optional. Specifies the SKU for the vault.')
@allowed([
  'premium'
  'standard'
])
param sku string = 'premium'

@description('Optional. Resource tags.')
param tags object = {}

@description('Optional. Tags to apply to resources based on their resource type. Resource type specific tags will be merged with tags for all resources.')
param tagsByResource object = {}

@description('Required. Resource ID of the virtual network for private endpoints.')
param virtualNetworkId string

@description('Required. Resource ID of the subnet for private endpoints.')
param privateEndpointSubnetId string

@description('Optional. Enable public access to the data lake.  Default: false.')
param enablePublicAccess bool

//------------------------------------------------------------------------------
// Variables
//------------------------------------------------------------------------------

// Generate globally unique KeyVault name: 3-24 chars; letters, numbers, dashes
var keyVaultPrefix = '${replace(hubName, '_', '-')}-vault'
var keyVaultSuffix = '-${uniqueSuffix}'
var keyVaultName = replace('${take(keyVaultPrefix, 24 - length(keyVaultSuffix))}${keyVaultSuffix}', '--', '-')
var keyVaultSecretName = '${toLower(hubName)}-storage-key'
// cSpell:ignore privatelink, vaultcore
var keyVaultPrivateDnsZoneName = 'privatelink${replace(environment().suffixes.keyvaultDns, 'vault', 'vaultcore')}'

var formattedAccessPolicies = [for accessPolicy in accessPolicies: {
  applicationId: accessPolicy.?applicationId ?? ''
  objectId: accessPolicy.?objectId ?? ''
  permissions: accessPolicy.permissions
  tenantId: accessPolicy.?tenantId ?? tenant().tenantId
}]

//==============================================================================
// Resources
//==============================================================================

// TODO: Move vault creation to the hub-app module
resource keyVault 'Microsoft.KeyVault/vaults@2023-02-01' = {
  name: keyVaultName
  location: location
  tags: union(tags, tagsByResource[?'Microsoft.KeyVault/vaults'] ?? {})
  properties: {
    enabledForDeployment: true
    enabledForTemplateDeployment: true
    enabledForDiskEncryption: true
    enableSoftDelete: true
    softDeleteRetentionInDays: 90
    enableRbacAuthorization: false
    createMode: 'default'
    tenantId: subscription().tenantId
    accessPolicies: formattedAccessPolicies
    sku: {
      // Azure China only supports standard
      name: startsWith(location, 'china') ? 'standard' : sku
      family: 'A'
    }
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: enablePublicAccess ? 'Allow' : 'Deny'
    }
  }
}

resource keyVault_accessPolicies 'Microsoft.KeyVault/vaults/accessPolicies@2023-02-01' = if (!empty(accessPolicies)) {
  name: 'add'
  parent: keyVault
  properties: {
    accessPolicies: formattedAccessPolicies
  }
}

module keyVault_secret 'hub-vault.bicep' = if (!empty(storageAccountKey)) {
  name: 'keyVault_secret'
  params: {
    vaultName: keyVault.name
    secretName: keyVaultSecretName
    secretValue: storageAccountKey
    secretExpirationInSeconds: 1702648632
    secretNotBeforeInSeconds: 10000
  }
}

resource keyVaultPrivateDnsZone 'Microsoft.Network/privateDnsZones@2024-06-01' = if (!enablePublicAccess) {
  name: keyVaultPrivateDnsZoneName
  location: 'global'
  tags: union(tags, tagsByResource[?'Microsoft.KeyVault/privateDnsZones'] ?? {})
  properties: {}
}

resource keyVaultPrivateDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2024-06-01' = if (!enablePublicAccess) {
  name: '${replace(keyVaultPrivateDnsZone.name, '.', '-')}-link'
  location: 'global'
  parent: keyVaultPrivateDnsZone
  tags: union(tags, tagsByResource[?'Microsoft.Network/privateDnsZones/virtualNetworkLinks'] ?? {})
  properties: {
    virtualNetwork: {
      id: virtualNetworkId
    }
    registrationEnabled: false
  }
}

resource keyVaultEndpoint 'Microsoft.Network/privateEndpoints@2023-11-01' = if (!enablePublicAccess) {
  name: '${keyVault.name}-ep'
  location: location
  tags: union(tags, tagsByResource[?'Microsoft.Network/privateEndpoints'] ?? {})
  properties: {
    subnet: {
      id: privateEndpointSubnetId
    }
    privateLinkServiceConnections: [
      {
        name: 'keyVaultLink'
        properties: {
          privateLinkServiceId: keyVault.id
          groupIds: ['vault']
        }
      }
    ]
  }
}

resource keyVaultPrivateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-11-01' = if (!enablePublicAccess) {
  name: 'keyvault-endpoint-zone'
  parent: keyVaultEndpoint
  properties: {
    privateDnsZoneConfigs: [
      {
        name: keyVaultPrivateDnsZone.name
        properties: {
          privateDnsZoneId: keyVaultPrivateDnsZone.id
        }
      }
    ]
  }
}


//==============================================================================
// Outputs
//==============================================================================

@description('The resource ID of the key vault.')
output resourceId string = keyVault.id

@description('The name of the key vault.')
output name string = keyVault.name

@description('The URI of the key vault.')
output uri string = keyVault.properties.vaultUri
