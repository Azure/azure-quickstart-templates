param sqlWitnessVMName string
param domainName string
param sharePath string
param adminUsername string

@secure()
param adminPassword string
param _artifactsLocation string

@secure()
param _artifactsLocationSasToken string

@description('Location for all resources.')
param location string

var fswModulesURL = uri(_artifactsLocation, 'dsc/create-file-share-witness.ps1.zip${_artifactsLocationSasToken}')
var fswConfigurationFunction = 'CreateFileShareWitness.ps1\\CreateFileShareWitness'

resource createFileShareWitness 'Microsoft.Compute/virtualMachines/extensions@2023-09-01' = {
  name: '${sqlWitnessVMName}/CreateFileShareWitness'
  location: location
  properties: {
    publisher: 'Microsoft.Powershell'
    type: 'DSC'
    typeHandlerVersion: '2.17'
    autoUpgradeMinorVersion: true
    settings: {
      wmfVersion: '5.0'
      modulesUrl: fswModulesURL
      configurationFunction: fswConfigurationFunction
      properties: {
        domainName: domainName
        sharePath: sharePath
        adminCreds: {
          userName: adminUsername
          password: 'PrivateSettingsRef:adminPassword'
        }
      }
    }
    protectedSettings: {
      items: {
        adminPassword: adminPassword
      }
    }
  }
}
