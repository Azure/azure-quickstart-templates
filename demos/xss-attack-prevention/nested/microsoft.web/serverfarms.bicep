param name string
param location string
param sku string = 'Free'
param skucode string = 'F1'
param workerSizeId int = 0
param numberOfWorkers int = 1
param tags object

resource serverfarm 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    targetWorkerSizeId: workerSizeId
    targetWorkerCount: numberOfWorkers
    reserved: false
  }
  sku: {
    tier: sku
    name: skucode
  }
}
