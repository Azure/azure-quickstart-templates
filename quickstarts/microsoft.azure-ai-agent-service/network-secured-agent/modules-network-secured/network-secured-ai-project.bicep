// Creates an Azure AI resource with proxied endpoints for the Azure AI services provider

@description('Azure region of the deployment')
param location string

@description('Tags to add to the resources')
param tags object

@description('AI Project name')
param aiProjectName string

@description('AI Project display name')
param aiProjectFriendlyName string = aiProjectName

@description('AI Project description')
param aiProjectDescription string

@description('Resource ID of the AI Hub resource')
param aiHubId string

@description('Name for capabilityHost.')
param capabilityHostName string = 'caphost1'

@description('Name for ACS connection.')
param acsConnectionName string

@description('Name for ACS connection.')
param aoaiConnectionName string

param uaiName string

//for constructing endpoint
var subscriptionId = subscription().subscriptionId
var resourceGroupName = resourceGroup().name

var projectConnectionString = '${location}.api.azureml.ms;${subscriptionId};${resourceGroupName};${aiProjectName}'


var storageConnections = ['${aiProjectName}/workspaceblobstore']
var aiSearchConnection = ['${acsConnectionName}']
var aiServiceConnections = ['${aoaiConnectionName}']

resource uai 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-07-31-preview' existing = {
  name: uaiName
  scope: resourceGroup()
}


// Documentation: https://learn.microsoft.com/en-us/azure/templates/microsoft.machinelearningservices/workspaces?tabs=bicep
resource aiProject 'Microsoft.MachineLearningServices/workspaces@2023-08-01-preview' = {
  name: aiProjectName
  location: location
  tags: union(tags, {
    ProjectConnectionString: projectConnectionString
  })
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${uai.id}': {}
    }
  }
  properties: {
    // organization
    friendlyName: aiProjectFriendlyName
    description: aiProjectDescription
    primaryUserAssignedIdentity: uai.id

    // dependent resources
    hubResourceId: aiHubId
  }
  kind: 'project'

  // Resource definition for the capability host
  // Documentation: https://learn.microsoft.com/en-us/azure/templates/microsoft.machinelearningservices/workspaces/capabilityhosts?tabs=bicep
  resource capabilityHost 'capabilityHosts@2024-10-01-preview' = {
    name: '${aiProjectName}-${capabilityHostName}'
    properties: {
      capabilityHostKind: 'Agents'
      aiServicesConnections: aiServiceConnections
      vectorStoreConnections: aiSearchConnection
      storageConnections: storageConnections
    }
  }
}

output aiProjectName string = aiProject.name
output aiProjectResourceId string = aiProject.id
output aiProjectWorkspaceId string = aiProject.properties.workspaceId
output projectConnectionString string = aiProject.tags.ProjectConnectionString
