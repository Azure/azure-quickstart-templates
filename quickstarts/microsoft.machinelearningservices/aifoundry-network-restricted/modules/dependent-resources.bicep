// Creates Azure dependent resources for Azure AI Foundry
@minLength(2)
@maxLength(10)
@description('Prefix for all resource names.')
param prefix string

@description('Azure region of the deployment')
param location string

@description('Tags to add to the resources')
param tags object = {}

@description('Subnet Id to deploy into.')
param subnetResourceId string

@description('Resource Id of the virtual network to deploy the resource into.')
param vnetResourceId string

// Variables
var name = toLower('${prefix}')

// Create a short, unique suffix, that will be unique to each resource group
var uniqueSuffix = substring(uniqueString(resourceGroup().id), 0, 4)

module applicationInsights 'dependent/applicationinsights.bicep' = {
  name: 'appi-${name}-${uniqueSuffix}-deployment'
  params: {
    location: location
    applicationInsightsName: 'appi-${name}-${uniqueSuffix}'
    logAnalyticsWorkspaceName: 'ws-${name}-${uniqueSuffix}'
    tags: tags
  }
}

// Dependent resources for the Azure Machine Learning workspace
module keyvault 'dependent/keyvault.bicep' = {
  name: 'kv-${name}-${uniqueSuffix}-deployment'
  params: {
    location: location
    keyvaultName: 'kv-${name}-${uniqueSuffix}'
    keyvaultPleName: 'ple-${name}-${uniqueSuffix}-kv'
    subnetId: subnetResourceId
    virtualNetworkId: vnetResourceId
    tags: tags
  }
}

module containerRegistry 'dependent/containerregistry.bicep' = {
  name: 'cr${name}${uniqueSuffix}-deployment'
  params: {
    location: location
    containerRegistryName: 'cr${name}${uniqueSuffix}'
    containerRegistryPleName: 'ple-${name}-${uniqueSuffix}-cr'
    subnetId: subnetResourceId
    virtualNetworkId: vnetResourceId
    tags: tags
  }
}

module aiServices 'dependent/aiservices.bicep' = {
  name: 'ai${name}${uniqueSuffix}-deployment'
  params: {
    location: location
    aiServiceName: 'ai${name}${uniqueSuffix}'
    aiServicesPleName: 'ple-${name}-${uniqueSuffix}-ais'
    subnetId: subnetResourceId
    virtualNetworkId: vnetResourceId
    tags: tags
  }
}

module storage 'dependent/storage.bicep' = {
  name: 'st${name}${uniqueSuffix}-deployment'
  params: {
    location: location
    storageName: 'st${name}${uniqueSuffix}'
    storagePleBlobName: 'ple-${name}-${uniqueSuffix}-st-blob'
    storagePleFileName: 'ple-${name}-${uniqueSuffix}-st-file'
    storageSkuName: 'Standard_LRS'
    subnetId: subnetResourceId
    virtualNetworkId: vnetResourceId
    tags: tags
  }
}

module searchService 'dependent/aisearch.bicep' = {
  name: 'search${name}${uniqueSuffix}-deployment'
  params: {
    location: location
    searchServiceName: 'search${name}${uniqueSuffix}'
    searchPrivateLinkName: 'ple-${name}-${uniqueSuffix}-search'
    subnetId: subnetResourceId
    virtualNetworkId: vnetResourceId
    tags: tags
  }
}

output aiservicesID string = aiServices.outputs.aiServicesId
output aiservicesTarget string = aiServices.outputs.aiServicesEndpoint
output storageId string = storage.outputs.storageId
output keyvaultId string = keyvault.outputs.keyvaultId
output containerRegistryId string = containerRegistry.outputs.containerRegistryId
output applicationInsightsId string = applicationInsights.outputs.applicationInsightsId
output searchServiceId string = searchService.outputs.searchServiceId
output searchServiceTarget string = searchService.outputs.searchServiceEndpoint

output aiServicesPrincipalId string = aiServices.outputs.aiServicesPrincipalId
output searchServicePrincipalId string = searchService.outputs.searchServicePrincipalId

output aiservicesName string = aiServices.outputs.aiServicesName
output searchServiceName string = searchService.outputs.searchServiceName
output storageName string = storage.outputs.storageName
