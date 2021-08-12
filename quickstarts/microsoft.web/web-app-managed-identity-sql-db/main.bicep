@description('Specifies region for all resources')
param location string = resourceGroup().location

@description('Speicifes app plan SKU')
param skuName string = 'F1'

@description('Specifies app plan capacity')
param skuCapacity int = 1

@description('Specifies sql admin login')
param sqlAdministratorLogin string

@description('Specifies sql admin password')
@secure()
param sqlAdministratorLoginPassword string

@description('Specifies managed identity name')
param managedIdentityName string


var hostingPlanName = 'hostingplan${uniqueString(resourceGroup().id)}'
var webSiteName = 'webSite${uniqueString(resourceGroup().id)}'
var sqlserverName = 'sqlserver${uniqueString(resourceGroup().id)}'
var databaseName = 'sampledb'

// Data resources
resource sqlserver 'Microsoft.Sql/servers@2019-06-01-preview' = {
  name: sqlserverName
  location: location
  properties: {
    administratorLogin: sqlAdministratorLogin
    administratorLoginPassword: sqlAdministratorLoginPassword
    version: '12.0'
  }
}

resource database 'Microsoft.Sql/servers/databases@2020-08-01-preview' = {
  name: '${sqlserver.name}/${databaseName}'
  location: location
  sku: {
    name: 'Basic'
  }
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    maxSizeBytes: 1073741824
  }
}

resource firewallRule 'Microsoft.Sql/servers/firewallRules@2014-04-01' = {
  name: '${sqlserver.name}/AllowAllWindowsAzureIps'
  properties: {
    endIpAddress: '0.0.0.0'
    startIpAddress: '0.0.0.0'
  }
}

// Web App resources
resource hostingPlan 'Microsoft.Web/serverfarms@2020-06-01' = {
  name: hostingPlanName
  location: location
  sku: {
    name: skuName
    capacity: skuCapacity
  }
}

resource webSite 'Microsoft.Web/sites@2020-06-01' = {
  name: webSiteName
  location: location
  tags: {
    'hidden-related:${hostingPlan.id}': 'empty'
    displayName: 'Website'
  }
  properties: {
    serverFarmId: hostingPlan.id
  }
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${msi.id}': {}
    }
  }

  resource connectionString 'config@2020-06-01' = {
    name: 'connectionstrings'
    properties: {
      DefaultConnection: {
        value: 'Data Source=tcp:${sqlserver.properties.fullyQualifiedDomainName},1433;Initial Catalog=${database.name};User Id=${sqlserver.properties.administratorLogin}@${sqlserver.properties.fullyQualifiedDomainName};Password=${sqlserver.properties.administratorLoginPassword};'
        type: 'SQLAzure'
      }
    }
  }
}

// Managed Identity resources
resource msi 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: managedIdentityName
  location: location
}

resource roleassignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid('b24988ac-6180-42a0-ab88-20f7382dd24c', resourceGroup().id)
  properties: {
    principalType: 'ServicePrincipal'
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'b24988ac-6180-42a0-ab88-20f7382dd24c')
    principalId: msi.properties.principalId
  }
}

// Monitor
resource appInsights 'Microsoft.Insights/components@2018-05-01-preview' = {
  name: 'AppInsights${webSite.name}'
  location: location
  tags: {
    'hidden-link:${webSite.id}': 'Resource'
    displayName: 'AppInsightsComponent'
  }
  kind: 'web'
  properties: {
    Application_Type: 'web'
  }
}
