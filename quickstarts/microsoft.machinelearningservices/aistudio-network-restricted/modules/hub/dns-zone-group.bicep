@description('Name for the endpoint')
param privateEndpointName string

@description('Dns Zone ID for notebook private link')
param notebookDnsZoneId string

@description('Dns Zone ID for API private link')
param apiDnsZoneId string

resource privateEndpointName_default 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-11-01' = {
  name: '${privateEndpointName}/default'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'privatelink-api-azureml-ms'
        properties: {
            privateDnsZoneId: apiDnsZoneId
        }
      }
      {
        name: 'privatelink-notebooks-azure-net'
        properties: {
            privateDnsZoneId: notebookDnsZoneId
        }
      }
    ]
  }
}
