@description('Name for the blob PE endpoint')
param privateEndpointNameBlob string

@description('Name for the file PE endpoint')
param privateEndpointNameFile string

@description('Dns Zone ID for File Blob Storage')
param fileDnsZoneId string

@description('Dns Zone ID for Blob Blob Storage')
param blobDnsZoneId string

resource privateEndpointName_blob_default 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-11-01' = {
  name: '${privateEndpointNameBlob}/default'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'privatelink-blob-core-windows-net'
        properties: {
            privateDnsZoneId: blobDnsZoneId
        }
      }
    ]
  }
}

resource privateEndpointName_file_default 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-11-01' = {
  name: '${privateEndpointNameFile}/default'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'privatelink-file-core-windows-net'
        properties: {
            privateDnsZoneId: fileDnsZoneId
        }
      }
    ]
  }
}
