@description('Flow Log name')
param flowlogName string

@description('Network Watcher name')
param networkWatcherName string

@description('Flow Log location')
param location string = resourceGroup().location

@description('Network Security Group resource id')
param nsgId string

@description('Storage account resource id')
param flowLogStorageAccountId string

@description('Log analytics workspace resource id')
param logAnalyticsWorkspaceId string = ''

var flowLogsStorageRetention = 60

resource nsgFlowLog 'Microsoft.Network/networkWatchers/flowLogs@2021-02-01' = {
  name: '${networkWatcherName}/${flowlogName}'
  location: location
  properties: {
    enabled: true
    flowAnalyticsConfiguration: {
      networkWatcherFlowAnalyticsConfiguration: {
        enabled: empty(logAnalyticsWorkspaceId) ? false : true
        trafficAnalyticsInterval: 60
        workspaceResourceId: empty(logAnalyticsWorkspaceId) ? null : logAnalyticsWorkspaceId
      }
    }
    format: {
      type: 'JSON'
      version: 2
    }
    retentionPolicy: {
      days: flowLogsStorageRetention
      enabled: true
    }
    storageId: flowLogStorageAccountId
    targetResourceId: nsgId
  }
}
