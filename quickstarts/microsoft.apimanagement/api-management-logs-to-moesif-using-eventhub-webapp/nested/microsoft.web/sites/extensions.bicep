@description('Name of the Azure App service resource')
param appServiceName string

@description('URL to Zip file that contains webjob using format suitable to be published using msdeploy')
param webJobZipDeployUrl string

resource appServiceName_MSDeploy 'Microsoft.Web/sites/extensions@2022-03-01' = {
  name: '${appServiceName}/MSDeploy'
  properties: {
    addOnPackages: [
      {
        packageUri: webJobZipDeployUrl
        AppOffline: true
      }
    ]
  }
}
