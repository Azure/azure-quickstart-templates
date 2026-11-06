@description('The globally unique name of the SQL logical server.')
@minLength(1)
@maxLength(63)
param serverName string = 'sql-${uniqueString(resourceGroup().id)}'

@description('The name of the new free tier SQL database.')
param databaseName string = 'freeDatabase'

@description('Location for all resources. Use the region of any existing free tier databases in the subscription.')
param location string = resourceGroup().location

@description('The display name of an existing Microsoft Entra user, group, or application to configure as the SQL server administrator.')
@minLength(1)
param administratorLogin string

@description('The object ID of the Microsoft Entra administrator in the subscription tenant. For an application, use the service principal object ID, not the application ID.')
@minLength(36)
@maxLength(36)
param administratorObjectId string

@description('The type of Microsoft Entra principal to configure as the SQL server administrator.')
@allowed([
  'User'
  'Group'
  'Application'
])
param administratorPrincipalType string = 'User'

@description('The public IPv4 address of the client allowed through the SQL server firewall. Specify a single client address, not 0.0.0.0.')
@minLength(7)
@maxLength(15)
param clientIpAddress string

resource sqlServer 'Microsoft.Sql/servers@2023-08-01' = {
  name: serverName
  location: location
  properties: {
    version: '12.0'
    minimalTlsVersion: '1.2'
    publicNetworkAccess: 'Enabled'
    administrators: {
      administratorType: 'ActiveDirectory'
      principalType: administratorPrincipalType
      login: administratorLogin
      sid: administratorObjectId
      tenantId: subscription().tenantId
      azureADOnlyAuthentication: true
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
    name: 'GP_S_Gen5'
    tier: 'GeneralPurpose'
    family: 'Gen5'
    capacity: 2
  }
  properties: {
    createMode: 'Default'
    maxSizeBytes: 34359738368
    minCapacity: json('0.5')
    useFreeLimit: true
    freeLimitExhaustionBehavior: 'AutoPause'
    requestedBackupStorageRedundancy: 'Local'
  }
}

@description('The fully qualified domain name of the SQL logical server.')
output serverFullyQualifiedDomainName string = sqlServer.properties.fullyQualifiedDomainName

@description('The name of the free tier SQL database.')
output databaseName string = sqlDatabase.name

@description('The resource ID of the free tier SQL database.')
output databaseResourceId string = sqlDatabase.id
