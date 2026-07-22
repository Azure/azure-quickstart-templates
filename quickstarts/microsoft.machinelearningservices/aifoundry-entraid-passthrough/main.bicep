// Execute this main file to deploy Azure AI Foundry resources with key-less authentication via Microsoft Entra ID.

// Parameters
@minLength(2)
@maxLength(12)
@description('Name for the Azure AI Hub resource and used to derive names of dependent resources.')
param aiHubName string = 'aih-demo'

@description('Friendly name for your Azure AI Hub resource, displayed in the Foundry UI.')
param aiHubFriendlyName string = 'Demo AI resource'

@description('Description of your Azure AI Hub resource, displayed in the Foundry UI.')
param aiHubDescription string = 'This is an example AI resource for use in Azure AI Foundry.'

@description('The object ID of a Microsoft Entra ID users to be granted necessary role assignments to access the Azure AI Hub.')
param userObjectId string = ''

@description('Azure region used for the deployment of all resources.')
param location string = resourceGroup().location

@description('Set of tags to apply to all resources.')
param tags object = {}

// Variables
var name = toLower('${aiHubName}')

// Create a short, unique suffix, that will be unique to each resource group
var uniqueSuffix = substring(uniqueString(resourceGroup().id), 0, 4)

// Dependent resources for the Azure AI Hub workspace
module aiDependencies 'modules/dependent-resources.bicep' = {
  name: 'dependencies-${name}-${uniqueSuffix}-deployment'
  params: {
    location: location
    storageName: 'st${name}${uniqueSuffix}'
    keyVaultName: 'kv-${name}-${uniqueSuffix}'
    applicationInsightsName: 'appi-${name}-${uniqueSuffix}'
    containerRegistryName: 'cr${name}${uniqueSuffix}'
    aiServicesName: 'ais${name}${uniqueSuffix}'
    userObjectId: userObjectId
    tags: tags
  }
}

module aiHub 'modules/ai-hub.bicep' = {
  name: 'ai-${name}-${uniqueSuffix}-deployment'
  params: {
    // workspace organization
    aiHubName: 'ai-${name}-${uniqueSuffix}'
    aiHubFriendlyName: aiHubFriendlyName
    aiHubDescription: aiHubDescription
    userObjectId: userObjectId
    location: location
    tags: tags

    // dependent resources
    aiServicesId: aiDependencies.outputs.aiServicesId
    aiServicesTarget: aiDependencies.outputs.aiServicesTarget
    applicationInsightsId: aiDependencies.outputs.applicationInsightsId
    containerRegistryId: aiDependencies.outputs.containerRegistryId
    keyVaultId: aiDependencies.outputs.keyVaultId
    storageAccountId: aiDependencies.outputs.storageId
  }
}
