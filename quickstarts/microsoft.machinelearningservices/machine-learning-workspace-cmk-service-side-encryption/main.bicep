@description('Specifies the name of the deployment that is used to generate resource names.')
@minLength(1)
param name string

@minLength(1)
@description('Specifies the name of the environment that is used to generate resource names.')
param environment string

@description('Specifies the location of the Azure Machine Learning workspace and dependent resources.')
@allowed([
  'australiaeast'
  'brazilsouth'
  'canadacentral'
  'centralus'
  'centralindia'
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

@description('Specifies whether to reduce telemetry collection and enable additional encryption.')
@allowed([
  false
  true
])
param hbi_workspace bool = true

@description('Specifies if the Azure Machine Learning workspace should be encrypted with the customer managed key.')
@allowed([
  'Enabled'
  'Disabled'
])
param encryption_status string = 'Enabled'

@description('Specifies the customer managed keyvault Resource Manager ID.')
param cmk_keyvault_id string

@description('Specifies the customer managed keyvault key uri.')
param cmk_keyvault_key_uri string

var tenantId = subscription().tenantId
var storageAccountName = 'st${name}${environment}'
var keyVaultName = 'kv-${name}-${environment}'
var applicationInsightsName = 'appi-${name}-${environment}'
var containerRegistryName = 'cr${name}${environment}'
var workspaceName = 'mlw${name}${environment}'

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_RAGRS'
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
    minimumTlsVersion: 'TLS1_2'
    supportsHttpsTrafficOnly: true
    allowBlobPublicAccess: false
  }
}

resource vault 'Microsoft.KeyVault/vaults@2022-07-01' = {
  name: keyVaultName
  location: location
  properties: {
    tenantId: tenantId
    sku: {
      name: 'standard'
      family: 'A'
    }
    accessPolicies: []
    enableSoftDelete: true
    enablePurgeProtection: true
  }
}

resource insight 'Microsoft.Insights/components@2020-02-02' = {
  name: applicationInsightsName
  location: (((location == 'eastus2') || (location == 'westcentralus')) ? 'southcentralus' : location)
  kind: 'web'
  properties: {
    Application_Type: 'web'
  }
}

resource registry 'Microsoft.ContainerRegistry/registries@2023-07-01' = {
  name: containerRegistryName
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    adminUserEnabled: true
  }
}

resource workspace 'Microsoft.MachineLearningServices/workspaces@2024-04-01-preview' = {
  name: workspaceName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    friendlyName: workspaceName
    storageAccount: storageAccount.id
    keyVault: vault.id
    applicationInsights: insight.id
    containerRegistry: registry.id
    hbiWorkspace: hbi_workspace
    encryption: {
      status: encryption_status
      keyVaultProperties: {
        keyVaultArmId: cmk_keyvault_id
        keyIdentifier: cmk_keyvault_key_uri
      }
    }
    enableServiceSideCMKEncryption: true
  }
}
