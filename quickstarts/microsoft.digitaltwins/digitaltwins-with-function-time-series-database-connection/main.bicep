@description('Name given to Digital Twins resource')
param digitalTwinsName string = 'digitalTwins-${uniqueString(resourceGroup().id)}'

@description('Name given to Event Hubs namespace resource')
param eventHubsNamespaceName string = 'eventHubsNamespace-${uniqueString(resourceGroup().id)}'

@description('Name given to event hub resource')
param eventHubName string = 'eventHub-${uniqueString(resourceGroup().id)}'

@description('Name given to Azure Data Explorer cluster resource')
param adxClusterName string = 'adx${uniqueString(resourceGroup().id)}'

@description('Name given to twin lifecycle event table')
param adxTwinLifecycleEventsTableName string = 'AdtTwinLifecycleEvents'

@description('Name given to relationship lifecycle event table')
param adxRelationshipLifecycleEventsTableName string = 'AdtRelationshipLifecycleEvents'

@description('Name given to database')
param databaseName string = 'database-${uniqueString(resourceGroup().id)}'

@description('Name given to table in database')
param databaseTableName string = 'databaseTable-${uniqueString(resourceGroup().id)}'

@allowed([
  'Basic'
  'Premium'
  'Standard'
])
@description('Event Hubs namespace SKU option')
param eventHubsNamespacePlan string = 'Basic'

@allowed([
  'Basic'
  'Standard'
])
@description('Event Hubs namespace SKU billing tier')
param eventHubsNamespaceTier string = 'Basic'

@description('Event Hubs throughput units')
param eventHubsNamespaceCapacity int = 1

@allowed([
  'Dev(No SLA)_Standard_D11_v2'
  'Standard_D11_v2'
  'Standard_D12_v2'
  'Standard_D13_v2'
  'Standard_D14_v2'
  'Standard_DS13_v2+1TB_PS'
  'Standard_DS13_v2+2TB_PS'
  'Standard_DS14_v2+3TB_PS'
  'Standard_DS14_v2+4TB_PS'
  'Standard_L16s'
  'Standard_L4s'
  'Standard_L8s'
])
@description('Azure Data Explorer cluster SKU option')
param clusterPlan string = 'Dev(No SLA)_Standard_D11_v2'

@description('Azure Data Explorer cluster capacity')
param clusterCapacity int = 1

@description('Azure Data Explorer cluster tier')
param clusterTier string = 'Basic'

@description('Number of days to retain data in event hub')
param retentionInDays int = 1

@description('Number of partitions to create in event hub')
param partitionCount int = 2

@description('The time to keep database data in cache')
param hotCachePeriod string = 'P30D'

@description('The time data is kept in database')
param softDeletePeriod string = 'P1Y'

@description('The id that will be given data owner permission for the Digital Twins resource')
param principalId string

@description('The type of the given principal id')
param principalType string

@allowed([
  'westcentralus'
  'westus2'
  'westus3'
  'northeurope'
  'australiaeast'
  'westeurope'
  'eastus'
  'southcentralus'
  'southeastasia'
  'uksouth'
  'eastus2'
])
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
    digitalTwinsIdentityPrincipalId: digitalTwins.outputs.digitalTwinsIdentityPrincipalId
    digitalTwinsIdentityTenantId: digitalTwins.outputs.digitalTwinsIdentityTenantId
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
    adxTwinLifecycleEventsTableName: adxTwinLifecycleEventsTableName
    adxRelationshipLifecycleEventsTableName: adxRelationshipLifecycleEventsTableName
    databaseName: databaseName
    databaseTableName: databaseTableName
  }
  dependsOn: [
    roleAssignment
  ]
}
