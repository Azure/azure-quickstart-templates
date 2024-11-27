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

@description('Resource ID of the storage account resource for storing experimentation outputs')
param storageAccountId string

@description('Resource ID of the AI Services resource')
param aiServicesId string

@description('Resource ID of the AI Services endpoint')
param aiServicesTarget string

@description('Model/AI Resource deployment location')
param modelLocation string 

@description('The object ID of a Microsoft Entra ID users to be granted necessary role assignments to access the Azure AI Hub.')
param userObjectId string = ''

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
    storageAccount: storageAccountId
  }
  kind: 'hub'

  resource aiServicesConnection 'connections@2024-07-01-preview' = {
    name: '${aiHubName}-connection-AIServices'
    properties: {
      category: 'AIServices'
      target: aiServicesTarget
      // useWorkspaceManagedIdentity: true
      authType: 'ApiKey'
      isSharedToAll: true
      credentials: {
        key: '${listKeys(aiServicesId, '2022-10-01').key1}'
      }
      metadata: {
        ApiType: 'Azure'
        ResourceId: aiServicesId
        Location: modelLocation
      }
    }
  }
}

resource azureAIDeveloperRole 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = if (userObjectId != '') {
  name: '64702f94-c441-49e6-a78b-ef80e0188fee'
  scope: resourceGroup()
}

resource azureAIDeveloperRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (userObjectId != '') {
  scope: aiHub
  name: guid(userObjectId, azureAIDeveloperRole.id, aiHub.id)
  properties: {
    principalId: userObjectId
    roleDefinitionId: azureAIDeveloperRole.id
    principalType: 'User'
  }
}

output aiHubID string = aiHub.id
