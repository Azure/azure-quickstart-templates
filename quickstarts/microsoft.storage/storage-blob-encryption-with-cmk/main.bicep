@description('The location into which the resources should be deployed.')
param location string = resourceGroup().location

@description('The Tenant Id that should be used throughout the deployment.')
param tenantId string = subscription().tenantId

@description('The name of the existing User Assigned Identity.')
param userAssignedIdentityName string

@description('The name of the resource group for the User Assigned Identity.')
param userAssignedIdentityResourceGroupName string

@description('The name of the Key Vault.')
param keyVaultName string  = 'vault-${uniqueString(resourceGroup().id)}'

@description('Name of the key in the Key Vault')
param keyVaultKeyName string = 'cmkey'

@description('Expiration time of the key')
param keyExpiration int = dateTimeToEpoch(dateTimeAdd(utcNow(), 'P1Y'))

@description('The name of the Storage Account')
param storageAccountName string =  'storage${uniqueString(resourceGroup().id)}'


resource userAssignedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' existing = {
  scope: resourceGroup(userAssignedIdentityResourceGroupName)
  name: userAssignedIdentityName  
}

resource keyVault 'Microsoft.KeyVault/vaults@2021-10-01' = {
  name: keyVaultName
  location: location
  properties: {
    sku: {
      name: 'standard'
      family: 'A'
    }
    enableSoftDelete: true
    enablePurgeProtection: true
    enabledForDiskEncryption: true
    tenantId: tenantId
    accessPolicies: [
      {
        tenantId: tenantId
        permissions: {
          keys: [
            'unwrapKey'
            'wrapKey'
            'get'
          ]
        }
        objectId: userAssignedIdentity.properties.principalId
      }
    ]
  }
}

resource kvKey 'Microsoft.KeyVault/vaults/keys@2021-10-01' = {
  parent: keyVault
  name: keyVaultKeyName
  properties: {
    attributes: {
      enabled: true
      exp: keyExpiration
    }
    keySize: 4096
    kty: 'RSA'
  }
}

resource storage 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${userAssignedIdentity.id}': {}
    }
  }
  properties: {
    accessTier: 'Hot'
    supportsHttpsTrafficOnly: true
    minimumTlsVersion: 'TLS1_2'
    encryption: {
      identity: {
        userAssignedIdentity: userAssignedIdentity.id
      }
      services: {
         blob: {
           enabled: true
         }
      }
      keySource: 'Microsoft.Keyvault'
      keyvaultproperties: {
        keyname: kvKey.name
        keyvaulturi: endsWith(keyVault.properties.vaultUri,'/') ? substring(keyVault.properties.vaultUri,0,length(keyVault.properties.vaultUri)-1) : keyVault.properties.vaultUri
      }
    }
  }
}



