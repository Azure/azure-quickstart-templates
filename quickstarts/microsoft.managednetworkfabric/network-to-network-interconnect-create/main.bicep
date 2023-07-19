@description('Name of the Network Fabric')
param networkFabricName string

@description('Name of the Network To Network Interconnect')
param networkToNetworkInterconnectName string

@description('Type of NNI used')
@allowed([
  'CE'
  'NPB'
])
param nniType string = 'CE'

@description('Configuration to use NNI for Infrastructure Management')
@allowed([
  'True'
  'False'
])
param isManagementType string = 'True'

@description('Based on this parameter the layer2/layer3 is made as mandatory')
@allowed([
  'True'
  'False'
])
param useOptionB string

@description('Common properties for Layer2Configuration')
param layer2Configuration object = {}

@description('Common properties for optionBLayer3Configuration')
param optionBLayer3Configuration object = {}

@description('NPB Static Route Configuration properties')
param npbStaticRouteConfiguration object = {}

@description('Import Route Policy configuration')
param importRoutePolicy object = {}

@description('Export Route Policy configuration')
param exportRoutePolicy object = {}

resource networkFabrics 'Microsoft.ManagedNetworkFabric/networkFabrics@2023-06-15' existing = {
  name: networkFabricName
}

resource networkToNetworkInterconnect 'Microsoft.ManagedNetworkFabric/networkFabrics/networkToNetworkInterconnects@2023-06-15' = {
  name: networkToNetworkInterconnectName
  parent: networkFabrics
  properties: {
    nniType: nniType
    isManagementType: isManagementType
    useOptionB: useOptionB
    layer2Configuration: !empty(layer2Configuration) ? {
      interfaces: contains(layer2Configuration, 'interfaces') ? layer2Configuration.interfaces : null
      mtu: contains(layer2Configuration, 'mtu') ? layer2Configuration.mtu : null
    } : null
    optionBLayer3Configuration: !empty(optionBLayer3Configuration) ? {
      peerASN: optionBLayer3Configuration.peerASN
      vlanId: optionBLayer3Configuration.vlanId
      primaryIpv4Prefix: contains(optionBLayer3Configuration, 'primaryIpv4Prefix') ? optionBLayer3Configuration.primaryIpv4Prefix : null
      primaryIpv6Prefix: contains(optionBLayer3Configuration, 'primaryIpv6Prefix') ? optionBLayer3Configuration.primaryIpv6Prefix : null
      secondaryIpv4Prefix: contains(optionBLayer3Configuration, 'secondaryIpv4Prefix') ? optionBLayer3Configuration.secondaryIpv4Prefix : null
      secondaryIpv6Prefix: contains(optionBLayer3Configuration, 'secondaryIpv6Prefix') ? optionBLayer3Configuration.secondaryIpv6Prefix : null
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
