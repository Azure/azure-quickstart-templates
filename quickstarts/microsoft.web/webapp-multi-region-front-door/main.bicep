@description('The location into which regionally scoped resources should be deployed. Note that Front Door is a global resource.')
param location string = resourceGroup().location

@description('The location into which regionally scoped resources for the secondary should be deployed.')
param secondaryLocation string = 'eastus'

@description('The name of the App Service application to create. This must be globally unique.')
param webAppName string = 'myApp-${uniqueString(resourceGroup().id)}'

@description('The name of the secondary App Service application to create. This must be globally unique.')
param secondaryWebAppName string = 'mySecondaryApp-${uniqueString(resourceGroup().id)}'

@description('The name of the SKU to use when creating the App Service plan.')
param appServicePlanSkuName string = 'P1V2'

@description('The number of worker instances of your App Service plan that should be provisioned.')
param appServicePlanCapacity int = 1

@description('The name of the Front Door endpoint to create. This must be globally unique.')
param frontDoorEndpointName string = 'afd-${uniqueString(resourceGroup().id)}'

@description('The name of the SKU to use when creating the Front Door profile.')
@allowed([
  'Standard_AzureFrontDoor'
  'Premium_AzureFrontDoor'
])
param frontDoorSkuName string = 'Standard_AzureFrontDoor'

var appServicePlanName = 'AppServicePlan'
var secondaryAppServicePlanName = 'SecondaryAppServicePlan'

var frontDoorProfileName = 'MyFrontDoor'
var frontDoorOriginGroupName = 'MyOriginGroup'
var frontDoorOriginName = 'MyAppServiceOrigin'
var secondaryFrontDoorOriginName = 'MySecondaryAppServiceOrigin'
var frontDoorRouteName = 'MyRoute'

resource frontDoorProfile 'Microsoft.Cdn/profiles@2021-06-01' = {
  name: frontDoorProfileName
  location: 'global'
  sku: {
    name: frontDoorSkuName
  }
}

resource appServicePlan 'Microsoft.Web/serverFarms@2020-06-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: appServicePlanSkuName
    capacity: appServicePlanCapacity
  }
  kind: 'app'
  properties: {
    reserved: true
  }
}

resource secondaryAppServicePlan 'Microsoft.Web/serverFarms@2020-06-01' = {
  name: secondaryAppServicePlanName
  location: secondaryLocation
  sku: {
    name: appServicePlanSkuName
    capacity: appServicePlanCapacity
  }
  kind: 'app'
  properties: {
    reserved: true
  }
}

resource app 'Microsoft.Web/sites@2020-06-01' = {
  name: webAppName
  location: location
  kind: 'app'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
    siteConfig: {
      detailedErrorLoggingEnabled: true
      httpLoggingEnabled: true
      requestTracingEnabled: true
      ftpsState: 'Disabled'
      minTlsVersion: '1.2'
      ipSecurityRestrictions: [
        {
          tag: 'ServiceTag'
          ipAddress: 'AzureFrontDoor.Backend'
          action: 'Allow'
          priority: 100
          headers: {
            'x-azure-fdid': [
              frontDoorProfile.properties.frontDoorId
            ]
          }
          name: 'Allow traffic from Front Door'
        }
      ]
      scmIpSecurityRestrictionsDefaultAction: 'Deny'
    }
  }
}

resource ftpPolicy 'Microsoft.Web/sites/basicPublishingCredentialsPolicies@2022-03-01' = {
  name: 'ftp'
  location: location
  kind: 'string'
  parent: app
  properties: {
    allow: false
  }
}

resource scmPolicy 'Microsoft.Web/sites/basicPublishingCredentialsPolicies@2022-03-01' = {
  name: 'scm'
  location: location
  kind: 'string'
  parent: app
  properties: {
    allow: false
  }
}

resource appSlot 'Microsoft.Web/sites/slots@2020-06-01' = {
  name: '${webAppName}/stage'
  location: location
  kind: 'app'
  identity: {
    type: 'SystemAssigned'
  }
  dependsOn: [
    app
  ]
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
    siteConfig: {
      detailedErrorLoggingEnabled: true
      httpLoggingEnabled: true
      requestTracingEnabled: true
      ftpsState: 'Disabled'
      minTlsVersion: '1.2'
      ipSecurityRestrictions: [
        {
          tag: 'ServiceTag'
          ipAddress: 'AzureFrontDoor.Backend'
          action: 'Allow'
          priority: 100
          headers: {
            'x-azure-fdid': [
              frontDoorProfile.properties.frontDoorId
            ]
          }
          name: 'Allow traffic from Front Door'
        }
      ]
    }
  }
}

resource ftpPolicySlot 'Microsoft.Web/sites/slots/basicPublishingCredentialsPolicies@2022-03-01' = {
  name: 'ftp'
  location: location
  kind: 'string'
  parent: appSlot
  properties: {
    allow: false
  }
}

resource scmPolicySlot 'Microsoft.Web/sites/slots/basicPublishingCredentialsPolicies@2022-03-01' = {
  name: 'scm'
  location: location
  kind: 'string'
  parent: appSlot
  properties: {
    allow: false
  }
}

resource secondaryApp 'Microsoft.Web/sites@2020-06-01' = {
  name: secondaryWebAppName
  location: secondaryLocation
  kind: 'app'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: secondaryAppServicePlan.id
    httpsOnly: true
    siteConfig: {
      detailedErrorLoggingEnabled: true
      httpLoggingEnabled: true
      requestTracingEnabled: true
      ftpsState: 'Disabled'
      minTlsVersion: '1.2'
      ipSecurityRestrictions: [
        {
          tag: 'ServiceTag'
          ipAddress: 'AzureFrontDoor.Backend'
          action: 'Allow'
          priority: 100
          headers: {
            'x-azure-fdid': [
              frontDoorProfile.properties.frontDoorId
            ]
          }
          name: 'Allow traffic from Front Door'
        }
      ]
      scmIpSecurityRestrictionsDefaultAction: 'Deny'
    }
  }
}

resource secondaryFtpPolicy 'Microsoft.Web/sites/basicPublishingCredentialsPolicies@2022-03-01' = {
  name: 'ftp'
  location: secondaryLocation
  kind: 'string'
  parent: secondaryApp
  properties: {
    allow: false
  }
}

resource secondaryScmPolicy 'Microsoft.Web/sites/basicPublishingCredentialsPolicies@2022-03-01' = {
  name: 'scm'
  location: secondaryLocation
  kind: 'string'
  parent: secondaryApp
  properties: {
    allow: false
  }
}

resource secondaryAppSlot 'Microsoft.Web/sites/slots@2020-06-01' = {
  name: '${secondaryWebAppName}/stage'
  location: secondaryLocation
  kind: 'app'
  identity: {
    type: 'SystemAssigned'
  }
  dependsOn: [
    secondaryApp
  ]
  properties: {
    serverFarmId: secondaryAppServicePlan.id
    httpsOnly: true
    siteConfig: {
      detailedErrorLoggingEnabled: true
      httpLoggingEnabled: true
      requestTracingEnabled: true
      ftpsState: 'Disabled'
      minTlsVersion: '1.2'
      ipSecurityRestrictions: [
        {
          tag: 'ServiceTag'
          ipAddress: 'AzureFrontDoor.Backend'
          action: 'Allow'
          priority: 100
          headers: {
            'x-azure-fdid': [
              frontDoorProfile.properties.frontDoorId
            ]
          }
          name: 'Allow traffic from Front Door'
        }
      ]
    }
  }
}

resource secondaryFtpPolicySlot 'Microsoft.Web/sites/slots/basicPublishingCredentialsPolicies@2022-03-01' = {
  name: 'ftp'
  location: secondaryLocation
  kind: 'string'
  parent: secondaryAppSlot
  properties: {
    allow: false
  }
}

resource secondaryScmPolicySlot 'Microsoft.Web/sites/slots/basicPublishingCredentialsPolicies@2022-03-01' = {
  name: 'scm'
  location: secondaryLocation
  kind: 'string'
  parent: secondaryAppSlot
  properties: {
    allow: false
  }
}

resource frontDoorEndpoint 'Microsoft.Cdn/profiles/afdEndpoints@2021-06-01' = {
  name: frontDoorEndpointName
  location: 'global'
  parent: frontDoorProfile
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
    hostName: app.properties.defaultHostName
    httpPort: 80
    httpsPort: 443
    originHostHeader: app.properties.defaultHostName
    priority: 1
    weight: 1000
  }
}

resource secondaryFrontDoorOrigin 'Microsoft.Cdn/profiles/originGroups/origins@2021-06-01' = {
  name: secondaryFrontDoorOriginName
  parent: frontDoorOriginGroup
  properties: {
    hostName: secondaryApp.properties.defaultHostName
    httpPort: 80
    httpsPort: 443
    originHostHeader: app.properties.defaultHostName
    priority: 2
    weight: 1000
  }
}

resource frontDoorRoute 'Microsoft.Cdn/profiles/afdEndpoints/routes@2021-06-01' = {
  name: frontDoorRouteName
  parent: frontDoorEndpoint
  dependsOn: [
    frontDoorOrigin
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
    forwardingProtocol: 'HttpsOnly'
    linkToDefaultDomain: 'Enabled'
    httpsRedirect: 'Enabled'
  }
}

output appServiceHostName string = app.properties.defaultHostName
output secondaryAppServiceHostName string = secondaryApp.properties.defaultHostName
output appServiceSlotHostName string = appSlot.properties.defaultHostName
output secondaryAppServiceSlotHostName string = secondaryAppSlot.properties.defaultHostName
output frontDoorEndpointHostName string = frontDoorEndpoint.properties.hostName
