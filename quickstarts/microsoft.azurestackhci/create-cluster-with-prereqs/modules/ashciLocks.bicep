param clusterName string
param customLocationName string
param clusterWitnessStorageAccountName string
param clusterNodeNames array
param keyVaultName string

resource customLocation 'Microsoft.ExtendedLocation/customLocations@2021-08-15' existing = {
  name: customLocationName
}

resource cluster 'Microsoft.AzureStackHCI/clusters@2024-01-01' existing = {
  name: clusterName
}

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: keyVaultName
}

resource witnessStorageAccount 'Microsoft.Storage/storageAccounts@2021-04-01' existing = {
  name: clusterWitnessStorageAccountName
}

resource resourceBridge 'Microsoft.ResourceConnector/appliances@2022-10-27' existing = {
  name: '${clusterName}-arcbridge'
}

resource lock_keyvault 'Microsoft.Authorization/locks@2020-05-01' = {
  name: 'DeleteLock'
  properties: {
    level: 'CanNotDelete'
  }
  scope: keyVault
}

resource lock_witnessStorageAccount 'Microsoft.Authorization/locks@2020-05-01' = {
  name: 'DeleteLock'
  properties: {
    level: 'CanNotDelete'
  }
  scope: witnessStorageAccount
}

resource lock_customLocation 'Microsoft.Authorization/locks@2020-05-01' = {
  name: 'DeleteLock'
  properties: {
    level: 'CanNotDelete'
  }
  scope: customLocation
}

resource lock_cluster 'Microsoft.Authorization/locks@2020-05-01' = {
  name: 'DeleteLock'
  properties: {
    level: 'CanNotDelete'
  }
  scope: cluster
}

resource lock_resourceBridge 'Microsoft.Authorization/locks@2020-05-01' = {
  name: 'DeleteLock'
  properties: {
    level: 'CanNotDelete'
  }
  scope: resourceBridge
}

resource hciNodes 'Microsoft.HybridCompute/machines@2022-12-27' existing = [for hciNode in clusterNodeNames: {
  name: hciNode
}]

resource lock_hciNodes 'Microsoft.Authorization/locks@2020-05-01' = [for i in range(0, (length(clusterNodeNames))) : {
  name: 'DeleteLock'
  properties: {
    level: 'CanNotDelete'
  }
  scope: hciNodes[i]
}]

// storage paths created automatically by express mode have a random guid in the name, so we can't apply a lock using this template
//resource userStoragePaths 'Microsoft.AzureStackHCI/storageContainers@2024-01-01' existing = [for i in range(0, (length(clusterNodeNames))) : if (storageConfigurationMode == 'InfraStorage') {
//  name: 'user' + i
//}]
