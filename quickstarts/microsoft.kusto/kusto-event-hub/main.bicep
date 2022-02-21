@description('Location for all resources')
param location string = resourceGroup().location
@description('Name of the cluster')
param clusterName string = 'kusto${uniqueString(resourceGroup().id)}'
@description('Name of the database')
param databaseName string = 'kustodb'
@description('Name of Event Hub\'s namespace')
param eventHubNamespaceName string = 'eventHub${uniqueString(resourceGroup().id)}'
@description('Name of Event Hub')
param eventHubName string = 'kustoHub'

resource eventHubNamespace 'Microsoft.EventHub/namespaces@2021-11-01' = {
  name: eventHubNamespaceName
  location: location
  sku: {
    capacity: 1
    name: 'Standard'
    tier: 'Standard'
  }
  properties: {}

  resource hubNamespace 'eventhubs' = {
    name: eventHubName
    properties: {
      messageRetentionInDays: 2
      partitionCount: 2
    }

    resource kustoConsumerGroup 'consumergroups' = {
      name: 'kustoConsumerGroup'
      properties: {}
    }
  }
}

resource cluster 'Microsoft.Kusto/clusters@2022-02-01' = {
  name: clusterName
  location: location
  sku: {
    'name': 'Standard_D12_v2'
    'tier': 'Standard'
    'capacity': 2
  }
  identity: {
    type: 'SystemAssigned'
  }

  resource perfTestDbs 'databases' = {
    name: databaseName
    kind: 'ReadWrite'

    resource perfTestDbs 'scripts' = {
      name: 'db-script'
      properties: {
        scriptContent: loadTextContent('script.kql')
        continueOnErrors: false
      }
    }

    resource eventConnection 'dataConnections' = {
      name: 'eventConnection'
      dependsOn: [
        perfTestDbs
      ]
      kind: 'EventHub'
      properties: {
        compression: 'None'
        consumerGroup: kustoConsumerGroup.name
        dataFormat: 'MULTIJSON'
        eventHubResourceId: eventHub.Id
        eventSystemProperties: [
          // 'string'
        ]
        managedIdentityResourceId: 'system'
        mappingRuleName: 'DirectJson'
        tableName: 'RawEvents'
      }
    }
  }
}
