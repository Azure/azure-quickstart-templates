@description('The globally unique name of the SignalR resource to create.')
param name string = uniqueString(resourceGroup().id)

@description('Location for the SignalR resource.')
param location string = resourceGroup().location

@description('The pricing tier of the SignalR resource.')
@allowed([
  'Free_F1'
  'Standard_S1'
])
param pricingTier string = 'Standard_S1'

@description('The number of SignalR Unit.')
@allowed([
  1
  2
  5
  10
  20
  50
  100
])
param capacity int = 1

@description('Visit https://github.com/Azure/azure-signalr/blob/dev/docs/faq.md#service-mode to understand SignalR Service Mode.')
@allowed([
  'Default'
  'Serverless'
  'Classic'
])
param serviceMode string = 'Default'

@allowed([
  'true'
  'false'
])
param enableConnectivityLogs string = 'true'

@allowed([
  'true'
  'false'
])
param enableMessagingLogs string = 'true'

@allowed([
  'true'
  'false'
])
param enableLiveTrace string = 'true'

@description('Set the list of origins that should be allowed to make cross-origin calls.')
param allowedOrigins array = [
  'https://foo.com'
  'https://bar.com'
]

resource name_resource 'Microsoft.SignalRService/signalR@2022-02-01' = {
  name: name
  location: location
  sku: {
    capacity: capacity
    name: pricingTier
  }
  kind: 'SignalR'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    tls: {
      clientCertEnabled: false
    }
    features: [
      {
        flag: 'ServiceMode'
        value: serviceMode
      }
      {
        flag: 'EnableConnectivityLogs'
        value: enableConnectivityLogs
      }
      {
        flag: 'EnableMessagingLogs'
        value: enableMessagingLogs
      }
      {
        flag: 'EnableLiveTrace'
        value: enableLiveTrace
      }
    ]
    cors: {
      allowedOrigins: allowedOrigins
    }
    networkACLs: {
      defaultAction: 'Deny'
      publicNetwork: {
        allow: [
          'ClientConnection'
        ]
      }
      privateEndpoints: [
        {
          name: 'mySignalRService.1fa229cd-bf3f-47f0-8c49-afb36723997e'
          allow: [
            'ServerConnection'
          ]
        }
      ]
    }
    upstream: {
      templates: [
        {
          categoryPattern: '*'
          eventPattern: 'connect,disconnect'
          hubPattern: '*'
          urlTemplate: 'https://example.com/chat/api/connect'
        }
      ]
    }
  }
}
