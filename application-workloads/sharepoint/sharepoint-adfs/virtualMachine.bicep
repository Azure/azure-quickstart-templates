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

var modulePrefix = 'virtualMachine'

module vm_definition 'br/public:avm/res/compute/virtual-machine:0.15.0' = {
  name: '${modulePrefix}-${virtualMachineName}-module-avm'
  scope: resourceGroup()
  params: {
    location: resourceGroup().location
    name: 'vm-${virtualMachineName}'
    computerName: virtualMachineName
    adminUsername: adminUsername
    adminPassword: adminPassword
    imageReference: virtualMachineImageReference
    vmSize: virtualMachineSize
    zone: 0
    encryptionAtHost: false
    securityType: virtualMachineSecurityType
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
  }
}

resource virtualMachine 'Microsoft.Compute/virtualMachines@2024-11-01' existing = {
  dependsOn: [
    vm_definition
  ]
  scope: resourceGroup()
  name: 'vm-${virtualMachineName}'
}

resource runcommand_increase_dsc_quota 'Microsoft.Compute/virtualMachines/runCommands@2024-11-01' = if (increaseDscQuota == true) {
  parent: virtualMachine
  name: '${modulePrefix}-${virtualMachineName}-runcommand-increase-dsc-quota'
  location: location
  properties: {
    source: {
      script: 'Set-Item -Path WSMan:\\localhost\\MaxEnvelopeSizeKb -Value 2048'
    }
    timeoutInSeconds: 90
    treatFailureAsDeploymentFailure: false
  }
}

resource runcommand 'Microsoft.Compute/virtualMachines/runCommands@2024-11-01' = if (runCommandProperties != null) {
  parent: virtualMachine
  name: '${modulePrefix}-${virtualMachineName}-runcommand'
  location: location
  properties: runCommandProperties!
}

resource extension 'Microsoft.Compute/virtualMachines/extensions@2024-11-01' = if (dscSettings != null) {
  dependsOn: [
    runcommand_increase_dsc_quota
    runcommand
  ]
  parent: virtualMachine
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
output virtualMachineName string = virtualMachine.name

// output virtualMachinePublicDomainName string = virtualMachine.properties.dnsSettings.fqdn
// output virtualMachinePublicIP string = virtualMachine.properties.dnsSettings.ipAddress
// output virtualMachinePublicDomainName string = virtualMachine.properties.networkProfile.networkInterfaces[0].properties.dnsSettings.fqdn
