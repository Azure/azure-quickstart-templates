@description('Name of Internal Network')
param internalNetworkName string

@description('Name of the L3 Isolation Domain')
param l3IsolationDomainName string

@description('Switch configuration description')
param annotation string = ''

@description('Vlan identifier value')
@minValue(100)
@maxValue(4095)
param vlanId int

@description('Maximum transmission unit')
@minValue(64)
@maxValue(9200)
param mtu int = 1500

@description('List with object connected IPv4 Subnets')
param connectedIPv4Subnets array = []

@description('List with object connected IPv6 Subnets')
param connectedIPv6Subnets array = []

@description('Static Route Configuration model')
param staticRouteConfiguration object = {}

@description('BGP configuration properties')
param bgpConfiguration object = {}

@allowed([
  'True'
  'False'
])
@description('To check whether monitoring of internal network is enabled or not')
param isMonitoringEnabled string = 'False'

@allowed([
  'NoExtension'
  'NPB'
])
@description('Extension')
param extension string = 'NoExtension'

@description('Import Route Policy configuration')
param importRoutePolicy object = {}

@description('Export Route Policy configuration')
param exportRoutePolicy object = {}

@description('Name of existing l3 Isolation Domain Resource')
resource l3IsolationDomains 'Microsoft.ManagedNetworkFabric/l3IsolationDomains@2023-06-15' existing = {
  name: l3IsolationDomainName
}

@description('Create Internal Network Resource')
resource internalNetwork 'Microsoft.ManagedNetworkFabric/l3IsolationDomains/internalNetworks@2023-06-15' = {
  name: internalNetworkName
  parent: l3IsolationDomains
  properties: {
    annotation: !empty(annotation) ? annotation : null
    vlanId: vlanId
    isMonitoringEnabled: isMonitoringEnabled
    extension: extension
    mtu: mtu
    connectedIPv4Subnets: !empty(connectedIPv4Subnets) ? connectedIPv4Subnets : null
    connectedIPv6Subnets: !empty(connectedIPv6Subnets) ? connectedIPv6Subnets : null
    staticRouteConfiguration: !empty(staticRouteConfiguration) ? {
      bfdConfiguration: staticRouteConfiguration.bfdConfiguration
      ipv4Routes: contains(staticRouteConfiguration, 'ipv4Routes') ? staticRouteConfiguration.ipv4Routes : null
      ipv6Routes: contains(staticRouteConfiguration, 'ipv6Routes') ? staticRouteConfiguration.ipv6Routes : null
      extension: extension
    } : null
    bgpConfiguration: !empty(bgpConfiguration) ? {
      bfdConfiguration: contains(bgpConfiguration, 'bfdConfiguration') ? bgpConfiguration.bfdConfiguration : null
      defaultRouteOriginate: bgpConfiguration.defaultRouteOriginate
      allowAS: bgpConfiguration.allowAS
      allowASOverride: bgpConfiguration.allowASOverride
      peerASN: bgpConfiguration.peerASN
      ipv4ListenRangePrefixes: contains(bgpConfiguration, 'ipv4ListenRangePrefixes') ? bgpConfiguration.ipv4ListenRangePrefixes : null
      ipv6ListenRangePrefixes: contains(bgpConfiguration, 'ipv6ListenRangePrefixes') ? bgpConfiguration.ipv6ListenRangePrefixes : null
      ipv4NeighborAddress: contains(bgpConfiguration, 'ipv4NeighborAddress') ? bgpConfiguration.ipv4NeighborAddress : null
      ipv6NeighborAddress: contains(bgpConfiguration, 'ipv6NeighborAddress') ? bgpConfiguration.ipv6NeighborAddress : null
      annotation: contains(bgpConfiguration, 'annotation') ? annotation : null
    } : null
    importRoutePolicy: !empty(importRoutePolicy) ? {
      importIpv4RoutePolicyId: contains(importRoutePolicy, 'importIpv4RoutePolicyId') ? importRoutePolicy.importIpv4RoutePolicyId : null
      importIpv6RoutePolicyId: contains(importRoutePolicy, 'importIpv6RoutePolicyId') ? importRoutePolicy.importIpv6RoutePolicyId : null
    } : null
    exportRoutePolicy: !empty(exportRoutePolicy) ? {
      exportIpv4RoutePolicyId: contains(exportRoutePolicy, 'exportIpv4RoutePolicyId') ? exportRoutePolicy.exportIpv4RoutePolicyId : null
      exportIpv6RoutePolicyId: contains(exportRoutePolicy, 'exportIpv6RoutePolicyId') ? exportRoutePolicy.exportIpv6RoutePolicyId : null
    } : null
  }
}

output resourceID string = internalNetwork.id
