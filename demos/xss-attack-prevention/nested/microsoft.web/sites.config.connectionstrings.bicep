param webAppName string
param location string

@allowed([
  'MySql'
  'SQLServer'
  'SQLAzure'
  'Custom'
  'NotificationHub'
  'ServiceBus'
  'EventHub'
  'ApiHub'
  'DocDb'
  'RedisCache'
  'PostgreSQL'
])
param connectionType string = 'Custom'
param connectionString string

resource webAppName_connectionstrings 'Microsoft.Web/sites/config@2018-02-01' = {
  name: '${webAppName}/connectionstrings'
  location: location
  properties: {
    DefaultConnection: {
      value: connectionString
      type: connectionType
    }
  }
}