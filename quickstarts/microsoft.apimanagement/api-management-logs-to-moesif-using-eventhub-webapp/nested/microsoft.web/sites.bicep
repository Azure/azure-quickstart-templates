@description('The name to be given to this new App Service. This value is used in DNS and must be unique.')
param appServiceName string

@description('The name of an existing App Service plan for which the App Service will be created')
param appServicePlanName string

@description('sets environment variable APIMEVENTS-EVENTHUB-NAME')
param eventHubNamespace string

@description('Sets environment variable APIMEVENTS-EVENTHUB-NAME')
param eventHubName string

@description('Name of Event Hubs Namespace listen policy. Found in EventHubNamespace/Settings/Shared access policies: eg \'moesiflogaaaaaa-listen-policy\'')
param eventHubListenPolicy string

@description('Sets environment variable APIMEVENTS-STORAGEACCOUNT-NAME')
param apimEvtStorName string

@description('Sets environment variable APIMEVENTS-MOESIF-APPLICATION-ID')
param apimEvtMoesifApplicationId string

@description('Sets environment variable APIMEVENTS-MOESIF-SESSION-TOKEN')
param apimEvtMoesifSessionToken string = 'optional'

@description('Sets environment variable APIMEVENTS-MOESIF-API-VERSION')
param apimEvtMoesifApiVersion string = 'v1'

@description('DNS name to use for azure webapp such as .azurewebsites.net')
param azureWebsitesDomain string
param tags object = {}

@description('Location for all resources. eg \'westus2\'')
param location string

var appServiceHostName = '${appServiceName}${azureWebsitesDomain}'

resource appService 'Microsoft.Web/sites@2022-03-01' = {
  name: appServiceName
  location: location
  tags: tags
  kind: 'app'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    enabled: true
    hostNameSslStates: [
      {
        name: appServiceHostName
        sslState: 'Disabled'
        hostType: 'Standard'
      }
      {
        name: '${appServiceName}.scm${azureWebsitesDomain}'
        sslState: 'Disabled'
        hostType: 'Repository'
      }
    ]
    serverFarmId: resourceId('Microsoft.Web/serverfarms', appServicePlanName)
    reserved: false
    isXenon: false
    hyperV: false
    siteConfig: {
      appSettings: [
        {
          name: 'APIMEVENTS-EVENTHUB-CONNECTIONSTRING'
          value: listKeys(resourceId('Microsoft.EventHub/namespaces/authorizationRules', eventHubNamespace, eventHubListenPolicy), '2021-11-01').primaryConnectionString
        }
        {
          name: 'APIMEVENTS-EVENTHUB-NAME'
          value: eventHubName
        }
        {
          name: 'APIMEVENTS-STORAGEACCOUNT-NAME'
          value: apimEvtStorName
        }
        {
          name: 'APIMEVENTS-STORAGEACCOUNT-KEY'
          value: listKeys(resourceId('Microsoft.Storage/storageAccounts', apimEvtStorName), '2021-02-01').keys[0].value
        }
        {
          name: 'APIMEVENTS-MOESIF-APPLICATION-ID'
          value: apimEvtMoesifApplicationId
        }
        {
          name: 'APIMEVENTS-MOESIF-SESSION-TOKEN'
          value: apimEvtMoesifSessionToken
        }
        {
          name: 'APIMEVENTS-MOESIF-API-VERSION'
          value: apimEvtMoesifApiVersion
        }
      ]
    }
    scmSiteAlsoStopped: false
    clientAffinityEnabled: true
    clientCertEnabled: false
    hostNamesDisabled: false
    containerSize: 0
    dailyMemoryTimeQuota: 0
    httpsOnly: true
    redundancyMode: 'None'
  }
}

resource appServiceName_web 'Microsoft.Web/sites/config@2022-03-01' = {
  parent: appService
  name: 'web'
  properties: {
    netFrameworkVersion: 'v5.0'
    logsDirectorySizeLimit: 60
    numberOfWorkers: 1
    alwaysOn: true
    detailedErrorLoggingEnabled: true
    httpLoggingEnabled: true
    requestTracingEnabled: true
    ftpsState: 'Disabled'
    minTlsVersion: '1.2'
    defaultDocuments: [
      'Default.htm'
      'Default.html'
      'Default.asp'
      'index.htm'
      'index.html'
      'iisstart.htm'
      'default.aspx'
      'index.php'
      'hostingstart.html'
    ]
  }
  dependsOn: [
    appServiceName_appServiceHost
  ]
}

resource appServiceName_appServiceHost 'Microsoft.Web/sites/hostNameBindings@2022-03-01' = {
  parent: appService
  name: appServiceHostName
  properties: {
    siteName: appServiceName
    hostNameType: 'Verified'
  }
}

output appServiceName string = appServiceName
output appServiceHostName string = appServiceHostName
