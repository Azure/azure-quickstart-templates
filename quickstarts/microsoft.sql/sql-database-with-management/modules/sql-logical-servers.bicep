@description('SQL logical servers.')
param sqlLogicalServers array
param tags object

var defaultSqlLogicalServerProperties = {
  name: ''
  tags: {}
  userName: ''
  passwordFromKeyVault: {
    subscriptionId: subscription().subscriptionId
    resourceGroupName: ''
    name: ''
    secretName: ''
  }
  systemManagedIdentity: false
  minimalTlsVersion: '1.2'
  publicNetworkAccess: 'Enabled'
  azureActiveDirectoryAdministrator: {
    name: ''
    objectId: ''
    tenantId: subscription().tenantId
  }
  firewallRules: []
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
    microsoftSupportOperationsAuditLogs: false
  }
  databases: []
}

resource sqlPassKeyVaults 'Microsoft.KeyVault/vaults@2021-04-01-preview' existing = [for keyVault in sqlLogicalServers: {
  name: keyVault.passwordFromKeyVault.name
  scope: resourceGroup(union(defaultSqlLogicalServerProperties, keyVault).passwordFromKeyVault.subscriptionId, keyVault.passwordFromKeyVault.resourceGroupName)
}]

module sqlLogicalServer 'sql-logical-server.bicep' = [for (sqlLogicalServer, index) in sqlLogicalServers: {
  name: 'sqlLogicalServer-${index}'
  params: {
    sqlLogicalServer: union(defaultSqlLogicalServerProperties, sqlLogicalServer)
    password: sqlPassKeyVaults[index].getSecret(sqlLogicalServer.passwordFromKeyVault.secretName)
    tags: union(tags, union(defaultSqlLogicalServerProperties, sqlLogicalServer).tags)
  }
}]
