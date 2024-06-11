param location string = resourceGroup().location

@description('Virtual Network 1')
param vmnet1Name string

@description('Virtual Network 2')
param vmnet2Name string

resource vmnet1 'Microsoft.Network/virtualNetworks@2022-07-01' = {
  name: vmnet1Name
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'default'
        properties: {
          addressPrefix: '10.0.0.0/24'
        }
      }
    ]
  }
}

resource vnet2 'Microsoft.Network/virtualNetworks@2022-07-01' = {
  name: vmnet2Name
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '11.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'default'
        properties: {
          addressPrefix: '11.0.0.0/24'
        }
      }
    ]
  }
}
