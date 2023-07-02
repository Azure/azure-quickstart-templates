@description('Name of Internal Network')
param internalNetworkName string

@description('Name of the L3 Isolation Domain')
param l3IsolationDomainName string

@description('Switch configuration description')
param annotation string

@description('Vlan identifier value')
@minValue(100)
@maxValue(4095)
param vlanId int

@description('Maximum transmission unit')
@minValue(1500)
@maxValue(9000)
param mtu int

@description('List with object connected IPv4 Subnets')
param connectedIPv4Subnets array

@description('List with object connected IPv6 Subnets')
param connectedIPv6Subnets array

@description('Static Route Configuration model')
param staticRouteConfiguration object

@description('BGP configuration properties')
param bgpConfiguration object

@description('ARM resource ID of Import Route Policy')
param importRoutePolicyId string

@description('ARM resource ID of Export Route Policy')
param exportRoutePolicyId string

@allowed([
  'True'
  'False'
])
@description('To check whether monitoring of internal network is enabled or not')
param isMonitoringEnabled string

@allowed([
  'NoExtension'
  'NPB'
])
@description('Extension')
param extension string

@description('Import Route Policy configuration')
param importRoutePolicy object

@description('Export Route Policy configuration')
param exportRoutePolicy object

@description('Name of existing l3 Isolation Domain Resource')
resource l3IsolationDomains 'Microsoft.ManagedNetworkFabric/l3IsolationDomains@2023-06-15' existing = {
  name: l3IsolationDomainName
}

@description('Create Internal Network Resource')
resource internalNetwork 'Microsoft.ManagedNetworkFabric/l3IsolationDomains/internalNetworks@2023-06-15' = {
  name: internalNetworkName
  parent: l3IsolationDomains
  properties: {
    annotation: annotation
    vlanId: vlanId
    isMonitoringEnabled: isMonitoringEnabled
    extension: extension
    mtu: mtu != '' ? mtu : null
    connectedIPv4Subnets: connectedIPv4Subnets != [] ? connectedIPv4Subnets : null
    connectedIPv6Subnets: connectedIPv6Subnets != [] ? connectedIPv6Subnets : null
    staticRouteConfiguration: staticRouteConfiguration != {} ? {
      bfdConfiguration: staticRouteConfiguration.bfdConfiguration
      ipv4Routes: staticRouteConfiguration.ipv4Routes != [] ? staticRouteConfiguration.ipv4Routes : null
      ipv6Routes: staticRouteConfiguration.ipv6Routes != [] ? staticRouteConfiguration.ipv6Routes : null
      extension: staticRouteConfiguration.extension
    } : null
    bgpConfiguration: bgpConfiguration != {} ? {
      bfdConfiguration: bgpConfiguration.bfdConfiguration
      defaultRouteOriginate: bgpConfiguration.defaultRouteOriginate != '' ? bgpConfiguration.defaultRouteOriginate : null
      allowAS: bgpConfiguration.allowAS
      allowASOverride: bgpConfiguration.allowASOverride != '' ? bgpConfiguration.allowASOverride : null
      peerASN: bgpConfiguration.peerASN
      ipv4ListenRangePrefixes: bgpConfiguration.ipv4ListenRangePrefixes != [] ? bgpConfiguration.ipv4ListenRangePrefixes : null
      ipv6ListenRangePrefixes: bgpConfiguration.ipv6ListenRangePrefixes != [] ? bgpConfiguration.ipv6ListenRangePrefixes : null
      ipv4NeighborAddress: bgpConfiguration.ipv4NeighborAddress != [] ? bgpConfiguration.ipv4NeighborAddress : null
      ipv6NeighborAddress: bgpConfiguration.ipv6NeighborAddress != [] ? bgpConfiguration.ipv6NeighborAddress : null
      annotation: annotation
    } : null
    importRoutePolicyId: importRoutePolicyId != '' ? importRoutePolicyId : null
    exportRoutePolicyId: exportRoutePolicyId != '' ? exportRoutePolicyId : null
    importRoutePolicy: importRoutePolicy
    exportRoutePolicy: exportRoutePolicy
  }
}

output resourceID string = internalNetwork.id
