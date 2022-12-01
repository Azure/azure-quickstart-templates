param name string
param location string
param sku string = 'Free'
param skucode string = 'F1'
param workerSize int = 0
param workerSizeId int = 0
param numberOfWorkers int = 1
param hostingEnvironment string = ''
param tags object

resource name_resource 'Microsoft.Web/serverfarms@2019-08-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    name: name
    workerSize: workerSize
    workerSizeId: workerSizeId
    numberOfWorkers: numberOfWorkers
    reserved: false
    hostingEnvironment: hostingEnvironment
  }
  sku: {
    tier: sku
    name: skucode
  }
}