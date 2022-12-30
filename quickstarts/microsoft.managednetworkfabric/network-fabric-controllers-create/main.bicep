@description('Name of the Network Fabric Controller')
param networkFabricControllerName string

@description('Azure Region for deployment of the Network Fabric Controller and associated resources')
param location string = resourceGroup().location

var infraExRCircuitId = 'aaaaaa'
var infraExRAuthKey = 'abcdefgh'
var workloadExRCircuitId = 'bbbb'
var workloadExRAuthKey = 'abcdefgh'
var managedResourceGroupName = 'managedResourceGroupName'
var ipv4AddressSpace = '10.0.0.0/19'

@description('Create Network Fabric Controller Resource')
resource networkFabricController 'Microsoft.ManagedNetworkFabric/networkFabricControllers@2022-01-15-privatepreview' = {
  name: networkFabricControllerName
  location: location
  properties: {
    infrastructureExpressRouteConnections: [
      {
        expressRouteCircuitId: infraExRCircuitId
        expressRouteAuthorizationKey: infraExRAuthKey
      }
    ]
    workloadExpressRouteConnections: [
      {
        expressRouteCircuitId: workloadExRCircuitId
        expressRouteAuthorizationKey: workloadExRAuthKey
      }
    ]
    managedResourceGroupConfiguration: {
      name: managedResourceGroupName
      location: location
    }
    ipv4AddressSpace: ipv4AddressSpace
  }
}
