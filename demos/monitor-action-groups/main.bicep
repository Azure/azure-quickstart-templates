@description('Unique name (within the Resource Group) for the Action group.')
param actionGroupName string

@description('Short name (maximum 12 characters) for the Action group.')
param actionGroupShortName string

@description('The list of email receivers that are part of this action group.')
param emailReceivers array = []

@description('The list of SMS receivers that are part of this action group.')
param smsReceivers array = []

@description('The list of webhook receivers that are part of this action group.')
param webhookReceivers array = []

@description('The list of ITSM receivers that are part of this action group')
param itsmReceivers array = []

@description('The list of AzureAppPush receivers that are part of this action group')
param azureAppPushReceivers array = []

@description('The list of AutomationRunbook receivers that are part of this action group.')
param automationRunbookReceivers array = []

@description('The list of voice receivers that are part of this action group.')
param voiceReceivers array = []

@description('The list of logic app receivers that are part of this action group.')
param logicAppReceivers array = []

@description('The list of azure function receivers that are part of this action group.')
param azureFunctionReceivers array = []

@description('The list of ARM role receivers that are part of this action group. Roles are Azure RBAC roles and only built-in roles are supported.')
param armRoleReceivers array = []

resource actionGroup 'Microsoft.Insights/actionGroups@2019-06-01' = {
  name: actionGroupName
  location: 'Global'
  properties: {
    groupShortName: actionGroupShortName
    enabled: true
    emailReceivers: emailReceivers
    smsReceivers: smsReceivers
    webhookReceivers: webhookReceivers
    itsmReceivers: itsmReceivers
    azureAppPushReceivers: azureAppPushReceivers
    automationRunbookReceivers: automationRunbookReceivers
    voiceReceivers: voiceReceivers
    logicAppReceivers: logicAppReceivers
    azureFunctionReceivers: azureFunctionReceivers
    armRoleReceivers: armRoleReceivers
  }
}

output actionGroupId string = actionGroup.id
