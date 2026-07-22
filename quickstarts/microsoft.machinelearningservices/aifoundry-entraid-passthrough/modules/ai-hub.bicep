// Creates an Azure AI Hub resource with proxied endpoints for the Azure AI services provider

@description('Azure region used for the deployment of the Azure AI Hub.')
param location string

@description('Set of tags to apply to the Azure AI Hub.')
param tags object

@description('Name for the Azure AI Hub resource.')
param aiHubName string

@description('Friendly name for your Azure AI Hub resource, displayed in the Foundry UI.')
param aiHubFriendlyName string = aiHubName

@description('Description of your Azure AI Hub resource, displayed in the Foundry UI.')
param aiHubDescription string

@description('Resource ID of the Azure Application Insights resource for storing diagnostics logs.')
param applicationInsightsId string

@description('Resource ID of the Azure Container Registry resource for storing Docker images for models.')
param containerRegistryId string

@description('Resource ID of the Azure Key Vault resource for storing connection strings.')
param keyVaultId string

@description('Resource ID of the Azure Storage Account resource for storing workspace data.')
param storageAccountId string

@description('Resource ID of the Azure AI Services resource for connecting AI capabilities.')
param aiServicesId string

@description('Target endpoint for the Azure AI Services resource to link to the Azure AI Hub.')
param aiServicesTarget string

@description('The object ID of a Microsoft Entra ID users to be granted necessary role assignments to access the Azure AI Hub.')
param userObjectId string = ''

resource aiHub 'Microsoft.MachineLearningServices/workspaces@2024-04-01-preview' = {
  name: aiHubName
  location: location
  tags: tags
  kind: 'Hub'
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
    applicationInsights: applicationInsightsId
    containerRegistry: containerRegistryId
    systemDatastoresAuthMode: 'identity'
  }

  resource aiServicesConnection 'connections@2024-04-01-preview' = {
    name: '${aiHubName}-connection'
    properties: {
      category: 'AIServices'
      target: aiServicesTarget
      authType: 'AAD'
      isSharedToAll: true
      metadata: {
        ApiType: 'Azure'
        ResourceId: aiServicesId
      }
    }
  }
}

resource azureMLDataScientistRole 'Microsoft.Authorization/roleDefinitions@2022-05-01-preview' existing = if (userObjectId != '') {
  name: 'f6c7c914-8db3-469d-8ca1-694a8f32e121'
  scope: resourceGroup()
}

resource azureMLDataScientistRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (userObjectId != '') {
  name: guid(aiHub.id, userObjectId, azureMLDataScientistRole.id)
  scope: aiHub
  properties: {
    principalId: userObjectId
    roleDefinitionId: azureMLDataScientistRole.id
    principalType: 'User'
  }
}

output aiHubId string = aiHub.id
