metadata description = 'Creates a data export rule.'
param name string
param logAnalyticsWorkspaceName string
param storageAccountName string
param tables string[]

resource dataExportRule 'Microsoft.OperationalInsights/workspaces/dataExports@2020-08-01' = {
  name: name
  parent: logAnalyticsWorkspace
  properties: {
    destination: {
      resourceId: storageAccount.id
    }
    enable: true
    tableNames: tables
  }
}

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-12-01-preview'  existing = {
  name: logAnalyticsWorkspaceName
}

resource storageAccount  'Microsoft.Storage/storageAccounts@2022-09-01'  existing = {
  name: storageAccountName
}
