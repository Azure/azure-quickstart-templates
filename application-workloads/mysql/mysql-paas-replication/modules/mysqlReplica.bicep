@description('SKU for the MySQL PaaS instance to be deployed.')
param sku object

@description('Name of the MySQL PaaS instance to be deployed.')
param serverName string

@description('Location where the instance should be deployed.')
param location string

@description('Number of replica instances to be deployed.')
param numberOfReplicas int

@description('Backup retention period.')
param backupRetentionDays int

@description('Enable or disable geo redundant backups.')
param geoRedundantBackup string

@description('Reference ID of the MySQL PaaS instance being deployed.')
param sourceServerId string

@batchSize(1)
resource mysqlServer 'Microsoft.DBforMySQL/servers@2017-12-01' = [for i in range(0, ((numberOfReplicas == 0) ? (numberOfReplicas + 1) : numberOfReplicas)): {
  sku: sku
  name: '${serverName}${(i + 1)}'
  location: location
  properties: {
    createMode: 'Replica'
    sourceServerId: sourceServerId
    storageProfile: {
      storageMB: sku.size
      backupRetentionDays: backupRetentionDays
      geoRedundantBackup: geoRedundantBackup
    }
  }
}]
