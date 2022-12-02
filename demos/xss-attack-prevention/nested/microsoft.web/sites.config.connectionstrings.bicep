param webAppName string

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

resource connectionstring 'Microsoft.Web/sites/config@2022-03-01' = {
  name: '${webAppName}/connectionstrings'
  properties: {
    DefaultConnection: {
      value: connectionString
      type: connectionType
    }
  }
}
