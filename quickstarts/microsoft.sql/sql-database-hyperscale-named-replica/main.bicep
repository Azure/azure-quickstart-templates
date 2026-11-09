@description('Azure region supporting provisioned Hyperscale standard-series (Gen5) databases.')
param location string = resourceGroup().location

@description('Globally unique logical server name. Use lowercase letters, digits, and hyphens; start and end with a letter or digit.')
@minLength(1)
@maxLength(63)
param sqlServerName string = 'sql-${uniqueString(resourceGroup().id)}'

@description('Display name or user principal name of an existing Microsoft Entra administrator in the subscription tenant.')
@minLength(1)
param administratorLogin string

@description('Object ID (not application/client ID) of the existing Microsoft Entra administrator in the subscription tenant.')
@minLength(36)
@maxLength(36)
param administratorObjectId string

@description('Type of the Microsoft Entra administrator principal.')
@allowed([
  'User'
  'Group'
  'Application'
])
param administratorPrincipalType string = 'User'

@description('One trusted client public IPv4 address. Do not use 0.0.0.0, which enables access from Azure services.')
@minLength(7)
@maxLength(15)
param clientIpAddress string

@description('Name of the writable primary Hyperscale database. The named replica receives this name plus -reporting.')
@minLength(1)
@maxLength(118)
param databaseName string = 'hyperscale'

@description('Provisioned Gen5 vCores for the primary database. Minimum 2; choose a supported Hyperscale Gen5 size in the selected region.')
@minValue(2)
param primaryVcores int = 2

@description('Independently provisioned Gen5 vCores for the named replica. Minimum 2; choose a supported Hyperscale Gen5 size in the selected region.')
@minValue(2)
param namedReplicaVcores int = 2

var namedReplicaName = '${databaseName}-reporting'

resource sqlServer 'Microsoft.Sql/servers@2023-08-01' = {
  name: sqlServerName
  location: location
  properties: {
    version: '12.0'
    minimalTlsVersion: '1.2'
    publicNetworkAccess: 'Enabled'
    administrators: {
      administratorType: 'ActiveDirectory'
      azureADOnlyAuthentication: true
      login: administratorLogin
      principalType: administratorPrincipalType
      sid: administratorObjectId
      tenantId: subscription().tenantId
    }
  }
}

resource clientFirewallRule 'Microsoft.Sql/servers/firewallRules@2023-08-01' = {
  parent: sqlServer
  name: 'AllowSingleClient'
  properties: {
    startIpAddress: clientIpAddress
    endIpAddress: clientIpAddress
  }
}

resource primaryDatabase 'Microsoft.Sql/servers/databases@2023-08-01' = {
  parent: sqlServer
  name: databaseName
  location: location
  sku: {
    name: 'HS_Gen5_${primaryVcores}'
    tier: 'Hyperscale'
    family: 'Gen5'
    capacity: primaryVcores
  }
  properties: {
    highAvailabilityReplicaCount: 0
  }
}

resource namedReplica 'Microsoft.Sql/servers/databases@2023-08-01' = {
  parent: sqlServer
  name: namedReplicaName
  location: location
  sku: {
    name: 'HS_Gen5_${namedReplicaVcores}'
    tier: 'Hyperscale'
    family: 'Gen5'
    capacity: namedReplicaVcores
  }
  properties: {
    createMode: 'Secondary'
    secondaryType: 'Named'
    sourceDatabaseId: primaryDatabase.id
    highAvailabilityReplicaCount: 0
  }
}

output sqlServerName string = sqlServer.name
output sqlServerFullyQualifiedDomainName string = sqlServer.properties.fullyQualifiedDomainName
output primaryDatabaseName string = primaryDatabase.name
output primaryDatabaseResourceId string = primaryDatabase.id
output namedReplicaDatabaseName string = namedReplica.name
output namedReplicaResourceId string = namedReplica.id
