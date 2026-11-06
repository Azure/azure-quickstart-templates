@description('The globally unique SQL logical server name.')
@minLength(1)
@maxLength(63)
param serverName string = 'sql-${uniqueString(resourceGroup().id)}'

@description('The database name.')
param databaseName string = 'retentionDatabase'

@description('Location for all resources.')
param location string = resourceGroup().location

@description('The display name of an existing Microsoft Entra administrator.')
@minLength(1)
param administratorLogin string

@description('The object ID of the existing Microsoft Entra administrator in the subscription tenant.')
@minLength(36)
@maxLength(36)
param administratorObjectId string

@description('The Microsoft Entra administrator principal type.')
@allowed([
  'User'
  'Group'
  'Application'
])
param administratorPrincipalType string = 'User'

@description('The SQL client public IPv4 address. Do not use 0.0.0.0, which allows Azure services.')
@minLength(7)
@maxLength(15)
param clientIpAddress string

@description('The paid Standard-tier database service objective.')
param databaseSkuName string = 'S0'

@description('Days of point-in-time restore retention.')
@minValue(1)
@maxValue(35)
param retentionDays int = 7

@description('How long weekly full backups are retained, in ISO 8601 duration format. P1W retains each weekly backup for one week.')
param weeklyRetention string = 'P1W'

@description('How long monthly full backups are retained, in ISO 8601 duration format.')
param monthlyRetention string = 'P1M'

@description('How long yearly full backups are retained, in ISO 8601 duration format.')
param yearlyRetention string = 'P1Y'

@description('The week of the year whose full backup is retained as the yearly backup.')
@minValue(1)
@maxValue(52)
param weekOfYear int = 1

resource sqlServer 'Microsoft.Sql/servers@2023-08-01' = {
  name: serverName
  location: location
  properties: {
    version: '12.0'
    minimalTlsVersion: '1.2'
    publicNetworkAccess: 'Enabled'
    administrators: {
      administratorType: 'ActiveDirectory'
      azureADOnlyAuthentication: true
      principalType: administratorPrincipalType
      login: administratorLogin
      sid: administratorObjectId
      tenantId: subscription().tenantId
    }
  }
}

resource clientFirewallRule 'Microsoft.Sql/servers/firewallRules@2023-08-01' = {
  parent: sqlServer
  name: 'AllowClientIp'
  properties: {
    startIpAddress: clientIpAddress
    endIpAddress: clientIpAddress
  }
}

resource sqlDatabase 'Microsoft.Sql/servers/databases@2023-08-01' = {
  parent: sqlServer
  name: databaseName
  location: location
  sku: {
    name: databaseSkuName
    tier: 'Standard'
  }
  properties: {
    createMode: 'Default'
    requestedBackupStorageRedundancy: 'Local'
  }
}

resource shortTermRetention 'Microsoft.Sql/servers/databases/backupShortTermRetentionPolicies@2023-08-01' = {
  parent: sqlDatabase
  name: 'default'
  properties: {
    retentionDays: retentionDays
  }
}

resource longTermRetention 'Microsoft.Sql/servers/databases/backupLongTermRetentionPolicies@2023-08-01' = {
  parent: sqlDatabase
  name: 'default'
  properties: {
    weeklyRetention: weeklyRetention
    monthlyRetention: monthlyRetention
    yearlyRetention: yearlyRetention
    weekOfYear: weekOfYear
  }
}

@description('The SQL server fully qualified domain name.')
output serverFullyQualifiedDomainName string = sqlServer.properties.fullyQualifiedDomainName

@description('The SQL logical server name.')
output serverName string = sqlServer.name

@description('The database name.')
output databaseName string = sqlDatabase.name

@description('The database resource ID.')
output databaseResourceId string = sqlDatabase.id
