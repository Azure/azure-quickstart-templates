@description('The location into which regionally scoped resources should be deployed. Note that Front Door is a global resource.')
param location string = resourceGroup().location

@description('The IP address prefix (CIDR range) to use when deploying the virtual network.')
param vnetIPPrefix string = '10.0.0.0/16'

@description('The IP address prefix (CIDR range) to use when deploying the Application Gateway subnet within the virtual network.')
param applicationGatewaySubnetIPPrefix string = '10.0.0.0/24'

@description('The name of the Front Door endpoint to create. This must be globally unique.')
param frontDoorEndpointName string = 'afd-${uniqueString(resourceGroup().id)}'

@description('The host name that should be used when connecting from Application Gateway to the origin.')
param originHostName string

@description('The name of the SKU to use when creating the Front Door profile.')
@allowed([
  'Standard_AzureFrontDoor'
  'Premium_AzureFrontDoor'
])
param frontDoorSkuName string = 'Standard_AzureFrontDoor'

var frontDoorProfileName = 'MyFrontDoor'
var frontDoorOriginGroupName = 'MyOriginGroup'
var frontDoorOriginName = 'MyOrigin'
var frontDoorRouteName = 'MyRoute'
var frontDoorToApplicationGatewayProtocol = 'HttpOnly' // For this sample, we send traffic to Application Gateway using HTTP instead of HTTPS.  This is to keep the configuration of the Application Gateway simpler.  However, in production solutions you should use HTTPS and configure a certificate on the Application Gateway.

module network 'modules/network.bicep' = {
  name: 'network'
  params: {
    location: location
    vnetIPPrefix: vnetIPPrefix
    applicationGatewaySubnetIPPrefix: applicationGatewaySubnetIPPrefix
  }
}

resource frontDoorProfile 'Microsoft.Cdn/profiles@2021-06-01' = {
  name: frontDoorProfileName
  location: 'global'
  sku: {
    name: frontDoorSkuName
  }
}

module applicationGateway 'modules/application-gateway.bicep' = {
  name: 'application-gateway'
  params: {
    location: location
    backendFqdn: originHostName
    pickHostNameFromBackendAddress: true // This is required for multitenant backends, as per https://docs.microsoft.com/azure/application-gateway/configure-web-app-portal#edit-http-settings-for-app-service
    subnetResourceId: network.outputs.applicationGatewaySubnetResourceId
    frontDoorId: frontDoorProfile.properties.frontDoorId
  }
}

resource frontDoorEndpoint 'Microsoft.Cdn/profiles/afdEndpoints@2021-06-01' = {
  name: frontDoorEndpointName
  parent: frontDoorProfile
  location: 'global'
  properties: {
    enabledState: 'Enabled'
  }
}

resource frontDoorOriginGroup 'Microsoft.Cdn/profiles/originGroups@2021-06-01' = {
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

resource frontDoorOrigin 'Microsoft.Cdn/profiles/originGroups/origins@2021-06-01' = {
  name: frontDoorOriginName
  parent: frontDoorOriginGroup
  properties: {
    hostName: applicationGateway.outputs.publicIPAddressHostName
    httpPort: 80
    httpsPort: 443
    originHostHeader: applicationGateway.outputs.publicIPAddressHostName
    priority: 1
    weight: 1000
  }
}

resource frontDoorRoute 'Microsoft.Cdn/profiles/afdEndpoints/routes@2021-06-01' = {
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
    forwardingProtocol: frontDoorToApplicationGatewayProtocol
    linkToDefaultDomain: 'Enabled'
    httpsRedirect: 'Enabled'
  }
}

output applicationGatewayHostName string = applicationGateway.outputs.publicIPAddressHostName
output frontDoorEndpointHostName string = frontDoorEndpoint.properties.hostName
