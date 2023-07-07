@description('Name of the External Network')
param externalNetworkName string

@description('Name of the L3 Isolation Domain')
param l3IsolationDomainName string

@description('Switch configuration description')
param annotation string = ''

@description('Peering option list')
@allowed([
  'OptionA'
  'OptionB'
])
param peeringOption string

@description('option A properties')
param optionAProperties object = {}

@description('option B properties')
param optionBProperties object = {}

@description('Import Route Policy configuration')
param importRoutePolicy object = {}

@description('Export Route Policy configuration')
param exportRoutePolicy object = {}

@description('Name of existing l3 Isolation Domain Resource')
resource l3IsolationDomains 'Microsoft.ManagedNetworkFabric/l3IsolationDomains@2023-06-15' existing = {
  name: l3IsolationDomainName
}

@description('Create External Network Resource')
resource externalNetwork 'Microsoft.ManagedNetworkFabric/l3IsolationDomains/externalNetworks@2023-06-15' = {
  name: externalNetworkName
  parent: l3IsolationDomains
  properties: {
    peeringOption: peeringOption
    annotation: !empty(annotation) ? annotation : null
    optionAProperties: !empty(optionAProperties) ? {
      bfdConfiguration: contains(optionAProperties, 'bfdConfiguration') ? optionAProperties.bfdConfiguration : null
      mtu: contains(optionAProperties, 'mtu') ? optionAProperties.mtu : null
      vlanId: optionAProperties.vlanId
      peerASN: optionAProperties.peerASN
      primaryIpv4Prefix: contains(optionAProperties, 'primaryIpv4Prefix') ? optionAProperties.primaryIpv4Prefix : null
      primaryIpv6Prefix: contains(optionAProperties, 'primaryIpv6Prefix') ? optionAProperties.primaryIpv6Prefix : null
      secondaryIpv4Prefix: contains(optionAProperties, 'secondaryIpv4Prefix') ? optionAProperties.secondaryIpv4Prefix : null
      secondaryIpv6Prefix: contains(optionAProperties, 'secondaryIpv6Prefix') ? optionAProperties.secondaryIpv6Prefix : null
    } : null
    optionBProperties: !empty(optionBProperties) ? {
      routeTargets: contains(optionBProperties, 'routeTargets') ? optionBProperties.routeTargets : null
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

output resourceID string = externalNetwork.id
