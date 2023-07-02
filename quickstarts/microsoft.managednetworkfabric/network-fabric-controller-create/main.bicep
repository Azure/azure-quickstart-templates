@description('Name of the Network Fabric Controller')
param networkFabricControllerName string

@description('Azure Region for deployment of the Network Fabric Controller and associated resources')
param location string = resourceGroup().location

@description('Switch configuration description')
param annotation string

@description('A workload management network is required for all the tenant (workload) traffic. This traffic is only dedicated for Tenant workloads which are required to access internet or any other MSFT/Public endpoints')
@allowed([
  'False'
  'True'
])
param workloadManagementNetwork string

@description('Network Fabric Controller SKU')
@allowed([
  'Basic'
  'HighPerformance'
  'Standard'
])
param nfcSku string

@description('Name of Express Route circuit')
param infraExRCircuitId string

@description('Authorization key for the circuit')
param infraExRAuthKey string

@description('Name of Express Route circuit')
param workloadExRCircuitId string

@description('Authorization key for the circuit')
param workloadExRAuthKey string

@description('IPv4 Network Fabric Controller Address Space')
param ipv4AddressSpace string

@description('IPv6 Network Fabric Controller Address Space')
param ipv6AddressSpace string

@description('Create Network Fabric Controller Resource')
resource networkFabricController 'Microsoft.ManagedNetworkFabric/networkFabricControllers@2023-06-15' = {
  name: networkFabricControllerName
  location: location
  properties: {
    annotation: annotation != '' ? annotation : null
    workloadManagementNetwork: workloadManagementNetwork != '' ? workloadManagementNetwork : null
    nfcSku: nfcSku != '' ? nfcSku : null
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
    ipv4AddressSpace: ipv4AddressSpace != '' ? ipv4AddressSpace : null
    ipv6AddressSpace: ipv6AddressSpace != '' ? ipv6AddressSpace : null
  }
}

output resourceID string = networkFabricController.id
