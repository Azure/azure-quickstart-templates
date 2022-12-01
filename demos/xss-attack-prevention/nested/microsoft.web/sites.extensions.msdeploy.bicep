param webAppName string
param location string
param packageUri string
param tags object

resource webAppName_MSDeploy 'Microsoft.Web/sites/extensions@2018-02-01' = {
  name: '${webAppName}/MSDeploy'
  location: location
  tags: tags
  properties: {
    packageUri: packageUri
  }
}