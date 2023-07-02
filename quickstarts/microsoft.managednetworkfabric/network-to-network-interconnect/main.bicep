@description('Name of the Network Fabric')
param networkFabricName string

@description('Name of the Network To Network Interconnect')
param networkToNetworkInterconnectName string

@description('Type of NNI used')
@allowed([
  'CE'
  'NPB'
])
param nniType string

@description('Configuration to use NNI for Infrastructure Management')
@allowed([
  'True'
  'False'
])
param isManagementType string

@description('Based on this parameter the layer2/layer3 is made as mandatory')
@allowed([
  'True'
  'False'
])
param useOptionB string

@description('Common properties for Layer2Configuration')
param layer2Configuration object

@description('Common properties for optionBLayer3Configuration')
param optionBLayer3Configuration object

@description('NPB Static Route Configuration properties')
param npbStaticRouteConfiguration object

@description('Import Route Policy configuration')
param importRoutePolicy object

@description('Export Route Policy configuration')
param exportRoutePolicy object

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
    layer2Configuration: layer2Configuration
    optionBLayer3Configuration: optionBLayer3Configuration
    npbStaticRouteConfiguration: npbStaticRouteConfiguration
    importRoutePolicy: importRoutePolicy
    exportRoutePolicy: exportRoutePolicy
  }
}
