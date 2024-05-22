resource privatelink_api_azureml_ms 'Microsoft.Network/privateDnsZones@2018-09-01' = {
  name: 'privatelink.api.azureml.ms'
  location: 'global'
  tags: {}
  properties: {}
}

resource privatelink_notebooks_azure_net 'Microsoft.Network/privateDnsZones@2018-09-01' = {
  name: 'privatelink.notebooks.azure.net'
  location: 'global'
  tags: {}
  properties: {}
}

output notebookDnsZoneId string = privatelink_notebooks_azure_net.id
output apiDnsZoneId string = privatelink_api_azureml_ms.id
