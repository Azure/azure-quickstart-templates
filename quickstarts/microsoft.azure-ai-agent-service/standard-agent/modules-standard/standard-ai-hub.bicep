// Creates an Azure AI resource with proxied endpoints for the Azure AI services provider

@description('Azure region of the deployment')
param location string

@description('Tags to add to the resources')
param tags object

@description('AI hub name')
param aiHubName string

@description('AI hub display name')
param aiHubFriendlyName string = aiHubName

@description('AI hub description')
param aiHubDescription string

@description('Resource ID of the key vault resource for storing connection strings')
param keyVaultId string

@description('Resource ID of the storage account resource for storing experimentation outputs')
param storageAccountId string

@description('Model/AI Resource deployment location')
param modelLocation string 

@description('Resource ID of the AI Services resource')
param aiServicesId string

@description('Resource ID of the AI Services endpoint')
param aiServicesTarget string

@description('Name AI Search resource')
param aiSearchName string

@description('Resource ID of the AI Search resource')
param aiSearchId string

@description('Name for capabilityHost.')
param capabilityHostName string = 'caphost1'

var acsConnectionName = '${aiHubName}-connection-AISearch'

var aoaiConnection  = '${aiHubName}-connection-AIServices_aoai'

resource aiHub 'Microsoft.MachineLearningServices/workspaces@2024-07-01-preview' = {
  name: aiHubName
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    // organization
    friendlyName: aiHubFriendlyName
    description: aiHubDescription

    // dependent resources
    keyVault: keyVaultId
    storageAccount: storageAccountId
  }
  kind: 'hub'

  resource aiServicesConnection 'connections@2024-07-01-preview' = {
    name: '${aiHubName}-connection-AIServices'
    properties: {
      category: 'AIServices'
      target: aiServicesTarget
      authType: 'AAD'
      isSharedToAll: true
      metadata: {
        ApiType: 'Azure'
        ResourceId: aiServicesId
        location: modelLocation
      }
    }
  }
  resource hub_connection_azureai_search 'connections@2024-07-01-preview' = {
    name: acsConnectionName
    properties: {
      category: 'CognitiveSearch'
      target: 'https://${aiSearchName}.search.windows.net'
      authType: 'AAD'
      //useWorkspaceManagedIdentity: false
      isSharedToAll: true
      metadata: {
        ApiType: 'Azure'
        ResourceId: aiSearchId
        location: location
      }
    }
  }

  // Resource definition for the capability host
  resource capabilityHost 'capabilityHosts@2024-10-01-preview' = {
    name: '${aiHubName}-${capabilityHostName}'
    properties: {
      capabilityHostKind: 'Agents'
    }
  }
  
}

output aiHubID string = aiHub.id
output aoaiConnectionName string = aoaiConnection
output acsConnectionName string = acsConnectionName
