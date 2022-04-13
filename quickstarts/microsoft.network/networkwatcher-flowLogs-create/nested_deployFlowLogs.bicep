param location string
param NetworkWatcherName string
param FlowLogName string
param existingNSG string
param RetentionDays int
param FlowLogsversion string
param storageAccountResourceId string

resource NetworkWatcherName_FlowLogName 'Microsoft.Network/networkWatchers/flowLogs@2020-06-01' = {
  name: '${NetworkWatcherName}/${FlowLogName}'
  location: location
  properties: {
    targetResourceId: existingNSG
    storageId: storageAccountResourceId
    enabled: true
    retentionPolicy: {
      days: RetentionDays
      enabled: true
    }
    format: {
      type: 'JSON'
      version: FlowLogsversion
    }
  }
}