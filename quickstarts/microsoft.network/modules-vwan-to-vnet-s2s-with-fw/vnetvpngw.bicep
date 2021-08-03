param location string = resourceGroup().location
param vpngwpipname string
param vpngwname string

@description('Specifies the resource id of the subnet to connect the VM to.')
param subnetref string

@description('BGP AS-number to use for the VPN Gateway')
param asn int

resource vpngwpip 'Microsoft.Network/publicIPAddresses@2020-06-01' = {
  name: vpngwpipname
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource vpngw 'Microsoft.Network/virtualNetworkGateways@2020-06-01' = {
  name: vpngwname
  location: location
  properties: {
    gatewayType: 'Vpn'
    ipConfigurations: [
      {
        name: 'default'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: subnetref
          }
          publicIPAddress: {
            id: vpngwpip.id
          }
        }
      }
    ]
    activeActive: false
    enableBgp: true
    bgpSettings: {
      asn: asn
    }
    vpnType: 'RouteBased'
    vpnGatewayGeneration: 'Generation1'
    sku: {
      name: 'VpnGw1AZ'
      tier: 'VpnGw1AZ'
    }
  }
}

output id string = vpngw.id
output vpngwip string = vpngwpip.properties.ipAddress
output vpngwbgpaddress string = vpngw.properties.bgpSettings.bgpPeeringAddress
output bgpasn int = vpngw.properties.bgpSettings.asn
