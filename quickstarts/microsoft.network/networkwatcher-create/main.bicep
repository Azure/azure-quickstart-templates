@description('Network Watcher name')
param networkWatcherName string

@description('Location of Network Watcher')
param location string = resourceGroup().location

@description('Enable delete lock')
param enableDeleteLock bool = false

var lockName = '${networkWatcher.name}-lck'

resource networkWatcher 'Microsoft.Network/networkWatchers@2021-02-01' = {
  name: networkWatcherName
  location: location
  properties: {}
}

resource lock 'Microsoft.Authorization/locks@2016-09-01' = if (enableDeleteLock) {
  scope: networkWatcher
  name: lockName
  properties: {
    level: 'CanNotDelete'
  }
}

output name string = networkWatcher.name
output id string = networkWatcher.id
