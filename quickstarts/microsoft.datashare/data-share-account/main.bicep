@description('Specifies the name of the Data Share account.')
param accountName string

@description('Specifies the Azure location where the key vault should be created.')
param location string = resourceGroup().location

resource account 'Microsoft.DataShare/accounts@2021-08-01' = {
  name: accountName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
}
