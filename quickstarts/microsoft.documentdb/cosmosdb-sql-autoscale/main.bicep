@description('Cosmos DB account name, max length 44 characters, lowercase')
param accountName string = 'sql-${uniqueString(resourceGroup().id)}'

@description('Location for the Cosmos DB account.')
param location string = resourceGroup().location

@description('The primary replica region for the Cosmos DB account.')
param primaryRegion string

@description('The secondary replica region for the Cosmos DB account.')
param secondaryRegion string

@description('The default consistency level of the Cosmos DB account.')
@allowed([
  'Eventual'
  'ConsistentPrefix'
  'Session'
  'BoundedStaleness'
  'Strong'
])
param defaultConsistencyLevel string = 'Session'

@description('Max stale requests. Required for BoundedStaleness. Valid ranges, Single Region: 10 to 1000000. Multi Region: 100000 to 1000000.')
@minValue(10)
@maxValue(2147483647)
param maxStalenessPrefix int = 100000

@description('Max lag time (minutes). Required for BoundedStaleness. Valid ranges, Single Region: 5 to 84600. Multi Region: 300 to 86400.')
@minValue(5)
@maxValue(86400)
param maxIntervalInSeconds int = 300

@description('Enable automatic failover for regions')
param automaticFailover bool = true

@description('The name for the database')
param databaseName string

@description('The name for the container')
param containerName string

@description('Maximum throughput for the container')
@minValue(4000)
@maxValue(1000000)
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

resource accountName_resource 'Microsoft.DocumentDB/databaseAccounts@2021-01-15' = {
  name: accountName_var
  kind: 'GlobalDocumentDB'
  location: location
  properties: {
    consistencyPolicy: consistencyPolicy[defaultConsistencyLevel]
    locations: locations
    databaseAccountOfferType: 'Standard'
    enableAutomaticFailover: automaticFailover
  }
}

resource accountName_databaseName 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2021-01-15' = {
  parent: accountName_resource
  name: databaseName
  properties: {
    resource: {
      id: databaseName
    }
  }
}

resource accountName_databaseName_containerName 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2021-01-15' = {
  parent: accountName_databaseName
  name: containerName
  properties: {
    resource: {
      id: containerName
      partitionKey: {
        paths: [
          '/myPartitionKey'
        ]
        kind: 'Hash'
      }
      indexingPolicy: {
        indexingMode: 'consistent'
        includedPaths: [
          {
            path: '/*'
          }
        ]
        excludedPaths: [
          {
            path: '/myPathToNotIndex/*'
          }
        ]
        compositeIndexes: [
          [
            {
              path: '/name'
              order: 'ascending'
            }
            {
              path: '/age'
              order: 'descending'
            }
          ]
        ]
        spatialIndexes: [
          {
            path: '/path/to/geojson/property/?'
            types: [
              'Point'
              'Polygon'
              'MultiPolygon'
              'LineString'
            ]
          }
        ]
      }
      defaultTtl: 86400
      uniqueKeyPolicy: {
        uniqueKeys: [
          {
            paths: [
              '/phoneNumber'
            ]
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
