@description('Name of the new migration service.')
param serviceName string

@description('Location where the resources will be deployed.')
param location string = resourceGroup().location

@description('Name of the new virtual network.')
param vnetName string

@description('Name of the new subnet associated with the virtual network.')
param subnetName string

resource vnetName_resource 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
  }
}

resource vnetName_subnetName 'Microsoft.Network/virtualNetworks/subnets@2021-05-01' = {
  parent: vnetName_resource
  name: '${subnetName}'
  properties: {
    addressPrefix: '10.0.0.0/24'
  }
}

resource serviceName_resource 'Microsoft.DataMigration/services@2021-10-30-preview' = {
  name: serviceName
  location: location
  sku: {
    tier: 'Standard'
    size: '1 vCores'
    name: 'Standard_1vCores'
  }
  properties: {
    virtualSubnetId: vnetName_subnetName.id
  }
}
