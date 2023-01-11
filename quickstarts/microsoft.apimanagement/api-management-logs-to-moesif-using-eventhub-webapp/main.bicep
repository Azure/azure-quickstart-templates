@description('Your Moesif Application Id which can be found within your Moesif Portal. After signing up for a Moesif account, your Moesif Application Id will be displayed during the onboarding steps. Sets environment variable APIMEVENTS-MOESIF-APPLICATION-ID in App Service')
@minLength(50)
param moesifApplicationId string

@description('Name of your existing Azure API Management service. If blank, the log-to-eventhub logger is not created. The API Management service must be in same Resource Group as the deployment')
@minLength(0)
param existingApiMgmtName string = ''

@description('The instance / SKU name for Azure App Service eg: B1, B2, S1, P1V2. Note F1 and D1 shared plan are not supported as they do not support \'alwaysOn\'')
@allowed([
  'B1'
  'B2'
  'B3'
  'S1'
  'S2'
  'S3'
  'P1v2'
  'P2v2'
  'P3v2'
  'P1v3'
  'P2v3'
  'P3v3'
])
param azureAppServiceSku string = 'B1'

@description('A prefix that will be added to created resource names and DNS URLs. Allowed characters: alphabets and numbers only. Resulting name must be maximum 24 characters (storage account maximum)')
@minLength(6)
param dnsNamePrefix string = 'moesiflog${uniqueString(resourceGroup().id)}'

@description('Location for all resources. eg \'westus2\'')
param location string = resourceGroup().location

@description('The base URL where templates are located. Should end with trailing \'/\'')
param _artifactsLocation string = deployment().properties.templateLink.uri

@description('The sasToken required to access _artifactsLocation.  When the template is deployed using the accompanying scripts, a sasToken will be automatically generated.')
@secure()
param _artifactsLocationSasToken string = ''

var moesifSessionToken = 'optional'
var moesifApiVersion = 'v1'
var apiManagementLoggerName = 'moesif-log-to-event-hub'
var azureWebsitesDomainLookup = {
  AzureCloud: '.azurewebsites.net'
  AzureUSGovernment: '.azurewebsites.us'
}
var azureWebsitesDomain = azureWebsitesDomainLookup[environment().name]
var eventHubNS = dnsNamePrefix
var eventHubName = dnsNamePrefix
var eventHubSendPolicyName = '${dnsNamePrefix}-send-policy'
var eventHubListenPolicy = '${dnsNamePrefix}-listen-policy'
var azAppServiceWebJobZipUri = uri(_artifactsLocation, 'scripts/apim-2-moesif-webjob-webdeploy.zip${_artifactsLocationSasToken}')
var storageAccountName = replace(dnsNamePrefix, '-', '')
var apiMgrSpecified = (length(existingApiMgmtName) > 0)
var tags = {
  purpose: 'moesif'
}

module storage_deploy 'nested/microsoft.storage/storageaccounts.bicep' = {
  name: 'storage-deploy'
  params: {
    storageAccountName: storageAccountName
    tags: tags
    location: location
  }
}

module eventhub_deploy 'nested/microsoft.eventhub/namespaces.bicep' = {
  name: 'eventhub-deploy'
  params: {
    eventHubNsName: dnsNamePrefix
    eventHubName: dnsNamePrefix
    eventHubSendPolicyName: eventHubSendPolicyName
    eventHubListenPolicy: eventHubListenPolicy
    tags: tags
    location: location
  }
}

module api_management_logger_deploy 'nested/microsoft.apimanagement/service/loggers.bicep' = if (apiMgrSpecified) {
  name: 'api-management-logger-deploy'
  params: {
    existingApiMgmtName: existingApiMgmtName
    logToEventhubLoggerName: apiManagementLoggerName
    eventHubNS: eventHubNS
    eventHubName: eventHubName
    eventHubSendPolicyName: eventHubSendPolicyName
  }
  dependsOn: [
    eventhub_deploy
  ]
}

module app_service_plan_deploy 'nested/microsoft.web/serverfarms.bicep' = {
  name: 'app-service-plan-deploy'
  params: {
    appServicePlanName: dnsNamePrefix
    appServiceSkuName: azureAppServiceSku
    tags: tags
    location: location
  }
}

module app_service_deploy 'nested/microsoft.web/sites.bicep' = {
  name: 'app-service-deploy'
  params: {
    appServiceName: dnsNamePrefix
    appServicePlanName: dnsNamePrefix
    eventHubNamespace: dnsNamePrefix
    eventHubName: dnsNamePrefix
    eventHubListenPolicy: eventHubListenPolicy
    apimEvtStorName: storageAccountName
    apimEvtMoesifApplicationId: moesifApplicationId
    apimEvtMoesifSessionToken: moesifSessionToken
    apimEvtMoesifApiVersion: moesifApiVersion
    azureWebsitesDomain: azureWebsitesDomain
    tags: tags
    location: location
  }
  dependsOn: [
    app_service_plan_deploy
    storage_deploy
    eventhub_deploy
  ]
}

module app_service_webjob_msdeploy 'nested/microsoft.web/sites/extensions.bicep' = {
  name: 'app-service-webjob-msdeploy'
  params: {
    appServiceName: dnsNamePrefix
    webJobZipDeployUrl: azAppServiceWebJobZipUri
  }
  dependsOn: [
    app_service_deploy
  ]
}

output logToEventhubLoggerName string = apiManagementLoggerName
