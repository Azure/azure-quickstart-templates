// Execute this main file to configure Azure AI studio basics

// Parameters
@minLength(2)
@maxLength(10)
@description('Name for the deployment.')
param deploymentName string = 'demo'

@description('Azure region used for the deployment of all resources.')
param location string = resourceGroup().location

@description('Set of tags to apply to all resources.')
param tags object = {}

// Variables
var name = toLower('${deploymentName}')

// Create a short, unique suffix, that will be unique to each resource group
var uniqueSuffix = substring(uniqueString(resourceGroup().id), 0, 4)

// Dependent resources for the Azure Machine Learning workspace
module aiDependencies 'modules/dependent-resources.bicep' = {
  name: 'dependencies-${name}-${uniqueSuffix}-deployment'
  params: {
    location: location
    storageName: 'st${name}${uniqueSuffix}'
    keyvaultName: 'kv-${name}-${uniqueSuffix}'
    applicationInsightsName: 'appi-${name}-${uniqueSuffix}'
    containerRegistryName: 'cr${name}${uniqueSuffix}'
    tags: tags
  }
}

module aiResource 'modules/ai-resource.bicep' = {
  name: 'ai-${name}-${uniqueSuffix}-deployment'
  params: {
    // workspace organization
    aiResourceName: 'mlw-${name}-${uniqueSuffix}'
    aiResourceFriendlyName: 'Private link endpoint sample workspace'
    aiResourceDescription: 'This is an example workspace having a private link endpoint.'
    location: location
    tags: tags

    // dependent resources
    applicationInsightsId: aiDependencies.outputs.applicationInsightsId
    containerRegistryId: aiDependencies.outputs.containerRegistryId
    keyVaultId: aiDependencies.outputs.keyvaultId
    storageAccountId: aiDependencies.outputs.storageId
    
  }
  dependsOn: [
    aiDependencies
  ]
}
