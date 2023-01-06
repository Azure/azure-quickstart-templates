@description('Name of the Network Rack')
param networkRackName string

@description('Azure Region for deployment of the Network Rack and associated resources')
param location string = resourceGroup().location

@description('Resource Id of the Network Fabric, is should be in the format of /subscriptions/<Sub ID>/resourceGroups/<Resource group name>/providers/Microsoft.ManagedNetworkFabric/networkFabrics/<networkFabric name>')
param networkFabricId string

@description('Name of the Network Rack SKU')
param networkRackSku string

@description('Create Network Rack Resource')
resource networkRacks 'Microsoft.ManagedNetworkFabric/networkRacks@2022-01-15-privatepreview' = {
  name: networkRackName
  location: location
  properties: {
    networkRackSku: networkRackSku
    networkFabricId: networkFabricId
  }
}

output resourceID string = networkRacks.id
