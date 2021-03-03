@description('The host name that should be used when connecting to the origin for the API Management proxy gateway.')
param proxyOriginHostName string

@description('The host name that should be used when connecting to the origin for the API Management developer portal.')
param developerPortalOriginHostName string

@description('The name of the Front Door endpoint to create for the API Management proxy gateway. This must be globally unique.')
param proxyEndpointName string

@description('The name of the Front Door endpoint to create for the API Management developer portal. This must be globally unique.')
param developerPortalEndpointName string

@description('The name of the SKU to use when creating the Front Door profile. If you use Private Link this must be set to `Premium_AzureFrontDoor`.')
@allowed([
  'Standard_AzureFrontDoor'
  'Premium_AzureFrontDoor'
])
param skuName string

var profileName = 'FrontDoor'
var proxyOriginGroupName = 'Proxy'
var developerPortalOriginGroupName = 'DeveloperPortal'
var proxyOriginName = 'ApiManagementProxy'
var developerPortalOriginName = 'ApiManagementDeveloperPortal'
var proxyRouteName = 'ProxyRoute'
var developerPortalRouteName = 'DeveloperPortalRoute'

resource profile 'Microsoft.Cdn/profiles@2020-09-01' = {
  name: profileName
  location: 'global'
  sku: {
    name: skuName
  }
}

resource proxyEndpoint 'Microsoft.Cdn/profiles/afdEndpoints@2020-09-01' = {
  name: '${profile.name}/${proxyEndpointName}'
  location: 'global'
  properties: {
    originResponseTimeoutSeconds: 240
    enabledState: 'Enabled'
  }
}

resource proxyOriginGroup 'Microsoft.Cdn/profiles/originGroups@2020-09-01' = {
  name: '${profile.name}/${proxyOriginGroupName}'
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

resource proxyOrigin 'Microsoft.Cdn/profiles/originGroups/origins@2020-09-01' = {
  name: '${proxyOriginGroup.name}/${proxyOriginName}'
  properties: {
    hostName: proxyOriginHostName
    httpPort: 80
    httpsPort: 443
    originHostHeader: proxyOriginHostName
    priority: 1
    weight: 1000
  }
}

resource proxyRoute 'Microsoft.Cdn/profiles/afdEndpoints/routes@2020-09-01' = {
  name: '${proxyEndpoint.name}/${proxyRouteName}'
  properties: {
    originGroup: {
      id: proxyOriginGroup.id
    }
    supportedProtocols: [
      'Http'
      'Https'
    ]
    patternsToMatch: [
      '/*'
    ]
    queryStringCachingBehavior: 'NotSet'
    forwardingProtocol: 'HttpOnly'
    linkToDefaultDomain: 'Enabled'
    httpsRedirect: 'Enabled'
  }
}

resource developerPortalEndpoint 'Microsoft.Cdn/profiles/afdEndpoints@2020-09-01' = {
  name: '${profile.name}/${developerPortalEndpointName}'
  location: 'global'
  properties: {
    originResponseTimeoutSeconds: 240
    enabledState: 'Enabled'
  }
}

resource developerPortalOriginGroup 'Microsoft.Cdn/profiles/originGroups@2020-09-01' = {
  name: '${profile.name}/${developerPortalOriginGroupName}'
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

resource developerPortalOrigin 'Microsoft.Cdn/profiles/originGroups/origins@2020-09-01' = {
  name: '${developerPortalOriginGroup.name}/${developerPortalOriginName}'
  properties: {
    hostName: developerPortalOriginHostName
    httpPort: 80
    httpsPort: 443
    originHostHeader: developerPortalOriginHostName
    priority: 1
    weight: 1000
  }
}

resource developerPortalRoute 'Microsoft.Cdn/profiles/afdEndpoints/routes@2020-09-01' = {
  name: '${developerPortalEndpoint.name}/${developerPortalRouteName}'
  properties: {
    originGroup: {
      id: developerPortalOriginGroup.id
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
    forwardingProtocol: 'HttpOnly'
    linkToDefaultDomain: 'Enabled'
    httpsRedirect: 'Enabled'
  }
}

output frontDoorId string = profile.properties.frontDoorId
output frontDoorProxyEndpointHostName string = proxyEndpoint.properties.hostName
output frontDoorDeveloperPortalEndpointHostName string = developerPortalEndpoint.properties.hostName
