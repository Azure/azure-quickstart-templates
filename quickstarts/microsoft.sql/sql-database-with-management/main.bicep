targetScope = 'subscription'

@description('Resource Group object definition.')
param resourceGroup object

var defaultResourceGroupProperties = {
  tags: {}
  deploy: true
}

// Deploy Resource Group
resource sqlRg 'Microsoft.Resources/resourceGroups@2021-04-01' = if (union(defaultResourceGroupProperties, resourceGroup).deploy) {
  name: resourceGroup.name
  location: resourceGroup.location
  tags: union(defaultResourceGroupProperties, resourceGroup).tags
  properties: {}
}

// Start SQL Logical Servers deployment
module sqlLogicalServers 'modules/sql-logical-servers.bicep' = {
  name: 'sqlLogicalServers'
  scope: sqlRg
  params: {
    sqlLogicalServers: resourceGroup.sqlLogicalServers
    tags: union(defaultResourceGroupProperties, resourceGroup).tags
  }
}
