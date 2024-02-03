// Creates an Azure AI resource with proxied endpoints for the Azure AI services provider

@description('Azure region of the deployment')
param location string

@description('Tags to add to the resources')
param tags object

@description('AI resource name')
param aiHubName string

@description('AI resource display name')
param aiHubFriendlyName string = aiHubName

@description('AI resource description')
param aiHubDescription string

@description('Resource ID of the application insights resource for storing diagnostics logs')
param applicationInsightsId string

@description('Resource ID of the container registry resource for storing docker images')
param containerRegistryId string

@description('Resource ID of the key vault resource for storing connection strings')
param keyVaultId string

@description('Resource ID of the storage account resource for storing experimentation outputs')
param storageAccountId string

@description('Resource ID of the AI services base model provider. Allowed kinds: OpenAI, AIServices')
param endpointResourceId string = 'null'

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

resource aiResource 'Microsoft.MachineLearningServices/workspaces@2023-08-01-preview' = {
  name: aiHubName
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    // workspace organization
    friendlyName: aiHubFriendlyName
    description: aiHubDescription

    // dependent resources
    keyVault: keyVaultId
    storageAccount: storageAccountId
    applicationInsights: applicationInsightsId
    containerRegistry: containerRegistryId

    //encryption settings
    encryption: {
      status: encryption_status
      keyVaultProperties: {
        keyVaultArmId: cmk_keyvault_id
        keyIdentifier: cmk_keyvault_key_uri
      }
    }
  }
  kind: 'hub'

  #disable-next-line BCP081
  resource azureOpenAIEndpoint 'endpoints@2023-08-01-preview' = {
    name: 'Azure.OpenAI'
    properties: {
      name: 'Azure.OpenAI'
      endpointType: 'Azure.OpenAI'
      associatedResourceId: endpointResourceId != 'null' ? endpointResourceId : null
    }
  }

  #disable-next-line BCP081
  resource contentSafetyEndpoint 'endpoints@2023-08-01-preview' = {
    name: 'Azure.ContentSafety'
    properties: {
      name: 'Azure.ContentSafety'
      endpointType: 'Azure.ContentSafety'
      associatedResourceId: endpointResourceId != 'null' ? endpointResourceId : null
    }
  }

  #disable-next-line BCP081
  resource speechEndpoint 'endpoints@2023-08-01-preview' = {
    name: 'Azure.Speech'
    properties: {
      name: 'Azure.Speech'
      endpointType: 'Azure.Speech'
      associatedResourceId: endpointResourceId != 'null' ? endpointResourceId : null
    }
  }
}

output aiResourceID string = aiResource.id
