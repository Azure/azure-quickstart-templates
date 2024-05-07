targetScope = 'subscription'

@description('Specify the name of the resource group in which the datadog resource will be created')
param resourceGroupName string

@description('Specify a name for the Datadog resource')
param monitorName string = 'Datadog-${uniqueString(subscription().id)}'

@description('Specify the region for the monitor resource')
@allowed([
  'westus2'
])
param location string = 'westus2'

var guidValue = guid(deployment().name, 'datadog')
var monitorDeploymentName = 'DatadogMonitor_${substring(guidValue, 0, 8)}'
var roleAssignmentName = guidValue

resource resourceGroup 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: resourceGroupName
  location: location
  properties: {}
}

module monitorDeployment './nested_monitorDeployment.bicep' = {
  name: monitorDeploymentName
  scope: resourceGroup
  params: {
    monitorName: monitorName
    location: location
    skuName: 'payg_v2_Monthly@TIDgmz7xq9ge3py'
    singleSignOnState: 'Initial'
    tagRulesProperties: {
      metricRules: {
        filteringTags: []
      }
      logRules: {
        sendSubscriptionLogs: true
        sendResourceLogs: true
        filteringTags: []
      }
      automuting: true
    }
    monitorTags: {}
    cspm: false
  }
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: roleAssignmentName
  properties: {
    roleDefinitionId: monitoringReaderRoleDefinition.id
    principalId: monitorDeployment.outputs.monitorPrincipalId
    principalType: 'ServicePrincipal'
  }
}

resource monitoringReaderRoleDefinition 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  scope: subscription()
  name: '43d0d8ad-25c7-4714-9337-8ba259a9fe05' //Azure monitoring reader role
}
