@description('AI Hub Name')
param aiHubName string

@description('AI Hub Id')
param aiHubPrincipalId string

@description('AI Services Name')
param aiServicesName string

@description('AI Services Id')
param aiServicesPrincipalId string

@description('Search Service Name')
param searchServiceName string

@description('Search Service Id')
param searchServicePrincipalId string

@description('Storage Name')
param storageName string

var role = {
  SearchIndexDataContributor : '8ebe5a00-799e-43f5-93ac-243d3dce84a7'
  SearchServiceContributor : '7ca78c08-252a-4471-8644-bb5ff32d4ba0'
  StorageBlobDataReader : '2a2b9908-6ea1-4ae2-8e65-a410df84e7d1'
  StorageBlobDataContributor : 'ba92f5b4-2d11-453d-a403-e96b0029c9fe' 
  CognitiveServicesOpenAiContributor : 'a001fd3d-188f-4b5d-821b-7da978bf7442'
}

resource searchService 'Microsoft.Search/searchServices@2023-11-01' existing = {
  name: searchServiceName
}

resource aiServices 'Microsoft.CognitiveServices/accounts@2023-05-01' existing = {
  name: aiServicesName
}

resource storage 'Microsoft.Storage/storageAccounts@2023-01-01' existing = {
  name: storageName
}

resource aiHub 'Microsoft.MachineLearningServices/workspaces@2024-10-01-preview' existing = {
  name: aiHubName
}

resource searchIndexDataContributor 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, 'SearchIndexDataContributor')
  scope: searchService
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', role.SearchIndexDataContributor)
    principalId: aiServicesPrincipalId
    principalType: 'ServicePrincipal'
  }
}

resource searchServiceContributor 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, 'SearchServiceContributor')
  scope: searchService
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', role.SearchServiceContributor)
    principalId: aiServicesPrincipalId
    principalType: 'ServicePrincipal'
  }
}

resource storageBlobDataContributorAI 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, 'StorageBlobDataContributorAI')
  scope: storage
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', role.StorageBlobDataContributor)
    principalId: aiServicesPrincipalId
    principalType: 'ServicePrincipal'
  }
}

resource cognitiveServicesOpenAiContributor 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, 'CognitiveServicesOpenAiContributor')
  scope: aiServices
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', role.CognitiveServicesOpenAiContributor)
    principalId: searchServicePrincipalId
    principalType: 'ServicePrincipal'
  }
}

resource storageBlobDataContributorSearch 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, 'StorageBlobDataContributorSearch')
  scope: storage
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', role.StorageBlobDataContributor)
    principalId: searchServicePrincipalId
    principalType: 'ServicePrincipal'
  }
}

resource aiHubReaderRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, 'StorageBlobDataReaderAIHub')
  scope: aiHub
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', role.StorageBlobDataReader)
    principalId: aiHubPrincipalId
    principalType: 'ServicePrincipal'
  }
}
