@description('The location into which regionally scoped resources should be deployed. Note that Front Door is a global resource.')
param location string = resourceGroup().location

@description('The name of the Azure Functions application to create. This must be globally unique.')
param functionAppName string = 'fn-${uniqueString(resourceGroup().id)}'

@description('The name of the SKU to use when creating the Azure Functions plan.')
param functionPlanSkuName string = 'EP1'

@description('The name of the Front Door endpoint to create. This must be globally unique.')
param frontDoorEndpointName string = 'afd-${uniqueString(resourceGroup().id)}'

@description('The name of the SKU to use when creating the Front Door profile.')
@allowed([
  'Standard_AzureFrontDoor'
  'Premium_AzureFrontDoor'
])
param frontDoorSkuName string = 'Standard_AzureFrontDoor'

var frontDoorProfileName = 'MyFrontDoor'
var frontDoorOriginGroupName = 'MyOriginGroup'
var frontDoorOriginName = 'MyAppServiceOrigin'
var frontDoorRouteName = 'MyRoute'

resource frontDoorProfile 'Microsoft.Cdn/profiles@2020-09-01' = {
  name: frontDoorProfileName
  location: 'global'
  sku: {
    name: frontDoorSkuName
  }
}

module functionApp 'modules/function.bicep' = {
  name: 'functionapp'
  params: {
    location: location
    appName: functionAppName
    functionPlanSkuName: functionPlanSkuName
    frontDoorId: frontDoorProfile.properties.frontdoorId
  }
}

resource frontDoorEndpoint 'Microsoft.Cdn/profiles/afdEndpoints@2020-09-01' = {
  name: frontDoorEndpointName
  parent: frontDoorProfile
  location: 'global'
  properties: {
    originResponseTimeoutSeconds: 240
    enabledState: 'Enabled'
  }
}

resource frontDoorOriginGroup 'Microsoft.Cdn/profiles/originGroups@2020-09-01' = {
  name: frontDoorOriginGroupName
  parent: frontDoorProfile
  properties: {
    loadBalancingSettings: {
      sampleSize: 4
      successfulSamplesRequired: 3
    }
    healthProbeSettings: {
      probePath: '/'
      probeRequestType: 'HEAD'
      probeProtocol: 'Http'
      probeIntervalInSeconds: 100
    }
  }
}

resource frontDoorOrigin 'Microsoft.Cdn/profiles/originGroups/origins@2020-09-01' = {
  name: frontDoorOriginName
  parent: frontDoorOriginGroup
  properties: {
    hostName: functionApp.outputs.functionAppHostName
    httpPort: 80
    httpsPort: 443
    originHostHeader: functionApp.outputs.functionAppHostName
    priority: 1
    weight: 1000
  }
}

resource frontDoorRoute 'Microsoft.Cdn/profiles/afdEndpoints/routes@2020-09-01' = {
  name: frontDoorRouteName
  parent: frontDoorEndpoint
  dependsOn: [
    frontDoorOrigin // This explicit dependency is required to ensure that the origin group is not empty when the route is created.
  ]
  properties: {
    originGroup: {
      id: frontDoorOriginGroup.id
    }
    supportedProtocols: [
      'Http'
      'Https'
    ]
    patternsToMatch: [
      '/*'
    ]
    compressionSettings: {
      contentTypesToCompress: [
        'application/eot'
        'application/font'
        'application/font-sfnt'
        'application/javascript'
        'application/json'
        'application/opentype'
        'application/otf'
        'application/pkcs7-mime'
        'application/truetype'
        'application/ttf'
        'application/vnd.ms-fontobject'
        'application/xhtml+xml'
        'application/xml'
        'application/xml+rss'
        'application/x-font-opentype'
        'application/x-font-truetype'
        'application/x-font-ttf'
        'application/x-httpd-cgi'
        'application/x-javascript'
        'application/x-mpegurl'
        'application/x-opentype'
        'application/x-otf'
        'application/x-perl'
        'application/x-ttf'
        'font/eot'
        'font/ttf'
        'font/otf'
        'font/opentype'
        'image/svg+xml'
        'text/css'
        'text/csv'
        'text/html'
        'text/javascript'
        'text/js'
        'text/plain'
        'text/richtext'
        'text/tab-separated-values'
        'text/xml'
        'text/x-script'
        'text/x-component'
        'text/x-java-source'
      ]
      isCompressionEnabled: true
    }
    queryStringCachingBehavior: 'IgnoreQueryString'
    forwardingProtocol: 'HttpsOnly'
    linkToDefaultDomain: 'Enabled'
    httpsRedirect: 'Enabled'
  }
}

output frontDoorEndpointFunctionUrl string = 'https://${frontDoorEndpoint.properties.hostName}/api/${functionApp.outputs.functionName}'
output functionAppFunctionUrl string = 'https://${functionApp.outputs.functionAppHostName}/api/${functionApp.outputs.functionName}'
