@description('The name of the frontdoor resource.')
param frontDoorName string

@description('The hostname of the backend. Must be an IP address or FQDN.')
param backendAddress string

@description('Name of the Health probe settings associated with this Front Door instance.')
param healthProbeName string

@description('The path to use for the health probe. Default is /')
param healthProbePath string

@description('Protocol scheme to use for this probe. Must be Http or Https.')
@allowed([
  'Http'
  'Https'
])
param healthProbeProtocol string

@description('The number of seconds between health probes.')
param healthProbeIntervalInSeconds int

var frontdoorLocation = 'global'
var frontDoorSuffix = ((toLower(environment().name) == 'azureusgovernment') ? 'azurefd.us' : environment().suffixes.azureFrontDoorEndpointSuffix)
var frontDoorHostName = '${toLower(frontDoorName)}.${frontDoorSuffix}'

resource frontDoor 'Microsoft.Network/frontDoors@2020-05-01' = {
  name: frontDoorName
  location: frontdoorLocation
  properties: {
    routingRules: [
      {
        name: 'routingRule1'
        properties: {
          frontendEndpoints: [
            {
              id: resourceId('Microsoft.Network/frontDoors/frontendEndpoints', frontDoorName, 'frontendEndpoint1')
            }
          ]
          acceptedProtocols: [
            'Http'
          ]
          patternsToMatch: [
            '/*'
          ]
          routeConfiguration: {
            '@odata.type': '#Microsoft.Azure.FrontDoor.Models.FrontdoorForwardingConfiguration'
            forwardingProtocol: 'MatchRequest'
            backendPool: {
              id: resourceId('Microsoft.Network/frontDoors/backendPools', frontDoorName, 'backendPool1')
            }
          }
          enabledState: 'Enabled'
        }
      }
    ]
    healthProbeSettings: [
      {
        name: healthProbeName
        properties: {
          path: healthProbePath
          protocol: healthProbeProtocol
          intervalInSeconds: healthProbeIntervalInSeconds
        }
      }
    ]
    loadBalancingSettings: [
      {
        name: 'loadBalancingSettings1'
        properties: {
          sampleSize: 4
          successfulSamplesRequired: 2
        }
      }
    ]
    backendPools: [
      {
        name: 'backendPool1'
        properties: {
          backends: [
            {
              address: backendAddress
              httpPort: 80
              httpsPort: 443
              weight: 50
              priority: 1
              enabledState: 'Enabled'
            }
          ]
          loadBalancingSettings: {
            id: resourceId('Microsoft.Network/frontDoors/loadBalancingSettings', frontDoorName, 'loadBalancingSettings1')
          }
          healthProbeSettings: {
            id: resourceId('Microsoft.Network/frontDoors/healthProbeSettings', frontDoorName, 'healthProbeSettings1')
          }
        }
      }
    ]
    frontendEndpoints: [
      {
        name: 'frontendEndpoint1'
        properties: {
          hostName: frontDoorHostName
          sessionAffinityEnabledState: 'Disabled'
        }
      }
    ]
    enabledState: 'Enabled'
  }
}
