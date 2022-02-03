@description('Cosmos DB account name, max length 44 characters')
param accountName string = 'cassandra-${uniqueString(resourceGroup().id)}'

@description('Location for the Cosmos DB account.')
param location string = resourceGroup().location

@description('The primary replica region for the Cosmos DB account.')
param primaryRegion string

@description('The secondary replica region for the Cosmos DB account.')
param secondaryRegion string

@allowed([
  'Eventual'
  'ConsistentPrefix'
  'Session'
  'BoundedStaleness'
  'Strong'
])
@description('The default consistency level of the Cosmos DB account.')
param defaultConsistencyLevel string = 'Session'

@minValue(10)
@maxValue(1000000)
@description('Max stale requests. Required for BoundedStaleness. Valid ranges, Single Region: 10 to 1000000. Multi Region: 100000 to 1000000.')
param maxStalenessPrefix int = 100000

@minValue(5)
@maxValue(86400)
@description('Max lag time (seconds). Required for BoundedStaleness. Valid ranges, Single Region: 5 to 84600. Multi Region: 300 to 86400.')
param maxIntervalInSeconds int = 300

@allowed([
  true
  false
])
@description('Enable automatic failover for regions')
param automaticFailover bool = true

@description('The name for the Cassandra Keyspace')
param keyspaceName string

@description('The name for the Cassandra table')
param tableName string

@minValue(4000)
@maxValue(1000000)
@description('Maximum autoscale throughput for the Cassandra table')
param autoscaleMaxThroughput int = 4000

var accountName_var = toLower(accountName)
var consistencyPolicy = {
  Eventual: {
    defaultConsistencyLevel: 'Eventual'
  }
  ConsistentPrefix: {
    defaultConsistencyLevel: 'ConsistentPrefix'
  }
  Session: {
    defaultConsistencyLevel: 'Session'
  }
  BoundedStaleness: {
    defaultConsistencyLevel: 'BoundedStaleness'
    maxStalenessPrefix: maxStalenessPrefix
    maxIntervalInSeconds: maxIntervalInSeconds
  }
  Strong: {
    defaultConsistencyLevel: 'Strong'
  }
}
var locations = [
  {
    locationName: primaryRegion
    failoverPriority: 0
    isZoneRedundant: false
  }
  {
    locationName: secondaryRegion
    failoverPriority: 1
    isZoneRedundant: false
  }
]

resource accountName_resource 'Microsoft.DocumentDB/databaseAccounts@2021-04-15' = {
  name: accountName_var
  location: location
  kind: 'GlobalDocumentDB'
  properties: {
    capabilities: [
      {
        name: 'EnableCassandra'
      }
    ]
    consistencyPolicy: consistencyPolicy[defaultConsistencyLevel]
    locations: locations
    databaseAccountOfferType: 'Standard'
    enableAutomaticFailover: automaticFailover
  }
}

resource accountName_keyspaceName 'Microsoft.DocumentDB/databaseAccounts/cassandraKeyspaces@2021-04-15' = {
  name: '${accountName_resource.name}/${keyspaceName}'
  properties: {
    resource: {
      id: keyspaceName
    }
  }
}

resource accountName_keyspaceName_tableName 'Microsoft.DocumentDb/databaseAccounts/cassandraKeyspaces/tables@2021-04-15' = {
  name: '${accountName_keyspaceName.name}/${tableName}'
  properties: {
    resource: {
      id: tableName
      schema: {
        columns: [
          {
            name: 'loadid'
            type: 'uuid'
          }
          {
            name: 'machine'
            type: 'uuid'
          }
          {
            name: 'cpu'
            type: 'int'
          }
          {
            name: 'mtime'
            type: 'int'
          }
          {
            name: 'load'
            type: 'float'
          }
        ]
        partitionKeys: [
          {
            name: 'machine'
          }
          {
            name: 'cpu'
          }
          {
            name: 'mtime'
          }
        ]
        clusterKeys: [
          {
            name: 'loadid'
            orderBy: 'asc'
          }
        ]
      }
    }
    options: {
      autoscaleSettings: {
        maxThroughput: autoscaleMaxThroughput
      }
    }
  }
}
