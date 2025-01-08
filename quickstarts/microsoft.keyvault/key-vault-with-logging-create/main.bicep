@description('Specifies the name of the key vault.')
param keyVaultName string = 'kv-${uniqueString(resourceGroup().id)}'

@description('Specifies the location for all resources.')
param location string = resourceGroup().location

@description('Specifies the object ID of a user, service principal or security group in the Azure Active Directory tenant for the vault. The object ID must be unique for the list of access policies. Get it by using Get-AzADUser or Get-AzADServicePrincipal cmdlets.')
param objectId string

@description('Specifies the permissions to keys in the vault. Valid values are: all, encrypt, decrypt, wrapKey, unwrapKey, sign, verify, get, list, create, update, import, delete, backup, restore, recover, and purge.')
param keysPermissions array = [
  'all'
]

@description('Specifies the permissions to secrets in the vault. Valid values are: all, get, list, set, delete, backup, restore, recover, and purge.')
param secretsPermissions array = [
  'all'
]

@description('Specifies the SKU for the key vault')
@allowed([
  'standard'
  'premium'
])
param vaultSku string = 'standard'

@description('Specifies the number of days that logs are gonna be kept. If you do not want to apply any retention policy and retain data forever, set value to 0.')
@minValue(0)
@maxValue(365)
param logsRetentionInDays int = 0

@description('Determines if the resources should be locked to prevent deletion.')
param protectWithLocks bool = true

var diagnosticStorageAccountName = 'diagst${uniqueString(subscription().id,resourceGroup().id)}'

resource kv 'Microsoft.KeyVault/vaults@2021-04-01-preview' = {
  name: keyVaultName
  location: location
  tags: {
    displayName: 'Key Vault with logging'
  }
  properties: {
    sku: {
      name: vaultSku
      family: 'A'
    }
    tenantId: subscription().tenantId
    accessPolicies: [
      {
        objectId: objectId
        tenantId: subscription().tenantId
        permissions: {
          keys: keysPermissions
          secrets: secretsPermissions
        }
      }
    ]
  }
}

resource sto 'Microsoft.Storage/storageAccounts@2021-06-01' = {
  name: diagnosticStorageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  tags: {
    displayName: 'Key Vault ${keyVaultName} diagnostics storage account'
  }
}

resource service 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: kv
  name: 'service'
  properties: {
    storageAccountId: sto.id
    logs: [
      {
        category: 'AuditEvent'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: logsRetentionInDays
        }
      }
    ]
  }
}

resource kvDoNotDelete 'Microsoft.Authorization/locks@2017-04-01' = if (protectWithLocks) {
  scope: kv
  name: 'keyVaultDoNotDelete'
  properties: {
    level: 'CanNotDelete'
  }
}

resource storageDoNotDelete 'Microsoft.Authorization/locks@2017-04-01' = if (protectWithLocks) {
  scope: sto
  name: 'storageDoNotDelete'
  properties: {
    level: 'CanNotDelete'
  }
}
