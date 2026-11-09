targetScope = 'resourceGroup'

param name string
param location string
param tagsByResource object = {}

resource umi 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: name
  location: location
  tags: contains(tagsByResource, 'Microsoft.ManagedIdentity/userAssignedIdentities') ? tagsByResource['Microsoft.ManagedIdentity/userAssignedIdentities'] : {}
}

output id string = umi.id
output principalId string = umi.properties.principalId
output clientId string = umi.properties.clientId
