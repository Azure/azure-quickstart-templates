@description('The unique name of your website.')
param siteName string = uniqueString(resourceGroup().id)

@description('Database administrator login name')
@minLength(1)
param administratorLogin string

@description('Database administrator password')
@minLength(8)
@secure()
param administratorLoginPassword string

@description('Azure database for mySQL compute capacity in vCores (2,4,8,16,32)')
@allowed([
  2
  4
  8
  16
  32
])
param dbSkucapacity int = 2

@description('Azure database for mySQL sku name ')
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
param dbSkuName string = 'GP_Gen5_2'

@description('Azure database for mySQL Sku Size ')
@allowed([
  102400
  51200
])
param dbSkuSizeMB int = 51200

@description('Azure database for mySQL pricing tier')
@allowed([
  'GeneralPurpose'
  'MemoryOptimized'
])
param dbSkuTier string = 'GeneralPurpose'

@description('MySQL version')
@allowed([
  '5.6'
  '5.7'
])
param mysqlVersion string = '5.7'

@description('Location for all resources.')
param location string = resourceGroup().location

@description('Azure database for mySQL sku family')
param databaseskuFamily string = 'Gen5'

var databaseName = uniqueString(resourceGroup().id)
var mysqlserverName = uniqueString(resourceGroup().id)
var hostingPlanName = uniqueString(resourceGroup().id)

resource hostingPlan 'Microsoft.Web/serverfarms@2020-06-01' = {
  name: hostingPlanName
  location: location
  sku: {
    tier: 'Standard'
    name: 'S1'
  }
  kind: 'linux'
  properties: {
    reserved: true
  }
}

resource site 'Microsoft.Web/sites@2021-02-01' = {
  name: siteName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    siteConfig: {
      linuxFxVersion: 'php|7.0'
      ftpsState: 'FtpsOnly'
      minTlsVersion: '1.2'
      scmMinTlsVersion: '1.2'
      connectionStrings: [
        {
          name: 'defaultConnection'
          connectionString: 'Database=${databaseName};Data Source=${mysqlserver.properties.fullyQualifiedDomainName};User Id=${administratorLogin}@${mysqlserverName};Password=${administratorLoginPassword}'
          type: 'MySql'
        }
      ]
    }
    serverFarmId: hostingPlan.id
    httpsOnly: true
  }     
}

resource mysqlserver 'Microsoft.DBforMySQL/servers@2017-12-01' = {
  name: mysqlserverName
  location: location
  sku: {
    name: dbSkuName
    tier: dbSkuTier
    capacity: dbSkucapacity
    family: databaseskuFamily
  }
  properties: {
    createMode: 'Default'
    version: mysqlVersion
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword
    storageProfile: {
      storageMB: dbSkuSizeMB
      backupRetentionDays: 7
      geoRedundantBackup: 'Disabled'
    }
    sslEnforcement: 'Disabled'
  }
}

resource serverName_AllowAzureIPs 'Microsoft.DBforMySQL/servers/firewallrules@2017-12-01' = {
  parent: mysqlserver
  name: 'AllowAzureIPs'
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '255.255.255.255'
  }
}

resource mysqlserverName_databaseName 'Microsoft.DBforMySQL/servers/databases@2017-12-01' = {
  parent: mysqlserver
  name: databaseName
  properties: {
    charset: 'utf8'
    collation: 'utf8_general_ci'
  }
}
