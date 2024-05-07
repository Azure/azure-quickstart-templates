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

@description('Required. Name of the storage account to store access keys for.')
param storageAccountName string

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

//------------------------------------------------------------------------------
// Variables
//------------------------------------------------------------------------------

// Generate globally unique KeyVault name: 3-24 chars; letters, numbers, dashes
var keyVaultPrefix = '${replace(hubName, '_', '-')}-vault'
var keyVaultSuffix = '-${uniqueSuffix}'
var keyVaultName = replace('${take(keyVaultPrefix, 24 - length(keyVaultSuffix))}${keyVaultSuffix}', '--', '-')

var formattedAccessPolicies = [for accessPolicy in accessPolicies: {
  applicationId: contains(accessPolicy, 'applicationId') ? accessPolicy.applicationId : ''
  objectId: contains(accessPolicy, 'objectId') ? accessPolicy.objectId : ''
  permissions: accessPolicy.permissions
  tenantId: contains(accessPolicy, 'tenantId') ? accessPolicy.tenantId : tenant().tenantId
}]

//==============================================================================
// Resources
//==============================================================================

resource keyVault 'Microsoft.KeyVault/vaults@2022-11-01' = {
  name: keyVaultName
  location: location
  tags: union(tags, contains(tagsByResource, 'Microsoft.KeyVault/vaults') ? tagsByResource['Microsoft.KeyVault/vaults'] : {})
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
      // chinaeast2 is the only region in China that supports deployment scripts
      name: startsWith(location, 'china') ? 'standard' : sku
      family: 'A'
    }
  }
}

resource keyVault_accessPolicies 'Microsoft.KeyVault/vaults/accessPolicies@2022-11-01' = if (!empty(accessPolicies)) {
  name: 'add'
  parent: keyVault
  properties: {
    accessPolicies: formattedAccessPolicies
  }
}

resource storageRef 'Microsoft.Storage/storageAccounts@2022-09-01' existing = {
  name: storageAccountName
}

resource keyVault_secrets 'Microsoft.KeyVault/vaults/secrets@2022-11-01' = {
  name: storageRef.name
  parent: keyVault
  properties: {
    attributes: {
      enabled: true
      exp: 1702648632
      nbf: 10000
    }
    value: storageRef.listKeys().keys[0].value
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
