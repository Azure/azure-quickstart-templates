// Identity module: user-assigned managed identity used by the Supercomputer and
// Workspace. Skip this module and pass an existing identity to main.bicep
// (deployManagedIdentity = false) to reuse a central identity.

@description('Azure region for the managed identity.')
param location string = resourceGroup().location

@description('Name of the user-assigned managed identity (3-128 characters: letters, numbers, hyphens, and underscores; must start with a letter or number).')
@minLength(3)
@maxLength(128)
param managedIdentityName string = 'uami-${uniqueString(resourceGroup().id)}'

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2024-11-30' = {
  name: managedIdentityName
  location: location
  properties: {
    isolationScope: 'Regional'
  }
}

@description('Resource ID of the managed identity.')
output resourceId string = managedIdentity.id

@description('Principal (object) ID of the managed identity, used for role assignments.')
output principalId string = managedIdentity.properties.principalId

@description('Client ID of the managed identity.')
output clientId string = managedIdentity.properties.clientId
