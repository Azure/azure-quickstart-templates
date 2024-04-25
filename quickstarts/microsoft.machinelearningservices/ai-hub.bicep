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

@description('Resource ID of the application insights resource for storing diagnostics logs')
param applicationInsightsId string

@description('Resource ID of the container registry resource for storing docker images')
param containerRegistryId string

@description('Resource ID of the key vault resource for storing connection strings')
param keyVaultId string

@description('Resource ID of the storage account resource for storing experimentation outputs')
param storageAccountId string

@description('Resource ID of the AI Services resource')
param aiServicesId string

@description('Resource ID of the AI Services endpoint')
param aiServicesTarget string

@description('Resource ID of the virtual network')
param virtualNetworkId string

@description('Resource ID of the subnet resource')
param subnetId string

@description('AI Hub private link endpoint name')
param aiInboundPrivateEndpoint string

resource aiHub 'Microsoft.MachineLearningServices/workspaces@2023-08-01-preview' = {
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
    applicationInsights: applicationInsightsId
    containerRegistry: containerRegistryId

    //network isolations
    managedNetwork: {
      isolationMode: 'AllowOnlyApprovedOutbound' //or 'AllowInternetOutbound'
      //add outboundRules as needed
    }
    v1LegacyMode: false

    //inbound access managed vnet
    publicNetworkAccess: 'Disabled'
  }
  kind: 'hub'

  resource aiServicesConnection 'connections@2024-01-01-preview' = {
    name: '${aiHubName}-connection-AzureOpenAI'
    properties: {
      category: 'AzureOpenAI'
      target: aiServicesTarget
      authType: 'ApiKey'
      isSharedToAll: true
      credentials: {
        key: '${listKeys(aiServicesId, '2021-10-01').key1}'
      }
      metadata: {
        ApiType: 'Azure'
        ResourceId: aiServicesId
      }
    }
  }
}

module aiPrivateEndpoint 'ai-networking.bicep' = {
  name: 'aiInboundPrivateEndpoint'
  scope: resourceGroup()
  params: {
    location: location
    tags: tags
    virtualNetworkId: virtualNetworkId
    workspaceArmId: aiHub.id
    subnetId: subnetId
    aiInboundPrivateEndpoint: aiInboundPrivateEndpoint
  }
}


output aiHubID string = aiHub.id
