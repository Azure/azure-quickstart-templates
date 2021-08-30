@description('Name of azure web app')
param siteName string

@description('Database administrator login name')
@minLength(1)
param administratorLogin string

@description('Database administrator password')
@minLength(8)
@maxLength(128)
@secure()
param administratorLoginPassword string

@description('Azure database for MySQL compute capacity in vCores (2,4,8,16,32)')
@allowed([
  2
  4
  8
  16
  32
])
param databaseSkucapacity int = 2

@description('Azure database for MySQL sku name ')
@allowed([
  'GP_Gen5_2'
  'GP_Gen5_4'
  'GP_Gen5_8'
  'GP_Gen5_16'
  'GP_Gen5_32'
  'MO_Gen5_2'
  'MO_Gen5_4'
  'MO_Gen5_8'
  'MO_Gen5_16'
  'MO_Gen5_32'
])
param databaseSkuName string = 'GP_Gen5_2'

@description('Azure database for MySQL Sku Size ')
@allowed([
  51200
  102400
])
param databaseSkuSizeMB int = 51200

@description('Azure database for MySQL pricing tier')
@allowed([
  'GeneralPurpose'
  'MemoryOptimized'
])
param databaseSkuTier string = 'GeneralPurpose'

@description('MySQL version')
@allowed([
  '5.6'
  '5.7'
])
param mySqlVersion string = '5.6'

@description('Location for all resources.')
param location string = resourceGroup().location

@description('Azure database for MySQL sku family')
param databaseSkuFamily string = 'Gen5'

var databaseName = '${siteName}-database'
var serverName = '${siteName}-server'
var hostingPlanName = '${siteName}-serviceplan'

resource hostingPlan 'Microsoft.Web/serverfarms@2020-06-01' = {
  name: hostingPlanName
  location: location
  properties: {
    reserved: true
  }
  sku: {
    tier: 'Standard'
    name: 'S1'
  }
}

resource website 'Microsoft.Web/sites@2020-06-01' = {
  name: siteName
  location: location
  properties: {
    serverFarmId: hostingPlan.id
  }
}

resource connectionString 'Microsoft.Web/sites/config@2020-06-01' = {
  parent: website
  name: 'connectionstrings'
  properties: {
    defaultConnection: {
      value: 'Database=${databaseName};Data Source=${server.properties.fullyQualifiedDomainName};User Id=${administratorLogin}@${serverName};Password=${administratorLoginPassword}'
      type: 'MySql'
    }
  }
}

resource server 'Microsoft.DBforMySQL/servers@2017-12-01' = {
  location: location
  name: serverName
  sku: {
    name: databaseSkuName
    tier: databaseSkuTier
    capacity: databaseSkucapacity
    size: string(databaseSkuSizeMB)
    family: databaseSkuFamily
  }
  properties: {
    createMode: 'Default'
    version: mySqlVersion
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword
    storageProfile: {
      storageMB: databaseSkuSizeMB
      backupRetentionDays: 7
      geoRedundantBackup: 'Disabled'
    }
    sslEnforcement: 'Disabled'
  }
}

resource firewallRules 'Microsoft.DBforMySQL/servers/firewallrules@2017-12-01' = {
  parent: server
  name: 'AllowAzureIPs'
  dependsOn: [
    database
  ]
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '0.0.0.0'
  }
}

resource database 'Microsoft.DBforMySQL/servers/databases@2017-12-01' = {
  parent: server
  name: databaseName
  properties: {
    charset: 'utf8'
    collation: 'utf8_general_ci'
  }
}
