@description('The name of the Front Door resource.')
param frontDoorName string

@description('The custom domain name to associate with your Front Door.')
param customDomainName string

@description('The fully qualified resource ID of the Key Vault that contains the custom domain\'s certificate.')
param certificateKeyVaultResourceId string

@description('The name of the Key Vault secret that contains the custom domain\'s certificate.')
param certificateKeyVaultSecretName string

@description('The version of the Key Vault secret that contains the custom domain\'s certificate.')
param certificateKeyVaultSecretVersion string = ''

@description('The hostname of the backend. Must be a public IP address or FQDN.')
param backendAddress string

var frontEndEndpointDefaultHostName = '${frontDoorName}.azurefd.net'
var frontEndEndpointDefaultName = replace(frontEndEndpointDefaultHostName, '.', '-')
var frontEndEndpointCustomName = replace(customDomainName, '.', '-')
var loadBalancingSettingsName = 'loadBalancingSettings'
var healthProbeSettingsName = 'healthProbeSettings'
var routingRuleName = 'routingRule'
var backendPoolName = 'backendPool'

resource frontDoor 'Microsoft.Network/frontDoors@2020-01-01' = {
  name: frontDoorName
  location: 'global'
  properties: {
    enabledState: 'Enabled'

    frontendEndpoints: [
      {
        name: frontEndEndpointDefaultName
        properties: {
          hostName: frontEndEndpointDefaultHostName
          sessionAffinityEnabledState: 'Disabled'
        }
      }
      {
        name: frontEndEndpointCustomName
        properties: {
          hostName: customDomainName
          sessionAffinityEnabledState: 'Disabled'
        }
      }
    ]

    loadBalancingSettings: [
      {
        name: loadBalancingSettingsName
        properties: {
          sampleSize: 4
          successfulSamplesRequired: 2
        }
      }
    ]

    healthProbeSettings: [
      {
        name: healthProbeSettingsName
        properties: {
          path: '/'
          protocol: 'Http'
          intervalInSeconds: 120
        }
      }
    ]

    backendPools: [
      {
        name: backendPoolName
        properties: {
          backends: [
            {
              address: backendAddress
              backendHostHeader: backendAddress
              httpPort: 80
              httpsPort: 443
              weight: 50
              priority: 1
              enabledState: 'Enabled'
            }
          ]
          loadBalancingSettings: {
            id: resourceId('Microsoft.Network/frontDoors/loadBalancingSettings', frontDoorName, loadBalancingSettingsName)
          }
          healthProbeSettings: {
            id: resourceId('Microsoft.Network/frontDoors/healthProbeSettings', frontDoorName, healthProbeSettingsName)
          }
        }
      }
    ]

    routingRules: [
      {
        name: routingRuleName
        properties: {
          frontendEndpoints: [
            {
              id: resourceId('Microsoft.Network/frontDoors/frontEndEndpoints', frontDoorName, frontEndEndpointDefaultName)
            }
            {
              id: resourceId('Microsoft.Network/frontDoors/frontEndEndpoints', frontDoorName, frontEndEndpointCustomName)
            }
          ]
          acceptedProtocols: [
            'Http'
            'Https'
          ]
          patternsToMatch: [
            '/*'
          ]
          routeConfiguration: {
            '@odata.type': '#Microsoft.Azure.FrontDoor.Models.FrontdoorForwardingConfiguration'
            forwardingProtocol: 'MatchRequest'
            backendPool: {
              id: resourceId('Microsoft.Network/frontDoors/backEndPools', frontDoorName, backendPoolName)
            }
          }
          enabledState: 'Enabled'
        }
      }
    ]
  }

  resource frontendEndpoint 'frontendEndpoints' existing = {
    name: frontEndEndpointCustomName
  }
}

// This resource enables a custom TLS certificate on the frontend.
resource customHttpsConfiguration 'Microsoft.Network/frontdoors/frontendEndpoints/customHttpsConfiguration@2020-07-01' = {
  parent: frontDoor::frontendEndpoint
  name: 'default'
  properties: {
    protocolType: 'ServerNameIndication'
    certificateSource: 'AzureKeyVault'
    keyVaultCertificateSourceParameters: {
      vault: {
        id: certificateKeyVaultResourceId
      }
      secretName: certificateKeyVaultSecretName
      secretVersion: (certificateKeyVaultSecretVersion == '') ? null : certificateKeyVaultSecretVersion
    }
    minimumTlsVersion: '1.2'
  }
}
