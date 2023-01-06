@description('Name of the External Network')
param externalNetworkName string

@description('Azure Region for deployment of the External Network and associated resources')
param location string = resourceGroup().location

@description('Name of the L3 Isolation Domain')
param l3IsolationDomainName string

@description('Vlan identifier value')
param vlanId int

@description('Maximum transmission unit')
param mtu int

@description('ASN of Network Fabric')
param fabricASN int

@description('ASN of Provider Edge')
param peerASN int

@description('Interval value')
param interval int

@description('Multiplier value')
param multiplier int

@description('IPv4 Address Prefix of CE1-PE1 interconnect links')
param primaryIpv4Prefix string

@description('IPv6 Address Prefix of CE1-PE1 interconnect links')
param primaryIpv6Prefix string

@description('IPv4 Address Prefix of CE2-PE2 interconnect links')
param secondaryIpv4Prefix string

@description('IPv4 Address Prefix of CE2-PE2 interconnect links')
param secondaryIpv6Prefix string

@description('Name of existing l3 Isolation Domain Resource')
resource l3IsolationDomains 'Microsoft.ManagedNetworkFabric/l3IsolationDomains@2022-01-15-privatepreview' existing = {
  name: l3IsolationDomainName
}

@description('Create External Network Resource')
resource externalNetwork 'Microsoft.ManagedNetworkFabric/l3IsolationDomains/externalNetworks@2022-01-15-privatepreview' = {
  name: externalNetworkName
  parent: l3IsolationDomains
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

output resourceID string = externalNetwork.id
