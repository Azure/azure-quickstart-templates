param extName string
param location string
param adminUsername string

@secure()
param adminPassword string
param domainName string
param adBDCConfigurationScript string
param adBDCConfigurationFunction string
param adBDCConfigurationModulesURL string

@secure()
param artifactsLocationSasToken string

resource extName_resource 'Microsoft.Compute/virtualMachines/extensions@2020-12-01' = {
  name: extName
  location: location
  properties: {
    publisher: 'Microsoft.Powershell'
    type: 'DSC'
    typeHandlerVersion: '2.24'
    autoUpgradeMinorVersion: true
    settings: {
      configuration: {
        url: adBDCConfigurationModulesURL
        script: adBDCConfigurationScript
        function: adBDCConfigurationFunction
      }
      configurationArguments: {
        domainName: domainName
      }
    }
    protectedSettings: {
      configurationUrlSasToken: artifactsLocationSasToken
      configurationArguments: {
        adminCreds: {
          userName: adminUsername
          password: adminPassword
        }
      }
    }
  }
}