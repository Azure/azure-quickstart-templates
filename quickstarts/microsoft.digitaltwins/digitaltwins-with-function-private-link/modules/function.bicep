@description('Location of Azure Function')
param location string

@description('Virtual Network Name')
param virtualNetworkName string

@description('Storage Account name')
param storageAccountName string

@description('Name of the function app')
@maxLength(16)
param functionAppName string

@description('Name of the server farm')
param serverFarmName string

@description('Name of the subnet to connect the function to')
param functionsSubnetName string

@description('Digital Twins endpoint')
param digitalTwinsEndpoint string

@description('Name of application insights instance')
param applicationInsightsName string

@description('Specifies the Azure Function hosting plan SKU.')
@allowed([
  'EP1'
  'EP2'
  'EP3'
])
param functionAppPlanSku string = 'EP1'


resource storageaccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: storageAccountName
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
}

resource serverfarm 'Microsoft.Web/serverfarms@2022-03-01' = {
  location: location
  name: serverFarmName
  kind: 'elastic'
  sku: {
    name: functionAppPlanSku
    tier: 'ElasticPremium'
    size: functionAppPlanSku
    family: 'EP'
  }
  properties: {
    maximumElasticWorkerCount: 4
    reserved: false
  }
}

resource appinsights 'Microsoft.Insights/components@2020-02-02' = {
  name: applicationInsightsName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
  }
}

resource function 'Microsoft.Web/sites@2022-03-01' = {
  name: functionAppName
  location: location
  kind: 'functionapp'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: serverfarm.id
    siteConfig: {
      appSettings: [
        {
          name: 'AzureWebJobsDashboard'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageaccount.name};AccountKey=${storageaccount.listKeys().keys[0].value}'
        }
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageaccount.name};AccountKey=${storageaccount.listKeys().keys[0].value}'
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~3'
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: reference('${appinsights.id}', '2020-02-02').InstrumentationKey
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'dotnet'
        }
        {
          name: 'ADT_ENDPOINT'
          value: 'https://${digitalTwinsEndpoint}'
        }
      ]
    }
    vnetRouteAllEnabled: true
  }
}

resource planNetworkConfig 'Microsoft.Web/sites/networkConfig@2022-03-01' = {
  parent: function
  name: 'virtualNetwork'
  properties: {
    subnetResourceId: resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetworkName, functionsSubnetName)
    swiftSupported: true
  }
}

output functionIdentityPrincipalId string = function.identity.principalId
