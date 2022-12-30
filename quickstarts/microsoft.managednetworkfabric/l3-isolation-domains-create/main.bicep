@description('Name of the L3 Isolation Domain')
param l3DomainName string

@description('Azure Region for deployment of the L3 Isolation Domain and associated resources')
param location string = resourceGroup().location

var networkFabricId = '/subscriptions/d854f6e5-7f11-4515-9d58-2ef770a77ee2/resourceGroups/rahul-rg/providers/Microsoft.ManagedNetworkFabric/networkFabrics/rahulnf1'

@description('Create L3 Isolation Domain  Resource')
resource l3IsolationDomains 'Microsoft.ManagedNetworkFabric/l3IsolationDomains@2022-01-15-privatepreview' = {
  name: l3DomainName
  location: location
  properties: {
    networkFabricId: networkFabricId
    external: {
      optionBConfiguration: {
        importRouteTargets: [ '1234:1235' ]
        exportRouteTargets: [ '4321:5321' ]
      }
    }

  }
}
