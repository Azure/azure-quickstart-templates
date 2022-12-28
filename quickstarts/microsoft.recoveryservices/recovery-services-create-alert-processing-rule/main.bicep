@description('Email addresses to which the notifications should be sent. Should be specified as an array of strings, for example, ["user1@contoso.com", "user2@contoso.com"].')
param emailAddress array

@description('An action group is the channel to which a notification is sent, for example, email. Edit this field if you wish to use a custom name for the action group, otherwise, you can leave this unchanged. An action group name can have a length of 1-260 characters. You cannot use :,<,>,+,/,&,%,\\,? or control characters. The name cannot end with a space or period.')
param actionGroupName string = 'ActionGroup-${resourceGroup().name}'

@description('Short name of the action group used for display purposes. Can be 1-12 characters in length.')
@maxLength(12)
param actionGroupShortName string = 'ag-${((length(resourceGroup().name) >= 9) ? substring(resourceGroup().name, 0, 9) : resourceGroup().name)}'

@description('An alert processing rule lets you associate alerts to action groups. Edit this field if you wish to use a custom name for the alert processing rule, otherwise, you can leave this unchanged. An alert processing rule name can have a length of 1-260 characters. You cannot use <,>,*,%,&,:,\\,?,+,/,#,@,{,}.')
param alertProcessingRuleName string = 'AlertProcessingRule-${resourceGroup().name}'

@description('Description of the alert processing rule.')
param alertProcessingRuleDescription string = 'Sample alert processing rule'

@description('The scope of resources for which the alert processing rule will apply. You can leave this field unchanged if you wish to apply the rule for all Recovery Services vault within the subscription. If you wish to apply the rule on smaller scopes, you can specify an array of ARM URLs representing the scopes, eg. [\'/subscriptions/<sub-id>/resourceGroups/RG1\', \'/subscriptions/<sub-id>/resourceGroups/RG2\']')
param alertProcessingRuleScope array = [
  subscription().id
]

resource actionGroup 'Microsoft.Insights/actionGroups@2021-09-01' = {
  name: actionGroupName
  location: 'Global'
  properties: {
    emailReceivers: [for item in emailAddress: {
      name: 'emailReceivers-${uniqueString(item)}'
      emailAddress: item
      useCommonAlertSchema: true
    }]
    groupShortName: actionGroupShortName
    enabled: true
  }
}

resource alertProcessingRule 'Microsoft.AlertsManagement/actionRules@2021-08-08' = {
  name: alertProcessingRuleName
  location: 'Global'
  properties: {
    scopes: alertProcessingRuleScope
    conditions: [
      {
        field: 'TargetResourceType'
        operator: 'Equals'
        values: [
          'microsoft.recoveryservices/vaults'
        ]
      }
    ]
    description: alertProcessingRuleDescription
    enabled: true
    actions: [
      {
        actionGroupIds: [
          actionGroup.id
        ]
        actionType: 'AddActionGroups'
      }
    ]
  }
}

output actionGroupId string = actionGroup.id
output alertProcessingRuleId string = alertProcessingRule.id
