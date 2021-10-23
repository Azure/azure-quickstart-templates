@description('Specifies the location of AKS cluster.')
param location string = resourceGroup().location

@description('Specifies the name of the Azure Bastion resource.')
param bastionHostName string

@description('Specifies the id of the Azure Bastion subnet resource id.')
param bastionSubnetId string

var bastionPublicIpAddressName = '${bastionHostName}PublicIp'

resource bastionPublicIpAddress 'Microsoft.Network/publicIPAddresses@2020-08-01' = {
  name: bastionPublicIpAddressName
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource bastionHost 'Microsoft.Network/bastionHosts@2020-08-01' = {
  name: bastionHostName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'IpConf'
        properties: {
          subnet: {
            id: bastionSubnetId
          }
          publicIPAddress: {
            id: bastionPublicIpAddress.id
          }
        }
      }
    ]
  }
}
