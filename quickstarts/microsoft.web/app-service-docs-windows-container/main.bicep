@description('Web App name.')
@minLength(2)
param appServiceWebAppName string = 'webApp-${uniqueString(resourceGroup().id)}'

@description('App Service Plan name.')
@minLength(2)
param appServicePlanName string = 'webApp-${uniqueString(resourceGroup().id)}'
param skuTier string = 'P1v3'
param location string = resourceGroup().location

resource appServiceWebApp 'Microsoft.Web/sites@2023-01-01' = {
  name: appServiceWebAppName
  location: location
  tags: {
    'hidden-related:${appServicePlan.id}': 'empty'
  }
  properties: {
    siteConfig: {
      appSettings: [
        {
          name: 'PORT'
          value: '8080'
        }
      ]
      appCommandLine: ''
      windowsFxVersion: 'DOCKER|mcr.microsoft.com/dotnet/samples:aspnetapp'
    }
    serverFarmId: appServicePlan.id 
  }
}

resource appServicePlan 'Microsoft.Web/serverfarms@2023-01-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: skuTier
  }
  kind: 'windows'
  properties: {
    hyperV: true
  }
}
