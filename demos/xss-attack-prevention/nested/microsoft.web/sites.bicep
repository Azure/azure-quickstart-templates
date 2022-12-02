param name string
param hostingPlanName string
param location string
param tags object

var tag = {
  'hidden-related:${resourceId('Microsoft.Web/serverfarms', hostingPlanName)}': 'empty'
}
var combinedTags = union(tags, tag)

resource site 'Microsoft.Web/sites@2022-03-01' = {
  name: name
  tags: combinedTags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: resourceId('Microsoft.Web/serverfarms', hostingPlanName)
  }
  location: location
}

output principalId string = reference(site.id, '2019-08-01', 'Full').identity.principalId
output endpoint string = '${name}.azurewebsites.net'
