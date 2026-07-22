// Creates Azure dependent resources for the Azure AI Hub

@description('Azure region used for the deployment of dependent resources.')
param location string = resourceGroup().location

@description('Set of tags to apply to dependent resources.')
param tags object = {}

@description('Name for the Azure AI Services resource.')
param aiServicesName string

@description('Name of the Azure Application Insights resource.')
param applicationInsightsName string

@description('Name of the Azure Container Registry resource.')
param containerRegistryName string

@description('Name of the Azure Key Vault resource.')
param keyVaultName string

@description('Name of the Azure Storage Account resource.')
param storageName string

@allowed([
  'Standard_LRS'
  'Standard_ZRS'
  'Standard_GRS'
  'Standard_GZRS'
  'Standard_RAGRS'
  'Standard_RAGZRS'
  'Premium_LRS'
  'Premium_ZRS'
])
@description('SKU name for the Azure Storage Account resource.')
param storageSkuName string = 'Standard_LRS'

@description('The object ID of a Microsoft Entra ID users to be granted necessary role assignments to access the dependent resources.')
param userObjectId string = ''

// Removes special characters from the container registry and storage account names to ensure they are valid resource names
var containerRegistryNameCleaned = replace(containerRegistryName, '-', '')
var storageNameCleaned = replace(storageName, '-', '')

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: applicationInsightsName
  location: location
  tags: tags
  kind: 'web'
  properties: {
    Application_Type: 'web'
    DisableIpMasking: false
    DisableLocalAuth: false
    Flow_Type: 'Bluefield'
    ForceCustomerStorageForProfiler: false
    ImmediatePurgeDataOn30Days: true
    IngestionMode: 'ApplicationInsights'
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Disabled'
    Request_Source: 'rest'
  }
}

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2021-09-01' = {
  name: containerRegistryNameCleaned
  location: location
  tags: tags
  sku: {
    name: 'Premium'
  }
  properties: {
    adminUserEnabled: true
    dataEndpointEnabled: false
    networkRuleBypassOptions: 'AzureServices'
    networkRuleSet: {
      defaultAction: 'Deny'
    }
    policies: {
      quarantinePolicy: {
        status: 'enabled'
      }
      retentionPolicy: {
        status: 'enabled'
        days: 7
      }
      trustPolicy: {
        status: 'disabled'
        type: 'Notary'
      }
    }
    publicNetworkAccess: 'Disabled'
    zoneRedundancy: 'Disabled'
  }
}

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' = {
  name: keyVaultName
  location: location
  tags: tags
  properties: {
    createMode: 'default'
    enabledForDeployment: false
    enabledForDiskEncryption: false
    enabledForTemplateDeployment: false
    enableSoftDelete: true
    enableRbacAuthorization: true
    enablePurgeProtection: true
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Deny'
    }
    sku: {
      family: 'A'
      name: 'standard'
    }
    softDeleteRetentionInDays: 7
    tenantId: subscription().tenantId
  }
}

resource keyVaultAdministratorRole 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = if (userObjectId != '') {
  name: '00482a5a-887f-4fb3-b363-3b7fe8e74483'
  scope: resourceGroup()
}

resource keyVaultAdministratorRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (userObjectId != '') {
  name: guid(keyVault.id, userObjectId, keyVaultAdministratorRole.id)
  scope: keyVault
  properties: {
    principalId: userObjectId
    roleDefinitionId: keyVaultAdministratorRole.id
    principalType: 'User'
  }
}

resource aiServices 'Microsoft.CognitiveServices/accounts@2024-04-01-preview' = {
  name: aiServicesName
  location: location
  sku: {
    name: 'S0'
  }
  kind: 'AIServices' // or 'OpenAI'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    customSubDomainName: aiServicesName
    disableLocalAuth: true // Ensures that the service disables key-based authentication
    apiProperties: {
      statisticsEnabled: false
    }
  }
}

// Role assignments to grant user permissions to manage Azure AI Services, including model deployments
resource azureAIDeveloperRole 'Microsoft.Authorization/roleDefinitions@2022-05-01-preview' existing = if (userObjectId != '') {
  name: '64702f94-c441-49e6-a78b-ef80e0188fee'
  scope: resourceGroup()
}

resource azureAIDeveloperRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (userObjectId != '') {
  name: guid(aiServices.id, userObjectId, azureAIDeveloperRole.id)
  scope: aiServices
  properties: {
    principalId: userObjectId
    roleDefinitionId: azureAIDeveloperRole.id
    principalType: 'User'
  }
}

resource storage 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: storageNameCleaned
  location: location
  tags: tags
  sku: {
    name: storageSkuName
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
    allowBlobPublicAccess: false
    allowCrossTenantReplication: false
    allowSharedKeyAccess: false // Ensures that the services disables key-based authentication
    encryption: {
      keySource: 'Microsoft.Storage'
      requireInfrastructureEncryption: false
      services: {
        blob: {
          enabled: true
          keyType: 'Account'
        }
        file: {
          enabled: true
          keyType: 'Account'
        }
        queue: {
          enabled: true
          keyType: 'Service'
        }
        table: {
          enabled: true
          keyType: 'Service'
        }
      }
    }
    isHnsEnabled: false
    isNfsV3Enabled: false
    keyPolicy: {
      keyExpirationPeriodInDays: 7
    }
    largeFileSharesState: 'Disabled'
    minimumTlsVersion: 'TLS1_2'
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Deny'
    }
    supportsHttpsTrafficOnly: true
  }
}

// Role assignments to grant user permissions to create and manage Prompt Flow resources in the Azure AI Hub workspace
resource storageAccountContributorRole 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = if (userObjectId != '') {
  name: '17d1049b-9a84-46fb-8f53-869881c3d3ab'
  scope: resourceGroup()
}

resource storageAccountContributorRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (userObjectId != '') {
  name: guid(storage.id, userObjectId, storageAccountContributorRole.id)
  scope: storage
  properties: {
    principalId: userObjectId
    roleDefinitionId: storageAccountContributorRole.id
    principalType: 'User'
  }
}

resource storageBlobDataContributorRole 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = if (userObjectId != '') {
  name: 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
  scope: resourceGroup()
}

resource storageBlobDataContributorRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (userObjectId != '') {
  name: guid(storage.id, userObjectId, storageBlobDataContributorRole.id)
  scope: storage
  properties: {
    principalId: userObjectId
    roleDefinitionId: storageBlobDataContributorRole.id
    principalType: 'User'
  }
}

resource storageFileDataPrivilegedContributorRole 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = if (userObjectId != '') {
  name: '69566ab7-960f-475b-8e7c-b3118f30c6bd'
  scope: resourceGroup()
}

resource storageFileDataPrivilegedContributorRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (userObjectId != '') {
  name: guid(storage.id, userObjectId, storageFileDataPrivilegedContributorRole.id)
  scope: storage
  properties: {
    principalId: userObjectId
    roleDefinitionId: storageFileDataPrivilegedContributorRole.id
    principalType: 'User'
  }
}

resource storageTableDataContributorRole 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = if (userObjectId != '') {
  name: '0a9a7e1f-b9d0-4cc4-a60d-0319b160aaa3'
  scope: resourceGroup()
}

resource storageTableDataContributorRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (userObjectId != '') {
  name: guid(storage.id, userObjectId, storageTableDataContributorRole.id)
  scope: storage
  properties: {
    principalId: userObjectId
    roleDefinitionId: storageTableDataContributorRole.id
    principalType: 'User'
  }
}

output aiServicesId string = aiServices.id
output aiServicesTarget string = aiServices.properties.endpoint
output storageId string = storage.id
output keyVaultId string = keyVault.id
output containerRegistryId string = containerRegistry.id
output applicationInsightsId string = applicationInsights.id
