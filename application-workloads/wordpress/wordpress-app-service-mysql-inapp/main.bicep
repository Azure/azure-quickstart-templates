@description('SKU (App Service Pricing Tier)')
@allowed([
  'F1'
  'B1'
  'S1'
])
param sku string = 'F1'

@description('GitHub repo to deploy to App Service')
param repoUrl string = 'https://github.com/azureappserviceoss/wordpress-azure'

@description('GitHub repo branch to deploy to App Service')
param branch string = 'master'

@description('Location for all resources.')
param location string = resourceGroup().location

var uniqueHostingPlan = '${uniqueString(resourceGroup().id)}hostingplan'
var uniqueSite = '${uniqueString(resourceGroup().id)}website'

resource hostingPlan 'Microsoft.Web/serverfarms@2020-06-01' = {
  sku: {
    name: sku
    capacity: 1
  }
  name: uniqueHostingPlan
  location: location
  properties: {}
}

resource site 'Microsoft.Web/sites@2020-06-01' = {
  name: uniqueSite
  location: location
  properties: {
    serverFarmId: hostingPlan.id
    siteConfig: {
      localMySqlEnabled: true
      appSettings: [
        {
          name: 'WEBSITE_MYSQL_ENABLED'
          value: '1'
        }
        {
          name: 'WEBSITE_MYSQL_GENERAL_LOG'
          value: '0'
        }
        {
          name: 'WEBSITE_MYSQL_SLOW_QUERY_LOG'
          value: '0'
        }
        {
          name: 'WEBSITE_MYSQL_ARGUMENTS'
          value: '--max_allowed_packet=16M'
        }
      ]
    }
  }
}

resource site_web 'Microsoft.Web/sites/sourcecontrols@2020-06-01' = {
  parent: site
  name: 'web'
  properties: {
    repoUrl: repoUrl
    branch: branch
    isManualIntegration: true
  }
}

resource Microsoft_Web_sites_config_site_web 'Microsoft.Web/sites/config@2020-06-01' = {
  parent: site
  name: 'web'
  properties: {
    phpVersion: '7.0'
  }
}

