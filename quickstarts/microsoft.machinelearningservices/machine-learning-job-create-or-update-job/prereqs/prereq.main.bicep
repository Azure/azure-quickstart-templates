@description('Specifies the name of the Azure Machine Learning workspace.')
param workspaceName string = 'ws${uniqueString(resourceGroup().id)}'

@description('Specifies the location for all resources.')
param location string = resourceGroup().location

@description('The name for the storage account to created and associated with the workspace.')
param storageAccountName string = 'st${uniqueString(resourceGroup().id)}'

@description('The name for the key vault to created and associated with the workspace.')
param keyVaultName string = 'kv${uniqueString(resourceGroup().id)}'

@description('Specifies the tenant ID of the subscription. Get using Get-AzureRmSubscription cmdlet or Get Subscription API.')
param tenantId string = subscription().tenantId

@description('The name for the application insights to created and associated with the workspace.')
param applicationInsightsName string = 'ai${uniqueString(resourceGroup().id)}'

@description('Specifies the name of the Azure Machine Learning amlcompute cluster to be deployed')
param computeName string = 'compute${uniqueString(resourceGroup().id)}'

@description('The VM size for compute instance')
param vmSize string = 'Standard_DS1_v2'

@description('The minimum number of nodes to use on the cluster. If not specified, defaults to 0')
param minNodeCount int = 0

@description(' The maximum number of nodes to use on the cluster. If not specified, defaults to 1.')
param maxNodeCount int = 1

@description('Idle time before scale down')
param nodeIdleTimeBeforeScaleDown string = 'PT120S'

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    encryption: {
      services: {
        blob: {
          enabled: true
        }
        file: {
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
    }
    supportsHttpsTrafficOnly: true
  }
}

resource keyVault 'Microsoft.KeyVault/vaults@2021-10-01' = {
  name: keyVaultName
  location: location
  properties: {
    tenantId: tenantId
    sku: {
      name: 'standard'
      family: 'A'
    }
    accessPolicies: []
  }
}

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: applicationInsightsName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
  }
}

resource workspace 'Microsoft.MachineLearningServices/workspaces@2022-05-01' = {
  name: workspaceName
  location: location
  identity: {
    type: 'systemAssigned'
  }
  properties: {
    friendlyName: workspaceName
    storageAccount: storageAccount.id
    keyVault: keyVault.id
    applicationInsights: applicationInsights.id
  }
}

resource workspaceName_compute 'Microsoft.MachineLearningServices/workspaces/computes@2021-01-01' = {
  parent: workspace
  name: computeName
  location: location
  properties: {
    computeType: 'AmlCompute'
    properties: {
      vmSize: vmSize
      scaleSettings: {
        minNodeCount: minNodeCount
        maxNodeCount: maxNodeCount
        nodeIdleTimeBeforeScaleDown: nodeIdleTimeBeforeScaleDown
      }
    }
  }
}

output workspaceName string = workspaceName
output computeName string = computeName
output storageAccountName string = storageAccountName
