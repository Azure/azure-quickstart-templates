// Execute this main file to depoy Azure AI studio resources in the basic security configuraiton

// Parameters
@minLength(2)
@maxLength(12)
@description('Name for the AI resource and used to derive name of dependent resources.')
param aiResourceName string = 'air-demo'

@description('Friendly name for your Azure AI resource')
param aiResourceFriendlyName string = 'Demo AI resource'

@description('Description of your Azure AI resource dispayed in AI studio')
param aiResourceDescription string = 'This is an example AI resource for use in Azure AI Studio.'

@description('Azure region used for the deployment of all resources.')
param location string = resourceGroup().location

@description('Set of tags to apply to all resources.')
param tags object = {}

@description('Specifies whether to encrypt with the customer managed key.')
@allowed([
  'Enabled'
  'Disabled'
])
param encryption_status string = 'Enabled'

@description('Specifies the customer managed keyvault Resource Manager ID.')
param cmk_keyvault_id string

@description('Specifies the customer managed keyvault key uri.')
param cmk_keyvault_key_name string

@description('Specifies the customer managed keyvault key uri.')
param cmk_keyvault_key_uri string

// Variables
var name = toLower('${aiResourceName}')

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
    cmk_keyvault_id: cmk_keyvault_id
    cmk_keyvault_key_name: cmk_keyvault_key_name
  }
}

module aiResource 'modules/ai-hub.bicep' = {
  name: 'ai-${name}-${uniqueSuffix}-deployment'
  params: {
    // workspace organization
    aiHubName: 'ai-${name}-${uniqueSuffix}'
    aiHubFriendlyName: aiResourceFriendlyName
    aiHubDescription: aiResourceDescription
    location: location
    tags: tags

    // dependent resources
    applicationInsightsId: aiDependencies.outputs.applicationInsightsId
    containerRegistryId: aiDependencies.outputs.containerRegistryId
    keyVaultId: aiDependencies.outputs.keyvaultId
    storageAccountId: aiDependencies.outputs.storageId
    endpointResourceId: aiDependencies.outputs.aiServicesId

    // encryption configuration
    encryption_status: encryption_status
    cmk_keyvault_id: cmk_keyvault_id
    cmk_keyvault_key_uri: cmk_keyvault_key_uri
  }
}
