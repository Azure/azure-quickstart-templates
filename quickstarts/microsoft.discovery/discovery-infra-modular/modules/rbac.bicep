// RBAC module: grants the Discovery managed identity the roles it needs, and
// optionally grants an Entra ID group the Discovery Platform Contributor role so
// existing user groups can administer the platform. Deploy this module into the
// resource group that holds the storage account when assignStorageRole is true.

@description('Principal (object) ID of the managed identity to grant Discovery roles to.')
param principalId string

@description('Name of the storage account (in this resource group) to scope the Storage Blob Data Contributor role to.')
param storageAccountName string

@description('Assign Storage Blob Data Contributor on the storage account. Set false when the storage account lives in another resource group.')
param assignStorageRole bool = true

@description('Optional Entra ID group object ID to grant Discovery Platform Contributor at resource-group scope. Leave empty to skip.')
param discoveryContributorGroupObjectId string = ''

// Built-in role definition IDs
var storageBlobDataContributorRoleId = 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
var discoveryPlatformContributorRoleId = '01288891-85ee-45a7-b367-9db3b752fc65'
var acrPullRoleId = '7f951dda-4ed3-4680-a7ca-43fe172d538d'

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' existing = {
  name: storageAccountName
}

resource storageBlobDataContributorAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (assignStorageRole) {
  name: guid(storageAccount.id, principalId, storageBlobDataContributorRoleId)
  scope: storageAccount
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', storageBlobDataContributorRoleId)
    principalId: principalId
    principalType: 'ServicePrincipal'
  }
}

resource discoveryPlatformContributorAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, principalId, discoveryPlatformContributorRoleId)
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', discoveryPlatformContributorRoleId)
    principalId: principalId
    principalType: 'ServicePrincipal'
  }
}

resource acrPullAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, principalId, acrPullRoleId)
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', acrPullRoleId)
    principalId: principalId
    principalType: 'ServicePrincipal'
  }
}

resource groupDiscoveryContributorAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (!empty(discoveryContributorGroupObjectId)) {
  name: guid(resourceGroup().id, discoveryContributorGroupObjectId, discoveryPlatformContributorRoleId)
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', discoveryPlatformContributorRoleId)
    principalId: discoveryContributorGroupObjectId
    principalType: 'Group'
  }
}
