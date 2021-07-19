@description('Location for all resources.')
param location string = resourceGroup().location

var storageAccountName = 'storage${uniqueString(resourceGroup().id)}'
var endpointName = 'endpoint-${uniqueString(resourceGroup().id)}'
var profileName = 'cdn-${uniqueString(resourceGroup().id)}'
var storageAccountHostName = replace(replace(storageAccount.properties.primaryEndpoints.blob, 'https://', ''), '/', '')

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-01-01' = {
  name: storageAccountName
  location: location
  tags: {
    displayName: storageAccountName
  }
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
}

resource cdnProfile 'Microsoft.Cdn/profiles@2020-09-01' = {
  name: profileName
  location: location
  tags: {
    displayName: profileName
  }
  sku: {
    name: 'Standard_Verizon'
  }
}

resource endpoint 'Microsoft.Cdn/profiles/endpoints@2020-09-01' = {
  parent: cdnProfile
  name: endpointName
  location: location
  tags: {
    displayName: endpointName
  }
  properties: {
    originHostHeader: storageAccountHostName
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
          hostName: storageAccountHostName
        }
      }
    ]
  }
}

output hostName string = endpoint.properties.hostName
output originHostHeader string = endpoint.properties.originHostHeader
