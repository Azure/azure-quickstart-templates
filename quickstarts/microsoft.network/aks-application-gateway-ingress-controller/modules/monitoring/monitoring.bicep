param location string
param logAnalyticsWorkspaceName string
param logAnalyticsSku string
param logAnalyticsRetentionInDays int
param containerInsightsSolutionName string
param actionGroupName string
param actionGroupShortName string
param emailReceivers array
param smsReceivers array
param voiceReceivers array


resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: logAnalyticsWorkspaceName
  location: location
  properties: {
    sku: {
      name: logAnalyticsSku
    }
    retentionInDays: logAnalyticsRetentionInDays
  }
}

resource containerInsightsSolution 'Microsoft.OperationsManagement/solutions@2015-11-01-preview' = {
  name: containerInsightsSolutionName
  location: location
  plan: {
    name: containerInsightsSolutionName
    product: 'OMSGallery/ContainerInsights'
    publisher: 'Microsoft'
    promotionCode: ''
  }
  properties: {
    workspaceResourceId: logAnalyticsWorkspace.id
  }
}

resource actionGroup 'Microsoft.Insights/actionGroups@2023-09-01-preview' = {
  name: actionGroupName
  location: 'Global'
  properties: {
    groupShortName: actionGroupShortName
    enabled: true
    emailReceivers: emailReceivers
    smsReceivers: smsReceivers
    voiceReceivers: voiceReceivers
  }
}

resource AllAzureAdvisorAlert 'Microsoft.Insights/activityLogAlerts@2020-10-01' = {
  name: 'AllAzureAdvisorAlert'
  location: 'Global'
  properties: {
    scopes: [
      resourceGroup().id
    ]
    actions: {
      actionGroups: [
        {
          actionGroupId: actionGroup.id
        }
      ]
    }
    condition: {
      allOf: [
        {
          field: 'category'
          equals: 'Recommendation'
        }
        {
          field: 'operationName'
          equals: 'Microsoft.Advisor/recommendations/available/action'
        }
      ]
    }
    enabled: true
    description: 'All azure advisor alerts'
  }
}

output logAnalyticsWorkspaceId string = logAnalyticsWorkspace.id
output containerInsightsSolutionId string = containerInsightsSolution.id
