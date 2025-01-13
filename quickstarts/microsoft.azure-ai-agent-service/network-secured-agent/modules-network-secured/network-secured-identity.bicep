param location string
param userAssignedIdentityName string
param uaiExists bool = false

resource existingUAI 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-07-31-preview' existing = if(uaiExists) {
  name: userAssignedIdentityName
  scope: resourceGroup()
}

resource userAssignedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-07-31-preview' = {
  location: location
  name: userAssignedIdentityName
}

output uaiName string = uaiExists ? existingUAI.name : userAssignedIdentity.name
output uaiId string = uaiExists ? existingUAI.id : userAssignedIdentity.id
output uaiPrincipalId string = uaiExists ? existingUAI.properties.principalId : userAssignedIdentity.properties.principalId
output uaiClientId string = uaiExists ? existingUAI.properties.clientId : userAssignedIdentity.properties.clientId
