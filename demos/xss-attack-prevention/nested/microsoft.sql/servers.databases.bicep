param sqlServerName string
param databaseName string = 'contosodb'
param location string

@allowed([
  'Web'
  'Business'
  'Basic'
  'Standard'
  'Premium'
  'Free'
  'Stretch'
  'DataWarehouse'
  'System'
  'System2'
])
param edition string = 'Basic'
param tags object
param omsWorkspaceResourceId string
param administratorLogin string

@secure()
param administratorLoginPassword string
param bacpacuri string

@description('Specifies the number of days that logs are gonna be kept. If you do not want to apply any retention policy and retain data forever, set value to 0.')
@minValue(0)
@maxValue(365)
param logsRetentionInDays int = 0

resource database 'Microsoft.Sql/servers/databases@2022-05-01-preview' = {
  name: '${sqlServerName}/${databaseName}'
  tags: tags
  location: location
  sku: {
    name: edition
    tier: edition
  }
  properties: {
    createMode: 'Default'
  }
}

resource import 'Microsoft.Sql/servers/databases/extensions@2022-05-01-preview' = {
  parent: database
  name: 'Import'
  properties: {
    storageKey: '?'
    storageKeyType: 'SharedAccessKey'
    storageUri: bacpacuri
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword
    operationMode: 'Import'
  }
}

resource databaseDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: database
  name: 'service'
  properties: {
    workspaceId: omsWorkspaceResourceId
    logs: [
      {
        category: 'QueryStoreRuntimeStatistics'
        enabled: true
        retentionPolicy: {
          days: logsRetentionInDays
          enabled: true
        }
      }
      {
        category: 'QueryStoreWaitStatistics'
        enabled: true
        retentionPolicy: {
          days: logsRetentionInDays
          enabled: true
        }
      }
      {
        category: 'Errors'
        enabled: true
        retentionPolicy: {
          days: logsRetentionInDays
          enabled: true
        }
      }
      {
        category: 'DatabaseWaitStatistics'
        enabled: true
        retentionPolicy: {
          days: logsRetentionInDays
          enabled: true
        }
      }
      {
        category: 'Timeouts'
        enabled: true
        retentionPolicy: {
          days: logsRetentionInDays
          enabled: true
        }
      }
      {
        category: 'Blocks'
        enabled: true
        retentionPolicy: {
          days: logsRetentionInDays
          enabled: true
        }
      }
      {
        category: 'SQLInsights'
        enabled: true
        retentionPolicy: {
          days: logsRetentionInDays
          enabled: true
        }
      }
    ]
    metrics: [
      {
        timeGrain: 'AllMetrics'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: logsRetentionInDays
        }
      }
    ]
  }
}

output databaseName string = databaseName
output dbConnetcionString string = 'Data Source=tcp:${reference(resourceId('Microsoft.Sql/servers/', sqlServerName), '2020-02-02-preview').fullyQualifiedDomainName},1433;Initial Catalog=${databaseName}'
