@description('Name of the CDN Profile')
param profileName string = 'cdn-${uniqueString(resourceGroup().id)}'

@description('Name of the CDN Endpoint, must be unique')
param endpointName string = 'endpoint-${uniqueString(resourceGroup().id)}'

@description('Name of the App Service Plan')
param serverFarmName string = 'asp-${uniqueString(resourceGroup().id)}'

@description('Name of the App Service Web App')
param webAppName string = 'web-${uniqueString(resourceGroup().id)}'

@description('Location for all resources.')
param location string = resourceGroup().location

resource serverFarm 'Microsoft.Web/serverfarms@2021-02-01' = {
  name: serverFarmName
  location: location
  tags: {
    displayName: serverFarmName
  }
  sku: {
    name: 'F1'
    capacity: 1
  }
}

resource webApp 'Microsoft.Web/sites@2021-02-01' = {
  name: webAppName
  location: location
  tags: {
    displayName: webAppName
  }
  properties: {
    serverFarmId: serverFarm.id
    siteConfig:{
      ftpsState: 'FtpsOnly'
      minTlsVersion: '1.2'
      scmMinTlsVersion: '1.2'
    }
    httpsOnly: true
  }
  identity: {
    type: 'SystemAssigned'
  }
}

resource profile 'Microsoft.Cdn/profiles@2021-06-01' = {
  name: profileName
  location: location
  tags: {
    displayName: profileName
  }
  sku: {
    name: 'Standard_Microsoft'
  }
  properties: {}
}

resource endpoint 'Microsoft.Cdn/profiles/endpoints@2021-06-01' = {
  parent: profile
  name: endpointName
  location: location
  tags: {
    displayName: endpointName
  }
  properties: {
    originHostHeader: webApp.properties.hostNames[0]
    isHttpAllowed: true
    isHttpsAllowed: true
    queryStringCachingBehavior: 'IgnoreQueryString'
    contentTypesToCompress: [
      'text/plain'
      'text/html'
      'text/css'
      'application/x-javascript'
      'text/javascript'
    ]
    isCompressionEnabled: true
    origins: [
      {
        name: 'origin1'
        properties: {
          hostName: webApp.properties.hostNames[0]
        }
      }
    ]
  }
}

output hostName string = endpoint.properties.hostName
output originHostHeader string = endpoint.properties.originHostHeader
