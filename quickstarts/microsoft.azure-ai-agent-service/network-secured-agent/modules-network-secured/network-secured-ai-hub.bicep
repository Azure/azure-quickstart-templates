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

@description('Resource ID of the AI Services resource')
param aiServicesId string
@description('Resource ID of the AI Services endpoint')
param aiServicesTarget string
@description('Name AI Services resource')
param aiServicesName string
@description('Resource Group name of the AI Services resource')
param aiServiceAccountResourceGroupName string
@description('Subscription ID of the AI Services resource')
param aiServiceAccountSubscriptionId string

@description('Name AI Search resource')
param aiSearchName string
@description('Resource ID of the AI Search resource')
param aiSearchId string
param aiSearchServiceResourceGroupName string
param aiSearchServiceSubscriptionId string
@description('Name for capabilityHost.')
param capabilityHostName string = 'caphost1'

param uaiName string

param subnetId string

param aiHubExists bool = false

var acsConnectionName = '${aiHubName}-connection-AISearch'

var aoaiConnection  = '${aiHubName}-connection-AIServices_aoai'
resource userAssignedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing = {
  name: uaiName
}
var userAssignedIdentities = json('{\'${userAssignedIdentity.id}\': {}}')

resource aiServices 'Microsoft.CognitiveServices/accounts@2023-05-01' existing = {
  name: aiServicesName
  scope: resourceGroup(aiServiceAccountSubscriptionId, aiServiceAccountResourceGroupName)
}
resource searchService 'Microsoft.Search/searchServices@2023-11-01' existing = {
  name: aiSearchName
  scope: resourceGroup(aiSearchServiceSubscriptionId, aiSearchServiceResourceGroupName)
}


// Documentation: https://learn.microsoft.com/en-us/azure/templates/microsoft.machinelearningservices/workspaces?tabs=bicep
resource aiHub 'Microsoft.MachineLearningServices/workspaces@2024-10-01-preview' = if(!aiHubExists) {
  name: aiHubName
  location: location
  kind: 'hub'
  tags: tags
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: userAssignedIdentities
  }
  properties: {
    // organization
    friendlyName: aiHubFriendlyName
    description: aiHubDescription
    primaryUserAssignedIdentity: userAssignedIdentity.id

    // dependent resources
    //allowPublicAccessWhenBehindVnet: false
    keyVault: keyVaultId
    storageAccount: storageAccountId
  }
  

  // Documentation: https://learn.microsoft.com/en-us/azure/templates/microsoft.machinelearningservices/workspaces/connections?tabs=bicep
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
        location: aiServices.location
      }
    }
  }
  resource hub_connection_azureai_search 'connections@2024-07-01-preview' = {
    name: acsConnectionName
    properties: {
      category: 'CognitiveSearch'
      target: 'https://${aiSearchName}.search.windows.net'
      authType: 'AAD'
      isSharedToAll: true
      metadata: {
        ApiType: 'Azure'
        ResourceId: aiSearchId
        location: searchService.location
      }
    }
  }

  // Resource definition for the capability host
  // Documentation: https://learn.microsoft.com/en-us/azure/templates/microsoft.machinelearningservices/workspaces/capabilityhosts?tabs=bicep
  resource capabilityHost 'capabilityHosts@2024-10-01-preview' = {
    name: capabilityHostName
    properties: {
      customerSubnet: subnetId
      capabilityHostKind: 'Agents'
    }
  }
  dependsOn: [
    userAssignedIdentity
    aiServices
    //searchService
  ]
}

output aiHubID string = aiHub.id
output aoaiConnectionName string = aoaiConnection
output acsConnectionName string = acsConnectionName
