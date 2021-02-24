param location string {
  allowed:[
    'eastus'
    'westus2'
    'southcentralus'
  ]
  metadata: {
    description: 'When using Private Link origins with Front Door Premium during the preview period, there is a limited set of regions available for use. See https://docs.microsoft.com/en-us/azure/frontdoor/standard-premium/concept-private-link#limitations for more details.'
  }
}
param appName string
param appServicePlanSkuName string {
  metadata: {
    description: 'The SKU name to use for App Service. This must be a SKU that is compatible with private endpoints, i.e. P1v2 or better.'
  }
}
param appServicePlanCapacity int
param frontDoorEndpointName string

var appServicePlanName = 'AppServicePlan'
var appServicePrivateLinkGroupId = 'sites' // For App Service and Azure Functions, this needs to be 'sites'.

var frontDoorSkuName = 'Premium_AzureFrontDoor' // Private Link origins require the premium SKU.
var frontDoorProfileName = 'MyFrontDoor'
var frontDoorOriginGroupName = 'MyOriginGroup'
var frontDoorOriginName = 'MyOrigin'
var frontDoorOriginPath = ''
var frontDoorRouteName = 'MyRoute'

resource appServicePlan 'Microsoft.Web/serverfarms@2020-06-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: appServicePlanSkuName
    capacity: appServicePlanCapacity
  }
  kind: 'app'
}

resource app 'Microsoft.Web/sites@2020-06-01' = {
  name: appName
  location: location
  kind: 'app'
  properties: {
    serverFarmId: appServicePlan.id
  }
}

resource frontDoorProfile 'Microsoft.Cdn/profiles@2020-09-01' = {
  name: frontDoorProfileName
  location: 'global'
  sku: {
    name: frontDoorSkuName
  }
  properties: {}
}

resource frontDoorEndpoint 'Microsoft.Cdn/profiles/afdEndpoints@2020-09-01' = {
  name: '${frontDoorProfile.name}/${frontDoorEndpointName}'
  location: 'global'
  properties: {
    originResponseTimeoutSeconds: 240
    enabledState: 'Enabled'
  }
}

resource frontDoorOriginGroup 'Microsoft.Cdn/profiles/originGroups@2020-09-01' = {
  name: '${frontDoorProfile.name}/${frontDoorOriginGroupName}'
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
    trafficRestorationTimeToHealedOrNewEndpointsInMinutes: null
  }
}

resource frontDoorOrigin 'Microsoft.Cdn/profiles/originGroups/origins@2020-09-01' = {
  name: '${frontDoorOriginGroup.name}/${frontDoorOriginName}'
  properties: {
    hostName: app.properties.defaultHostName
    httpPort: 80
    httpsPort: 443
    originHostHeader: app.properties.defaultHostName
    priority: 1
    weight: 1000
    sharedPrivateLinkResource: {
      privateLink: {
        id: app.id
      }
      groupId: appServicePrivateLinkGroupId
      privateLinkLocation: location
      requestMessage: 'Please approve this connection.'
    }
  }
}

resource frontDoorRoute 'Microsoft.Cdn/profiles/afdEndpoints/routes@2020-09-01' = {
  name: '${frontDoorEndpoint.name}/${frontDoorRouteName}'
  properties: {
    customDomains: []
    originGroup: {
      id: frontDoorOriginGroup.id
    }
    originPath: frontDoorOriginPath != '' ? frontDoorOriginPath : null
    ruleSets: null
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

output appServiceHostName string = app.properties.defaultHostName
output frontDoorEndpointHostName string = frontDoorEndpoint.properties.hostName
