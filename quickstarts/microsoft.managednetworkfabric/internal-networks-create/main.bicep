@description('Name of Internal Network')
param internalNetworkName string

@description('Azure Region for deployment of Internal Network and associated resources')
param location string = resourceGroup().location

param l3IsolationDomainName string = 'rahull3d123'

var vlanId = 1234
var mtu = 1564
var ipv4prefix = '14.13.12.11/30'
var ipv4gateway = '10.0.0.1'
var ipv6prefix = '14.13.12.11/30'
var ipv6gateway = '10.0.0.1'
var fabricASN = 65046
var peerASN = 65500
var ipv4Prefix = '14.13.12.11/30'
var ipv6Prefix = '14.13.12.11/30'
var address = '10.0.0.11'
var interval = 300
var multiplier = 3
var prefix = '10.0.0.11'

@description('Create L3 Isolation Domain Resource')
resource internalNetwork 'Microsoft.ManagedNetworkFabric/l3IsolationDomains@2022-01-15-privatepreview' = {
  name: l3IsolationDomainName
  location: location
  resource internalNetwork 'internalNetworks' = {
    name: internalNetworkName
    properties: {
      vlanId: vlanId
      mtu: mtu
      connectedIPv4Subnets: [
        {
          prefix: ipv4prefix
          gateway: ipv4gateway
        }
      ]
      connectedIPv6Subnets: [
        {
          prefix: ipv6prefix
          gateway: ipv6gateway
        }
      ]
      staticRouteConfiguration: {
        bfdConfiguration: {
          interval: interval
          multiplier: multiplier
        }
        ipv4Routes: {
          prefix: prefix
        }
        ipv6Routes: {
          prefix: prefix
        }
      }
      bgpConfiguration: {
        bfdConfiguration: {
          interval: interval
          multiplier: multiplier
        }
        fabricASN: fabricASN
        peerASN: peerASN
        ipv4Prefix: ipv4Prefix
        ipv6Prefix: ipv6Prefix
        ipv4NeighborAddress: [
          {
            address: address
          }
        ]
        ipv6NeighborAddress: [
          {
            address: address
          }
        ]
      }
    }
  }
}
