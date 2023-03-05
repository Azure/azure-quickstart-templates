@description('Location for all resources')
param location string = resourceGroup().location

@description('Name of the cluster')
param clusterName string = 'kusto${uniqueString(resourceGroup().id)}'

@description('Name of the sku')
param skuName string = 'Standard_D12_v2'

@description('# of nodes')
@minValue(2)
@maxValue(1000)
param skuCapacity int = 2

@description('Name of the database')
param kustoDatabaseName string = 'kustodb'

@description('Name of Cosmos DB account')
param cosmosDbAccountName string = 'cosmosdb${uniqueString(resourceGroup().id)}'

@description('Name of Cosmos DB database')
param cosmosDbDatabaseName string = 'mydb'

@description('Name of Cosmos DB container')
param cosmosDbContainerName string = 'mycontainer'

//  Id of the Cosmos DB data reader role
var cosmosDataReader = '00000000-0000-0000-0000-000000000001'

//  Cosmos DB account, DB, container and role assignment
resource cosmosDbAccount 'Microsoft.DocumentDB/databaseAccounts@2022-08-15' = {
  name: cosmosDbAccountName
  location: location
  kind: 'GlobalDocumentDB'
  properties: {
    locations: [
      {
        locationName: location
        failoverPriority: 0
      }
    ]
    databaseAccountOfferType: 'Standard'
  }

  resource cosmosDbDatabase 'sqlDatabases' = {
    name: cosmosDbDatabaseName
    properties: {
      resource: {
        id: cosmosDbDatabaseName
      }
    }

    resource cosmosDbContainer 'containers' = {
      name: cosmosDbContainerName
      properties: {
        options:{
          throughput: 400
        }
        resource: {
          id: cosmosDbContainerName
          partitionKey: {
            kind: 'Hash'
            paths: [
              '/part'
            ]
          }
        }
      }
    }
  }

  //  We need to authorize the cluster to read Cosmos DB's change feed by assigning the role
  resource clusterCosmosDbAuthorization 'sqlRoleAssignments' = {
    name: guid(cluster.id, cosmosDbAccountName)

    properties: {
      principalId: cluster.identity.principalId
      roleDefinitionId: resourceId('Microsoft.DocumentDB/databaseAccounts/sqlRoleDefinitions', cosmosDbAccountName, cosmosDataReader)
      scope: resourceId('Microsoft.DocumentDB/databaseAccounts', cosmosDbAccountName)
    }
  }
}

//  Kusto Cluster, DB, script and data connection
resource cluster 'Microsoft.Kusto/clusters@2022-11-11' = {
  name: clusterName
  location: location
  sku: {
    name: skuName
    tier: 'Standard'
    capacity: skuCapacity
  }
  identity: {
    type: 'SystemAssigned'
  }

  resource kustoDb 'databases' = {
    name: kustoDatabaseName
    location: location
    kind: 'ReadWrite'

    resource kustoScript 'scripts' = {
      name: 'db-script'
      properties: {
        scriptContent: loadTextContent('script.kql')
        continueOnErrors: false
      }
    }

    resource eventConnection 'dataConnections' = {
      name: 'eventConnection'
      location: location
      //  Here we need to explicitely declare dependencies
      //  Since we do not use those resources in the event connection
      //  but we do need them to be deployed first
      dependsOn: [
        //  We need the table to be present in the database
        kustoScript
        //  We need the cluster to be receiver on the Event Hub
        cosmosDbAccount::clusterCosmosDbAuthorization
      ]
      kind: 'CosmosDb'
      properties: {
        tableName: 'TestTable'
        mappingRuleName: 'DocumentMapping'
        managedIdentityResourceId: cluster.id
        cosmosDbAccountResourceId: cosmosDbAccount.id
        cosmosDbDatabase: cosmosDbDatabaseName
        cosmosDbContainer: cosmosDbContainerName
      }
    }
  }
}
