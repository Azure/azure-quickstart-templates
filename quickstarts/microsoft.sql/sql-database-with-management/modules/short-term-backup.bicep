param sqlDatabase object
param sqlServerName string

// Short term backup
resource shortTermBackup 'Microsoft.Sql/servers/databases/backupShortTermRetentionPolicies@2021-02-01-preview' = {
  name: '${sqlServerName}/${sqlDatabase.name}/Default'
  properties: {
    retentionDays: sqlDatabase.shortTermBackupRetention
  }
}
