@description('The name of the Virtual Network')
param vnetName string

@description('the app subnet name of Dev Box')
param subnetName string

@description('The address prefixes of the vnet')
param vnetAddressPrefixes string 

@description('The subnet address prefixes for Dev Box')
param subnetAddressPrefixes string

@description('The location of the resource')
param location string

@description('The tags that will be associated to the Resources')
param tags object

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2022-11-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefixes
      ]
    }
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: subnetAddressPrefixes
        }
      }
    ]
  }

  resource subnet 'subnets' existing = {
    name: subnetName
  }
  
  tags: tags
}

output vnetName string = virtualNetwork.name
output subnetName string = virtualNetwork::subnet.name
output subnetId string = virtualNetwork::subnet.id
