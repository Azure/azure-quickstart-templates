@description('Specifies the name of the Azure Machine Learning service workspace.')
param workspaceName string = 'workspace${uniqueString(resourceGroup().id)}'

@description('Specifies the location for all resources.')
@allowed([
  'australiaeast'
  'brazilsouth'
  'canadacentral'
  'centralus'
  'eastasia'
  'eastus'
  'eastus2'
  'francecentral'
  'japaneast'
  'koreacentral'
  'northcentralus'
  'northeurope'
  'southeastasia'
  'southcentralus'
  'uksouth'
  'westcentralus'
  'westus'
  'westus2'
  'westeurope'
])
param location string

@description('Specifies the VM size of the agents.')
param vmSize string = 'Standard_D4_v3'

@description('Specifies the agent count.')
param agentCount int = 3

var storageAccountName = 'sa${uniqueString(resourceGroup().id)}'
var storageAccountType = 'Standard_LRS'
var keyVaultName = 'kv${uniqueString(resourceGroup().id)}'
var tenantId = subscription().tenantId
var applicationInsightsName = 'ai${uniqueString(resourceGroup().id)}'
var containerRegistryName = 'cr${uniqueString(resourceGroup().id)}'

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-05-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: storageAccountType
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
    allowBlobPublicAccess: false
    minimumTlsVersion: 'TLS1_2'
    networkAcls: {
      defaultAction: 'Deny'
    }
  }
}

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' = {
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
  location: (((location == 'eastus2') || (location == 'westcentralus')) ? 'southcentralus' : location)
  kind: 'web'
  properties: {
    Application_Type: 'web'
  }
}

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2022-02-01-preview' = {
  name: containerRegistryName
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    adminUserEnabled: false
  }
}

resource workspace 'Microsoft.MachineLearningServices/workspaces@2022-10-01' = {
  name: workspaceName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    friendlyName: workspaceName
    keyVault: keyVault.id
    applicationInsights: applicationInsights.id
    containerRegistry: containerRegistry.id
    storageAccount: storageAccount.id
  }
}

resource workspaceCompute 'Microsoft.MachineLearningServices/workspaces/computes@2022-10-01' = {
  parent: workspace
  name: 'compute-with-ilb'
  location: location
  properties: {
    computeType: 'AKS'
    computeLocation: location
    properties: {
      agentVmSize: vmSize
      agentCount: agentCount
      loadBalancerType: 'InternalLoadBalancer'
    }
  }
}
