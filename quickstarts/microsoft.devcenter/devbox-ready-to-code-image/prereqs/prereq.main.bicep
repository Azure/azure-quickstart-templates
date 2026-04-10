param location string = resourceGroup().location

var uniqueSuffix = uniqueString(deployment().name, resourceGroup().name)

resource builderIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: 'identity-builder-${uniqueSuffix}'
  location: location
}

resource imageIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: 'identity-image-${uniqueSuffix}'
  location: location
}

resource gallery 'Microsoft.Compute/galleries@2023-07-03' = {
  name: 'gallery${uniqueSuffix}'
  location: location
}

var contributorRoleDefinitionId = resourceId(
  'Microsoft.Authorization/roleDefinitions',
  'b24988ac-6180-42a0-ab88-20f7382dd24c' // https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#general
)

// Allow creation of images related resources in the resource group
resource imageIdentityRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(builderIdentity.id, contributorRoleDefinitionId, resourceGroup().id, subscription().id)
  scope: resourceGroup()
  properties: {
    principalId: builderIdentity.properties.principalId
    principalType: 'ServicePrincipal'
    roleDefinitionId: contributorRoleDefinitionId
  }
}

output builderIdentityId string = builderIdentity.id
output imageIdentityId string = imageIdentity.id
output galleryName string = gallery.name
output galleryResourceGroup string = resourceGroup().name
output gallerySubscriptionId string = subscription().subscriptionId
