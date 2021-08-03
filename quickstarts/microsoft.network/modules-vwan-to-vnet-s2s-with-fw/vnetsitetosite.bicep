param location string = resourceGroup().location
param localnetworkgwname string
param connectionname string = 'onprem-hub-cn'

@description('Specifices the address prefixes of the remote site')
param addressprefixes array

@description('Specifices the VPN Sites BGP Peering IP Addresses')
param bgppeeringpddress string

@description('Specifices the VPN Sites VPN Device IP Address')
param gwipaddress string

@description('Specifices the resource ID of the VPN Gateway to connect to the site to site vpn')
param vpngwid string

@secure()
@description('Specifies the pre-shared key to use for the VPN Connection')
param psk string

@description('BGP AS-number used by the remote site')
param remotesiteasn int

resource localnetworkgw 'Microsoft.Network/localNetworkGateways@2020-06-01' = {
  name: localnetworkgwname
  location: location
  properties: {
    localNetworkAddressSpace: {
      addressPrefixes: addressprefixes
    }
    gatewayIpAddress: gwipaddress
    bgpSettings: {
      asn: remotesiteasn
      bgpPeeringAddress: bgppeeringpddress
    }
  }
}

resource s2sconnection 'Microsoft.Network/connections@2020-06-01' = {
  name: connectionname
  location: location
  properties: {
    connectionType: 'IPsec'
    connectionProtocol: 'IKEv2'
    virtualNetworkGateway1: {
      id: vpngwid
      properties: {}
    }
    enableBgp: true
    sharedKey: psk
    localNetworkGateway2: {
      id: localnetworkgw.id
      properties: {}
    }
  }
}
