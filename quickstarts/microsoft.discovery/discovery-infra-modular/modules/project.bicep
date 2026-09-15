// Project module: a Microsoft Discovery project bound to an existing Workspace and
// its storage container(s). Split out from the Workspace module so the project
// lifecycle can be managed on its own and a Workspace can host multiple projects.

@description('Azure region for the project.')
param location string = resourceGroup().location

@description('Name of the parent Workspace that owns this project.')
@minLength(3)
@maxLength(24)
param workspaceName string

@description('Name of the project (3-24 characters, alphanumeric and hyphens).')
@minLength(3)
@maxLength(24)
param projectName string = 'prj-${uniqueString(resourceGroup().id)}'

@description('Resource IDs of the Discovery storage containers to attach to the project. Passing the container ID also orders this module after the workspace module that creates it.')
@minLength(1)
param storageContainerIds string[]

resource workspace 'Microsoft.Discovery/workspaces@2026-06-01' existing = {
  name: workspaceName
}

resource project 'Microsoft.Discovery/workspaces/projects@2026-06-01' = {
  parent: workspace
  name: projectName
  location: location
  properties: {
    storageContainerIds: storageContainerIds
  }
}

@description('Resource ID of the project.')
output projectId string = project.id
