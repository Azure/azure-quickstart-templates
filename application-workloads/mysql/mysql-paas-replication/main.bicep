@description('Server name for the MySQL PaaS instance and its replicas (replicas will get a "-" attached to the end with the replica number).')
param serverName string = uniqueString(resourceGroup().id)

@description('Location for the MySQL PaaS components to be deployed.')
param location string = resourceGroup().location

@description('Administrator name for MySQL servers.')
param administratorLogin string

@description('Password for the MySQL server administrator.')
@secure()
param administratorLoginPassword string

@description('Number of vCPUs for the MySQL Server instances to be deployed.')
param vCPU int = 2

@description('Hardware generation for the MySQL Server instances to be deployed.')
@allowed([
  'Gen4'
  'Gen5'
])
param skuFamily string = 'Gen5'

@description('Storage capacity for the MySQL Server instances to be deployed.')
@minValue(5120)
@maxValue(10240)
param skuSizeMB int = 5120

@description('Performance tier for the MySQL Server instances to be deployed.')
@allowed([
  'Basic'
  'GeneralPurpose'
  'MemoryOptimized'
])
param skuTier string = 'GeneralPurpose'

@description('Number of replica instances to be deployed.')
@allowed([
  0
  1
  2
  3
  4
  5
])
param numberOfReplicas int = 1

@description('MySQL version for the MySQL Server instances to be deployed.')
@allowed([
  '5.6'
  '5.7'
])
param version string = '5.7'

@description('Enable Azure hosted resources to access the master instance.')
param enableAzureResources bool = true

@description('Backup retention period.')
param backupRetentionDays int = 7

@description('Enable or disable geo redundant backups.')
@allowed([
  'Enabled'
  'Disabled'
])
param geoRedundantBackup string = 'Disabled'

var sourceServerId = resourceId('Microsoft.DBforMySQL/servers', serverName)
var skuName = '${((skuTier == 'GeneralPurpose') ? 'GP' : ((skuTier == 'Basic') ? 'B' : ((skuTier == 'MemoryOptimized') ? 'MO' : '')))}_${skuFamily}_${vCPU}'
var sku = {
  name: skuName
  tier: skuTier
  capacity: vCPU
  size: skuSizeMB
  family: skuFamily
}

module mySqlServer 'modules/mysql.bicep' = {
  name: 'MySQLServer'
  params: {
    sku: sku
    mysqlServerName: serverName
    location: location
    version: version
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword
    backupRetentionDays: backupRetentionDays
    geoRedundantBackup: geoRedundantBackup
    enableAzureResources: enableAzureResources
  }
}

module mySqlServerReplicas 'modules/mysqlReplica.bicep' = if (numberOfReplicas > 0) {
  name: 'MySQLServerReplicas'
  params: {
    sku: sku
    serverName: serverName
    location: location
    numberOfReplicas: numberOfReplicas
    backupRetentionDays: backupRetentionDays
    geoRedundantBackup: geoRedundantBackup
    sourceServerId: sourceServerId
  }
  dependsOn: [
    mySqlServer
  ]
}
