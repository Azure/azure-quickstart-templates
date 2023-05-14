@description('Location where all resources will be created.')
param location string = resourceGroup().location

@description('Name of the Virtual Wan.')
param vWanName string = 'SampleVirtualWan'

@description('Sku of the Virtual Wan.')
@allowed([
  'Standard'
  'Basic'
])
param vWanSku string = 'Standard'

@description('Name of the Virtual Hub. A virtual hub is created inside a virtual wan.')
param hubName string = 'SampleVirtualHub'

@description('Name of the VPN Gateway. A VPN Gateway is created inside a virtual hub.')
param vpnGatewayName string = 'SampleVpnGateway'

@description('Name of the vpnsite. A vpnsite represents the on-premise vpn device. A public ip address is mandatory for a VPN Site creation.')
param vpnSiteName string = 'SampleVpnSite'

@description('Name of the vpnconnection. A vpn connection is established between a vpnsite and a VPN Gateway.')
param connectionName string = 'SampleVpnsiteVpnGwConnection'

@description('A list of static routes corresponding to the VPN Gateway. These are configured on the VPN Gateway. Mandatory if BGP is disabled.')
param vpnSiteAddressspaceList array = []

@description('The public IP address of a VPN Site.')
param vpnSitePublicIPAddress string

@description('The BGP ASN number of a VPN Site. Unused if BGP is disabled.')
param vpnSiteBgpAsn int

@description('The BGP peer IP address of a VPN Site. Unused if BGP is disabled.')
param vpnSiteBgpPeeringAddress string

@description('The hub address prefix. This address prefix will be used as the address prefix for the hub vnet')
param hubAddressPrefix string = '192.168.0.0/24'

@description('This needs to be set to true if BGP needs to enabled on the VPN connection.')
param enableBgp bool = false

resource vWan 'Microsoft.Network/virtualWans@2021-03-01' = {
  name: vWanName
  location: location
  properties: {
    type: vWanSku
  }
}

resource hub 'Microsoft.Network/virtualHubs@2021-03-01' = {
  name: hubName
  location: location
  properties: {
    addressPrefix: hubAddressPrefix
    virtualWan: {
      id: vWan.id
    }
  }
}

resource vpnSite 'Microsoft.Network/vpnSites@2021-03-01' = {
  name: vpnSiteName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: vpnSiteAddressspaceList
    }
    bgpProperties: (enableBgp ? {
      asn: vpnSiteBgpAsn
      bgpPeeringAddress: vpnSiteBgpPeeringAddress
      peerWeight: 0
    } : null)
    deviceProperties: {
      linkSpeedInMbps: 10
    }
    ipAddress: vpnSitePublicIPAddress
    virtualWan: {
      id: vWan.id
    }
  }
}

resource vpnGateway 'Microsoft.Network/vpnGateways@2021-03-01' = {
  name: vpnGatewayName
  location: location
  properties: {
    connections: [
      {
        name: connectionName
        properties: {
          connectionBandwidth: 10
          enableBgp: enableBgp
          remoteVpnSite: {
            id: vpnSite.id
          }
        }
      }
    ]
    virtualHub: {
      id: hub.id
    }
    bgpSettings: {
      asn: 65515
    }
  }
}
