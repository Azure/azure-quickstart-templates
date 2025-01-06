// Existing Resource Overrides
var storageOverride = ''
var keyVaultOverride = ''
var aiServicesOverride = ''
var aiSearchOverride = ''
var userAssignedIdentityOverride = ''


/* ---------------------------------- Deployment Identifiers ---------------------------------- */

param deploymentName string = 'network-secured-agent'
// Create a short, unique suffix, that will be unique to each resource group
param deploymentTimestamp string = utcNow('yyyyMMddHHmmss')
param uniqueSuffix string = substring(uniqueString('${resourceGroup().id}-${deploymentTimestamp}'), 0, 4)

/* ---------------------------------- Default Parameters if Overrides Not Set ---------------------------------- */

// Parameters
@minLength(2)
@maxLength(12)
@description('Name for the AI resource and used to derive name of dependent resources.')
param defaultAiHubName string = 'hub-demo'

@description('Friendly name for your Hub resource')
param defaultAiHubFriendlyName string = 'Agents Hub resource'

@description('Description of your Azure AI resource displayed in AI studio')
param defaultAiHubDescription string = 'This is an example AI resource for use in Azure AI Studio.'

@description('Name for the AI project resources.')
param defaultAiProjectName string = 'project-demo'

@description('Friendly name for your Azure AI resource')
param defaultAiProjectFriendlyName string = 'Agents Project resource'

@description('Description of your Azure AI resource displayed in AI studio')
param defaultAiProjectDescription string = 'This is an example AI Project resource for use in Azure AI Studio.'

@description('Azure region used for the deployment of all resources.')
param location string = resourceGroup().location

@description('Set of tags to apply to all resources.')
param tags object = {}

@description('Name of the Azure AI Search account')
param defaultAiSearchName string = 'agent-ai-search'

@description('Name for capabilityHost.')
param defaultCapabilityHostName string = 'caphost1'

@description('Name of the storage account')
param defaultStorageName string = 'agentstorage'

@description('Name of the Azure AI Services account')
param defaultAiServicesName string = 'agent-ai-service'

@description('Model name for deployment')
param modelName string = 'o1-preview'

@description('Model format for deployment')
param modelFormat string = 'OpenAI'

@description('Model version for deployment')
param modelVersion string = '2024-09-12'

@description('Model deployment SKU name')
param modelSkuName string = 'GlobalStandard'

@description('Model deployment capacity')
param modelCapacity int = 1

@description('Model deployment location. If you want to deploy an Azure AI resource/model in different location than the rest of the resources created.')
param modelLocation string = 'westus2'

// Variables
//var name = toLower('${aiHubName}')
//var projectName = toLower('${aiProjectName}')


/* ---------------------------------- Create User Assigned Identity ---------------------------------- */

@description('The name of User Assigned Identity')
param userAssignedIdentityDefaultName string = 'secured-agents-identity-${uniqueSuffix}'
var uaiName = (userAssignedIdentityOverride == '') ? userAssignedIdentityDefaultName : userAssignedIdentityOverride

module identity 'modules-network-secured/network-secured-identity.bicep' = {
  name: '${deploymentName}-${uniqueSuffix}--identity'
  params: {
    location: location
    userAssignedIdentityName: uaiName
    uaiExists: userAssignedIdentityOverride != ''
  }
}


/* ---------------------------------- Create AI Assistant Dependent Resources ---------------------------------- */

//var storageName = (storageOverride == '') ? '${defaultStorageName}${uniqueSuffix}' : storageOverride
//var keyVaultName = (keyVaultOverride == '') ? 'kv-${defaultAiHubName}-${uniqueSuffix}' : keyVaultOverride
var aiServiceName = (aiServicesOverride == '') ? '${defaultAiServicesName}${uniqueSuffix}' : aiServicesOverride
var aiSearchName = (aiSearchOverride == '') ? '${defaultAiSearchName}${uniqueSuffix}' : aiSearchOverride

//resource existingStorage 'Microsoft.Storage/storageAccounts@2022-05-01' existing = if(storageOverride != '') {
//  name: storageName
//  scope: resourceGroup()
//}
//
//resource existingKeyVault 'Microsoft.KeyVault/vaults@2022-07-01' existing = if(keyVaultOverride != '') {
//  name: keyVaultName
//  scope: resourceGroup()
//}
resource existingAiServices 'Microsoft.CognitiveServices/accounts@2024-06-01-preview' existing = if(aiServicesOverride != '') {
  name: aiServiceName
  scope: resourceGroup()
}

resource existingAiSearch 'Microsoft.Search/searchServices@2024-06-01-preview' existing = if(aiSearchOverride != '') {
  name: aiSearchName
  scope: resourceGroup()
}

var storageNameClean = '${defaultStorageName}${uniqueSuffix}'
// Dependent resources for the Azure Machine Learning workspace
module aiDependencies 'modules-network-secured/network-secured-dependent-resources.bicep' = {
  name: '${deploymentName}-${uniqueSuffix}--dependencies'
  params: {
    suffix: uniqueSuffix
    storageName: storageNameClean
    keyvaultName: 'kv-${defaultAiHubName}-${uniqueSuffix}'
    aiServicesName: aiServiceName
    aiSearchName: aiSearchName
    tags: tags
    location: location

    aiServicesExists: aiServicesOverride != ''
    aiSearchExists: aiSearchOverride != ''

     // Model deployment parameters
     modelName: modelName
     modelFormat: modelFormat
     modelVersion: modelVersion
     modelSkuName: modelSkuName
     modelCapacity: modelCapacity  
     modelLocation: modelLocation

     userAssignedIdentityName: identity.outputs.uaiName
    }
}



module aiHub 'modules-network-secured/network-secured-ai-hub.bicep' = {
  name: '${deploymentName}-${uniqueSuffix}--hub'
  params: {
    // workspace organization
    aiHubName: '${defaultAiHubName}-${uniqueSuffix}'
    aiHubFriendlyName: defaultAiHubFriendlyName
    aiHubDescription: defaultAiHubDescription
    location: location
    tags: tags
    capabilityHostName: '${defaultAiHubName}-${uniqueSuffix}-${defaultCapabilityHostName}'

    aiSearchName: aiDependencies.outputs.aiSearchName
    aiSearchId: aiDependencies.outputs.aisearchID
    aiSearchServiceResourceGroupName: aiDependencies.outputs.aiSearchServiceResourceGroupName
    aiSearchServiceSubscriptionId: aiDependencies.outputs.aiSearchServiceSubscriptionId

    aiServicesName: aiDependencies.outputs.aiServicesName
    aiServicesId: aiDependencies.outputs.aiservicesID
    aiServicesTarget: aiDependencies.outputs.aiservicesTarget
    aiServiceAccountResourceGroupName:aiDependencies.outputs.aiServiceAccountResourceGroupName
    aiServiceAccountSubscriptionId:aiDependencies.outputs.aiServiceAccountSubscriptionId
    
    keyVaultId: aiDependencies.outputs.keyvaultId
    storageAccountId: aiDependencies.outputs.storageId
    subnetId: aiDependencies.outputs.agentSubnetId
    
    uaiName: identity.outputs.uaiName
  }
}

resource storage 'Microsoft.Storage/storageAccounts@2022-05-01' existing = {
  name: aiDependencies.outputs.storageAccountName
  scope: resourceGroup()
}

resource aiServices 'Microsoft.CognitiveServices/accounts@2023-05-01' existing = {
  name: aiDependencies.outputs.aiServicesName
  scope: resourceGroup(aiDependencies.outputs.aiServiceAccountSubscriptionId, aiDependencies.outputs.aiServiceAccountResourceGroupName)
}

resource aiSearch 'Microsoft.Search/searchServices@2023-11-01' existing = {
  name: aiDependencies.outputs.aiSearchName
  scope: resourceGroup(aiDependencies.outputs.aiSearchServiceSubscriptionId, aiDependencies.outputs.aiSearchServiceResourceGroupName)
}

module privateEndpointAndDNS 'modules-network-secured/private-endpoint-and-dns.bicep' = {
  name: '${deploymentName}-${uniqueSuffix}--private-endpoint'
  params: {
    aiServicesName: aiDependencies.outputs.aiServicesName
    aiSearchName: aiDependencies.outputs.aiSearchName
    aiStorageId: aiDependencies.outputs.storageId
    storageName: storageNameClean
    vnetName: aiDependencies.outputs.virtualNetworkName
    cxSubnetName: aiDependencies.outputs.cxSubnetName
    suffix: uniqueSuffix
  }
  dependsOn: [
    aiServices
    aiSearch
    storage
  ]
}

module aiProject 'modules-network-secured/network-secured-ai-project.bicep' = {
  name: '${deploymentName}-${uniqueSuffix}--project'
  params: {
    // workspace organization
    aiProjectName: '${defaultAiProjectName}-${uniqueSuffix}'
    aiProjectFriendlyName: defaultAiProjectFriendlyName
    aiProjectDescription: defaultAiProjectDescription
    location: location
    tags: tags
    
    // dependent resources
    capabilityHostName: defaultCapabilityHostName

    aiHubId: aiHub.outputs.aiHubID
    acsConnectionName: aiHub.outputs.acsConnectionName
    aoaiConnectionName: aiHub.outputs.aoaiConnectionName
    uaiName: identity.outputs.uaiName
  }
}

module aiServiceRoleAssignments 'modules-network-secured/ai-service-role-assignments.bicep' = {
  name: '${deploymentName}-${uniqueSuffix}--AiServices-RA'
  scope: resourceGroup()
  params: {
    aiServicesName: aiDependencies.outputs.aiServicesName
    aiProjectPrincipalId: identity.outputs.uaiPrincipalId
    aiProjectId: aiProject.outputs.aiProjectResourceId
  }
}

module aiSearchRoleAssignments 'modules-network-secured/ai-search-role-assignments.bicep' = {
  name: '${deploymentName}-${uniqueSuffix}--AiSearch-RA'
  scope: resourceGroup()
  params: {
    aiSearchName: aiDependencies.outputs.aiSearchName
    aiProjectPrincipalId: identity.outputs.uaiPrincipalId
    aiProjectId: aiProject.outputs.aiProjectResourceId
  }
}

output PROJECT_CONNECTION_STRING string = aiProject.outputs.projectConnectionString
