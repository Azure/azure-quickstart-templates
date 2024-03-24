param extName string
param location string
param adminUsername string

@secure()
param adminPassword string
param domainName string
param adBDCConfigurationScript string
param adBDCConfigurationFunction string
param adBDCConfigurationModulesPath string

param _artifactsLocation string
@secure()
param _artifactsLocationSasToken string

resource ext 'Microsoft.Compute/virtualMachines/extensions@2022-08-01' = {
  name: extName
  location: location
  properties: {
    publisher: 'Microsoft.Powershell'
    type: 'DSC'
    typeHandlerVersion: '2.24'
    autoUpgradeMinorVersion: true
    settings: {
      configuration: {
        url: uri(_artifactsLocation, adBDCConfigurationModulesPath)
        script: adBDCConfigurationScript
        function: adBDCConfigurationFunction
      }
      configurationArguments: {
        domainName: domainName
      }
    }
    protectedSettings: {
      configurationUrlSasToken: _artifactsLocationSasToken
      configurationArguments: {
        adminCreds: {
          userName: adminUsername
          password: adminPassword
        }
      }
    }
  }
}
