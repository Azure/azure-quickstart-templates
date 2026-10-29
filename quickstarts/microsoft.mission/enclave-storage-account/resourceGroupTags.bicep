targetScope = 'resourceGroup'

param tags object

resource resourceGroupTags 'Microsoft.Resources/tags@2021-04-01' = {
  name: 'default'
  properties: {
    tags: union(resourceGroup().tags, tags)
  }
}
