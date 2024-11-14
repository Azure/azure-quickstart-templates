@description('Name of the VNET to inject Cloud Shell into')
param vnetName string

@description('Address space of the subnet to add')
param vnetAddressPrefix string

@description('Name of the subnet to use for cloud shell containers')
param defaultSubnetName string = 'default'

@description('Address space of the subnet to add')
param defaultSubnetAddressPrefix string
param location string = resourceGroup().location

resource vnet 'Microsoft.Network/virtualNetworks@2023-05-01' = {
  name: vnetName
  location: location
  tags: {
    displayName: 'The VNET'
  }
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
    subnets: [
      {
        name: defaultSubnetName
        properties: {
          addressPrefix: defaultSubnetAddressPrefix
        }
      }
    ]
  }
}

output vnetName string = vnetName
output defaultSubnetAddressPrefix string = defaultSubnetAddressPrefix
