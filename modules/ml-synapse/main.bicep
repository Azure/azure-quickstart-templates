param name string = newGuid()
param location string
param tags object = {
  'aia-industry': 'industry'
  'aia-solution ': 'solution'
  version: '0.0.0'
}

param defaultDataLakeStorageFilesystemName string = 'workspace'
param storageLocation string = location
param cmkUri string = ''
param storageAccountName string = uniqueString(resourceGroup().id, name)
param azureMLName string = 'aml${uniqueString(resourceGroup().id, name)}'
param appInsights string = 'appin${uniqueString(resourceGroup().id, name)}'
param keyVault string = 'kv${uniqueString(resourceGroup().id, name)}'

var azureMLSku = 'basic'
var kind = 'StorageV2'
var storageBlobDataContributorRoleID = 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
var defaultDataLakeStorageAccountName = uniqueString(resourceGroup().id, name)
var defaultDataLakeStorageAccountUrl = 'https://${defaultDataLakeStorageAccountName}.dfs.${environment().suffixes.storage}'
var cmkUriStripVersion = (empty(cmkUri) ? '' : substring(cmkUri, 0, lastIndexOf(cmkUri, '/')))
var withCmk = {
  cmk: {
    key: {
      name: 'default'
      keyVaultUrl: cmkUriStripVersion
    }
  }
}
var encryption = (empty(cmkUri) ? json('{}') : withCmk)

resource storageAccount 'Microsoft.Storage/storageAccounts@2019-04-01' = {
  name: storageAccountName
  location: location
  tags: {
    Type: 'Synapse Data Lake Storage'
    'Created with': 'Synapse Azure Resource Manager deployment template'
  }
  sku: {
    name: 'Standard_RAGRS'
  }
  kind: kind
  properties: {
    isHnsEnabled: true
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Allow'
    }
    supportsHttpsTrafficOnly: true
    encryption: {
      services: {
        file: {
          enabled: true
        }
        blob: {
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
    }
    accessTier: 'Hot'
  }
}

resource blob 'Microsoft.Storage/storageAccounts/blobServices@2019-04-01' = {
  parent: storageAccount
  name: 'default'
  properties: {
    deleteRetentionPolicy: {
      enabled: false
    }
  }
}

resource container 'Microsoft.Storage/storageAccounts/blobServices/containers@2019-04-01' = {
  parent: blob
  name: 'workspace'
  properties: {
    publicAccess: 'None'
  }
}

resource synapseWorkspace 'Microsoft.Synapse/workspaces@2019-06-01-preview' = {
  name: name
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    defaultDataLakeStorage: {
      accountUrl: defaultDataLakeStorageAccountUrl
      filesystem: defaultDataLakeStorageFilesystemName
    }
    encryption: encryption
  }
  dependsOn: [
    blob
    storageAccount
  ]
}

resource firewallRules 'Microsoft.Synapse/workspaces/firewallrules@2019-06-01-preview' = {
  parent: synapseWorkspace
  name: 'allowAll'
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '255.255.255.255'
  }
}

resource roleAssignments 'Microsoft.Storage/storageAccounts/blobServices/containers/providers/roleAssignments@2018-09-01-preview' = {
  name: '${defaultDataLakeStorageAccountName}/default/${defaultDataLakeStorageFilesystemName}/Microsoft.Authorization/${guid('${resourceGroup().id}/${storageBlobDataContributorRoleID}/storageRoleDeploymentResource')}'
  location: storageLocation
  properties: {
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', storageBlobDataContributorRoleID)
    principalId: reference('Microsoft.Synapse/workspaces/${name}', '2019-06-01-preview', 'Full').identity.principalId
    principalType: 'ServicePrincipal'
  }
}

resource mlKeyVault 'Microsoft.KeyVault/vaults@2019-09-01' = {
  tags: tags
  name: keyVault
  location: location
  properties: {
    accessPolicies: []
    enableSoftDelete: true
    softDeleteRetentionInDays: 7
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
  }
}

resource mlAppInsights 'Microsoft.Insights/components@2020-02-02-preview' = {
  tags: tags
  name: appInsights
  location: (((location == 'eastus2') || (location == 'westcentralus')) ? 'southcentralus' : location)
  kind: 'web'
  properties: {
    Application_Type: 'web'
  }
}

resource azureML 'Microsoft.MachineLearningServices/workspaces@2020-06-01' = {
  tags: tags
  name: azureMLName
  location: location
  sku: {
    name: azureMLSku
    tier: azureMLSku
  }
  properties: {
    applicationInsights: mlAppInsights.id
    friendlyName: azureMLName
    keyVault: mlKeyVault.id
    storageAccount: storageAccount.id
    // hbiWorkspace: hbiWorkspace
  }
  identity: {
    type: 'SystemAssigned'
  }
}
