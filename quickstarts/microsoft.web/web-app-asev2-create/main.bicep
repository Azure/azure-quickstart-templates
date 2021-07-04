@description('Name of the App Service Environment')
param aseName string

@description('Location of the App Service Environment')
param location string = resourceGroup().location

@description('Subnet name that will contain the App Service Environment')
param existingSubnetName string

resource existingSubnet 'Microsoft.Network/virtualNetworks/subnets@2020-06-01' = {
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
