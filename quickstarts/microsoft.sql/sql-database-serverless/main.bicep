@description('The globally unique SQL logical server name.')
@minLength(1)
@maxLength(63)
param serverName string = 'sql-${uniqueString(resourceGroup().id)}'

@description('The database name.')
param databaseName string = 'serverlessDatabase'

@description('Location for all resources.')
param location string = resourceGroup().location

@description('The display name of the existing Microsoft Entra administrator.')
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

@description('The public IPv4 address of the SQL client. Do not use 0.0.0.0, which allows Azure services.')
@minLength(7)
@maxLength(15)
param clientIpAddress string

@description('Maximum serverless vCores. Check regional availability before increasing this value.')
@minValue(2)
@maxValue(40)
param maxVcores int = 2

@description('Minimum serverless vCores, expressed as a string because Bicep has no decimal literal type.')
@allowed([
  '0.5'
  '1'
  '2'
])
param minVcores string = '0.5'

@description('Minutes of inactivity before auto-pause. This paid sample does not disable auto-pause.')
@minValue(15)
@maxValue(10080)
param autoPauseDelay int = 60

@description('Maximum database data size in GiB.')
@minValue(1)
@maxValue(1024)
param maxSizeGB int = 32

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
    name: 'GP_S_Gen5'
    tier: 'GeneralPurpose'
    family: 'Gen5'
    capacity: maxVcores
  }
  properties: {
    createMode: 'Default'
    minCapacity: json(minVcores)
    autoPauseDelay: autoPauseDelay
    maxSizeBytes: maxSizeGB * 1073741824
    requestedBackupStorageRedundancy: 'Local'
    useFreeLimit: false
  }
}

@description('The SQL logical server fully qualified domain name.')
output serverFullyQualifiedDomainName string = sqlServer.properties.fullyQualifiedDomainName

@description('The serverless database name.')
output databaseName string = sqlDatabase.name

@description('The database resource ID.')
output databaseResourceId string = sqlDatabase.id
