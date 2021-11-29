@description('Name of the VNET to add a subnet to')
param existingVNETName string

@description('Name of the subnet to add')
param newSubnetName string

@description('Address space of the subnet to add')
param newSubnetAddressPrefix string = '10.0.0.0/24'

resource vnet 'Microsoft.Network/virtualNetworks@2021-03-01' existing = {
   name: existingVNETName
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2021-03-01' = {
  parent: vnet
  name: newSubnetName
  properties: {
    addressPrefix: newSubnetAddressPrefix
  }
}
