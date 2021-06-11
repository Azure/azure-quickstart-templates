@description('The name of the Data Lake Store account to create.')
param accountName string

@description('The location in which to create the Data Lake Store account.')
param location string = resourceGroup().location

resource dataLake 'Microsoft.DataLakeStore/accounts@2016-11-01' = {
  name: accountName
  location: location
  properties: {
    newTier: 'Consumption'
    encryptionState: 'Enabled'
    encryptionConfig: {
      type: 'ServiceManaged'
    }
  }
}
