param actionGroupName string
param actionGroupShortName string
param emailReceivers array = []
param smsReceivers array = []
param webhookReceivers array = []
param itsmReceivers array = []
param azureAppPushReceivers array = []
param automationRunbookReceivers array = []
param voiceReceivers array = []
param logicAppReceivers array = []
param azureFunctionReceivers array = []
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
