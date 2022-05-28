@description('Specify the name of alert')
param alertName string

@description('Specify a description of alert')
@allowed([
  'Active'
  'InProgress'
  'Resolved'
])
param status string = 'Active'

@description('Specify the email address where the alerts are sent to.')
param emailAddress string = 'email@example.com'

@description('Specify the email address name where the alerts are sent to.')
param emailName string = 'Example'

resource emailActionGroup 'microsoft.insights/actionGroups@2021-09-01' = {
  name: 'emailActionGroupName'
  location: 'global'
  properties: {
    groupShortName: 'string'
    enabled: true
    emailReceivers: [
      {
        name: emailName
        emailAddress: emailAddress
        useCommonAlertSchema: true
      }
    ]
  }
}

resource alert 'Microsoft.Insights/activityLogAlerts@2020-10-01' = {
  name: alertName
  location: 'global'
  properties: {
    enabled: true
    scopes: [
      subscription().id
    ]
    condition: {
      allOf: [
        {
          field: 'category'
          equals: 'ResourceHealth'
        }
        {
          field: 'status'
          equals: status
        }
      ]
    }
    actions: {
      actionGroups: [
        {
          actionGroupId: emailActionGroup.id
        }
      ]
    }
  }
}
