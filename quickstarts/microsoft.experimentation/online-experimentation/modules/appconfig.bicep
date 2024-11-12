metadata description = 'Creates an Azure App Configuration store.'
param name string
param location string = resourceGroup().location
param tags object = {}
param appInsightsId string

resource configStore 'Microsoft.AppConfiguration/configurationStores@2023-09-01-preview' = {
  name: name
  location: location
  sku: {
    name: 'standard'
  }
  tags: tags
  properties: {
    encryption: {}
    disableLocalAuth: true
    enablePurgeProtection: false
    experimentation:{}
    dataPlaneProxy:{
      authenticationMode: 'Pass-through'
      privateLinkDelegation: 'Disabled'
    }
    telemetry: {
      resourceId: appInsightsId
    }
  }
}

output endpoint string = configStore.properties.endpoint
output name string = configStore.name
