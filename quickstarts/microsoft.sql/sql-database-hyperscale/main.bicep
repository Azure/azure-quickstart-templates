@description('Azure region for the SQL logical server and database.')
param location string = resourceGroup().location

@description('Globally unique name of the new SQL logical server.')
@minLength(1)
@maxLength(63)
param serverName string = 'sql-${uniqueString(resourceGroup().id)}'

@description('Name of the new Hyperscale database.')
@minLength(1)
@maxLength(128)
param databaseName string = 'hyperscaledb'

@description('Display name of the existing Microsoft Entra administrator user or group. This is not a SQL authentication login.')
@minLength(1)
param administratorLogin string

@description('Object ID of the existing Microsoft Entra administrator in the deployment subscription tenant.')
@minLength(36)
@maxLength(36)
param administratorObjectId string

@description('Microsoft Entra administrator principal type.')
@allowed([
  'User'
  'Group'
])
param administratorPrincipalType string = 'User'

@description('Actual public IPv4 egress address of the SQL client. Allows exactly this address; do not use 0.0.0.0.')
@minLength(7)
@maxLength(15)
param clientIpAddress string

@description('Paid provisioned standard-series (Gen5) vCores. Choose a supported regional capacity; 2 is the smallest size. Compute is billed even when idle.')
@minValue(2)
@maxValue(80)
param databaseCapacity int = 2

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
      login: administratorLogin
      sid: administratorObjectId
      tenantId: subscription().tenantId
      principalType: administratorPrincipalType
    }
  }
}

resource clientFirewallRule 'Microsoft.Sql/servers/firewallRules@2023-08-01' = {
  parent: sqlServer
  name: 'AllowSqlClient'
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
    name: 'HS_Gen5'
    tier: 'Hyperscale'
    family: 'Gen5'
    capacity: databaseCapacity
  }
  properties: {
    licenseType: 'LicenseIncluded'
    highAvailabilityReplicaCount: 0
    zoneRedundant: false
    requestedBackupStorageRedundancy: 'Local'
  }
}

@description('Fully qualified domain name of the SQL logical server.')
output serverFullyQualifiedDomainName string = sqlServer.properties.fullyQualifiedDomainName

@description('Name of the Hyperscale database.')
output databaseName string = sqlDatabase.name

@description('Resource ID of the Hyperscale database.')
output databaseResourceId string = sqlDatabase.id
