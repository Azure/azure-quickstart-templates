@description('Optional. The location to deploy to.')
param location string = resourceGroup().location

@description('Required. The name of the virtual machine.')
param virtualMachineName string

@description('Required. The size of the virtual machine.')
param virtualMachineSize string

@description('Optional. The type of storage for the OS managed disk.')
param virtualMachineStorageAccountType string = 'StandardSSD_LRS'

@description('Optional. The size of the OS managed disk.')
param virtualMachineDiskSizeGB int = 128

@description('Required. The virtual machine image object.')
param virtualMachineImageReference object

@allowed([
  'Windows_Server'
])
param licenseType string?

@allowed([
  'ConfidentialVM'
  'TrustedLaunch'
  ''
])
param virtualMachineSecurityType string?

@description('Required. The name of the local administrator.')
param adminUsername string

@description('Required. The password of the local administrator.')
@secure()
param adminPassword string

param subnetResourceId string
param privateIPAddress string?
param pipConfiguration object?

param dscSettings object?

@secure()
param dscProtectedSettings object?

param runCommandProperties object?

param increaseDscQuota bool = true

param timeZone string = 'Romance Standard Time'
param autoShutdownTime string = '1900'
@description('Tags to apply on the resources.')
param tags object

var modulePrefix = 'virtualMachine'

module virtualMachine 'br/public:avm/res/compute/virtual-machine:0.21.0' = {
  name: '${modulePrefix}-${virtualMachineName}-module-avm'
  scope: resourceGroup()
  params: {
    tags: tags
    location: resourceGroup().location
    name: 'vm-${virtualMachineName}'
    computerName: virtualMachineName
    adminUsername: adminUsername
    adminPassword: adminPassword
    imageReference: virtualMachineImageReference
    vmSize: virtualMachineSize
    availabilityZone: -1
    securityType: virtualMachineSecurityType
    encryptionAtHost: false
    secureBootEnabled: virtualMachineSecurityType == 'TrustedLaunch' ? true : false
    vTpmEnabled: virtualMachineSecurityType == 'TrustedLaunch' ? true : false
    osType: 'Windows'
    licenseType: licenseType
    timeZone: timeZone
    autoShutdownConfig: autoShutdownTime != '9999'
      ? {
          status: 'Enabled'
          timeZoneId: timeZone
          dailyRecurrence: {
            time: autoShutdownTime
          }
        }
      : null
    nicConfigurations: [
      {
        ipConfigurations: [
          {
            name: 'ipconfig01'
            subnetResourceId: subnetResourceId
            privateIPAllocationMethod: privateIPAddress == null ? 'Dynamic' : 'Static'
            privateIPAddress: privateIPAddress
            pipConfiguration: pipConfiguration
          }
        ]
        nicSuffix: '-nic-01'
        enableAcceleratedNetworking: false
      }
    ]
    osDisk: {
      caching: 'ReadWrite'
      diskSizeGB: virtualMachineDiskSizeGB
      managedDisk: {
        storageAccountType: virtualMachineStorageAccountType
      }
    }
    extensionGuestConfigurationExtension: {
      enabled: true
    }

    // extensionCustomScriptConfig:
    // extensionDSCConfig:

    extensionCustomScriptConfig: increaseDscQuota == true ? {
      name: 'increase-dsc-quota'
      settings: {
        commandToExecute: 'powershell -Command "Set-Item -Path WSMan:\\localhost\\MaxEnvelopeSizeKb -Value 2048"'
      }
    } : null

    // extensionCustomScriptConfig : dscSettings != null ? {
    //   autoUpgradeMinorVersion: true
    //   settings: dscSettings
    //   protectedSettings: dscProtectedSettings
    // } : null
  }
}

resource virtualMachineCreated 'Microsoft.Compute/virtualMachines@2025-04-01' existing = {
  dependsOn: [
    virtualMachine
  ]
  scope: resourceGroup()
  name: 'vm-${virtualMachineName}'
}

// resource runcommand_increase_dsc_quota 'Microsoft.Compute/virtualMachines/runCommands@2025-04-01' = if (increaseDscQuota == true) {
//   parent: virtualMachineCreated
//   name: '${modulePrefix}-${virtualMachineName}-runcommand-increase-dsc-quota'
//   location: location
//   properties: {
//     source: {
//       script: 'Set-Item -Path WSMan:\\localhost\\MaxEnvelopeSizeKb -Value 2048'
//     }
//     timeoutInSeconds: 90
//     treatFailureAsDeploymentFailure: false
//   }
// }

resource runcommand 'Microsoft.Compute/virtualMachines/runCommands@2025-04-01' = if (runCommandProperties != null) {
  parent: virtualMachineCreated
  name: '${modulePrefix}-${virtualMachineName}-runcommand'
  location: location
  properties: runCommandProperties!
}

resource extension 'Microsoft.Compute/virtualMachines/extensions@2025-04-01' = if (dscSettings != null) {
  dependsOn: [
    // runcommand_increase_dsc_quota
    runcommand
  ]
  parent: virtualMachineCreated
  name: '${modulePrefix}-${virtualMachineName}-dsc'
  location: location
  properties: {
    publisher: 'Microsoft.Powershell'
    type: 'DSC'
    typeHandlerVersion: '2.9'
    autoUpgradeMinorVersion: true
    forceUpdateTag: '1.0'
    settings: dscSettings
    protectedSettings: dscProtectedSettings
  }
}

@description('The name of the virtual machine.')
output name string = virtualMachine.outputs.name

@description('The public IP address of the virtual machine.')
output publicIP string = virtualMachine.outputs.nicConfigurations[0].ipConfigurations[0].?publicIP ?? ''

// output virtualMachinePublicDomainName string = virtualMachine.properties.dnsSettings.fqdn
// output virtualMachinePublicIP string = virtualMachine.properties.dnsSettings.ipAddress
