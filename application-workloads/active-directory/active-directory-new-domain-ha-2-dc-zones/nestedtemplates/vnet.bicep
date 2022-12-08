@metadata({ Description: 'The name of the Virtual Network to Create' })
param virtualNetworkName string

@metadata({ Description: 'The address range of the new VNET in CIDR format' })
param virtualNetworkAddressRange string

@metadata({ Description: 'The name of the subnet created in the new VNET' })
param subnetName string

@metadata({ Description: 'The address range of the subnet created in the new VNET' })
param subnetRange string

@metadata({ Description: 'The DNS address(es) of the DNS Server(s) used by the VNET' })
param DNSServerAddress array = []

@description('Location for all resources.')
param location string

var dhcpOptions = {
  dnsServers: DNSServerAddress
}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2022-05-01' = {
  name: virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        virtualNetworkAddressRange
      ]
    }
    dhcpOptions: (empty(DNSServerAddress) ? json('null') : dhcpOptions)
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: subnetRange
        }
      }
    ]
  }
}
