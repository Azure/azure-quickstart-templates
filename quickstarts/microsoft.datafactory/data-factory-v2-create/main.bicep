param name string = 'myv2datafactory'

@description('Location for your data factory')
param location string = resourceGroup().location

resource DataFactory 'Microsoft.DataFactory/factories@2018-06-01' = {
  name: name
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {}
}
