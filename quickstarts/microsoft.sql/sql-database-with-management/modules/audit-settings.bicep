param sqlDatabase object
param sqlServerName string

var defaultAuditActionsAndGroups = [
  'SUCCESSFUL_DATABASE_AUTHENTICATION_GROUP'
  'FAILED_DATABASE_AUTHENTICATION_GROUP'
  'BATCH_COMPLETED_GROUP'
]

// Audit settings need for enabling auditing to Log Analytics workspace
resource auditSettings 'Microsoft.Sql/servers/databases/auditingSettings@2021-02-01-preview' = {
  name: '${sqlServerName}/${sqlDatabase.name}/Default'
  properties: {
    state: sqlDatabase.diagnosticLogsAndMetrics.auditLogs ? 'Enabled' : 'Disabled'
    auditActionsAndGroups: !empty(sqlDatabase.auditActionsAndGroups) ? sqlDatabase.auditActionsAndGroups : defaultAuditActionsAndGroups
    storageEndpoint: ''
    storageAccountAccessKey: ''
    storageAccountSubscriptionId: '00000000-0000-0000-0000-000000000000'
    retentionDays: 0
    isAzureMonitorTargetEnabled: sqlDatabase.diagnosticLogsAndMetrics.auditLogs
  }
}
