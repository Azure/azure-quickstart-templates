// New Resources Name
@description('Name given to Digital Twins resource')
param digitalTwinsName string
@description('Name given to Event Hubs namespace resource')
param eventHubsNamespaceName string
@description('Name given to event hub resource')
param eventHubName string
@description('Name given to Azure Data Explorer cluster resource')
param adxClusterName string
@description('Name given to database')
param databaseName string
@description('Name given to table in database')
param databaseTableName string

// Resources Configuration
@allowed([
  'Basic'
  'Premium'
  'Standard'
])
@description('Event Hubs namespace SKU option')
param eventHubsNamespacePlan string
@allowed([
  'Basic'
  'Standard'
])
@description('Event Hubs namespace SKU billing tier')
param eventHubsNamespaceTier string
@description('Event Hubs throughput units')
param eventHubsNamespaceCapacity int
@description('Azure Data Explorer cluster SKU option')
param clusterPlan string
@description('Azure Data Explorer cluster capacity')
param clusterCapacity int
@description('Azure Data Explorer cluster tier')
param clusterTier string
@description('Number of days to retain data in event hub')
param retentionInDays int
@description('Number of partitions to create in event hub')
param partitionCount int
@description('The time to keep database data in cache')
param hotCachePeriod string
@description('The time data is kept in database')
param softDeletePeriod string
@description('The id that will be given data owner permission for the Digital Twins resource')
param principalId string
@description('The type of the given principal id')
param principalType string


@description('Location of to be created resources')
param location string

// Creates Digital Twins resource
module digitalTwins 'modules/digitaltwins.bicep' = {
  name: 'digitalTwins'
  params: {
    digitalTwinsName: digitalTwinsName
    location: location
  }
}

// Creates Event Hubs namespace and associated event hub
module eventHub 'modules/eventhub.bicep' = {
  name: 'eventHub'
  params: {
    eventHubsNamespaceName: eventHubsNamespaceName
    eventHubsNamespaceCapacity: eventHubsNamespaceCapacity
    eventHubsNamespacePlan: eventHubsNamespacePlan
    eventHubsNamespaceTier: eventHubsNamespaceTier
    eventHubName: eventHubName
    retentionInDays: retentionInDays
    partitionCount: partitionCount
    location: location
  }
}

// Creates Azure Data Explorer cluster and database
module dataExplorerCluster 'modules/dataexplorercluster.bicep' = {
  name: 'dataExlorerCluster'
  params: {
    adxClusterName: adxClusterName
    databaseName: databaseName
    clusterPlan: clusterPlan
    clusterTier: clusterTier
    clusterCapacity: clusterCapacity
    hotCachePeriod: hotCachePeriod
    softDeletePeriod: softDeletePeriod
    location: location
  }
}

// Assigns roles to resources
module roleAssignment 'modules/roleassignment.bicep' = {
  name: 'roleAssignment'
  params: {
    principalId: principalId
    principalType: principalType
    digitalTwinsName: digitalTwinsName
    eventHubsNamespaceName: eventHubsNamespaceName
    eventHubName: eventHubName
    adxClusterName: adxClusterName
    databaseName: databaseName
  }
  dependsOn: [
    digitalTwins
    eventHub
    dataExplorerCluster
  ]
}

// Creates time series data history connection
module tsdbConnection 'modules/tsdbconnection.bicep' = {
  name: 'tsdbConnection'
  params: {
    digitalTwinsName: digitalTwinsName
    eventHubsNamespaceName: eventHubsNamespaceName
    eventHubName: eventHubName
    adxClusterName: adxClusterName
    databaseName: databaseName
    databaseTableName: databaseTableName
  }
  dependsOn: [
    roleAssignment
  ]
}
