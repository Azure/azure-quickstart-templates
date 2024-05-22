@description('Name for the blob PE endpoint')
param privateEndpointNameBlob string

@description('Name for the file PE endpoint')
param privateEndpointNameFile string

@description('Azure region of the deployment')
param location string

@description('Resource Vnet name of the virtual network')
param vnetRgName string

var subscriptionId = subscription().subscriptionId

resource privateEndpointName_blob_default 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-05-01' = {
  name: '${privateEndpointNameBlob}/default'
  location: location
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'privatelink-blob-core-windows-net'
        properties: {
            privateDnsZoneId: '/subscriptions/${subscriptionId}/resourceGroups/${vnetRgName}/providers/Microsoft.Network/privateDnsZones/privatelink.blob.core.windows.net'
        }
      }
    ]
  }
}

resource privateEndpointName_file_default 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-05-01' = {
  name: '${privateEndpointNameFile}/default'
  location: location
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'privatelink-file-core-windows-net'
        properties: {
            privateDnsZoneId: '/subscriptions/${subscriptionId}/resourceGroups/${vnetRgName}/providers/Microsoft.Network/privateDnsZones/privatelink.file.core.windows.net'
        }
      }
    ]
  }
}
