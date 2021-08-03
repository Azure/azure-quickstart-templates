param appName string = uniqueString(resourceGroup().id)

module appServicePlanModule './app-service-plan.bicep' = {
  name: 'appServicePlanDeploy'
  params: {
    appName: appName
  }
}

module appServiceModule './app-service.bicep' = {
  name: 'appServiceDeploy'
  params: {
    appName: appName
    appServicePlanID: appServicePlanModule.outputs.appServicePlanID
    APPINSIGHTS_INSTRUMENTATIONKEY: appInsightsModule.outputs.APPINSIGHTS_INSTRUMENTATIONKEY
  }
}

module appInsightsModule './app-insights.bicep' = {
  name: 'appInsightsDeploy'
  params: {
    appName: appName
    logAnalaticsWorkspaceResourceID: logAnalyticsWorkspace.outputs.logAnalaticsWorkspaceResourceID
  }
}

module logAnalyticsWorkspace './log-analytics.bicep' = {
  name: 'logAnalyticsWorkspaceDeploy'
  params: {
    appName: appName
  }
}
