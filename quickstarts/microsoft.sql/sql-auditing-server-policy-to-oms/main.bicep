@description('Name of the SQL server')
param sqlServerName string

@description('Location for all resources.')
param location string = resourceGroup().location

@description('The administrator username of the SQL Server.')
param sqlAdministratorLogin string

@description('The administrator password of the SQL Server.')
@secure()
param sqlAdministratorLoginPassword string

@description('Log Analytics workspace name')
param omsWorkspaceName string = 'omsworkspace${uniqueString(resourceGroup().id)}'

@description('Specify the region for your OMS workspace')
param workspaceRegion string

@description('Select the SKU for OMS workspace')
@allowed([
  'Free'
  'Standalone'
  'pernode'
])
param omsSku string = 'Free'

@description('Enable Auditing of Microsoft support operations (DevOps)')
param isMSDevOpsAuditEnabled bool = false

var diagnosticSettingsName = 'SQLSecurityAuditEvents_3d229c42-c7e7-4c97-9a99-ec0d0d8b86c1'

resource omsWorkspace'Microsoft.OperationalInsights/workspaces@2021-12-01-preview' = {
  name: omsWorkspaceName
  location: workspaceRegion
  properties: {
    sku: {
      name: omsSku
    }
  }
}

resource sqlServer 'Microsoft.Sql/servers@2021-08-01-preview' = {
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

resource sqlServerMasterDB 'Microsoft.Sql/servers/databases@2021-08-01-preview' = {
  parent: sqlServer
  location: location
  name: 'master'
  properties: {}
}

resource sqlServerNameDiagnosticSettingsName 'Microsoft.Sql/servers/databases/providers/diagnosticSettings@2021-05-01-preview' = {
  name: '${sqlServerName}/master/microsoft.insights/${diagnosticSettingsName}'
  properties: {
    name: diagnosticSettingsName
    workspaceId: omsWorkspace.id
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
        condition: isMSDevOpsAuditEnabled
        category: 'DevOpsOperationsAudit'
        enabled: true
        retentionPolicy: {
          days: 0
          enabled: false
        }
      }
    ]
  }
}

resource sqlServerName_DefaultAuditingSettings 'Microsoft.Sql/servers/auditingSettings@2021-08-01-preview' = {
  parent: sqlServer
  name: 'default'
  properties: {
    state: 'Enabled'
    isAzureMonitorTargetEnabled: true
  }
}

resource sqlServerName_Default 'Microsoft.Sql/servers/devOpsAuditingSettings@2021-08-01-preview' = if (isMSDevOpsAuditEnabled) {
  parent: sqlServer
  name: 'Default'
  properties: {
    state: 'Enabled'
    isAzureMonitorTargetEnabled: true
  }
}
