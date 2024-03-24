param webAppName string
param packageUri string

resource msDeploy 'Microsoft.Web/sites/extensions@2022-03-01' = {
  name: '${webAppName}/MSDeploy'
  properties: {
    packageUri: packageUri
  }
}
