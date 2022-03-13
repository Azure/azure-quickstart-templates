@description('Specifies the name of the App Configuration store.')
param configStoreName string

@description('Specifies the Azure location where the app configuration store should be created.')
param location string = resourceGroup().location

@description('Specifies the names of the key-value resources. The name is a combination of key and label with $ as delimiter. The label is optional.')
param keyValueNames array = [
  'myKey'
  'myKey$myLabel'
]

@description('Specifies the values of the key-value resources. It\'s optional')
param keyValueValues array = [
  'Key-value without label'
  'Key-value with label'
]

@description('Specifies the content type of the key-value resources. For feature flag, the value should be application/vnd.microsoft.appconfig.ff+json;charset=utf-8. For Key Value reference, the value should be application/vnd.microsoft.appconfig.keyvaultref+json;charset=utf-8. Otherwise, it\'s optional.')
param contentType string = 'the-content-type'

@description('Adds tags for the key-value resources. It\'s optional')
param tags object = {
  tag1: 'tag-value-1'
  tag2: 'tag-value-2'
}

resource configStore 'Microsoft.AppConfiguration/configurationStores@2020-07-01-preview' = {
  name: configStoreName
  location: location
  sku: {
    name: 'standard'
  }
}

resource configStorekeyValue 'Microsoft.AppConfiguration/configurationStores/keyValues@2020-07-01-preview' = [for (item, i) in keyValueNames: {
  name: '${configStore}/${item}'
  properties: {
    value: keyValueValues[i]
    contentType: contentType
    tags: tags
  }
}]

output KeyValueReference string = reference(resourceId('Microsoft.AppConfiguration/configurationStores/keyValues', configStoreName, keyValueNames[0]), '2020-07-01-preview').value
output KeyValueObjectReference object = reference(resourceId('Microsoft.AppConfiguration/configurationStores/keyValues', configStoreName, keyValueNames[1]), '2020-07-01-preview')
