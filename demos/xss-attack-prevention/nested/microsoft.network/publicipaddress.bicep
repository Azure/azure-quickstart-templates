param publicIPAddressName string
param publicIPAddressType string = 'Dynamic'
param dnsNameForPublicIP string
param location string
param tags object

resource publicIPAddress 'Microsoft.Network/publicIPAddresses@2022-05-01' = {
  name: publicIPAddressName
  location: location
  tags: tags
  properties: {
    publicIPAllocationMethod: publicIPAddressType
    dnsSettings: {
      domainNameLabel: dnsNameForPublicIP
    }
  }
}

output publicIPAddressName string = publicIPAddressName
output publicIPRef string = publicIPAddress.id
