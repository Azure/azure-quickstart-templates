@description('The name of the SQL server.')
param sqlServerName string

@description('The SQL database parameters object.')
param sqlDatabase object

param tags object

resource sqlDb 'Microsoft.Sql/servers/databases@2020-02-02-preview' = {
  name: '${sqlServerName}/${sqlDatabase.name}'
  location: resourceGroup().location
  tags: tags
  sku: {
    name: sqlDatabase.skuName
    tier: sqlDatabase.tier
  }
  properties: {
    zoneRedundant: sqlDatabase.zoneRedundant
    collation: sqlDatabase.collation
    maxSizeBytes: sqlDatabase.dataMaxSize == 0 ? null : 1024 * 1024 * 1024 * sqlDatabase.dataMaxSize
    licenseType: sqlDatabase.hybridBenefit ? 'BasePrice' : 'LicenseIncluded'
    readScale: sqlDatabase.readReplicas == 0 ? 'Disabled' : 'Enabled'
    readReplicaCount: sqlDatabase.readReplicas
    minCapacity: sqlDatabase.minimumCores == 0 ? null : sqlDatabase.minimumCores
    autoPauseDelay: sqlDatabase.autoPauseDelay == 0 ? null : sqlDatabase.autoPauseDelay
  }
}

// Transparent Data Encryption
resource transparentDataEncryption 'Microsoft.Sql/servers/databases/transparentDataEncryption@2014-04-01' = {
  name: 'current'
  parent: sqlDb
  properties: {
    status: sqlDatabase.dataEncryption
  }
}

// Short term backup
module shortTermBackup 'short-term-backup.bicep' = if (!(sqlDatabase.shortTermBackupRetention == 0)) {
  dependsOn: [
    transparentDataEncryption
    sqlDb
  ]
  name: 'shortTermBackup-${uniqueString(sqlServerName, sqlDatabase.name)}'
  params: {
    sqlDatabase: sqlDatabase
    sqlServerName: sqlServerName
  }
}

// Long term backup
resource longTermBackup 'Microsoft.Sql/servers/databases/backupLongTermRetentionPolicies@2021-02-01-preview' = if (sqlDatabase.longTermBackup.enabled) {
  dependsOn: [
    transparentDataEncryption
    shortTermBackup
  ]
  name: 'Default'
  parent: sqlDb
  properties: {
    weeklyRetention: sqlDatabase.longTermBackup.weeklyRetention
    monthlyRetention: sqlDatabase.longTermBackup.monthlyRetention
    yearlyRetention: sqlDatabase.longTermBackup.yearlyRetention
    weekOfYear: sqlDatabase.longTermBackup.weekOfYear
  }
}

// Azure Defender
module azureDefender 'azure-defender.bicep' = {
  dependsOn: [
    transparentDataEncryption
    sqlDb
  ]
  name: 'azureDefender-${uniqueString(sqlServerName, sqlDatabase.name)}'
  params: {
    sqlDatabase: sqlDatabase
    sqlServerName: sqlServerName
  }
}

// Get existing storage account
resource storageAccountVulnerabilityAssessments 'Microsoft.Storage/storageAccounts@2021-04-01' existing = if (sqlDatabase.azureDefender.enabled && sqlDatabase.azureDefender.vulnerabilityAssessments.recurringScans && !empty(sqlDatabase.azureDefender.vulnerabilityAssessments.storageAccount.name)) {
  scope: resourceGroup(sqlDatabase.azureDefender.vulnerabilityAssessments.storageAccount.resourceGroupName)
  name: sqlDatabase.azureDefender.vulnerabilityAssessments.storageAccount.name
}

// Vulnerability Assessments
// Can be enabled only if Azure Defender is enabled as well
resource vulnerabilityAssessments 'Microsoft.Sql/servers/databases/vulnerabilityAssessments@2021-02-01-preview' = if (sqlDatabase.azureDefender.enabled && sqlDatabase.azureDefender.vulnerabilityAssessments.recurringScans && !empty(sqlDatabase.azureDefender.vulnerabilityAssessments.storageAccount.name)) {
  dependsOn: [
    transparentDataEncryption
    azureDefender
  ]
  name: 'Default'
  parent: sqlDb
  properties: {
    recurringScans: {
      isEnabled: sqlDatabase.azureDefender.vulnerabilityAssessments.recurringScans
      emailSubscriptionAdmins: sqlDatabase.azureDefender.vulnerabilityAssessments.emailSubscriptionAdmins
      emails: sqlDatabase.azureDefender.vulnerabilityAssessments.emails
    }
    storageContainerPath: !empty(sqlDatabase.azureDefender.vulnerabilityAssessments.storageAccount.name) ? '${storageAccountVulnerabilityAssessments.properties.primaryEndpoints.blob}${sqlDatabase.azureDefender.vulnerabilityAssessments.storageAccount.containerName}' : ''
    storageAccountAccessKey: !empty(sqlDatabase.azureDefender.vulnerabilityAssessments.storageAccount.name) ? listKeys(storageAccountVulnerabilityAssessments.id, storageAccountVulnerabilityAssessments.apiVersion).keys[0].value : ''
  }
}

// Audit settings need for enabling auditing to Log Analytics workspace
module auditSettings 'audit-settings.bicep' = {
  dependsOn: [
    transparentDataEncryption
    sqlDb
  ]
  name: 'auditSettings-${uniqueString(sqlServerName, sqlDatabase.name)}'
  params: {
    sqlDatabase: sqlDatabase
    sqlServerName: sqlServerName
  }
}

// Get existing Log Analytics workspace
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-10-01' existing = if (sqlDatabase.diagnosticLogsAndMetrics.auditLogs || !empty(sqlDatabase.diagnosticLogsAndMetrics.name)) {
  scope: resourceGroup(sqlDatabase.diagnosticLogsAndMetrics.subscriptionId, sqlDatabase.diagnosticLogsAndMetrics.resourceGroupName)
  name: sqlDatabase.diagnosticLogsAndMetrics.name
}

// Sends audit logs to Log Analytics Workspace
resource auditDiagnosticSettings 'microsoft.insights/diagnosticSettings@2017-05-01-preview' = if (sqlDatabase.diagnosticLogsAndMetrics.auditLogs) {
  dependsOn: [
    transparentDataEncryption
    auditSettings
  ]
  scope: sqlDb
  name: 'SQLSecurityAuditEvents_3d229c42-c7e7-4c97-9a99-ec0d0d8b86c1'
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    logs: [
      {
        category: 'SQLSecurityAuditEvents'
        enabled: true
      }
    ]
  }
}

// Send other logs and metrics to Log Analytics
resource diagnosticSettings 'microsoft.insights/diagnosticSettings@2017-05-01-preview' = if (!empty(sqlDatabase.diagnosticLogsAndMetrics.name)) {
  dependsOn: [
    transparentDataEncryption
  ]
  scope: sqlDb
  name: 'sendLogsAndMetrics'
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    logs: [for log in sqlDatabase.diagnosticLogsAndMetrics.logs: {
      category: log
      enabled: true
    }]
    metrics: [for metric in sqlDatabase.diagnosticLogsAndMetrics.metrics: {
      category: metric
      enabled: true
    }]
  }
}
