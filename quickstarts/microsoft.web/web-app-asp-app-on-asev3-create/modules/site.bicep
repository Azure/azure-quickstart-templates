@description('App service prefix.')
param appName string

@description('App service location.')
param location string = resourceGroup().location

@description('App service plan prefix.')
param hostingPlanName string

@description('App service plan hosting environment profile name (ASEv3 name).')
param hostingEnvironmentProfileName string

@description('Enable Always-on of App service.')
param alwaysOn bool = true

@description('App service plan sku.')
param sku string = 'IsolatedV2'

@description('App service plan sku code.')
param skuCode string = 'I1V2'

@description('Enable php of App service.')
param phpVersion string = 'OFF'

@description('.NET Framework version of App service.')
param netFrameworkVersion string = 'v5.0'

resource site 'Microsoft.Web/sites@2021-01-15' = {
  name: appName
  location: location
  properties: {
    siteConfig: {
      phpVersion: phpVersion
      netFrameworkVersion: netFrameworkVersion
      alwaysOn: alwaysOn
    }
    serverFarmId: hostingPlan.id
    clientAffinityEnabled: true
    hostingEnvironmentProfile: {
      id: resourceId('Microsoft.Web/hostingEnvironments', hostingEnvironmentProfileName)
    }
  }
}

resource hostingPlan 'Microsoft.Web/serverfarms@2021-01-15' = {
  name: hostingPlanName
  location: location
  sku: {
    tier: sku
    name: skuCode
  }
  properties: {
    hostingEnvironmentProfile: {
      id: resourceId('Microsoft.Web/hostingEnvironments', hostingEnvironmentProfileName)
    }
  }
}
