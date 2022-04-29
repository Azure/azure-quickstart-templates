/* This Bicep file deploys a new instance of Azure Web PubSub service. It's the template for "Quickstart: Create an Azure Web PubSub instance using Bicep" in the Azure documentation. Use it as a convenient starting point for tutorials, testing, or as a component of a more complex deployment.

  WORK IN PROGRESS 04/28/2022

*/

// Parameters

@description('The name for your new Web PubSub instance.')
param wpsName string = 'simpleWebPubSub'

@description('The region in which to create the new instance, defaults to the same location as the resource group.')
param wpsLocation string = resourceGroup().location

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
param wpsUnitCount int = 1

@description('SKU name')
@allowed([
  'Standard_S1'
  'Free_F1'
])
param wpsSkuName string = 'Free_F1'

@description('Priciing tier')
@allowed([
  'Free'
  'Standard'
])
param wpsPricingTier string = 'Free'



// Resource definition
resource symbolicname 'Microsoft.SignalRService/webPubSub@2021-10-01' = {
  name: wpsName
  location: wpsLocation
  /*
  tags: {
    tagName1: 'tagValue1'
    tagName2: 'tagValue2'
  }
  */
  sku: {
    capacity: wpsUnitCount
    name: wpsSkuName
    tier: wpsPricingTier
  }
  identity: {
    type: 'string'
    userAssignedIdentities: {}
  }
  properties: {
    disableAadAuth: false
    disableLocalAuth: false
    liveTraceConfiguration: {
      categories: [
        {
          enabled: 'false'
          name: 'ConnectivityLogs'
        },
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
        },
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
