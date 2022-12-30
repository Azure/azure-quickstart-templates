@description('Name of the External Network')
param externalNetworkName string

@description('Azure Region for deployment of the External Network and associated resources')
param location string = resourceGroup().location

param l3IsolationDomainName string = 'l3dbicep'

var vlanId = 1234
var mtu = 1564
var fabricASN = 65046
var peerASN = 65500
var interval = 300
var multiplier = 3
var primaryIpv4Prefix = '172.31.0.0/30'
var primaryIpv6Prefix = '3FFE:FFFF:0:CD30::a4/126'
var secondaryIpv4Prefix = '172.31.0.4/30'
var secondaryIpv6Prefix = '3FFE:FFFF:0:CD30::a4/126'

@description('Create External Network  Resource')
resource l3IsolationDomains 'Microsoft.ManagedNetworkFabric/l3IsolationDomains@2022-01-15-privatepreview' = {
  name: l3IsolationDomainName
  location: location
  resource externalNetwork 'externalNetworks' = {
    name: externalNetworkName
    properties: {
      vlanId: vlanId
      mtu: mtu
      fabricASN: fabricASN
      peerASN: peerASN
      bfdConfiguration: {
        interval: interval
        multiplier: multiplier
      }
      primaryIpv4Prefix: primaryIpv4Prefix
      primaryIpv6Prefix: primaryIpv6Prefix
      secondaryIpv4Prefix: secondaryIpv4Prefix
      secondaryIpv6Prefix: secondaryIpv6Prefix
    }
  }
}
