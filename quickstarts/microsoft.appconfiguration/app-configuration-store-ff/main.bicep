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

resource configStoreName_resource 'Microsoft.AppConfiguration/configurationStores@2020-07-01-preview' = {
  name: configStoreName
  location: location
  sku: {
    name: 'standard'
  }
}

resource configStoreName_appconfig_featureflag_2F_featureFlagKey_featureFlagLabel 'Microsoft.AppConfiguration/configurationStores/keyValues@2020-07-01-preview' = {
  parent: configStoreName_resource
  name: '.appconfig.featureflag~2F${featureFlagKey}$${featureFlagLabel}'
  properties: {
    value: string(featureFlagValue)
    contentType: 'application/vnd.microsoft.appconfig.ff+json;charset=utf-8'
  }
}