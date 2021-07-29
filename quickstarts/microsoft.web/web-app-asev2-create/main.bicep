@description('Name of the App Service Environment')
param aseName string

@description('Location of the App Service Environment')
param location string = resourceGroup().location

@description('Name of the existing VNET')
param existingVirtualNetworkName string

@description('Subnet name that will contain the App Service Environment')
param existingSubnetName string

resource existingVnet 'Microsoft.Network/virtualNetworks@2021-02-01' existing = {
  name: existingVirtualNetworkName
}

resource existingSubnet 'Microsoft.Network/virtualNetworks/subnets@2020-06-01' existing = {
  parent: existingVnet
  name: existingSubnetName
}

resource ase 'Microsoft.Web/hostingEnvironments@2020-06-01' = {
  name: aseName
  kind: 'ASEV2'
  location: location
  properties: {
    location: location
    name: aseName
    workerPools: []
    virtualNetwork: {
      id: existingSubnet.id
    }
  }
}
