// Execute this main file to deploy Azure AI Foundry resources in the basic security configuration

// Parameters
@minLength(2)
@maxLength(12)
@description('Name for the AI resource and used to derive name of dependent resources.')
param aiHubName string = 'demo'

@description('Friendly name for your Azure AI resource')
param aiHubFriendlyName string = 'Demo AI resource'

@description('Description of your Azure AI resource displayed in AI Foundry')
param aiHubDescription string = 'This is an example AI resource for use in Azure AI Foundry.'

@description('Set of tags to apply to all resources.')
param tags object = {}

@description('Resource name of the virtual network to deploy the resource into.')
param vnetName string

@description('Resource group name of the virtual network to deploy the resource into.')
param vnetRgName string

@description('Name of the subnet to deploy into.')
param subnetName string

@description('The location into which the resources should be deployed.')
param location string = resourceGroup().location

@minLength(2)
@maxLength(10)
@description('Prefix for all resource names.')
param prefix string

@description('Determines whether or not to use credentials for the system datastores of the workspace workspaceblobstore and workspacefilestore. The default value is accessKey, in which case, the workspace will create the system datastores with credentials. If set to identity, the workspace will create the system datastores with no credentials.')
@allowed([
  'identity'
  'accesskey'
])
param systemDatastoresAuthMode string = 'identity'

@description('Determines whether to use an API key or Azure Active Directory (AAD) for the AI service connection authentication. The default value is apiKey.')
@allowed([
  'ApiKey'
  'AAD'
])
param connectionAuthMode string = 'ApiKey'

// Variables
var name = toLower('${aiHubName}')

// Create a short, unique suffix, that will be unique to each resource group
var uniqueSuffix = substring(uniqueString(resourceGroup().id), 0, 7)

var vnetResourceId = '/subscriptions/${subscription().subscriptionId}/resourceGroups/${vnetRgName}/providers/Microsoft.Network/virtualNetworks/${vnetName}'
var subnetResourceId = '${vnetResourceId}/subnets/${subnetName}'

// Dependent resources for the Azure Machine Learning workspace
module aiDependencies 'modules/dependent-resources.bicep' = {
  name: 'dependencies-${name}-${uniqueSuffix}-deployment'
  params: {
    location: location
    tags: tags
    subnetResourceId: subnetResourceId
    vnetResourceId: vnetResourceId
    prefix: prefix
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

    //metadata
    uniqueSuffix: uniqueSuffix

    //network related
    vnetResourceId: vnetResourceId
    subnetResourceId: subnetResourceId

    // dependent resources
    aiServicesId: aiDependencies.outputs.aiservicesID
    aiServicesTarget: aiDependencies.outputs.aiservicesTarget
    applicationInsightsId: aiDependencies.outputs.applicationInsightsId
    containerRegistryId: aiDependencies.outputs.containerRegistryId
    keyVaultId: aiDependencies.outputs.keyvaultId
    storageAccountId: aiDependencies.outputs.storageId
    searchId: aiDependencies.outputs.searchServiceId
    searchTarget: aiDependencies.outputs.searchServiceTarget

    //configuration settings
    systemDatastoresAuthMode: systemDatastoresAuthMode
    connectionAuthMode: connectionAuthMode

  }
}

// Assignment of roles necessary for template usage
module roleAssignments 'modules/role-assignments.bicep' = {
  name: 'role-assignments-${name}-${uniqueSuffix}-deployment'
  params: {
    aiHubName: aiHub.outputs.aiHubName
    aiHubPrincipalId: aiHub.outputs.aiHubPrincipalId
    aiServicesPrincipalId: aiDependencies.outputs.aiServicesPrincipalId
    aiServicesName: aiDependencies.outputs.aiservicesName
    searchServicePrincipalId: aiDependencies.outputs.searchServicePrincipalId
    searchServiceName: aiDependencies.outputs.searchServiceName
    storageName: aiDependencies.outputs.storageName
  }
  dependsOn:[
    aiHub
  ]
}
