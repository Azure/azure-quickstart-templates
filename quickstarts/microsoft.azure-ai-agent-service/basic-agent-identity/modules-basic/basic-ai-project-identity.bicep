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

param aiServicesName string

resource aiServices 'Microsoft.CognitiveServices/accounts@2023-05-01' existing = {
  name: aiServicesName
}

//for constructing project connection string
var subscriptionId = subscription().subscriptionId
var resourceGroupName = resourceGroup().name

var projectConnectionString = '${location}.api.azureml.ms;${subscriptionId};${resourceGroupName};${aiProjectName}'

resource aiProject 'Microsoft.MachineLearningServices/workspaces@2023-08-01-preview' = {
  name: aiProjectName
  location: location
  tags: union(tags, {
    ProjectConnectionString: projectConnectionString
  })
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    // organization
    friendlyName: aiProjectFriendlyName
    description: aiProjectDescription

    // dependent resources
    hubResourceId: aiHubId
  
  }
  kind: 'project'
}

resource cognitiveServicesContributorRole 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  name: '25fbc0a9-bd7c-42a3-aa1a-3b75d497ee68'
  scope: resourceGroup()
}

resource cognitiveServicesContributorAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01'= {
  scope: aiServices
  name: guid(aiProject.id, cognitiveServicesContributorRole.id, aiServices.id)
  properties: {  
    principalId: aiProject.identity.principalId
    roleDefinitionId: cognitiveServicesContributorRole.id
    principalType: 'ServicePrincipal'
  }
  }


resource cognitiveServicesOpenAIUserRole 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  name: '5e0bd9bd-7b93-4f28-af87-19fc36ad61bd'
  scope: resourceGroup()
}
resource cognitiveServicesOpenAIUserRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: aiServices
  name: guid(aiProject.id, cognitiveServicesOpenAIUserRole.id, aiServices.id)
  properties: {
    principalId: aiProject.identity.principalId
    roleDefinitionId: cognitiveServicesOpenAIUserRole.id
    principalType: 'ServicePrincipal'
  }
}

resource cognitiveServicesUserRole 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  name: 'a97b65f3-24c7-4388-baec-2e87135dc908'
  scope: resourceGroup()
}

resource cognitiveServicesUserRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: aiServices
  name: guid(aiProject.id, cognitiveServicesUserRole.id, aiServices.id)
  properties: {
    principalId: aiProject.identity.principalId
    roleDefinitionId: cognitiveServicesUserRole.id
    principalType: 'ServicePrincipal'
  }
}

output aiProjectName string = aiProject.name
output aiProjectResourceId string = aiProject.id
output aiProjectWorkspaceId string = aiProject.properties.workspaceId
output projectConnectionString string = aiProject.tags.ProjectConnectionString
