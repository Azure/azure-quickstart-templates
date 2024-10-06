param location string
param prefix string

resource aksManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: '${prefix}-aks'
  location: location
}

output aksManagedIdentityId string = aksManagedIdentity.id
output aksManagedIdentityPrincipalId string = aksManagedIdentity.properties.principalId
