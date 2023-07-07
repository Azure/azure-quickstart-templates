@description('Name of Network Tap Rule Name')
param networkTapRuleName string

@description('Azure Region for deployment of the Ip Prefix and associated resources')
param location string = resourceGroup().location

@description('Switch configuration description')
param annotation string = ''

@description('Input method to configure Network Tap Rule')
@allowed([
  'File'
  'Inline'
])
param configurationType string

@description('Polling interval in seconds')
@allowed([
  120
  30
  60
  90
])
param pollingIntervalInSeconds int = 30

@description('Network Tap Rules file URL')
param tapRulesUrl string = ''

@description('List of match configurations')
param matchConfigurations array = []

@description('List of dynamic match configurations')
param dynamicMatchConfigurations array = []

@description('Create Network Tap Rule Resource')
resource tapRule 'Microsoft.ManagedNetworkFabric/networkTapRules@2023-06-15' = {
  name: networkTapRuleName
  location: location
  properties: {
    annotation: !empty(annotation) ? annotation : null
    configurationType: configurationType
    pollingIntervalInSeconds: pollingIntervalInSeconds
    tapRulesUrl: !empty(tapRulesUrl) ? tapRulesUrl : null
    matchConfigurations: [for i in (!empty(matchConfigurations) ? range(0, length(matchConfigurations)) : []): {
      matchConfigurationName: matchConfigurations[i].matchConfigurationName
      sequenceNumber: matchConfigurations[i].sequenceNumber
      ipAddressType: matchConfigurations[i].ipAddressType
      matchConditions: matchConfigurations[i].matchConditions
      actions: matchConfigurations[i].actions
    }]
    dynamicMatchConfigurations: [for i in (!empty(dynamicMatchConfigurations) ? range(0, length(dynamicMatchConfigurations)) : []): {
      ipGroups: dynamicMatchConfigurations[i].ipGroups
      vlanGroups: dynamicMatchConfigurations[i].vlanGroups
      portGroups: dynamicMatchConfigurations[i].portGroups
    }]
  }
}

output resourceID string = tapRule.id
