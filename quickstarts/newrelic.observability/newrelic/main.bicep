targetScope = 'subscription'

@description('Specify the name of the resource group in which the newrelic resource will be created')
param resourceGroupName string

@description('Specify a name for the NewRelic resource')
param resourceName string

@description('Specify the region for the monitor resource')
@allowed([
  'eastus'
  'centraluseuap'
  'eastus2euap'
])
param location string = 'eastus'

@description('Provide your first name (same as that setup as subscription owner on Azure)')
param firstName string

@description('Provide your last name (same as that setup as subscription owner on Azure)')
param lastName string

@description('Provide your work email address (same as that setup as subscription owner on Azure)')
param emailAddress string

var guidValue = guid(deployment().name, 'newrelic')
var roleDefinition = '/providers/Microsoft.Authorization/roleDefinitions/43d0d8ad-25c7-4714-9337-8ba259a9fe05'
var monitorDeploymentName = 'NewRelicMonitor_${substring(guidValue, 0, 8)}'
var roleAssignmentName = guidValue

module monitorDeployment './nested_monitorDeployment.bicep' = {
  name: monitorDeploymentName
  scope: resourceGroup(resourceGroupName)
  params: {
    resourceName: resourceName
    location: location
    emailAddress: emailAddress
    firstName: firstName
    lastName: lastName
    tagRulesProperties: {
      logRules: {
        sendAadLogs: 'Disabled'
        sendSubscriptionLogs: 'Disabled'
        sendActivityLogs: 'Enabled'
        filteringTags: []
      }
      metricRules: {
        sendMetrics: 'Enabled'
        filteringTags: []
        userEmail: emailAddress
      }
    }
  }
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: roleAssignmentName
  properties: {
    roleDefinitionId: format('{0}{1}', subscription().id, roleDefinition)
    principalId: monitorDeployment.outputs.monitorPrincipalId
    principalType: 'ServicePrincipal'
  }
}
