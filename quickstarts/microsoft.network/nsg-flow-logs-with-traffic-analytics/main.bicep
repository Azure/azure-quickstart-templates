@description('Flow Log name')
param flowlogName string = 'flowlog'

@description('Flow Log location')
param location string = resourceGroup().location

@description('Network Watcher name')
param networkWatcherName string = 'NetworkWatcher_${location}'

@description('Network Watcher Resource Group')
param networkWatcherResourceGroup string = 'NetworkWatcherRG'

@description('Network Security Group resource id')
param existingNsgId string

@description('Storage account resource id')
param existingFlowLogStorageAccountId string

@description('Log analytics workspace resource id')
param logAnalyticsWorkspaceId string = ''

module flowLogs './nested/nested.flowlogs.bicep' = {
  name: 'deployFlowLogs'
  scope: resourceGroup(networkWatcherResourceGroup)
  params: {
    flowlogName: flowlogName
    location: location
    networkWatcherName: networkWatcherName
    existingNsgId: existingNsgId
    existingFlowLogStorageAccountId: existingFlowLogStorageAccountId
    logAnalyticsWorkspaceId: logAnalyticsWorkspaceId
  }
}
