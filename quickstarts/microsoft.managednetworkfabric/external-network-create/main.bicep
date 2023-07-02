@description('Name of the External Network')
param externalNetworkName string

@description('Name of the L3 Isolation Domain')
param l3IsolationDomainName string

@description('Switch configuration description')
param annotation string

@description('Peering option list')
@allowed([
  'OptionA'
  'OptionB'
])
param peeringOption string

@description('option A properties')
param optionAProperties object

@description('option B properties')
param optionBProperties object

@description('ARM resource ID of importRoutePolicy')
param importRoutePolicyId string

@description('ARM resource ID of exportRoutePolicy')
param exportRoutePolicyId string

@description('Import Route Policy configuration')
param importRoutePolicy object

@description('Export Route Policy configuration')
param exportRoutePolicy object

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
    annotation: annotation
    optionAProperties: optionAProperties != {} ? {
      bfdConfiguration: optionAProperties.bfdConfiguration
      mtu: optionAProperties.mtu != '' ? optionAProperties.mtu : null
      vlanId: optionAProperties.vlanId
      peerASN: optionAProperties.peerASN
      primaryIpv4Prefix: optionAProperties.primaryIpv4Prefix != '' ? optionAProperties.primaryIpv4Prefix : null
      primaryIpv6Prefix: optionAProperties.primaryIpv6Prefix != '' ? optionAProperties.primaryIpv6Prefix : null
      secondaryIpv4Prefix: optionAProperties.secondaryIpv4Prefix != '' ? optionAProperties.secondaryIpv4Prefix : null
      secondaryIpv6Prefix: optionAProperties.secondaryIpv6Prefix != '' ? optionAProperties.secondaryIpv6Prefix : null
    } : null
    optionBProperties: optionBProperties != {} ? {
      importRouteTargets: optionBProperties.importRouteTargets != '' ? optionBProperties.importRouteTargets : null
      exportRouteTargets: optionBProperties.exportRouteTargets != '' ? optionBProperties.exportRouteTargets : null
      routeTargets: optionBProperties.routeTargets
    } : null
    importRoutePolicyId: importRoutePolicyId != '' ? importRoutePolicyId : null
    exportRoutePolicyId: exportRoutePolicyId != '' ? exportRoutePolicyId : null
    importRoutePolicy: importRoutePolicy
    exportRoutePolicy: exportRoutePolicy
  }
}

output resourceID string = externalNetwork.id
