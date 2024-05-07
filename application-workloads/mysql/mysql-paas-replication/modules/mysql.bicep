@description('SKU for the MySQL PaaS instance to be deployed.')
param sku object

@description('Name of the MySQL PaaS instance to be deployed.')
param mysqlServerName string

@description('Location where the instance should be deployed.')
param location string

@description('MySQL version for the MySQL Server instances to be deployed.')
param version string

@description('Administrator name for MySQL servers.')
param administratorLogin string

@description('Password for the MySQL server administrator.')
@secure()
param administratorLoginPassword string

@description('Backup retention period.')
param backupRetentionDays int

@description('Enable or disable geo redundant backups.')
param geoRedundantBackup string

@description('Enable Azure hosted resources to access the master instance.')
param enableAzureResources bool

resource mysqlServer 'Microsoft.DBforMySQL/servers@2017-12-01' = {
  sku: sku
  name: mysqlServerName
  location: location
  properties: {
    version: version
    createMode: 'Default'
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword
    storageProfile: {
      storageMB: sku.size
      backupRetentionDays: backupRetentionDays
      geoRedundantBackup: geoRedundantBackup
    }
  }
}

resource allowAzureResources 'Microsoft.DBforMySQL/servers/firewallRules@2017-12-01' = if (enableAzureResources) {
  parent: mysqlServer
  name: 'AllowAzureResources'
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '0.0.0.0'
  }
}

output mysqlDetails object = mysqlServer.properties
