param location string
param hciCustomLocationName string
param hciLogicalNetworkName string
param addressPrefix string
param startIPAddress string
param endIPAddress string
param defaultGateway string
param vmSwitchName string
param dnsServers array
param vlan int = 0

var customLocationId = resourceId('Microsoft.ExtendedLocation/customLocations', hciCustomLocationName) // full custom location ID

resource logicalNetwork 'Microsoft.AzureStackHCI/logicalNetworks@2023-09-01-preview' = {
  name: hciLogicalNetworkName
  location: location
  extendedLocation: {
    type: 'CustomLocation'
    name: customLocationId
  }
  properties: {
    subnets: [ {
        name: 'default'
        properties: {
          addressPrefix: addressPrefix
          ipAllocationMethod: 'Static'
          vlan: vlan
          ipPools: [
            {
              start: startIPAddress
              end: endIPAddress
            }
          ]
          routeTable: {
            properties: {
              routes: [
                {
                  name: 'default'
                  properties: {
                    addressPrefix: '0.0.0.0/0'
                    nextHopIpAddress: defaultGateway
                  }
                }
              ]
            }
          }
        }
      } ]
    vmSwitchName: vmSwitchName
    dhcpOptions: {
      dnsServers: dnsServers
    }
  }
}
