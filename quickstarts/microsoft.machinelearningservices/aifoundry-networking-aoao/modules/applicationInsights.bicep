// Parameters
@description('Specifies the name of the Azure Application Insights.')
param name string

@description('Specifies the location.')
param location string = resourceGroup().location

@description('Specifies the Azure Log Analytics workspace ID.')
param workspaceId string

@description('Specifies the resource tags.')
param tags object

// Resources
resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: name
  location: location
  tags: tags
  kind: 'web'
  properties: {
    Application_Type: 'web'
    DisableIpMasking: false
    DisableLocalAuth: false
    Flow_Type: 'Bluefield'
    ForceCustomerStorageForProfiler: false
    ImmediatePurgeDataOn30Days: true
    WorkspaceResourceId: workspaceId
    IngestionMode: 'LogAnalytics'
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Disabled'
    Request_Source: 'rest'
  }
}

//Outputs
output id string = applicationInsights.id
output name string = applicationInsights.name
