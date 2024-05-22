resource privatelink_blob_core_windows_net 'Microsoft.Network/privateDnsZones@2018-09-01' = {
  name: 'privatelink.blob.${environment().suffixes.storage}'
  location: 'global'
  tags: {}
  properties: {}
}

resource privatelink_file_core_windows_net 'Microsoft.Network/privateDnsZones@2018-09-01' = {
  name: 'privatelink.file.${environment().suffixes.storage}'
  location: 'global'
  tags: {}
  properties: {}
}

output blobDnsZoneId string = privatelink_blob_core_windows_net.id
output fileDnsZoneId string = privatelink_file_core_windows_net.id
