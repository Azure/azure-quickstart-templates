// Execute this main file to depoy Azure AI Foundry resources in the basic security configuraiton

// Parameters
@minLength(2)
@maxLength(12)
@description('Name for the AI resource and used to derive name of dependent resources.')
param aiHubName string = 'demo'

@description('Friendly name for your Azure AI resource')
param aiHubFriendlyName string = 'Demo AI resource'

@description('Description of your Azure AI resource dispayed in AI Foundry')
param aiHubDescription string = 'This is an example AI resource for use in Azure AI Foundry.'

@description('Azure region used for the deployment of all resources.')
param location string = resourceGroup().location

@description('Set of tags to apply to all resources.')
param tags object = {}

@description('Specifies the customer managed keyvault Resource Manager ID.')
param cmk_keyvault_id string

@description('Specifies the customer managed keyvault key uri.')
param cmk_keyvault_vault_uri string

@description('Specifies the customer managed keyvault key uri.')
param cmk_keyvault_key_name string

@description('Specifies the customer managed keyvault key version.')
param cmk_keyvault_key_version string

// Variables
var name = toLower('${aiHubName}')

// Create a short, unique suffix, that will be unique to each resource group
var uniqueSuffix = substring(uniqueString(resourceGroup().id), 0, 4) 

var cmk_keyvault_key_uri = '${cmk_keyvault_vault_uri}keys/${cmk_keyvault_key_name}/${cmk_keyvault_key_version}'

// Dependent resources for the Azure Machine Learning workspace
module aiDependencies 'modules/dependent-resources.bicep' = {
  name: 'dependencies-${name}-${uniqueSuffix}-deployment'
  params: {
    location: location
    storageName: 'st${name}${uniqueSuffix}'
    keyvaultName: 'kv-${name}-${uniqueSuffix}'
    applicationInsightsName: 'appi-${name}-${uniqueSuffix}'
    containerRegistryName: 'cr${name}${uniqueSuffix}'
    aiServicesName: 'ais${name}${uniqueSuffix}'
    cmk_keyvault_id: cmk_keyvault_id
    cmk_keyvault_uri: cmk_keyvault_vault_uri
    cmk_keyvault_key_name: cmk_keyvault_key_name
    cmk_keyvault_key_version: cmk_keyvault_key_version
    tags: tags
  }
}

module aiHub 'modules/ai-hub.bicep' = {
  name: 'ai-${name}-${uniqueSuffix}-deployment'
  params: {
    // workspace organization
    aiHubName: 'aih-${name}-${uniqueSuffix}'
    aiHubFriendlyName: aiHubFriendlyName
    aiHubDescription: aiHubDescription
    location: location
    tags: tags

    // dependent resources
    aiServicesId: aiDependencies.outputs.aiservicesID
    aiServicesTarget: aiDependencies.outputs.aiservicesTarget
    applicationInsightsId: aiDependencies.outputs.applicationInsightsId
    containerRegistryId: aiDependencies.outputs.containerRegistryId
    keyVaultId: aiDependencies.outputs.keyvaultId
    storageAccountId: aiDependencies.outputs.storageId

    // encryption configuration
    cmk_keyvault_id: cmk_keyvault_id
    cmk_keyvault_key_uri: cmk_keyvault_key_uri
  }
}

output vaulturi string = cmk_keyvault_vault_uri
output keyuri string = cmk_keyvault_key_uri
