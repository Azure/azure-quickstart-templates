@description('The SQL Logical Server name.')
param sqlServerName string = 'sql${uniqueString(resourceGroup().id)}'

@description('The administrator username of the SQL Server.')
param sqlAdministratorLogin string

@description('The administrator password of the SQL Server.')
@secure()
param sqlAdministratorPassword string

@description('The name of the Database.')
param databasesName string

@description('Enable/Disable Transparent Data Encryption')
@allowed([
  'Enabled'
  'Disabled'
])
param transparentDataEncryption string = 'Enabled'

@description('DW Performance Level expressed in DTU (i.e. 900 DTU = DW100c)')
@minValue(900)
@maxValue(54000)
param capacity int

@description('The SQL Database collation.')
param databaseCollation string = 'SQL_Latin1_General_CP1_CI_AS'

@description('Resource location')
param location string = resourceGroup().location

resource sqlServer 'Microsoft.Sql/servers@2021-11-01-preview' = {
  name: sqlServerName
  location: location
  properties: {
    administratorLogin: sqlAdministratorLogin
    administratorLoginPassword: sqlAdministratorPassword
    version: '12.0'
    publicNetworkAccess: 'Enabled'
    restrictOutboundNetworkAccess: 'Disabled'
  }
}

resource sqlServerDatabase 'Microsoft.Sql/servers/databases@2021-11-01-preview' = {
  parent: sqlServer
  name: databasesName
  location: location
  sku: {
    name: 'DataWarehouse'
    tier: 'DataWarehouse'
    capacity: capacity
  }
  properties: {
    collation: databaseCollation
    catalogCollation: databaseCollation
    readScale: 'Disabled'
    requestedBackupStorageRedundancy: 'Geo'
    isLedgerOn: false
  }
}

resource encryption 'Microsoft.Sql/servers/databases/transparentDataEncryption@2021-11-01-preview' = {
  parent: sqlServerDatabase
  name: 'current'
  properties: {
    state: transparentDataEncryption
  }
}
