@description('That name is the name of our application. It has to be unique.Type a name followed by your resource group name. (<name>-<resourceGroupName>)')
param webAppName string = 'Django-${uniqueString(resourceGroup().id)}'

@description('Location for all resources.')
param location string = resourceGroup().location

var sku = 'Free'
var skuCode = 'F1'
var workerSize = 0
var appInsightName = '${webAppName}-insights'
var hostingPlanName = 'hpn-${resourceGroup().name}'

resource webApp 'Microsoft.Web/sites@2022-03-01' = {
  name: webAppName
  location: location
  properties: {
    siteConfig: {
      appSettings: [
        {
          name: 'WEBSITES_ENABLE_APP_SERVICE_STORAGE'
          value: 'false'
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: appInsights.properties.InstrumentationKey
        }
        {
          name: 'XDT_MicrosoftApplicationInsights_Mode'
          value: 'default'
        }
        {
          name: 'ApplicationInsightsAgent_EXTENSION_VERSION'
          value: '~2'
        }
      ]
      linuxFxVersion: 'DOCKER|appsvcorg/django-python:0.1'
    }
    clientAffinityEnabled: false
    serverFarmId: hostingPlan.id
  }
}

resource hostingPlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: hostingPlanName
  location: location
  sku: {
    tier: sku
    name: skuCode
  }
  kind: 'linux'
  properties: {
    reserved: true
    targetWorkerSizeId: workerSize
    targetWorkerCount: 1
  }
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
  }
}
