@description('Name of the hosting plan to use in Azure.')
@minLength(1)
param hostingPlanName string

@description('Name of the Azure Web app to create.')
@minLength(1)
param webSiteName string

@description('Describes plan\'s pricing tier and instance size. Check details at https://azure.microsoft.com/en-us/pricing/details/app-service/')
@allowed([
  'F1'
  'D1'
  'B1'
  'B2'
  'B3'
  'S1'
  'S2'
  'S3'
  'P1'
  'P2'
  'P3'
  'P4'
])
param skuName string = 'F1'

@description('Describes plan\'s instance count')
@minValue(1)
@maxValue(3)
param skuCapacity int = 1

@description('Location for all resources.')
param location string = resourceGroup().location

resource hostingPlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: hostingPlanName
  location: location
  tags: {
    displayName: 'HostingPlan'
  }
  sku: {
    name: skuName
    capacity: skuCapacity
  }
  properties: {}
}

resource webSite 'Microsoft.Web/sites@2022-03-01' = {
  name: webSiteName
  location: location
  tags: {
    'hidden-related:${resourceGroup().id}/providers/Microsoft.Web/serverfarms/${hostingPlanName}': 'Resource'
    displayName: 'Website'
  }
  properties: {
    serverFarmId: hostingPlan.id
  }
}

resource webSiteConfig 'Microsoft.Web/sites/config@2022-03-01' = {
  parent: webSite
  name: 'web'
  properties: {
    javaVersion: '1.8'
    javaContainer: 'TOMCAT'
    javaContainerVersion: '9.0'
  }
}
