@description('Required. Subscription id.')
param subscriptionId string = subscription().id
@description('Required. App service prefix.')
param appNamePrefix string = 'app'
@description('Required. App service location.')
param location string = resourceGroup().location
@description('Required. App service plan prefix.')
param hostingPlanNamePrefix string = 'asev3-asp'
@description('Required. App service plan resource group name.')
param serverFarmResourceGroup string = resourceGroup().name
@description('Required. App service plan hosting environment profile name (ASEv3 name).')
param hostingEnvironmentProfileName string

// App Service Parameters
@description('Required. Enable Always-on of App service.')
param alwaysOn bool = true
@description('Required. App service plan sku.')
param sku string = 'IsolatedV2'
@description('Required. App service plan sku code.')
param skuCode string = 'I1V2'
@description('Required. App service plan worker size.')
param workerSize string = '6'
@description('Required. App service plan worker size id.')
param workerSizeId string = '6'
@description('Required. Number of App service plan workers.')
param numberOfWorkers string = '1'
@description('Required. Current stack of App service.')
param currentStack string = 'dotnet'
@description('Required. Enable php of App service.')
param phpVersion string = 'OFF'
@description('Required. .NET Framework version of App service.')
param netFrameworkVersion string = 'v5.0'

@description('Optional. It is only for unique string generation base on timestamp.')
param timeStamp string = utcNow()

// Variable definitions
var uniStr = substring('${uniqueString(resourceGroup().id, timeStamp)}', 0, 4)
var appName = '${appNamePrefix}-${uniStr}'
var hostingPlanName = '${hostingPlanNamePrefix}-${uniStr}'
var hostingEnvironmentProfile = {
  id: resourceId('Microsoft.Web/hostingEnvironments', hostingEnvironmentProfileName)
}

resource site 'Microsoft.Web/sites@2018-11-01' = {
  name: appName
  location: location
  properties: {
    name: appName
    siteConfig: {
      appSettings: []
      metadata: [
        {
          name: 'CURRENT_STACK'
          value: currentStack
        }
      ]
      phpVersion: phpVersion
      netFrameworkVersion: netFrameworkVersion
      alwaysOn: alwaysOn
    }
    serverFarmId: '/subscriptions/${subscriptionId}/resourcegroups/${serverFarmResourceGroup}/providers/Microsoft.Web/serverfarms/${hostingPlanName}'
    clientAffinityEnabled: true
    hostingEnvironmentProfile: hostingEnvironmentProfile
  }
  dependsOn: [
    hostingPlanName_resource
  ]
}

resource hostingPlanName_resource 'Microsoft.Web/serverfarms@2018-11-01' = {
  name: hostingPlanName
  location: location
  kind: ''
  properties: {
    name: hostingPlanName
    workerSize: workerSize
    workerSizeId: workerSizeId
    numberOfWorkers: numberOfWorkers
    hostingEnvironmentProfile: hostingEnvironmentProfile
  }
  sku: {
    Tier: sku
    Name: skuCode
  }
  dependsOn: []
}
