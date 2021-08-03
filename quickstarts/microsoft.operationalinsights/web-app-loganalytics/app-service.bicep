param location string = resourceGroup().location
param appName string
param appServicePlanID string
param APPINSIGHTS_INSTRUMENTATIONKEY string
var webSiteName = toLower('wapp-${appName}')

resource appService 'Microsoft.Web/sites@2020-06-01' = {
  name: webSiteName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  tags: {
    displayName: 'Website'
    ProjectName: appName
  }
  properties: {
    serverFarmId: appServicePlanID
    httpsOnly: true
    siteConfig: {
      minTlsVersion: '1.2'
    }
  }
}
resource appServiceLogging 'Microsoft.Web/sites/config@2020-06-01' = {
  name: '${appService.name}/logs'
  properties: {
    applicationLogs: {
      fileSystem: {
        level: 'Warning'
      }
    }
    httpLogs: {
      fileSystem: {
        retentionInMb: 40
        enabled: true
      }
    }
    failedRequestsTracing: {
      enabled: true
    }
    detailedErrorMessages: {
      enabled: true
    }
  }
}

resource appServiceAppSettings 'Microsoft.Web/sites/config@2020-06-01' = {
  name: '${appService.name}/appsettings'
  properties: {
    APPINSIGHTS_INSTRUMENTATIONKEY: APPINSIGHTS_INSTRUMENTATIONKEY
  }
}
resource appServiceSiteExtension 'Microsoft.Web/sites/siteextensions@2020-06-01' = {
  name: '${appService.name}/Microsoft.ApplicationInsights.AzureWebsites'
}
