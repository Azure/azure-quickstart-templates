@description('Name of Internal Network')
param internalNetworkName string

@description('Azure Region for deployment of Internal Network and associated resources')
param location string = resourceGroup().location

@description('Name of the L3 Isolation Domain')
param l3IsolationDomainName string

@description('Vlan identifier value')
param vlanId int

@description('Maximum transmission unit')
param mtu int

@description('IPv4 Prefix of the subnet in the VLAN')
param connectedIpv4Prefix string

@description('Gateway of IPv4 Subnet')
param connectedIpv4Gateway string

@description('IPv6 Prefix of the subnet in the VLAN')
param connectedIpv6Grefix string

@description('Gateway of IPv6 Subnet')
param connectedIpv6Gateway string

@description('ASN number assigned on CE for BGP peering with PE')
param fabricASN int

@description('ASN number assigned on PE for BGP peering with CE')
param peerASN int

@description('Address')
param address string

@description('Interval value')
param interval int

@description('Multiplier value')
param multiplier int

@description('Prefix of Ipv4Routes')
param ipv4RoutePrefix string

@description('Prefix of Ipv6Routes')
param ipv6RoutePrefix string

@description('Ipv4 prefix of bgp configuration')
param ipv4Prefix string

@description('Ipv6 prefix of bgp configuration')
param ipv6Prefix string

@description('Name of existing l3 Isolation Domain Resource')
resource l3IsolationDomains 'Microsoft.ManagedNetworkFabric/l3IsolationDomains@2022-01-15-privatepreview' existing = {
  name: l3IsolationDomainName
}

@description('Create Internal Network Resource')
resource internalNetwork 'Microsoft.ManagedNetworkFabric/l3IsolationDomains/internalNetworks@2022-01-15-privatepreview' = {
  name: internalNetworkName
  parent: l3IsolationDomains
  properties: {
    vlanId: vlanId
    mtu: mtu
    connectedIPv4Subnets: [
      {
        prefix: connectedIpv4Prefix
        gateway: connectedIpv4Gateway
      }
    ]
    connectedIPv6Subnets: [
      {
        prefix: connectedIpv6Grefix
        gateway: connectedIpv6Gateway
      }
    ]
    staticRouteConfiguration: {
      bfdConfiguration: {
        interval: interval
        multiplier: multiplier
      }
      ipv4Routes: {
        prefix: ipv4RoutePrefix
      }
      ipv6Routes: {
        prefix: ipv6RoutePrefix
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

output resourceID string = internalNetwork.id
