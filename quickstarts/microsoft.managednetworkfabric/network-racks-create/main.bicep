@description('Name of the Network Rack')
param networkRackName string

@description('Azure Region for deployment of the Network Rack and associated resources')
param location string = resourceGroup().location

var networkRackSku = 'fab1'
var networkFabricId = '/subscriptions/d854f6e5-7f11-4515-9d58-2ef770a77ee2/resourceGroups/rahul-rg/providers/Microsoft.ManagedNetworkFabric/networkFabrics/rahul-nf'

@description('Create Network Rack Resource')
resource networkRacks 'Microsoft.ManagedNetworkFabric/networkRacks@2022-01-15-privatepreview' = {
  name: networkRackName
  location: location
  properties: {
    networkRackSku: networkRackSku
    networkFabricId: networkFabricId
  }
}
