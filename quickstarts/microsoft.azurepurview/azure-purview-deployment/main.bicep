@description('Specify a name for the Azure Purview account.')
param purviewName string = 'azurePurview${uniqueString(resourceGroup().id)}'

@description('Specify a region for resource deployment.')
param location string = resourceGroup().location

resource purview 'Microsoft.Purview/accounts@2021-12-01' = {
  name: purviewName
  location: location
  sku: {
    name: 'Standard'
    capacity: 1
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    publicNetworkAccess: 'Enabled'
    managedResourceGroupName: 'managed-rg-${purviewName}'
  }
}
