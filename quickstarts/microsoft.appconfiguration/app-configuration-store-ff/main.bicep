@description('Specifies the name of the App Configuration store.')
param configStoreName string = 'appconfig${uniqueString(resourceGroup().id)}'

@description('Specifies the Azure location where the app configuration store should be created.')
param location string = resourceGroup().location

@description('Specifies the key of the feature flag.')
param featureFlagKey string = 'FeatureFlagSample'

@description('Specifies the label of the feature flag. The label is optional and can be left as empty.')
param featureFlagLabel string = ''

var featureFlagValue = {
  id: featureFlagKey
  description: 'Your description.'
  enabled: true
}

resource configStore 'Microsoft.AppConfiguration/configurationStores@2024-05-01' = {
  name: configStoreName
  location: location
  sku: {
    name: 'standard'
  }
  properties: {}
}

resource configStoreFeatureflag 'Microsoft.AppConfiguration/configurationStores/keyValues@2024-05-01' = {
  parent: configStore
  name: '.appconfig.featureflag~2F${featureFlagKey}$${featureFlagLabel}'
  properties: {
    value: string(featureFlagValue)
    contentType: 'application/vnd.microsoft.appconfig.ff+json;charset=utf-8'
  }
}
