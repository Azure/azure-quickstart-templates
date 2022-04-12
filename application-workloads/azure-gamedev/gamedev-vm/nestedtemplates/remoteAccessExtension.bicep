param cmdGDKInstall              string
param cmdTeradiciRegistration    string
param _artifactsLocation         string
param _artifactsLocationSasToken string
param virtualMachineName         string
param remoteAccessTechnology     string
param location                   string
param fileShareStorageAccount    string
param fileShareStorageAccountKey string
param fileShareName              string
param p4Port                     string
param p4Username                 string
param p4Password                 string
param p4Workspace                string
param p4Stream                   string
param p4ClientViews              string

var mountFileShareParams = '-storageAccount \'${fileShareStorageAccount}\' -storageAccountKey \'${fileShareStorageAccountKey}\' -fileShareName \'${fileShareName}\''
var p4Params = '-p4Port \'${p4Port}\' -p4Username \'${p4Username}\' -p4Password \'${p4Password}\' -p4Workspace \'${p4Workspace}\' -p4Stream \'${p4Stream}\' -p4ClientViews \'${p4ClientViews}\''

var remoteAccessExtension = {
  RDP: {
    publisher              : 'Microsoft.Compute'
    type                   : 'CustomScriptExtension'
    typeHandlerVersion     : '1.10'
    autoUpgradeMinorVersion: true
    settings: {
      fileUris: [
        uri(_artifactsLocation, 'scripts/CreateDataDisk.ps1${_artifactsLocationSasToken}')
        uri(_artifactsLocation, 'scripts/MountFileShare.ps1${_artifactsLocationSasToken}')
        uri(_artifactsLocation, 'scripts/p4DepotSync.ps1${_artifactsLocationSasToken}')
        uri(_artifactsLocation, 'scripts/ibSetup.ps1${_artifactsLocationSasToken}')
      ]
      commandToExecute: 'powershell -ExecutionPolicy Unrestricted -NoProfile -NonInteractive -command "./CreateDataDisk.ps1;./MountFileShare.ps1 ${mountFileShareParams};./p4DepotSync.ps1 ${p4Params};./ibSetup.ps1;${cmdGDKInstall}"'
    }
  }
  Teradici: {
    publisher              : 'Microsoft.Compute'
    type                   : 'CustomScriptExtension'
    typeHandlerVersion     : '1.10'
    autoUpgradeMinorVersion: true
    settings: {
      fileUris: [
        uri(_artifactsLocation, 'scripts/CreateDataDisk.ps1${_artifactsLocationSasToken}')
        uri(_artifactsLocation, 'scripts/MountFileShare.ps1${_artifactsLocationSasToken}')
        uri(_artifactsLocation, 'scripts/p4DepotSync.ps1${_artifactsLocationSasToken}')
        uri(_artifactsLocation, 'scripts/ibSetup.ps1${_artifactsLocationSasToken}')
        uri(_artifactsLocation, 'scripts/TeradiciRegCAS.ps1${_artifactsLocationSasToken}')
      ]
    }
    protectedSettings: {
      commandToExecute: 'powershell -ExecutionPolicy Unrestricted -command "./CreateDataDisk.ps1;./MountFileShare.ps1 ${mountFileShareParams};./p4DepotSync.ps1 ${p4Params};./ibSetup.ps1;${cmdGDKInstall};${cmdTeradiciRegistration}"'
    }
  }
  Parsec: {
    publisher              : 'Microsoft.Compute'
    type                   : 'CustomScriptExtension'
    typeHandlerVersion     : '1.10'
    autoUpgradeMinorVersion: true
    settings: {
      fileUris: [
        uri(_artifactsLocation, 'scripts/CreateDataDisk.ps1${_artifactsLocationSasToken}')
        uri(_artifactsLocation, 'scripts/MountFileShare.ps1${_artifactsLocationSasToken}')
        uri(_artifactsLocation, 'scripts/p4DepotSync.ps1${_artifactsLocationSasToken}')
        uri(_artifactsLocation, 'scripts/ibSetup.ps1${_artifactsLocationSasToken}')
        uri(_artifactsLocation, 'scripts/PostInstall.ps1${_artifactsLocationSasToken}')
        uri(_artifactsLocation, 'scripts/PreInstall.zip${_artifactsLocationSasToken}')
      ]
      commandToExecute: 'powershell -ExecutionPolicy Unrestricted -NoProfile -NonInteractive -command "./CreateDataDisk.ps1;./MountFileShare.ps1 ${mountFileShareParams};./p4DepotSync.ps1 ${p4Params};./ibSetup.ps1;${cmdGDKInstall};./PostInstall.ps1"'
    }
  }
}

resource virtualMachine_remoteAccessExtension 'Microsoft.Compute/virtualMachines/extensions@2021-11-01' = {
  name      : '${virtualMachineName}/CustomScriptExtension-${remoteAccessTechnology}'
  location  : location
  properties: remoteAccessExtension[remoteAccessTechnology]
}

output id string = virtualMachine_remoteAccessExtension.id
