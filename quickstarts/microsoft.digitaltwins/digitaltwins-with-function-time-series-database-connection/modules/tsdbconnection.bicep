@description('Existing Digital Twin resource name')
param digitalTwinsName string

@description('Existing Event Hubs namespace resource name')
param eventHubsNamespaceName string

@description('Existing event hub name')
param eventHubName string

@description('Existing Azure Data Explorer cluster resource name')
param adxClusterName string

@description('Name given to twin lifecycle event table')
param adxTwinLifecycleEventsTableName string

@description('Name given to relationship lifecycle event table')
param adxRelationshipLifecycleEventsTableName string

@description('Existing database name')
param databaseName string

@description('Name given to table in database')
param databaseTableName string

var eventHubEndpoint = 'sb://${eventHubsNamespaceName}.servicebus.windows.net'

// Gets Digital Twins resource
// Gets Azure Data Explorer cluster resource
resource adxCluster 'Microsoft.Kusto/Clusters@2022-11-11' existing = {
  name: adxClusterName
}

// Gets Event Hubs namespace resource
resource eventHubsNamespace 'Microsoft.EventHub/namespaces@2021-11-01' existing = {
  name: eventHubsNamespaceName
}

// Gets database resource
// Creates a time series database connection between the Digital Twin resource and Azure Data Explorer cluster table
resource tsdbConnection 'Microsoft.DigitalTwins/digitalTwinsInstances/timeSeriesDatabaseConnections@2023-01-31' = {
  name: '${digitalTwinsName}/${databaseTableName}'
  properties: {
    connectionType: 'AzureDataExplorer'
    adxEndpointUri: adxCluster.properties.uri
    adxDatabaseName: databaseName
    adxTwinLifecycleEventsTableName: adxTwinLifecycleEventsTableName
    adxRelationshipLifecycleEventsTableName: adxRelationshipLifecycleEventsTableName
    eventHubEndpointUri: eventHubEndpoint
    eventHubEntityPath: eventHubName
    adxResourceId: adxCluster.id
    eventHubNamespaceResourceId: eventHubsNamespace.id
  }
}
