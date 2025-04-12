targetScope = 'subscription'

@description('Name of the resource group to create.')
param rgName string

@description('Azure Region the resource group will be created in.')
param rgLocation string = deployment().location

resource resourceGroup 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: rgName
  location: rgLocation
}
