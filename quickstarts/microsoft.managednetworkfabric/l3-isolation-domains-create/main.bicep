@description('Name of the L3 Isolation Domain')
param l3DomainName string

@description('Azure Region for deployment of the L3 Isolation Domain and associated resources')
param location string = resourceGroup().location

@description('Resource Id of the Network Fabric, is should be in the format of /subscriptions/<Sub ID>/resourceGroups/<Resource group name>/providers/Microsoft.ManagedNetworkFabric/networkFabrics/<networkFabric name>')
param networkFabricId string

@description('Import Route Policy Ids')
param importRoutePolicyIds array

@description('Export Route Policy Ids')
param exportRoutePolicyIds array

@description('Import Route targets to be configured on CEs')
param importRouteTargets array

@description('Export Route targets to be configured on CEs')
param exportRouteTargets array

@description('Create L3 Isolation Domain  Resource')
resource l3IsolationDomains 'Microsoft.ManagedNetworkFabric/l3IsolationDomains@2022-01-15-privatepreview' = {
  name: l3DomainName
  location: location
  properties: {
    networkFabricId: networkFabricId
    internal: {
      importRoutePolicyIds: importRoutePolicyIds
      exportRoutePolicyIds: exportRoutePolicyIds
    }
    external: {
      importRoutePolicyIds: importRoutePolicyIds
      exportRoutePolicyIds: exportRoutePolicyIds
      optionBConfiguration: {
        importRouteTargets: importRouteTargets
        exportRouteTargets: exportRouteTargets
      }
    }
  }
}

output resourceID string = l3IsolationDomains.id
