// Workspace module: Microsoft Discovery Workspace plus its chat model deployment,
// Discovery storage container, and project. Bind it to a Supercomputer, a managed
// identity, subnets, and the Azure storage account that backs the container.

import { workspaceFeatureTags } from 'types.bicep'

@description('Azure region for the Workspace and its child resources.')
param location string = resourceGroup().location

@description('Name of the Workspace (3-24 characters, alphanumeric and hyphens).')
@minLength(3)
@maxLength(24)
param workspaceName string = 'ws-${uniqueString(resourceGroup().id)}'

@description('Workbench feature tags for the Workspace.')
param featureTags workspaceFeatureTags = {
  enableGhcpAiFeatures: true
  enableExtensions: true
  networkIsolation: true
}

@description('Resource ID of the user-assigned managed identity for the Workspace.')
param managedIdentityResourceId string

@description('Resource ID of the Supercomputer to link to the Workspace.')
param supercomputerId string

@description('Resource ID of the agent subnet.')
param agentSubnetId string

@description('Resource ID of the private endpoint subnet.')
param privateEndpointSubnetId string

@description('Resource ID of the Workspace subnet.')
param workspaceSubnetId string

@description('Name of the chat model deployment.')
@minLength(3)
@maxLength(24)
param chatModelDeploymentName string = 'gpt-5-4'

@description('Chat model format. Microsoft Discovery uses the OpenAI model format.')
@allowed([
  'OpenAI'
])
param chatModelFormat string = 'OpenAI'

@description('Chat model name to deploy. Discovery Engine tasks require the primary deployment to use gpt-5.4 (with deployment name gpt-5-4).')
@minLength(1)
@maxLength(64)
param chatModelName string = 'gpt-5.4'

@description('Name of the Discovery storage container resource (3-24 characters, alphanumeric and hyphens).')
@minLength(3)
@maxLength(24)
param storageContainerName string = 'stc-${uniqueString(resourceGroup().id)}'

@description('Resource ID of the Azure storage account backing the Discovery storage container.')
param storageAccountResourceId string

@description('Name of the project (3-24 characters, alphanumeric and hyphens).')
@minLength(3)
@maxLength(24)
param projectName string = 'prj-${uniqueString(resourceGroup().id)}'

resource workspace 'Microsoft.Discovery/workspaces@2026-06-01' = {
  name: workspaceName
  location: location
  tags: {
    version: 'v2'
    'discovery.workbench.enableGhcpAiFeatures': string(featureTags.enableGhcpAiFeatures)
    'discovery.workbench.enableExtensions': string(featureTags.enableExtensions)
    NetworkIsolation: string(featureTags.networkIsolation)
  }
  properties: {
    workspaceIdentity: {
      id: managedIdentityResourceId
    }
    supercomputerIds: [
      supercomputerId
    ]
    agentSubnetId: agentSubnetId
    privateEndpointSubnetId: privateEndpointSubnetId
    workspaceSubnetId: workspaceSubnetId
  }
}

resource chatModelDeployment 'Microsoft.Discovery/workspaces/chatModelDeployments@2026-06-01' = {
  parent: workspace
  name: chatModelDeploymentName
  location: location
  properties: {
    modelFormat: chatModelFormat
    modelName: chatModelName
  }
}

resource discoveryStorageContainer 'Microsoft.Discovery/storageContainers@2026-06-01' = {
  name: storageContainerName
  location: location
  properties: {
    storageStore: {
      kind: 'AzureStorageBlob'
      storageAccountId: storageAccountResourceId
    }
  }
}

resource project 'Microsoft.Discovery/workspaces/projects@2026-06-01' = {
  parent: workspace
  name: projectName
  location: location
  dependsOn: [
    chatModelDeployment
  ]
  properties: {
    storageContainerIds: [
      discoveryStorageContainer.id
    ]
  }
}

@description('Resource ID of the Workspace.')
output workspaceId string = workspace.id

@description('Resource ID of the chat model deployment.')
output chatModelDeploymentId string = chatModelDeployment.id

@description('Resource ID of the Discovery storage container.')
output storageContainerId string = discoveryStorageContainer.id

@description('Resource ID of the project.')
output projectId string = project.id
