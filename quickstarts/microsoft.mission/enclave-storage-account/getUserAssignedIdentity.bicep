targetScope = 'resourceGroup'

param name string

resource umi 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing = {
  name: name
}

output principalId string = umi.properties.principalId
