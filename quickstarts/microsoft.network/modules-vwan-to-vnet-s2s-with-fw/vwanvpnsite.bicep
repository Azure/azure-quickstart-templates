param vpnsitename string
param location string = resourceGroup().location

@description('Specifices the VPN Sites local IP Addresses')
param addressprefix string

@description('Specifices the VPN Sites BGP Peering IP Addresses')
param bgppeeringpddress string

@description('Specifices the VPN Sites VPN Device IP Address')
param ipaddress string

@description('Specifices the resource ID of the Virtual WAN where the VPN Site should be created')
param wanid string

@description('BGP AS-Number used by the remote site')
param remotesiteasn int

resource vpnsite 'Microsoft.Network/vpnSites@2020-06-01' = {
  name: vpnsitename
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressprefix
      ]
    }
    bgpProperties: {
      asn: remotesiteasn
      bgpPeeringAddress: bgppeeringpddress
      peerWeight: 0
    }
    deviceProperties: {
      linkSpeedInMbps: 0
    }
    ipAddress: ipaddress
    virtualWan: {
      id: wanid
    }
  }
}

output id string = vpnsite.id
