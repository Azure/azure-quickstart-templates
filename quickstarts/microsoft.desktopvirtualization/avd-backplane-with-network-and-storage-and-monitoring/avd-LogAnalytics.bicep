//Define Log Analytics parameters
param logAnalyticsWorkspaceName string
param logAnalyticslocation string = 'westeurope'
param logAnalyticsWorkspaceSku string = 'pergb2018'
param hostpoolName string
param workspaceName string
param avdBackplaneResourceGroup string

//Create Log Analytics Workspace
resource avdla 'Microsoft.OperationalInsights/workspaces@2020-08-01' = {
  name: logAnalyticsWorkspaceName
  location: logAnalyticslocation
  properties: {
    sku: {
      name: logAnalyticsWorkspaceSku
    }
  }
}

//Create Diagnotic Setting for AVD components
module avdmonitor './avd-monitor-diag.bicep' = {
  name: 'myBicepLADiag'
  scope: resourceGroup(avdBackplaneResourceGroup)
  params: {
    logAnalyticsWorkspaceID: avdla.id
    hostpoolName: hostpoolName
    workspaceName: workspaceName
  }
}
