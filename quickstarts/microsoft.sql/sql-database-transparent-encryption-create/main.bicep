@description('The administrator username of the SQL Server.')
param sqlAdministratorLogin string

@description('The administrator password of the SQL Server.')
@secure()
param sqlAdministratorLoginPassword string

@description('Enable or disable Transparent Data Encryption (TDE) for the database.')
@allowed([
  'Enabled'
  'Disabled'
])
param transparentDataEncryption string = 'Enabled'

@description('Location for all resources.')
param location string = resourceGroup().location

var sqlServerName = 'sqlserver${uniqueString(subscription().id,resourceGroup().id)}'
var databaseName = 'sample-db-with-tde'
var skuName = 'Basic'
var databaseCollation = 'SQL_Latin1_General_CP1_CI_AS'

resource sqlServer 'Microsoft.Sql/servers@2024-11-01-preview' = {
  name: sqlServerName
  location: location
  tags: {
    displayName: 'SqlServer'
  }
  properties: {
    administratorLogin: sqlAdministratorLogin
    administratorLoginPassword: sqlAdministratorLoginPassword
    version: '12.0'
  }
}

resource sqlServerName_database 'Microsoft.Sql/servers/databases@2020-02-02-preview' = {
  parent: sqlServer
  name: databaseName
  location: location
  tags: {
    displayName: 'Database'
  }
  sku: {
    name: skuName
  }
  properties: {
    collation: databaseCollation
  }
}

resource sqlServerName_databaseName_current 'Microsoft.Sql/servers/databases/transparentDataEncryption@2024-11-01-preview' = {
  parent: sqlServerName_database
  name: 'current'
  properties: {
    state: transparentDataEncryption
  }
}

resource sqlServerName_AllowAllMicrosoftAzureIps 'Microsoft.Sql/servers/firewallrules@2020-02-02-preview' = {
  parent: sqlServer
  name: 'AllowAllMicrosoftAzureIps'
  properties: {
    endIpAddress: '0.0.0.0'
    startIpAddress: '0.0.0.0'
  }
}

output sqlServerFqdn string = sqlServer.properties.fullyQualifiedDomainName
output databaseName string = databaseName
