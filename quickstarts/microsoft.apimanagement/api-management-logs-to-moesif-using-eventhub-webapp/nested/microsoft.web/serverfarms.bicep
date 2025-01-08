@description('The name to be given to this new App Service Plan')
param appServicePlanName string

@description('The instance / SKU name for Azure App Service eg: B1, B2, S1, S2, P1V2. Note F1 and D1 shared plan are not supported as they do not support \'alwaysOn\'')
@allowed([
  'B1'
  'B2'
  'B3'
  'S1'
  'S2'
  'S3'
  'P1v2'
  'P2v2'
  'P3v2'
  'P1v3'
  'P2v3'
  'P3v3'
])
param appServiceSkuName string = 'B1'
param tags object

@description('Location for all resources. eg \'westus2\'')
param location string

resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: appServicePlanName
  location: location
  tags: tags
  sku: {
    name: appServiceSkuName
  }
  kind: 'app'
  properties: {
  }
}
