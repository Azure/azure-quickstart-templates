@description('Name of the SQL server')
param sqlServerName string = 'server-${uniqueString(resourceGroup().id,deployment().name)}'

@description('Location for all resources.')
param location string = resourceGroup().location

@description('Administrator username of the SQL Server.')
param sqlAdministratorLogin string

@description('Administrator password of the SQL Server.')
@secure()
param sqlAdministratorLoginPassword string

@description('Name of the Event Hub.')
param eventHubName string = 'eventhub'

@description('Name of the Event Hub Namespace.')
param eventHubNamespaceName string = 'namespace${uniqueString(resourceGroup().id)}'

@description('Name of the Event Hub Authorization Rule.')
param eventHubAuthorizationRuleName string = 'RootManageSharedAccessKey'

@description('Enable Auditing of Microsoft support operations (DevOps)')
param isMSDevopsAuditEnabled bool = false

var diagnosticSettingsName = 'SQLSecurityAuditEvents_${sqlServerName}'

resource eventHubNamespace 'Microsoft.EventHub/namespaces@2018-01-01-preview' = {
  name: eventHubNamespaceName
  location: location
  sku: {
    name: 'Standard'
    tier: 'Standard'
  }
  properties: {}
}

resource eventHubNamespaceName_eventHub 'Microsoft.EventHub/namespaces/eventhubs@2017-04-01' = {
  parent: eventHubNamespace
  name: eventHubName
}

resource sqlServer 'Microsoft.Sql/servers@2019-06-01-preview' = {
  location: location
  name: sqlServerName
  properties: {
    administratorLogin: sqlAdministratorLogin
    administratorLoginPassword: sqlAdministratorLoginPassword
    version: '12.0'
  }
  tags: {
    DisplayName: sqlServerName
  }
}

resource sqlServerName_master 'Microsoft.Sql/servers/databases@2019-06-01-preview' = {
  parent: sqlServer
  location: location
  name: 'master'
  properties: {}
}

resource sqlServerName_master_microsoft_insights_diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: diagnosticSettingsName
  scope: sqlServerName_master
  properties: {
    eventHubAuthorizationRuleId: resourceId(
      'Microsoft.EventHub/namespaces/authorizationRules',
      eventHubNamespaceName,
      eventHubAuthorizationRuleName
    )
    eventHubName: eventHubName
    logs: [
      {
        category: 'SQLSecurityAuditEvents'
        enabled: true
        retentionPolicy: {
          days: 0
          enabled: false
        }
      }
      {
        category: 'DevOpsOperationsAudit'
        enabled: isMSDevopsAuditEnabled
        retentionPolicy: {
          days: 0
          enabled: false
        }
      }
    ]
  }
}

resource sqlServerName_DefaultAuditingSettings 'Microsoft.Sql/servers/auditingSettings@2017-03-01-preview' = {
  parent: sqlServer
  name: 'DefaultAuditingSettings'
  properties: {
    state: 'Enabled'
    isAzureMonitorTargetEnabled: true
  }
}

resource sqlServerName_Default 'Microsoft.Sql/servers/devOpsAuditingSettings@2020-08-01-preview' = if (isMSDevopsAuditEnabled) {
  parent: sqlServer
  name: 'Default'
  properties: {
    state: 'Enabled'
    isAzureMonitorTargetEnabled: true
  }
}
