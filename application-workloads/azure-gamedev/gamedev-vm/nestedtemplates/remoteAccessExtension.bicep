@description('Deployment Location')
param location string

@description('The base URI where artifacts required by this template are located including a trailing \'/\'')
param _artifactsLocation string = deployment().properties.templateLink.uri

@description('The sasToken required to access _artifactsLocation.')
@secure()
param _artifactsLocationSasToken string = ''

@description('Toggle to Install GDK')
param cmdGDKInstall string

@description('Toggle to Register Teradici')
param cmdTeradiciRegistration string

@description('Name of Game Developer Virtual Machine')
param virtualMachineName string

@description('Remote Access technology')
@allowed([
  'RDP'
  'Teradici'
  'Parsec'
])
param remoteAccessTechnology string

@description('Name of Storage Account to Link')
param fileShareStorageAccount string

@description('Key of Storage Account to Link')
@secure()
param fileShareStorageAccountKey string

@description('Name of File Share')
param fileShareName string

@description('Port to use for p4')
param p4Port string

@description('Username for p4')
param p4Username string

@description('Password for p4')
@secure()
param p4Password string

@description('p4 Workspace')
param p4Workspace string

@description('Stream for p4')
param p4Stream string

@description('Client View for p4')
param p4ClientViews string

var mountFileShareParams = '-storageAccount \'${fileShareStorageAccount}\' -storageAccountKey \'${fileShareStorageAccountKey}\' -fileShareName \'${fileShareName}\''

var p4Params = '-p4Port \'${p4Port}\' -p4Username \'${p4Username}\' -p4Password \'${p4Password}\' -p4Workspace \'${p4Workspace}\' -p4Stream \'${p4Stream}\' -p4ClientViews \'${p4ClientViews}\''

var remoteAccessExtension = {
  RDP: {
    publisher: 'Microsoft.Compute'
    type: 'CustomScriptExtension'
    typeHandlerVersion: '1.10'
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
    publisher: 'Microsoft.Compute'
    type: 'CustomScriptExtension'
    typeHandlerVersion: '1.10'
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
    publisher: 'Microsoft.Compute'
    type: 'CustomScriptExtension'
    typeHandlerVersion: '1.10'
    autoUpgradeMinorVersion: true
    settings: {
      fileUris: [
        uri(_artifactsLocation, 'scripts/CreateDataDisk.ps1${_artifactsLocationSasToken}')
        uri(_artifactsLocation, 'scripts/MountFileShare.ps1${_artifactsLocationSasToken}')
        uri(_artifactsLocation, 'scripts/p4DepotSync.ps1${_artifactsLocationSasToken}')
        uri(_artifactsLocation, 'scripts/ibSetup.ps1${_artifactsLocationSasToken}')
        uri(_artifactsLocation, 'scripts/PostInstall.ps1${_artifactsLocationSasToken}')

        uri(_artifactsLocation, 'scripts/parsec/Automatic-Shutdown.ps1${_artifactsLocationSasToken}')
        uri(_artifactsLocation, 'scripts/parsec/Clear-Proxy.ps1${_artifactsLocationSasToken}')
        uri(_artifactsLocation, 'scripts/parsec/CreateAutomaticShutdownScheduledTask.ps1${_artifactsLocationSasToken}')
        uri(_artifactsLocation, 'scripts/parsec/CreateClearProxyScheduledTask.ps1${_artifactsLocationSasToken}')
        uri(_artifactsLocation, 'scripts/parsec/ForceCloseShutDown.reg${_artifactsLocationSasToken}')
        uri(_artifactsLocation, 'scripts/parsec/gpt.ini${_artifactsLocationSasToken}')
        uri(_artifactsLocation, 'scripts/parsec/GPU-Update.ico${_artifactsLocationSasToken}')
        uri(_artifactsLocation, 'scripts/parsec/NetWorkRestore.ps1${_artifactsLocationSasToken}')
        uri(_artifactsLocation, 'scripts/parsec/NetworkRestore.reg${_artifactsLocationSasToken}')
        uri(_artifactsLocation, 'scripts/parsec/OneHour.ps1${_artifactsLocationSasToken}')
        uri(_artifactsLocation, 'scripts/parsec/Parsec.png${_artifactsLocationSasToken}')
        uri(_artifactsLocation, 'scripts/parsec/psscripts.ini${_artifactsLocationSasToken}')
        uri(_artifactsLocation, 'scripts/parsec/ShowDialog.ps1${_artifactsLocationSasToken}')
        uri(_artifactsLocation, 'scripts/parsec/TeamMachineSetup.ps1${_artifactsLocationSasToken}')
        uri(_artifactsLocation, 'scripts/parsec/WarningMessage.ps1${_artifactsLocationSasToken}')
        
      ]
      commandToExecute: 'powershell -ExecutionPolicy Unrestricted -NoProfile -NonInteractive -command "./CreateDataDisk.ps1;./MountFileShare.ps1 ${mountFileShareParams};./p4DepotSync.ps1 ${p4Params};./ibSetup.ps1;${cmdGDKInstall};./PostInstall.ps1"'
    }
  }
}

resource virtualMachine_remoteAccessExtension 'Microsoft.Compute/virtualMachines/extensions@2021-11-01' = {
  name: '${virtualMachineName}/CustomScriptExtension-${remoteAccessTechnology}'
  location: location
  properties: remoteAccessExtension[remoteAccessTechnology]
}

output id string = virtualMachine_remoteAccessExtension.id
