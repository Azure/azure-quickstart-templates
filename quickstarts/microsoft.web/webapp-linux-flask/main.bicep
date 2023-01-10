@description('That name is the name of our application. It has to be unique.Type a name followed by your resource group name. (<name>-<resourceGroupName>)')
param webAppName string = 'flask-${uniqueString(resourceGroup().id)}'

@description('Location for all resources.')
param location string = resourceGroup().location

var alwaysOn = false
var sku = 'Free'
var skuCode = 'F1'
var workerSizeId = 0
var numberOfWorkers = 1
var linuxFxVersion = 'PYTHON|3.7'
var hostingPlanName = 'hpn-${resourceGroup().name}'

resource webApp 'Microsoft.Web/sites@2022-03-01' = {
  name: webAppName
  location: location
  properties: {
    siteConfig: {
      linuxFxVersion: linuxFxVersion
      alwaysOn: alwaysOn
    }
    serverFarmId: hostingPlan.id
    clientAffinityEnabled: false
  }
}

resource hostingPlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: hostingPlanName
  location: location
  kind: 'linux'
  properties: {
    targetWorkerCount: numberOfWorkers
    targetWorkerSizeId: workerSizeId
    reserved: true
  }
  sku: {
    tier: sku
    name: skuCode
  }
}
