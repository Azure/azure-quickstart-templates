/* This Bicep file deploys a new instance of Azure Web PubSub service. */

// Parameters

@description('The name for your new Web PubSub instance.')
@maxLength(63)
@minLength(3)
param wpsName string = uniqueString(resourceGroup().id)

@description('The region in which to create the new instance, defaults to the same location as the resource group.')
param location string = resourceGroup().location

@description('Unit count')
@allowed([
  1
  2
  5
  10
  20
  50
  100
])
param unitCount int = 1

@description('SKU name')
@allowed([
  'Standard_S1'
  'Free_F1'
])
param sku string = 'Free_F1'

@description('Pricing tier')
@allowed([
  'Free'
  'Standard'
])
param pricingTier string = 'Free'

// Resource definition
resource webpubsub 'Microsoft.SignalRService/webPubSub@2021-10-01' = {
  name: wpsName
  location: location
  sku: {
    capacity: unitCount
    name: sku
    tier: pricingTier
  }
  identity: {
    type: 'None'
  }
  properties: {
    disableAadAuth: false
    disableLocalAuth: false
    liveTraceConfiguration: {
      categories: [
        {
          enabled: 'false'
          name: 'ConnectivityLogs'
        }
        {
          enabled: 'false'
          name: 'MessagingLogs'
        }
      ]
      enabled: 'false'
    }
    networkACLs: {
      defaultAction: 'Deny'     
      publicNetwork: {
        allow: [
          'ServerConnection'
          'ClientConnection'
          'RESTAPI'
          'Trace'
        ]
      }
    }
    publicNetworkAccess: 'Enabled'
    resourceLogConfiguration: {
      categories: [
        {
          enabled: 'true'
          name: 'ConnectivityLogs'
        }
        {
          enabled: 'true'
          name: 'MessagingLogs'
        }
      ]
    }
    tls: {
      clientCertEnabled: false
    }
  }
}
