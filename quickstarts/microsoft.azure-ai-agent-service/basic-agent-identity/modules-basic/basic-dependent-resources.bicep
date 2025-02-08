@description('Azure region of the deployment')
param location string = resourceGroup().location

@description('AI services name')
param aiServicesName string

@description('The name of the Key Vault')
param keyvaultName string

@description('Model name for deployment')
param modelName string 

@description('Model format for deployment')
param modelFormat string 

@description('Model version for deployment')
param modelVersion string 

@description('Model deployment SKU name')
param modelSkuName string 

@description('Model deployment capacity')
param modelCapacity int 

@description('Model/AI Resource deployment location')
param modelLocation string 

@description('The AI Service Account full ARM Resource ID. This is an optional field, and if not provided, the resource will be created.')
param aiServiceAccountResourceId string

@description('Name of the storage account')
param storageName string

var storageNameCleaned = replace(storageName, '-', '')

var aiServiceExists = aiServiceAccountResourceId != ''

var aiServiceParts = split(aiServiceAccountResourceId, '/')

resource existingAIServiceAccount 'Microsoft.CognitiveServices/accounts@2024-10-01' existing = if (aiServiceExists) {
  name: aiServiceParts[8]
  scope: resourceGroup(aiServiceParts[2], aiServiceParts[4])
}

resource aiServices 'Microsoft.CognitiveServices/accounts@2024-10-01' = if(!aiServiceExists) {
  name: aiServicesName
  location: modelLocation
  sku: {
    name: 'S0'
  }
  kind: 'AIServices' // or 'OpenAI'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    customSubDomainName: toLower('${toLower(aiServicesName)}')
    apiProperties: {
      statisticsEnabled: false
    }
    publicNetworkAccess: 'Enabled'
  }
}

resource modelDeployment 'Microsoft.CognitiveServices/accounts/deployments@2024-10-01'= if(!aiServiceExists) {
  parent: aiServices
  name: modelName
  sku : {
    capacity: modelCapacity
    name: modelSkuName
  }
  properties: {
    model:{
      name: modelName
      format: modelFormat
      version: modelVersion
    }
  }
}

param noZRSRegions array = ['southindia', 'westus']
param sku object = contains(noZRSRegions, location) ? { name: 'Standard_GRS' } : { name: 'Standard_ZRS' }

resource storage 'Microsoft.Storage/storageAccounts@2023-05-01' =  {
  name: storageNameCleaned
  location: location
  kind: 'StorageV2'
  sku: sku
  properties: {
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
    publicNetworkAccess: 'Enabled'
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Allow'
      virtualNetworkRules: []
    }
    allowSharedKeyAccess: false
  }
}

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' = {
  name: keyvaultName
  location: location
  properties: {
    tenantId: subscription().tenantId
    sku: { family: 'A', name: 'standard' }
    enableSoftDelete: true
    enabledForTemplateDeployment: true
    accessPolicies: []
  }
}

output aiServicesName string =  aiServiceExists ? existingAIServiceAccount.name : aiServicesName
output aiservicesID string = aiServiceExists ? existingAIServiceAccount.id : aiServices.id
output aiservicesTarget string = aiServiceExists ? existingAIServiceAccount.properties.endpoint : aiServices.properties.endpoint
output aiServiceAccountResourceGroupName string = aiServiceExists ? aiServiceParts[4] : resourceGroup().name
output aiServiceAccountSubscriptionId string = aiServiceExists ? aiServiceParts[2] : subscription().subscriptionId 

output storageId string = storage.id
output keyvaultId string = keyVault.id
