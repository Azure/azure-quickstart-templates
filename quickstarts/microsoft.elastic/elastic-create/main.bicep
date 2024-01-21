@description('Specify name for the Elastic resource')
param resourceName string

@description('Provide your work email address (same as that setup as subscription owner on Azure)')
param emailAddress string

@description('Specify the region for the resource')
@allowed([
  'westus2'
  'francecentral'
  'centralus'
  'australiaeast'
  'brazilsouth'
  'canadacentral'
  'centralindia'
  'eastus'
  'eastus2'
  'japaneast'
  'northeurope'
  'southafricanorth'
  'southcentralus'
  'southeastasia'
  'uksouth'
  'westeurope'
])
param location string = 'westus2'

var monitorTags = {}
var tagRulesProperties = {
  logRules: {
    sendSubscriptionLogs: false
    sendActivityLogs: false
    filteringTags: []
  }
}

resource monitor 'Microsoft.Elastic/monitors@2023-11-01-preview' = {
  name: resourceName
  location: location
  sku: {
    name: 'ess-consumption-2024_Monthly@TIDgmz7xq9ge3py'
  }
  properties: {
    userInfo: {
      emailAddress: emailAddress
    }
  }
  tags: monitorTags
}

resource tagRule 'Microsoft.Elastic/monitors/tagRules@2023-11-01-preview' = {
  parent: monitor
  name: 'default'
  properties: tagRulesProperties
}
