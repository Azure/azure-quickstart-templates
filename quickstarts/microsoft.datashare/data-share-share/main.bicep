@description('Name for your Data Share Account')
param accountName string

@description('Location for your data share')
param location string = resourceGroup().location

@description('Name for your data share')
param shareName string = 'share'

resource account 'Microsoft.DataShare/accounts@2021-08-01' = {
  name: accountName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
}

resource share 'Microsoft.DataShare/accounts/shares@2021-08-01' = {
  parent: account
  name: shareName
  properties: {
    shareKind: 'CopyBased'
  }
}
