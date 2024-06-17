@description('Specifies the location for resources.')
param location string = resourceGroup().location

@description('The name of the API center.')
param apiCenterName string = 'apicenter${uniqueString(resourceGroup().id)}'

@description('The name of an API to register in the API center.')
param apiName string = 'first-api'

@description('The type of the API to register in the API center.')
@allowed([
  'rest'
  'soap'
  'graphql'
  'grpc'
  'webhook'
  'websocket'
])
param apiType string = 'rest'

resource apiCenterService 'Microsoft.ApiCenter/services@2024-03-01' = {
  name: apiCenterName
  location: location
  properties: {}
}

resource apiCenterWorkspace 'Microsoft.ApiCenter/services/workspaces@2024-03-01' = {
  parent: apiCenterService
  name: 'default'
  properties: {
    title: 'Default workspace'
    description: 'Default workspace'
  }
}

resource apiCenterAPI 'Microsoft.ApiCenter/services/workspaces/apis@2024-03-01' = {
  parent: apiCenterWorkspace
  name: apiName
  properties: {
    title: apiName
    kind: apiType
    externalDocumentation: [
      {
        description: 'API Center documentation'
        title: 'API Center documentation'
        url: 'https://learn.microsoft.com/azure/api-center/overview'
      }
    ]
    contacts: [
      {
        email: 'apideveloper@contoso.com'
        name: 'API Developer'
        url: 'https://learn.microsoft.com/azure/api-center/overview'
      }
    ]
    customProperties: {}
    summary: 'This is a test API, deployed using a template!'
    description: 'This is a test API, deployed using a template!'
  }
}
