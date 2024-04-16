@description('Database watcher name')
param watcherName string

@description('The type of managed identity to assign to a watcher')
param identityType string

@description('The location (Azure region) of the watcher')
param location string = resourceGroup().location

@description('Set to true to create a new Azure Data Explorer cluster and database as the data store for the watcher')
param createNewDatastore bool

@description('The Kusto offering type of the data store. Supported values are: adx, free, fabric.')
param kustoOfferingType string = 'adx'

@description('The name of the Azure Data Explorer cluster')
param clusterName string

@description('The name of the Azure Data Explorer database')
param databaseName string = 'database-watcher-data-store'

@description('The SKU of the Azure Data Explorer cluster')
param clusterSkuName string

@description('The SKU tier of the Azure Data Explorer cluster')
param clusterSkuTier string

@description('The total number of SQL targets to add to a watcher')
param targetCount int

@description('The array of SQL target properties. Each element of the array defines a SQL target.')
param targetProperties array

@description('The total number of managed private links to add to a watcher')
param privateLinkCount int

@description('The array of managed private link properties. Each element of the array defines a managed private link to an Azure resource.')
param privateLinkProperties array

resource cluster 'Microsoft.Kusto/clusters@2023-05-02' = if (createNewDatastore == bool('true')) {
  name: clusterName
  location: location
  tags: {}
  sku: {
    capacity: 2
    name: clusterSkuName
    tier: clusterSkuTier
  }
  identity: {
    type: 'None'
  }
  properties: {
    enableAutoStop: false
    enableDiskEncryption: true
    enableDoubleEncryption: false
    enableStreamingIngest: true
    enablePurge: true
    engineType: 'V3'
    optimizedAutoscale: {
      isEnabled: false
      minimum: 2
      maximum: 2
      version: 1
    }
    publicIPType: 'IPv4'
    publicNetworkAccess: 'Enabled'
    restrictOutboundNetworkAccess: 'Disabled'
  }
}

resource watcher 'Microsoft.DatabaseWatcher/watchers@2023-09-01-preview' = {
  name: watcherName
  location: location
  identity: {
    type: identityType
  }
  properties: {
    datastore: {
      adxClusterResourceId: cluster.id
      kustoClusterDisplayName: clusterName
      kustoDatabaseName: databaseName
      kustoClusterUri: cluster.properties.uri
      kustoDataIngestionUri: cluster.properties.dataIngestionUri
      kustoManagementUrl: '${environment().portal}/resource/subscriptions/${cluster.id}/overview'
      kustoOfferingType: kustoOfferingType
    }
  }
}

resource clusterName_database 'Microsoft.Kusto/clusters/databases@2023-05-02' = {
  parent: cluster
  name: databaseName
  location: location
  kind: 'ReadWrite'
  properties: {}
}

resource principalAssignment 'Microsoft.Kusto/Clusters/Databases/PrincipalAssignments@2023-05-02' = {
  parent: clusterName_database
  name: guid(resourceGroup().id)
  properties: {
    tenantId: watcher.identity.tenantId
    principalId: watcher.identity.principalId
    role: 'Admin'
    principalType: 'App'
  }
}

resource targetSqlDbAad 'Microsoft.DatabaseWatcher/watchers/targets@2023-09-01-preview' = [for i in range(0, length(range(0, targetCount))): if ((targetProperties[i].targetType == 'SqlDb') && (targetProperties[i].targetAuthenticationType == 'Aad')) {
  parent: watcher
  name: guid(resourceGroup().id, watcherName, string(i))
  properties: {
    targetType: targetProperties[i].targetType
    sqlDbResourceId: resourceId(targetProperties[i].targetLogicalServerSubscriptionId, targetProperties[i].targetLogicalServerResourceGroupName, 'Microsoft.Sql/servers/databases', targetProperties[i].targetLogicalServerName, targetProperties[i].targetDatabaseName)
    connectionServerName: concat(targetProperties[i].targetLogicalServerName, targetProperties[i].targetServerDnsSuffix)
    readIntent: targetProperties[i].readIntent
    targetAuthenticationType: targetProperties[i].targetAuthenticationType
  }
}]

resource targetSqlDbSql 'Microsoft.DatabaseWatcher/watchers/targets@2023-09-01-preview' = [for i in range(0, length(range(0, targetCount))): if ((targetProperties[i].targetType == 'SqlDb') && (targetProperties[i].targetAuthenticationType == 'Sql')) {
  parent: watcher
  name: guid(resourceGroup().id, watcherName, string(i))
  properties: {
    targetType: targetProperties[i].targetType
    sqlDbResourceId: resourceId(targetProperties[i].targetLogicalServerSubscriptionId, targetProperties[i].targetLogicalServerResourceGroupName, 'Microsoft.Sql/servers/databases', targetProperties[i].targetLogicalServerName, targetProperties[i].targetDatabaseName)
    connectionServerName: concat(targetProperties[i].targetLogicalServerName, targetProperties[i].targetServerDnsSuffix)
    readIntent: targetProperties[i].readIntent
    targetAuthenticationType: targetProperties[i].targetAuthenticationType
    targetVault: {
      akvResourceId: resourceId(targetProperties[i].targetVaultSubscriptionId, targetProperties[i].targetVaultResourceGroup, 'Microsoft.KeyVault/vaults', targetProperties[i].targetVaultName)
      akvTargetUser: targetProperties[i].akvTargetUser
      akvTargetPassword: targetProperties[i].akvTargetPassword
    }
  }
}]

resource targetSqlEpAad 'Microsoft.DatabaseWatcher/watchers/targets@2023-09-01-preview' = [for i in range(0, length(range(0, targetCount))): if ((targetProperties[i].targetType == 'SqlEp') && (targetProperties[i].targetAuthenticationType == 'Aad')) {
  parent: watcher
  name: guid(resourceGroup().id, watcherName, string(i))
  properties: {
    targetType: targetProperties[i].targetType
    sqlEpResourceId: resourceId(targetProperties[i].targetLogicalServerSubscriptionId, targetProperties[i].targetLogicalServerResourceGroupName, 'Microsoft.Sql/servers/elasticPools', targetProperties[i].targetLogicalServerName, targetProperties[i].targetElasticPoolName)
    anchorDatabaseResourceId: resourceId('Microsoft.Sql/servers/databases', targetProperties[i].targetLogicalServerName, targetProperties[i].targetAnchorDatabaseName)
    connectionServerName: concat(targetProperties[i].targetLogicalServerName, targetProperties[i].targetServerDnsSuffix)
    readIntent: targetProperties[i].readIntent
    targetAuthenticationType: targetProperties[i].targetAuthenticationType
  }
}]

resource targetSqlEpSql 'Microsoft.DatabaseWatcher/watchers/targets@2023-09-01-preview' = [for i in range(0, length(range(0, targetCount))): if ((targetProperties[i].targetType == 'SqlEp') && (targetProperties[i].targetAuthenticationType == 'Sql')) {
  parent: watcher
  name: guid(resourceGroup().id, watcherName, string(i))
  properties: {
    targetType: targetProperties[i].targetType
    sqlEpResourceId: resourceId(targetProperties[i].targetLogicalServerSubscriptionId, targetProperties[i].targetLogicalServerResourceGroupName, 'Microsoft.Sql/servers/elasticPools', targetProperties[i].targetLogicalServerName, targetProperties[i].targetElasticPoolName)
    anchorDatabaseResourceId: resourceId('Microsoft.Sql/servers/databases', targetProperties[i].targetLogicalServerName, targetProperties[i].targetAnchorDatabaseName)
    connectionServerName: concat(targetProperties[i].targetLogicalServerName, targetProperties[i].targetServerDnsSuffix)
    readIntent: targetProperties[i].readIntent
    targetAuthenticationType: targetProperties[i].targetAuthenticationType
    targetVault: {
      akvResourceId: resourceId(targetProperties[i].targetVaultSubscriptionId, targetProperties[i].targetVaultResourceGroup, 'Microsoft.KeyVault/vaults', targetProperties[i].targetVaultName)
      akvTargetUser: targetProperties[i].akvTargetUser
      akvTargetPassword: targetProperties[i].akvTargetPassword
    }
  }
}]

resource targetSqlMiAad 'Microsoft.DatabaseWatcher/watchers/targets@2023-09-01-preview' = [for i in range(0, length(range(0, targetCount))): if ((targetProperties[i].targetType == 'SqlMi') && (targetProperties[i].targetAuthenticationType == 'Aad')) {
  parent: watcher
  name: guid(resourceGroup().id, watcherName, string(i))
  properties: {
    targetType: targetProperties[i].targetType
    sqlMiResourceId: resourceId(targetProperties[i].targetManagedInstanceSubscriptionId, targetProperties[i].targetManagedInstanceResourceGroupName, 'Microsoft.Sql/managedInstances', targetProperties[i].targetManagedInstanceName)
    connectionServerName: '${targetProperties[i].targetManagedInstanceName}.${targetProperties[i].targetManagedInstanceDnsZone}${targetProperties[i].targetManagedInstanceDnsSuffix}'
    connectionTcpPort: targetProperties[i].connectionTcpPort
    readIntent: targetProperties[i].readIntent
    targetAuthenticationType: targetProperties[i].targetAuthenticationType
  }
}]

resource targetSqlMiSql 'Microsoft.DatabaseWatcher/watchers/targets@2023-09-01-preview' = [for i in range(0, length(range(0, targetCount))): if ((targetProperties[i].targetType == 'SqlMi') && (targetProperties[i].targetAuthenticationType == 'Sql')) {
  parent: watcher
  name: guid(resourceGroup().id, watcherName, string(i))
  properties: {
    targetType: targetProperties[i].targetType
    sqlMiResourceId: resourceId(targetProperties[i].targetManagedInstanceSubscriptionId, targetProperties[i].targetManagedInstanceResourceGroupName, 'Microsoft.Sql/managedInstances', targetProperties[i].targetManagedInstanceName)
    connectionServerName: '${targetProperties[i].targetManagedInstanceName}.${targetProperties[i].targetManagedInstanceDnsZone}${targetProperties[i].targetManagedInstanceDnsSuffix}'
    connectionTcpPort: targetProperties[i].connectionTcpPort
    readIntent: targetProperties[i].readIntent
    targetAuthenticationType: targetProperties[i].targetAuthenticationType
    targetVault: {
      akvResourceId: resourceId(targetProperties[i].targetVaultSubscriptionId, targetProperties[i].targetVaultResourceGroup, 'Microsoft.KeyVault/vaults', targetProperties[i].targetVaultName)
      akvTargetUser: targetProperties[i].akvTargetUser
      akvTargetPassword: targetProperties[i].akvTargetPassword
    }
  }
}]

resource privateLinkSqlDb 'Microsoft.DatabaseWatcher/watchers/sharedPrivateLinkResources@2023-09-01-preview' = [for i in range(0, length(range(0, privateLinkCount))): if (privateLinkProperties[i].groupId == 'sqlServer') {
  parent: watcher
  name: '${privateLinkProperties[i].privateLinkName}'
  properties: {
    privateLinkResourceId: resourceId(privateLinkProperties[i].logicalServerSubscriptionId, privateLinkProperties[i].logicalServerResourceGroupName, 'Microsoft.Sql/servers', privateLinkProperties[i].logicalServerName)
    groupId: privateLinkProperties[i].groupId
    requestMessage: privateLinkProperties[i].requestMessage
    dnsZone: privateLinkProperties[i].dnsZone
  }
}]

resource privateLinkSqlMi 'Microsoft.DatabaseWatcher/watchers/sharedPrivateLinkResources@2023-09-01-preview' = [for i in range(0, length(range(0, privateLinkCount))): if (privateLinkProperties[i].groupId == 'managedInstance') {
  parent: watcher
  name: '${privateLinkProperties[i].privateLinkName}'
  properties: {
    privateLinkResourceId: resourceId(privateLinkProperties[i].managedInstanceSubscriptionId, privateLinkProperties[i].managedInstanceResourceGroupName, 'Microsoft.Sql/managedInstances', privateLinkProperties[i].managedInstanceName)
    groupId: privateLinkProperties[i].groupId
    requestMessage: privateLinkProperties[i].requestMessage
    dnsZone: privateLinkProperties[i].dnsZone
  }
}]

resource privateLinkAdx 'Microsoft.DatabaseWatcher/watchers/sharedPrivateLinkResources@2023-09-01-preview' = [for i in range(0, length(range(0, privateLinkCount))): if (privateLinkProperties[i].groupId == 'cluster') {
  parent: watcher
  name: '${privateLinkProperties[i].privateLinkName}'
  properties: {
    privateLinkResourceId: resourceId(privateLinkProperties[i].adxClusterSubscriptionId, privateLinkProperties[i].adxClusterResourceGroupName, 'Microsoft.Kusto/clusters', privateLinkProperties[i].adxClusterName)
    groupId: privateLinkProperties[i].groupId
    requestMessage: privateLinkProperties[i].requestMessage
    dnsZone: privateLinkProperties[i].dnsZone
  }
}]

resource privateLinkAkv 'Microsoft.DatabaseWatcher/watchers/sharedPrivateLinkResources@2023-09-01-preview' = [for i in range(0, length(range(0, privateLinkCount))): if (privateLinkProperties[i].groupId == 'vault') {
  parent: watcher
  name: '${privateLinkProperties[i].privateLinkName}'
  properties: {
    privateLinkResourceId: resourceId(privateLinkProperties[i].vaultSubscriptionId, privateLinkProperties[i].vaultResourceGroupName, 'Microsoft.KeyVault/vaults', privateLinkProperties[i].vaultName)
    groupId: privateLinkProperties[i].groupId
    requestMessage: privateLinkProperties[i].requestMessage
    dnsZone: privateLinkProperties[i].dnsZone
  }
}]

output watcherName string = watcher.name
output watcherId string = watcher.id
output location string = watcher.location
output resourceGroupName string = resourceGroup().name
