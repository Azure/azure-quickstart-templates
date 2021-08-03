param sqlDatabase object
param sqlServerName string

// Azure Defender
resource azureDefender 'Microsoft.Sql/servers/databases/securityAlertPolicies@2021-02-01-preview' = {
  name: '${sqlServerName}/${sqlDatabase.name}/Default'
  properties: {
    state: sqlDatabase.azureDefender.enabled ? 'Enabled' : 'Disabled'
    emailAddresses: sqlDatabase.azureDefender.emailAddresses
    emailAccountAdmins: sqlDatabase.azureDefender.emailAccountAdmins
    disabledAlerts: sqlDatabase.azureDefender.disabledRules
  }
}
