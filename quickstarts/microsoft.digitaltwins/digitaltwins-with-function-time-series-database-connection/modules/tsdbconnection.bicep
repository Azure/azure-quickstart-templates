@description('Existing Digital Twin resource name')
param digitalTwinsName string
@description('Existing Event Hubs namespace resource name')
param eventHubsNamespaceName string
@description('Existing event hub name')
param eventHubName string
@description('Existing Azure Data Explorer cluster resource name')
param adxClusterName string
@description('Existing database name')
param databaseName string

@description('Name given to table in database')
param databaseTableName string

@description('Location of to be created resources')
param location string

// Gets Digital Twins resource
resource digitalTwins 'Microsoft.DigitalTwins/digitalTwinsInstances@2022-05-31' existing = {
  name: digitalTwinsName
}

// Gets Azure Data Explorer cluster resource
resource adxCluster 'Microsoft.Kusto/Clusters@2022-02-01' existing = {
  name: adxClusterName
}

// Gets Event Hubs namespace resource
resource eventHubsNamespace 'Microsoft.EventHub/namespaces@2021-11-01' existing = {
  name: eventHubsNamespaceName
}

// Gets database resource
resource database 'Microsoft.Kusto/clusters/databases@2022-02-01' existing = {
  name: '${adxClusterName}/${databaseName}'
}

// Assigns Digital Twins admin assignment to database
resource digitalTwinsToDatabasePrincipalAssignment 'Microsoft.Kusto/clusters/databases/principalAssignments@2022-02-01' = {
  name: '${adxClusterName}/${databaseName}/${guid(digitalTwins.id, resourceGroup().id, 'Admin')}'
  properties: {
    principalId: digitalTwins.identity.principalId
    role: 'Admin'
    tenantId: digitalTwins.identity.tenantId
    principalType: 'App'
  }
}

// Creates a time series database connection between the Digital Twin resource and Azure Data Explorer cluster table
resource tsdbConnection 'Microsoft.DigitalTwins/digitalTwinsInstances/timeSeriesDatabaseConnections@2021-06-30-preview' = {
  name: '${digitalTwinsName}/${databaseTableName}'
  properties: {
    connectionType: 'AzureDataExplorer'
    adxEndpointUri: 'https://${adxClusterName}.${location}.kusto.windows.net'
    adxDatabaseName: databaseName
    eventHubEndpointUri: 'sb://${eventHubsNamespaceName}.servicebus.windows.net'
    eventHubEntityPath: eventHubName
    adxResourceId: adxCluster.id
    eventHubNamespaceResourceId: eventHubsNamespace.id
  }
  dependsOn: [
    digitalTwinsToDatabasePrincipalAssignment
  ]
}
