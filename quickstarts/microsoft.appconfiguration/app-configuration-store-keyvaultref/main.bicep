@description('Specifies the name of the App Configuration store.')
param configStoreName string = 'appconfig${uniqueString(resourceGroup().id)}'

@description('Specifies the Azure location where the app configuration store should be created.')
param location string = resourceGroup().location

@description('Specifies the name of the key-value resource. The name is a combination of key and label with $ as delimiter.')
param keyValue string = 'key$label'

@description('Format should be https://{vault-name}.{vault-DNS-suffix}/secrets/{secret-name}/{secret-version}. Secret version is optional.')
param keyVaultSecretURL string

var keyVaultRef = {
  uri: keyVaultSecretURL
}

resource configStore 'Microsoft.AppConfiguration/configurationStores@2024-05-01' = {
  name: configStoreName
  location: location
  sku: {
    name: 'standard'
  }
}

resource configStorekeyValue 'Microsoft.AppConfiguration/configurationStores/keyValues@2024-05-01' = {
  parent: configStore
  name: keyValue
  properties: {
    value: string(keyVaultRef)
    contentType: 'application/vnd.microsoft.appconfig.keyvaultref+json;charset=utf-8'
  }
}
