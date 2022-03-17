@description('The host name that should be used when connecting to the origin for the API Management proxy gateway.')
param proxyOriginHostName string

@description('The name of the Front Door endpoint to create for the API Management proxy gateway. This must be globally unique.')
param proxyEndpointName string

@description('The resource ID of the API Management instance.')
param apiManagementResourceId string = ''

@description('The location of the API Management instance.')
param apiManagementLocation string = ''

var skuName = 'Premium_AzureFrontDoor'
var profileName = 'FrontDoor'
var proxyOriginGroupName = 'Proxy'
var proxyOriginName = 'ApiManagementProxy'
var proxyOriginPrivateLinkGroupId = 'Gateway'
var proxyRouteName = 'ProxyRoute'

resource profile 'Microsoft.Cdn/profiles@2021-06-01' = {
  name: profileName
  location: 'global'
  sku: {
    name: skuName
  }
}

resource proxyEndpoint 'Microsoft.Cdn/profiles/afdEndpoints@2021-06-01' = {
  name: proxyEndpointName
  parent: profile
  location: 'global'
  properties: {
    enabledState: 'Enabled'
  }
}

resource proxyOriginGroup 'Microsoft.Cdn/profiles/originGroups@2021-06-01' = {
  name: proxyOriginGroupName
  parent: profile
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

resource proxyOrigin 'Microsoft.Cdn/profiles/originGroups/origins@2021-06-01' = {
  name: proxyOriginName
  parent: proxyOriginGroup
  properties: {
    hostName: proxyOriginHostName
    httpPort: 80
    httpsPort: 443
    originHostHeader: proxyOriginHostName
    priority: 1
    weight: 1000
    sharedPrivateLinkResource: {
      privateLink: {
        id: apiManagementResourceId
      }
      groupId: proxyOriginPrivateLinkGroupId
      privateLinkLocation: apiManagementLocation
      requestMessage: 'Please approve this connection.'
    }
  }
}

resource proxyRoute 'Microsoft.Cdn/profiles/afdEndpoints/routes@2021-06-01' = {
  name: proxyRouteName
  parent: proxyEndpoint
  dependsOn: [
    proxyOrigin // This explicit dependency is required to ensure that the origin group is not empty when the route is created.
  ]
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
    forwardingProtocol: 'HttpsOnly'
    linkToDefaultDomain: 'Enabled'
    httpsRedirect: 'Enabled'
  }
}

output frontDoorId string = profile.properties.frontDoorId
output frontDoorProxyEndpointHostName string = proxyEndpoint.properties.hostName
