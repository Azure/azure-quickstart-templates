@description('Specifies the name of the App Configuration store.')
param configStoreName string

@description('Specifies the Azure location where the app configuration store should be created.')
param location string = resourceGroup().location

@description('Array of Objects that contain the key name, value, tag and contentType')
param keyData array = [
  {
    key: 'key01_name'
    value: 'key01_value'
    tag: {
      tag01_name: 'tag01_value'
      tag02_name: 'tag02_value'
    }
    contentType: 'key01_contentType'
  }
  {
    key: 'key02_name'
    value: 'key02_value'
    label: 'key02_label01'
    tag: {
      tag01_name: 'tag01_value'
      tag02_name: 'tag02_value'
    }
    contentType: 'key02_contentType'
  }
  {
    key: 'key02_name'
    value: 'key02_value'
    label: 'key02_label02'
    tag: {
      tag01_name: 'tag01_value'
      tag02_name: 'tag02_value'
    }
    contentType: 'key02_contentType'
  }
]

resource configStore 'Microsoft.AppConfiguration/configurationStores@2020-07-01-preview' = {
  name: configStoreName
  location: location
  sku: {
    name: 'standard'
  }
}

resource configStoreNameKeyVaule 'Microsoft.AppConfiguration/configurationStores/keyValues@2020-07-01-preview' = [for item in keyData: {
  name: '${configStoreName}/${(contains(item, 'label') ? '${item.key}$${item.label}' : item.key)}'
  properties: {
    value: item.value
    contentType: (contains(item, 'contentType') ? item.contentType : json('null'))
    tags: (contains(item, 'tag') ? item.tag : json('null'))
  }
  dependsOn: [
    configStore
  ]
}]

output KeyVauleReference string = reference(resourceId('Microsoft.AppConfiguration/configurationStores/keyValues', configStoreName, keyData[0].key), '2020-07-01-preview').value
output KeyVauleObjectReference object = reference(resourceId('Microsoft.AppConfiguration/configurationStores/keyValues', configStoreName, keyData[0].key), '2020-07-01-preview')
