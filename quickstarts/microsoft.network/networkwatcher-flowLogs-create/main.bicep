@description('Region where you resources are located')
param location string = resourceGroup().location

@description('Name of the Network Watcher attached to your subscription. Format: NetworkWatcher_<region_name>')
param NetworkWatcherName string = 'NetworkWatcher_${location}'

@description('Chosen name of your Flow log resource')
param FlowLogName string = 'FlowLog1'

@description('Resource ID of the target NSG')
param existingNSG string

@description('Retention period in days. Default is zero which stands for permanent retention. Can be any Integer from 0 to 365')
@minValue(0)
@maxValue(365)
param RetentionDays int = 0

@description('FlowLogs Version. Correct values are 1 or 2 (default)')
@allowed([
  1
  2
])
param FlowLogsversion int = 2

@description('Storage Account type')
@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Standard_ZRS'
])
param storageAccountType string = 'Standard_LRS'

var storageAccountName = 'flowlogs${uniqueString(resourceGroup().id)}'

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-08-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: storageAccountType
  }
  kind: 'StorageV2'
  properties: {}
}

module deployFlowLogs './nested_deployFlowLogs.bicep' = {
  name: 'deployFlowLogs'
  scope: resourceGroup('NetworkWatcherRG')
  params: {
    location: location
    NetworkWatcherName: NetworkWatcherName
    FlowLogName: FlowLogName
    existingNSG: existingNSG
    RetentionDays: RetentionDays
    FlowLogsversion: FlowLogsversion
    storageAccountResourceId: storageAccount.id
  }
}
