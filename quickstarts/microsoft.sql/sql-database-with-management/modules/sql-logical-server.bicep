@description('SQL Logical server.')
param sqlLogicalServer object

@description('The SQL Logical Server password.')
@secure()
param password string

param tags object

var defaultAuditActionsAndGroups = [
  'SUCCESSFUL_DATABASE_AUTHENTICATION_GROUP'
  'FAILED_DATABASE_AUTHENTICATION_GROUP'
  'BATCH_COMPLETED_GROUP'
]

var defaultSqlDatabaseProperties = {
  name: ''
  status: ''
  tags: {}
  skuName: ''
  tier: ''
  zoneRedundant: false
  collation: 'SQL_Latin1_General_CP1_CI_AS'
  dataMaxSize: 0
  hybridBenefit: false
  readReplicas: 0
  minimumCores: 0
  autoPauseDelay: 0
  dataEncryption: 'Enabled'
  shortTermBackupRetention: 0
  longTermBackup: {
    enabled: false
    weeklyRetention: 'P1W'
    monthlyRetention: 'P4W'
    yearlyRetention: 'P52W'
    weekOfYear: 1
  }
  azureDefender: {
    enabled: false
    emailAccountAdmins: false
    emailAddresses: []
    disabledRules: []
    vulnerabilityAssessments: {
      recurringScans: false
      storageAccount: {
        resourceGroupName: ''
        name: ''
        containerName: ''
      }
      emailSubscriptionAdmins: false
      emails: []
    }
  }
  auditActionsAndGroups: []
  diagnosticLogsAndMetrics: {
    name: ''
    resourceGroupName: ''
    subscriptionId: subscription().subscriptionId
    logs: []
    metrics: []
    auditLogs: false
  }
}

resource sqlLogicalServerRes 'Microsoft.Sql/servers@2021-02-01-preview' = {
  name: sqlLogicalServer.name
  location: resourceGroup().location
  tags: tags
  identity: {
    type: sqlLogicalServer.systemManagedIdentity ? 'SystemAssigned' : 'None'
  }
  properties: {
    administratorLogin: sqlLogicalServer.userName
    administratorLoginPassword: password
    version: '12.0'
    minimalTlsVersion: sqlLogicalServer.minimalTlsVersion
    publicNetworkAccess: sqlLogicalServer.publicNetworkAccess
  }
}

// Azure Active Directory integration
resource azureAdIntegration 'Microsoft.Sql/servers/administrators@2021-02-01-preview' = if (!empty(sqlLogicalServer.azureActiveDirectoryAdministrator.objectId)) {
  name: 'activeDirectory'
  parent: sqlLogicalServerRes
  properties: {
    administratorType: 'ActiveDirectory'
    login: sqlLogicalServer.azureActiveDirectoryAdministrator.name
    sid: sqlLogicalServer.azureActiveDirectoryAdministrator.objectId
    tenantId: sqlLogicalServer.azureActiveDirectoryAdministrator.tenantId
  }
}

// Azure Defender
resource azureDefender 'Microsoft.Sql/servers/securityAlertPolicies@2021-02-01-preview' = {
  name: 'Default'
  parent: sqlLogicalServerRes
  properties: {
    state: sqlLogicalServer.azureDefender.enabled ? 'Enabled' : 'Disabled'
    emailAddresses: sqlLogicalServer.azureDefender.emailAddresses
    emailAccountAdmins: sqlLogicalServer.azureDefender.emailAccountAdmins
    disabledAlerts: sqlLogicalServer.azureDefender.disabledRules
  }
}

// Get existing storage account
resource storageAccountVulnerabilityAssessments 'Microsoft.Storage/storageAccounts@2021-04-01' existing = if (sqlLogicalServer.azureDefender.enabled && sqlLogicalServer.azureDefender.vulnerabilityAssessments.recurringScans && !empty(sqlLogicalServer.azureDefender.vulnerabilityAssessments.storageAccount.name)) {
  scope: resourceGroup(sqlLogicalServer.azureDefender.vulnerabilityAssessments.storageAccount.resourceGroupName)
  name: sqlLogicalServer.azureDefender.vulnerabilityAssessments.storageAccount.name
}

// Vulnerability Assessments
// Can be enabled only if Azure Defender is enabled as well
resource vulnerabilityAssessments 'Microsoft.Sql/servers/vulnerabilityAssessments@2021-02-01-preview' = if (sqlLogicalServer.azureDefender.enabled && sqlLogicalServer.azureDefender.vulnerabilityAssessments.recurringScans && !empty(sqlLogicalServer.azureDefender.vulnerabilityAssessments.storageAccount.name)) {
  dependsOn: [
    azureDefender
  ]
  name: 'Default'
  parent: sqlLogicalServerRes
  properties: {
    recurringScans: {
      isEnabled: sqlLogicalServer.azureDefender.vulnerabilityAssessments.recurringScans
      emailSubscriptionAdmins: sqlLogicalServer.azureDefender.vulnerabilityAssessments.emailSubscriptionAdmins
      emails: sqlLogicalServer.azureDefender.vulnerabilityAssessments.emails
    }
    storageContainerPath: !empty(sqlLogicalServer.azureDefender.vulnerabilityAssessments.storageAccount.name) ? '${storageAccountVulnerabilityAssessments.properties.primaryEndpoints.blob}${sqlLogicalServer.azureDefender.vulnerabilityAssessments.storageAccount.containerName}' : ''
    storageAccountAccessKey: !empty(sqlLogicalServer.azureDefender.vulnerabilityAssessments.storageAccount.name) ? listKeys(storageAccountVulnerabilityAssessments.id, storageAccountVulnerabilityAssessments.apiVersion).keys[0].value : ''
  }
}

// Audit settings need for enabling auditing to Log Analytics workspace
resource auditSettings 'Microsoft.Sql/servers/auditingSettings@2021-02-01-preview' = {
  name: 'Default'
  parent: sqlLogicalServerRes
  properties: {
    state: sqlLogicalServer.diagnosticLogsAndMetrics.auditLogs ? 'Enabled' : 'Disabled'
    auditActionsAndGroups: !empty(sqlLogicalServer.auditActionsAndGroups) ? sqlLogicalServer.auditActionsAndGroups : defaultAuditActionsAndGroups
    storageEndpoint: ''
    storageAccountAccessKey: ''
    storageAccountSubscriptionId: '00000000-0000-0000-0000-000000000000'
    retentionDays: 0
    isAzureMonitorTargetEnabled: sqlLogicalServer.diagnosticLogsAndMetrics.auditLogs
    isDevopsAuditEnabled: sqlLogicalServer.diagnosticLogsAndMetrics.microsoftSupportOperationsAuditLogs
  }
}

// SQL Logical Server Firewall Rules
module sqlFirewallRules 'sql-firewall-rule.bicep' = [for (firewallRules, index) in sqlLogicalServer.firewallRules: {
  dependsOn: [
    sqlLogicalServerRes
  ]
  name: 'sqlFirewallRule-${uniqueString(sqlLogicalServer.name)}-${index}'
  params: {
    sqlFirewallRule: sqlLogicalServer.firewallRules[index]
    sqlServerName: sqlLogicalServer.name
  }
}]

// SQL Databases
module sqlDatabases 'sql-database.bicep' = [for (sqlDatabase, index) in sqlLogicalServer.databases: {
  dependsOn: [
    sqlLogicalServerRes
  ]
  name: 'sqlDb-${uniqueString(sqlLogicalServer.name)}-${index}'
  params: {
    sqlServerName: sqlLogicalServer.name
    sqlDatabase: union(defaultSqlDatabaseProperties, sqlLogicalServer.databases[index])
    tags: union(tags, union(defaultSqlDatabaseProperties, sqlLogicalServer.databases[index]).tags)
  }
}]

// Empty deployment that serves as artificial delay until master database resource is created
@batchSize(1)
resource dummyDeployments 'Microsoft.Resources/deployments@2021-04-01' = [for (dummyDeployment, index) in range(0, 5): if (sqlLogicalServer.diagnosticLogsAndMetrics.auditLogs && !empty(sqlLogicalServer.diagnosticLogsAndMetrics.name)) {
  dependsOn: [
    sqlLogicalServerRes
  ]
  name: 'dummyTemplateSqlServer-${uniqueString(sqlLogicalServer.name)}-${index}'
  properties: {
    mode: 'Incremental'
    template: {
      '$schema': 'https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#'
      contentVersion: '1.0.0.0'
      resources: []
    }
  }
}]

// Get existing master database
resource masterDb 'Microsoft.Sql/servers/databases@2021-02-01-preview' existing = if (sqlLogicalServer.diagnosticLogsAndMetrics.auditLogs || !empty(sqlLogicalServer.diagnosticLogsAndMetrics.name)) {
  name: 'master'
  parent: sqlLogicalServerRes
}

// Get existing Log Analytics workspace
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-10-01' existing = if (sqlLogicalServer.diagnosticLogsAndMetrics.auditLogs || !empty(sqlLogicalServer.diagnosticLogsAndMetrics.name)) {
  scope: resourceGroup(sqlLogicalServer.diagnosticLogsAndMetrics.subscriptionId, sqlLogicalServer.diagnosticLogsAndMetrics.resourceGroupName)
  name: sqlLogicalServer.diagnosticLogsAndMetrics.name
}

// Sends audit logs to Log Analytics Workspace
resource auditDiagnosticSettings 'microsoft.insights/diagnosticSettings@2017-05-01-preview' = if (sqlLogicalServer.diagnosticLogsAndMetrics.auditLogs) {
  dependsOn: [
    auditSettings
    sqlDatabases
    dummyDeployments
  ]
  scope: masterDb
  name: 'SQLSecurityAuditEvents_3d229c42-c7e7-4c97-9a99-ec0d0d8b86c1'
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    logs: [
      {
        category: 'SQLSecurityAuditEvents'
        enabled: true
      }
      {
        category: 'DevOpsOperationsAudit'
        enabled: sqlLogicalServer.diagnosticLogsAndMetrics.microsoftSupportOperationsAuditLogs
      }
    ]
  }
}

// Send other logs and metrics to Log Analytics
resource diagnosticSettings 'microsoft.insights/diagnosticSettings@2017-05-01-preview' = if (!empty(sqlLogicalServer.diagnosticLogsAndMetrics.name)) {
  dependsOn: [
    sqlDatabases
    dummyDeployments
  ]
  scope: masterDb
  name: 'sendLogsAndMetrics'
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    logs: [for log in sqlLogicalServer.diagnosticLogsAndMetrics.logs: {
      category: log
      enabled: true
    }]
    metrics: [for metric in sqlLogicalServer.diagnosticLogsAndMetrics.metrics: {
      category: metric
      enabled: true
    }]
  }
}
