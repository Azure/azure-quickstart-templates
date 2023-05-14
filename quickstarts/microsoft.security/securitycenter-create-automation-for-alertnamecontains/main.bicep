@minLength(3)
@maxLength(24)
param automationName string

@description('Location for the automation')
param location string = resourceGroup().location

@minLength(3)
param logicAppName string

@minLength(3)
param logicAppResourceGroupName string

@description('The Azure resource GUID id of the subscription')
param subscriptionId string = subscription().subscriptionId

@description('The alert settings object used for deploying the automation')
param alertSettings object

var automationDescription = 'automation description for subscription {0}'
var scopeDescription = 'automation scope for subscription {0}'

resource automation 'Microsoft.Security/automations@2019-01-01-preview' = {
  name: automationName
  location: location
  properties: {
    description: format(automationDescription, subscriptionId)
    isEnabled: true
    actions: [
      {
        actionType: 'LogicApp'
        logicAppResourceId: resourceId('Microsoft.Logic/workflows', logicAppName)
        uri: listCallbackURL(resourceId(subscriptionId, logicAppResourceGroupName, 'Microsoft.Logic/workflows/triggers', logicAppName, 'manual'), '2019-05-01').value
      }
    ]
    scopes: [
      {
        description: format(scopeDescription, subscriptionId)
        scopePath: subscription().id
      }
    ]
    sources: [
      {
        eventSource: 'Alerts'
        ruleSets: [for j in range(0, length(alertSettings.alertSeverityMapping)): {
          rules: [
            {
              propertyJPath: alertSettings.alertSeverityMapping[j].jpath
              propertyType: 'String'
              expectedValue: alertSettings.alertSeverityMapping[j].expectedValue
              operator: alertSettings.alertSeverityMapping[j].operator
            }
            {
              propertyJPath: 'Severity'
              propertyType: 'String'
              expectedValue: alertSettings.alertSeverityMapping[j].severity
              operator: 'Equals'
            }
          ]
        }]
      }
    ]
  }
}
