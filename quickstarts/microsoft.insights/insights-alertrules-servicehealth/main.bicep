@description('Name of alert')
param alertName string

@description('Description of alert')
@allowed([
  'Active'
  'InProgress'
  'Resolved'
])
param status string = 'Active'

@description('Email address where the alerts are sent.')
param emailAddress string = 'email@example.com'

@description('Email address where the alerts are sent.')
param emailName string = 'Example'

resource emailActionGroup 'microsoft.insights/actionGroups@2021-09-01' = {
  name: 'emailActionGroup'
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

resource alertName_resource 'Microsoft.Insights/activityLogAlerts@2020-10-01' = {
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