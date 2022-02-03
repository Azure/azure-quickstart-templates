@description('VNet name')
param vnetName string = 'VNet1'

@description('Address prefix')
param vnetAddressPrefix string = '10.0.0.0/16'

@description('Subnet 1 Prefix')
param subnet1Prefix string = '10.0.0.0/24'

@description('Subnet 1 Name')
param subnet1Name string = 'Subnet1'

@description('Subnet 2 Prefix')
param subnet2Prefix string = '10.0.1.0/24'

@description('Subnet 2 Name')
param subnet2Name string = 'Subnet2'

@description('Location for all resources.')
param location string = resourceGroup().location

resource vnet 'Microsoft.Network/virtualNetworks@2020-06-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
  }

  resource subnet1 'subnets' = {
    name: subnet1Name
    properties: {
      addressPrefix: subnet1Prefix
    }
  }

  resource subnet2 'subnets' = {
    name: subnet2Name
    dependsOn: [
      // This ensures only one subnets is created at a time (so they're not both trying to modify the vnet at the same)
      subnet1
    ]
    properties: {
      addressPrefix: subnet2Prefix
    }
  }
}
