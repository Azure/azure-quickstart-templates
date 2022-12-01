param name string
param hostingPlanName string
param location string
param hostingEnvironment string = ''
param tags object

var tags_var = {
  'hidden-related:${resourceId('Microsoft.Web/serverfarms', hostingPlanName)}': 'empty'
}
var combinedTags = union(tags, tags_var)

resource name_resource 'Microsoft.Web/sites@2019-08-01' = {
  name: name
  tags: combinedTags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    name: name
    serverFarmId: resourceId('Microsoft.Web/serverfarms', hostingPlanName)
    hostingEnvironment: hostingEnvironment
  }
  location: location
}

output principalId string = reference(name_resource.id, '2019-08-01', 'Full').identity.principalId
output endpoint string = '${name}.azurewebsites.net'