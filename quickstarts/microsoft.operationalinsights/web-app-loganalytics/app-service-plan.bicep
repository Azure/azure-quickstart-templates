param skuName string = 'S1'
param skuCapacity int = 1
param location string = resourceGroup().location
param appName string
var appServicePlanName = toLower('asp-${appName}')
resource appServicePlan 'Microsoft.Web/serverfarms@2020-06-01' = {
  name: appServicePlanName // Globally unique storage account name
  location: location // Azure Region
  sku: {
    name: skuName
    capacity: skuCapacity
  }
  tags: {
    displayName: 'HostingPlan'
    ProjectName: appName
  }
}
output appServicePlanID string = appServicePlan.id
