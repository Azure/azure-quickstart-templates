targetScope = 'subscription'

@description('Name of the resourceGroup.')
param resourceGroupName string

param location string = deployment().location

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  location: location
}
