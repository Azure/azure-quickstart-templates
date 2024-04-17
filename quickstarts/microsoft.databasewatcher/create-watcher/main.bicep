// This is a Bicep template for deploying a database watcher.
// For database watcher documentation, see https://aka.ms/dbwatcher.

@description('Database watcher name')
@minLength(4)
@maxLength(62)
param watcherName string

@description('The type of managed identity to assign to the watcher')
@allowed([
  'SystemAssigned'
])
param identityType string

@description('The location (Azure region) of the watcher')
param watcherLocation string = resourceGroup().location

@description('Set to true to create a new Azure Data Explorer cluster and database as the data store for the watcher')
param createNewDatastore bool

@description('The Kusto offering type of the data store')
@allowed([
  'adx'
])
param kustoOfferingType string = 'adx'

@description('The subscription ID of the Azure Data Explorer cluster. By default, the cluster is created in the same subscription as the watcher.')
param clusterSubscriptionId string = subscription().subscriptionId

@description('The resource group name of the Azure Data Explorer cluster. By default, the cluster is created in the same resource group as the watcher.')
@minLength(1)
@maxLength(90)
param clusterResourceGroupName string = resourceGroup().name

@description('The location (Azure region) of the Azure Data Explorer cluster. By default, the cluster is created in the same location as the watcher.')
param clusterLocation string = watcherLocation

@description('The name of the Azure Data Explorer cluster. If createNewDatastore is set to false, this must be an existing cluster.')
@minLength(4)
@maxLength(22)
param clusterName string

@description('The name of the Azure Data Explorer database. If createNewDatastore is set to false, this must be an existing database.')
@minLength(1)
@maxLength(260)
param kustoDatabaseName string = 'database-watcher-data-store'

@description('The SKU of the new Azure Data Explorer cluster. Not used if createNewDatastore is set to false.')
param clusterSkuName string = createNewDatastore ? 'Standard_E2d_v5' : ''

@description('The SKU tier of the Azure Data Explorer cluster. Not used if createNewDatastore is set to false.')
param clusterSkuTier string = createNewDatastore ? 'Standard' : ''

@description('The total number of SQL targets to add to the watcher. Must match the number of elements in the targetProperties array.')
@minValue(0)
@maxValue(50)
param targetCount int

@description('The array of SQL target properties. Each element of the array defines a SQL target.')
param targetProperties array

@description('The total number of managed private links to add to the watcher. Must match the number of elements in the privateLinkProperties array.')
@minValue(0)
@maxValue(101)
param privateLinkCount int

@description('The array of managed private link properties. Each element of the array defines a managed private link the watcher will use to connect to an Azure resource.')
param privateLinkProperties array

// Conditionally create an Azure Data Explorer cluster and a database on that cluster to be used as the watcher data store
module newDataStore './adxDataStore.bicep' =
  if(createNewDatastore && kustoOfferingType == 'adx') {
  name: 'watcher-data-store'
  scope: resourceGroup(clusterSubscriptionId, clusterResourceGroupName)
  params: {
    clusterName: clusterName
    clusterLocation: clusterLocation
    clusterSkuName: clusterSkuName
    clusterSkuTier: clusterSkuTier
    kustoDatabaseName: kustoDatabaseName
  }
}

// If a new Azure Data Explorer cluster is not created, get an existing cluster
resource adxCluster 'Microsoft.Kusto/clusters@2023-08-15' existing = 
  if(!createNewDatastore) {
  name: clusterName
  scope: resourceGroup(clusterSubscriptionId, clusterResourceGroupName)
}

// Create a watcher and configure it to use either the new or an existing data store
resource watcher 'Microsoft.DatabaseWatcher/watchers@2023-09-01-preview' = {
  name: watcherName
  location: watcherLocation
  identity: {
    type: identityType
  }
  properties: {
    datastore: {
      adxClusterResourceId: createNewDatastore ? newDataStore.outputs.adxClusterResourceId : adxCluster.id
      kustoClusterDisplayName: clusterName
      kustoDatabaseName: kustoDatabaseName
      kustoClusterUri: createNewDatastore ? newDataStore.outputs.adxClusterUri : adxCluster.properties.uri
      kustoDataIngestionUri: createNewDatastore ? newDataStore.outputs.adxDataIngestionUri : adxCluster.properties.dataIngestionUri
      kustoManagementUrl: '${environment().portal}/resource/subscriptions${resourceId('Microsoft.Kusto/Clusters', clusterName)}/overview'
      kustoOfferingType: kustoOfferingType
    }
  }
  dependsOn: [
    newDataStore
  ]
}

// Grant access to the managed identity of the watcher on the Azure Data Explorer database
module dataStoreRoleAssignment './adxRoleAssignment.bicep' = 
  if (kustoOfferingType == 'adx') {
  name: 'watcher-data-store-role-assignment'
  scope: resourceGroup(clusterSubscriptionId, clusterResourceGroupName)
  params: {
    clusterName: clusterName
    kustoDatabaseName: kustoDatabaseName
    watcherResourceId: watcher.id
    watcherIdentity: watcher.identity
  }
  dependsOn: [
    newDataStore
  ]
}

// Add SQL targets to the watcher. Set target properties conditionally based on target type and authentication type.

resource sqlDbAadTargets 'Microsoft.DatabaseWatcher/watchers/targets@2023-09-01-preview' = [
  for i in range(0, length(range(0, targetCount))): if ((targetProperties[i].targetType == 'SqlDb') && (targetProperties[i].targetAuthenticationType == 'Aad')) {
    parent: watcher
    name: guid(resourceGroup().id, watcherName, string(i))
    properties: {
      targetType: targetProperties[i].targetType
      sqlDbResourceId: resourceId(
        targetProperties[i].targetLogicalServerSubscriptionId,
        targetProperties[i].targetLogicalServerResourceGroupName,
        'Microsoft.Sql/servers/databases',
        targetProperties[i].targetLogicalServerName,
        targetProperties[i].targetDatabaseName
      )
      connectionServerName: concat(
        targetProperties[i].targetLogicalServerName,
        targetProperties[i].targetServerDnsSuffix
      )
      readIntent: targetProperties[i].readIntent
      targetAuthenticationType: targetProperties[i].targetAuthenticationType
    }
  }
]

resource sqlDbSqlTargets 'Microsoft.DatabaseWatcher/watchers/targets@2023-09-01-preview' = [
  for i in range(0, length(range(0, targetCount))): if ((targetProperties[i].targetType == 'SqlDb') && (targetProperties[i].targetAuthenticationType == 'Sql')) {
    parent: watcher
    name: guid(resourceGroup().id, watcherName, string(i))
    properties: {
      targetType: targetProperties[i].targetType
      sqlDbResourceId: resourceId(
        targetProperties[i].targetLogicalServerSubscriptionId,
        targetProperties[i].targetLogicalServerResourceGroupName,
        'Microsoft.Sql/servers/databases',
        targetProperties[i].targetLogicalServerName,
        targetProperties[i].targetDatabaseName
      )
      connectionServerName: concat(
        targetProperties[i].targetLogicalServerName,
        targetProperties[i].targetServerDnsSuffix
      )
      readIntent: targetProperties[i].readIntent
      targetAuthenticationType: targetProperties[i].targetAuthenticationType
      targetVault: {
        akvResourceId: resourceId(
          targetProperties[i].targetVaultSubscriptionId,
          targetProperties[i].targetVaultResourceGroup,
          'Microsoft.KeyVault/vaults',
          targetProperties[i].targetVaultName
        )
        akvTargetUser: targetProperties[i].akvTargetUser
        akvTargetPassword: targetProperties[i].akvTargetPassword
      }
    }
  }
]

resource sqlEpAadTargets 'Microsoft.DatabaseWatcher/watchers/targets@2023-09-01-preview' = [
  for i in range(0, length(range(0, targetCount))): if ((targetProperties[i].targetType == 'SqlEp') && (targetProperties[i].targetAuthenticationType == 'Aad')) {
    parent: watcher
    name: guid(resourceGroup().id, watcherName, string(i))
    properties: {
      targetType: targetProperties[i].targetType
      sqlEpResourceId: resourceId(
        targetProperties[i].targetLogicalServerSubscriptionId,
        targetProperties[i].targetLogicalServerResourceGroupName,
        'Microsoft.Sql/servers/elasticPools',
        targetProperties[i].targetLogicalServerName,
        targetProperties[i].targetElasticPoolName
      )
      anchorDatabaseResourceId: resourceId(
        targetProperties[i].targetLogicalServerSubscriptionId,
        targetProperties[i].targetLogicalServerResourceGroupName,
        'Microsoft.Sql/servers/databases',
        targetProperties[i].targetLogicalServerName,
        targetProperties[i].targetAnchorDatabaseName
      )
      connectionServerName: concat(
        targetProperties[i].targetLogicalServerName,
        targetProperties[i].targetServerDnsSuffix
      )
      readIntent: targetProperties[i].readIntent
      targetAuthenticationType: targetProperties[i].targetAuthenticationType
    }
  }
]

resource sqlEpSqlTargets 'Microsoft.DatabaseWatcher/watchers/targets@2023-09-01-preview' = [
  for i in range(0, length(range(0, targetCount))): if ((targetProperties[i].targetType == 'SqlEp') && (targetProperties[i].targetAuthenticationType == 'Sql')) {
    parent: watcher
    name: guid(resourceGroup().id, watcherName, string(i))
    properties: {
      targetType: targetProperties[i].targetType
      sqlEpResourceId: resourceId(
        targetProperties[i].targetLogicalServerSubscriptionId,
        targetProperties[i].targetLogicalServerResourceGroupName,
        'Microsoft.Sql/servers/elasticPools',
        targetProperties[i].targetLogicalServerName,
        targetProperties[i].targetElasticPoolName
      )
      anchorDatabaseResourceId: resourceId(
        targetProperties[i].targetLogicalServerSubscriptionId,
        targetProperties[i].targetLogicalServerResourceGroupName,
        'Microsoft.Sql/servers/databases',
        targetProperties[i].targetLogicalServerName,
        targetProperties[i].targetAnchorDatabaseName
      )
      connectionServerName: concat(
        targetProperties[i].targetLogicalServerName,
        targetProperties[i].targetServerDnsSuffix
      )
      readIntent: targetProperties[i].readIntent
      targetAuthenticationType: targetProperties[i].targetAuthenticationType
      targetVault: {
        akvResourceId: resourceId(
          targetProperties[i].targetVaultSubscriptionId,
          targetProperties[i].targetVaultResourceGroup,
          'Microsoft.KeyVault/vaults',
          targetProperties[i].targetVaultName
        )
        akvTargetUser: targetProperties[i].akvTargetUser
        akvTargetPassword: targetProperties[i].akvTargetPassword
      }
    }
  }
]

resource sqlMiAadTargets 'Microsoft.DatabaseWatcher/watchers/targets@2023-09-01-preview' = [
  for i in range(0, length(range(0, targetCount))): if ((targetProperties[i].targetType == 'SqlMi') && (targetProperties[i].targetAuthenticationType == 'Aad')) {
    parent: watcher
    name: guid(resourceGroup().id, watcherName, string(i))
    properties: {
      targetType: targetProperties[i].targetType
      sqlMiResourceId: resourceId(
        targetProperties[i].targetManagedInstanceSubscriptionId,
        targetProperties[i].targetManagedInstanceResourceGroupName,
        'Microsoft.Sql/managedInstances',
        targetProperties[i].targetManagedInstanceName
      )
      connectionServerName: '${targetProperties[i].targetManagedInstanceName}.${targetProperties[i].targetManagedInstanceDnsZone}${targetProperties[i].targetManagedInstanceDnsSuffix}'
      connectionTcpPort: targetProperties[i].connectionTcpPort
      readIntent: targetProperties[i].readIntent
      targetAuthenticationType: targetProperties[i].targetAuthenticationType
    }
  }
]

resource sqlMiSqlTargets 'Microsoft.DatabaseWatcher/watchers/targets@2023-09-01-preview' = [
  for i in range(0, length(range(0, targetCount))): if ((targetProperties[i].targetType == 'SqlMi') && (targetProperties[i].targetAuthenticationType == 'Sql')) {
    parent: watcher
    name: guid(resourceGroup().id, watcherName, string(i))
    properties: {
      targetType: targetProperties[i].targetType
      sqlMiResourceId: resourceId(
        targetProperties[i].targetManagedInstanceSubscriptionId,
        targetProperties[i].targetManagedInstanceResourceGroupName,
        'Microsoft.Sql/managedInstances',
        targetProperties[i].targetManagedInstanceName
      )
      connectionServerName: '${targetProperties[i].targetManagedInstanceName}.${targetProperties[i].targetManagedInstanceDnsZone}${targetProperties[i].targetManagedInstanceDnsSuffix}'
      connectionTcpPort: targetProperties[i].connectionTcpPort
      readIntent: targetProperties[i].readIntent
      targetAuthenticationType: targetProperties[i].targetAuthenticationType
      targetVault: {
        akvResourceId: resourceId(
          targetProperties[i].targetVaultSubscriptionId,
          targetProperties[i].targetVaultResourceGroup,
          'Microsoft.KeyVault/vaults',
          targetProperties[i].targetVaultName
        )
        akvTargetUser: targetProperties[i].akvTargetUser
        akvTargetPassword: targetProperties[i].akvTargetPassword
      }
    }
  }
]

// Add managed private endpoints to the watcher. Set private link properties based on the type of Azure resource targeted by the endpoint.
// Private endpoints created here are pending and not usable until approved by an authorized principal.

resource sqlDbPrivateLinks 'Microsoft.DatabaseWatcher/watchers/sharedPrivateLinkResources@2023-09-01-preview' = [
  for i in range(0, length(range(0, privateLinkCount))): if (privateLinkProperties[i].groupId == 'sqlServer') {
    parent: watcher
    name: privateLinkProperties[i].privateLinkName
    properties: {
      privateLinkResourceId: resourceId(
        privateLinkProperties[i].logicalServerSubscriptionId,
        privateLinkProperties[i].logicalServerResourceGroupName,
        'Microsoft.Sql/servers',
        privateLinkProperties[i].logicalServerName
      )
      groupId: privateLinkProperties[i].groupId
      requestMessage: privateLinkProperties[i].requestMessage
      dnsZone: privateLinkProperties[i].dnsZone
    }
  }
]

resource sqlMiPrivateLinks 'Microsoft.DatabaseWatcher/watchers/sharedPrivateLinkResources@2023-09-01-preview' = [
  for i in range(0, length(range(0, privateLinkCount))): if (privateLinkProperties[i].groupId == 'managedInstance') {
    parent: watcher
    name: privateLinkProperties[i].privateLinkName
    properties: {
      privateLinkResourceId: resourceId(
        privateLinkProperties[i].managedInstanceSubscriptionId,
        privateLinkProperties[i].managedInstanceResourceGroupName,
        'Microsoft.Sql/managedInstances',
        privateLinkProperties[i].managedInstanceName
      )
      groupId: privateLinkProperties[i].groupId
      requestMessage: privateLinkProperties[i].requestMessage
      dnsZone: privateLinkProperties[i].dnsZone
    }
  }
]

resource adxPrivateLinks 'Microsoft.DatabaseWatcher/watchers/sharedPrivateLinkResources@2023-09-01-preview' = [
  for i in range(0, length(range(0, privateLinkCount))): if (privateLinkProperties[i].groupId == 'cluster') {
    parent: watcher
    name: privateLinkProperties[i].privateLinkName
    properties: {
      privateLinkResourceId: resourceId(
        privateLinkProperties[i].adxClusterSubscriptionId,
        privateLinkProperties[i].adxClusterResourceGroupName,
        'Microsoft.Kusto/clusters',
        privateLinkProperties[i].adxClusterName
      )
      groupId: privateLinkProperties[i].groupId
      requestMessage: privateLinkProperties[i].requestMessage
      dnsZone: privateLinkProperties[i].dnsZone
    }
  }
]

resource akvPrivateLinks 'Microsoft.DatabaseWatcher/watchers/sharedPrivateLinkResources@2023-09-01-preview' = [
  for i in range(0, length(range(0, privateLinkCount))): if (privateLinkProperties[i].groupId == 'vault') {
    parent: watcher
    name: privateLinkProperties[i].privateLinkName
    properties: {
      privateLinkResourceId: resourceId(
        privateLinkProperties[i].vaultSubscriptionId,
        privateLinkProperties[i].vaultResourceGroupName,
        'Microsoft.KeyVault/vaults',
        privateLinkProperties[i].vaultName
      )
      groupId: privateLinkProperties[i].groupId
      requestMessage: privateLinkProperties[i].requestMessage
      dnsZone: privateLinkProperties[i].dnsZone
    }
  }
]
