@description('Name of the virtual machine')
param vmName string

@description('Type of the volume OS or Data to perform encryption operation')
param volumeType string = 'All'

@description('Pass in an unique value like a GUID everytime the operation needs to be force run')
param forceUpdateTag string = uniqueString(resourceGroup().id, deployment().name)

@description('Location for all resources.')
param location string = resourceGroup().location

resource vmExt 'Microsoft.Compute/virtualMachines/extensions@2019-12-01' = {
  name: '${vmName}/AzureDiskEncryption'
  location: location
  properties: {
    publisher: 'Microsoft.Azure.Security'
    type: 'AzureDiskEncryption'
    typeHandlerVersion: '2.2'
    autoUpgradeMinorVersion: true
    forceUpdateTag: forceUpdateTag
    settings: {
      EncryptionOperation: 'DisableEncryption'
      VolumeType: volumeType
    }
  }
}
