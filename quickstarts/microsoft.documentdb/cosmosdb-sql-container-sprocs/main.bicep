@description('Cosmos DB account name')
param accountName string = 'cosmos-${uniqueString(resourceGroup().id)}'

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

@description('Max lag time (seconds). Required for BoundedStaleness. Valid ranges, Single Region: 5 to 84600. Multi Region: 300 to 86400.')
@minValue(5)
@maxValue(86400)
param maxIntervalInSeconds int = 300

@description('Enable automatic failover for regions')
param automaticFailover bool = true

@description('The name for the Core (SQL) database')
param databaseName string

@description('The name for the Core (SQL) API container')
param containerName string = 'container1'

@description('The throughput for the container')
@minValue(400)
@maxValue(1000000)
param throughput int = 400

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
    consistencyPolicy: consistencyPolicy[defaultConsistencyLevel]
    locations: locations
    databaseAccountOfferType: 'Standard'
    enableAutomaticFailover: automaticFailover
  }
}

resource accountName_databaseName 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2021-04-15' = {
  parent: accountName_resource
  name: databaseName
  properties: {
    resource: {
      id: databaseName
    }
  }
}

resource accountName_databaseName_containerName 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2021-04-15' = {
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
      }
    }
    options: {
      throughput: throughput
    }
  }
}

resource accountName_databaseName_containerName_myStoredProcedure 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/storedProcedures@2021-04-15' = {
  parent: accountName_databaseName_containerName
  name: 'myStoredProcedure'
  properties: {
    resource: {
      id: 'myStoredProcedure'
      body: 'function () { var context = getContext(); var response = context.getResponse(); response.setBody(\'Hello, World\'); }'
    }
  }
}

resource accountName_databaseName_containerName_myPreTrigger 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/triggers@2021-04-15' = {
  parent: accountName_databaseName_containerName
  name: 'myPreTrigger'
  properties: {
    resource: {
      id: 'myPreTrigger'
      triggerType: 'Pre'
      triggerOperation: 'Create'
      body: 'function validateToDoItemTimestamp(){var context=getContext();var request=context.getRequest();var itemToCreate=request.getBody();if(!(\'timestamp\'in itemToCreate)){var ts=new Date();itemToCreate[\'timestamp\']=ts.getTime();}request.setBody(itemToCreate);}'
    }
  }
}

resource accountName_databaseName_containerName_myUserDefinedFunction 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/userDefinedFunctions@2021-04-15' = {
  parent: accountName_databaseName_containerName
  name: 'myUserDefinedFunction'
  properties: {
    resource: {
      id: 'myUserDefinedFunction'
      body: 'function tax(income){if(income==undefined)throw\'no input\';if(income<1000)return income*0.1;else if(income<10000)return income*0.2;else return income*0.4;}'
    }
  }
}
