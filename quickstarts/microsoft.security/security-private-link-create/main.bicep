@description('The name of the Security Private Link to Create')
param privateLinkName string = 'spl-${uniqueString(resourceGroup().id)}'

resource pls 'Microsoft.Security/privateLinks@2026-01-01' = {
  name: privateLinkName
  location: 'global'
  properties: {}
}

output name string = pls.name
output resourceId string = pls.id
