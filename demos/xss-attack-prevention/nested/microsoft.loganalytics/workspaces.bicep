param omsWorkspaceName string = 'oms-workspace${uniqueString(resourceGroup().id)}'
param omsSolutionsName array
param tags object

@description('Service Tier: Free, Standalone, or PerNode')
@allowed([
  'Free'
  'Standalone'
  'PerNode'
])
param sku string = 'Free'

@description('Number of days of retention. Free plans can only have 7 days, Standalone and OMS plans include 30 days for free')
@minValue(7)
@maxValue(730)
param dataRetention int = 90

@description('Default location')
param location string

resource omsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: omsWorkspaceName
  location: location
  tags: tags
  properties: {
    sku: {
      name: sku
    }
    retentionInDays: dataRetention
  }
}

resource solution 'Microsoft.OperationsManagement/solutions@2015-11-01-preview' = [for item in omsSolutionsName: {
  name: '${item}(${omsWorkspaceName})'
  location: location
  plan: {
    name: '${item}(${omsWorkspaceName})'
    product: 'OMSGallery/${item}'
    promotionCode: ''
    publisher: 'Microsoft'
  }
  properties: {
    workspaceResourceId: omsWorkspace.id
  }
}]

resource dataSource 'Microsoft.OperationalInsights/workspaces/dataSources@2020-08-01' = {
  parent: omsWorkspace
  kind: 'AzureActivityLog'
  name: subscription().subscriptionId
  properties: {
    linkedResourceId: subscriptionResourceId('microsoft.insights/eventTypes', 'management')
  }
}

output workspaceName string = omsWorkspaceName
output workspaceId string = omsWorkspace.id
