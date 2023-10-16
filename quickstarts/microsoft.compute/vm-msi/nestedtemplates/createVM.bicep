@description('The base URI where artifacts required by this template are located. When the template is deployed using the accompanying scripts, a private location in the subscription will be used and this value will be automatically generated.')
param _artifactsLocation string

@description('Security Type of the Virtual Machine.')
@allowed([
  'Standard'
  'TrustedLaunch'
])
param securityType string = 'TrustedLaunch'

@description('The sasToken required to access _artifactsLocation.')
@secure()
param _artifactsLocationSasToken string = ''

@description('OS Admin password or SSH Key depending on value of authentication type')
@secure()
param adminPasswordOrKey string

@description('Username for the Virtual Machine.')
param adminUsername string

@description('Authentication type')
@allowed([
  'password'
  'sshPublicKey'
])
param authenticationType string = 'password'

@description('The Docker image to rin the azure CLI from')
param azureCLI2DockerImage string = 'azuresdk/azure-cli-python:latest'
param containerName string

@description('The Location For the resources')
param location string

@description('The nsg id for the VM')
param nsgId string

@description('OS for the VM, this is the offer and SKU concatenated with underscores and then mapped to a variable')
param operatingSystem string

@description('determines whether to provision the extensions')
param provisionExtensions bool

@description('The storage account Id for boot diagnostics for the VMs')
param storageAccountId string

@description('The name of the storage account for the blob copy')
param storageAccountName string
param subnetRef string

@description('The size of the VM to create')
param vmSize string = 'Standard_D2s_v3'

@description('The name of the vm')
param vmName string

var extensionName = 'GuestAttestation'
var extensionVersion = '1.0'
var maaTenantName = 'GuestAttestation'
var securityProfileJson = {
  uefiSettings: {
    secureBootEnabled: true
    vTpmEnabled: true
  }
  securityType: securityType
}
var isWindowsOS = bool(contains(toLower(imageReference[operatingSystem].offer), 'windows'))
var linuxConfiguration = {
  disablePasswordAuthentication: true
  ssh: {
    publicKeys: [
      {
        path: '/home/${adminUsername}/.ssh/authorized_keys'
        keyData: adminPasswordOrKey
      }
    ]
  }
}
var imageReference = {
  'UbuntuServer_23_04-gen2': {
    publisher: 'Canonical'
    offer: '0001-com-ubuntu-server-lunar'
    sku: '23_04-gen2'
    version: 'latest'
  }
  'UbuntuServer_23_04-daily-gen2': {
    publisher: 'Canonical'
    offer: '0001-com-ubuntu-server-lunar-daily'
    sku: '23_04-daily-gen2'
    version: 'latest'
  }
  'WindowsServer_2022-datacenter-azure-edition': {
    publisher: 'MicrosoftWindowsServer'
    offer: 'WindowsServer'
    sku: '2022-datacenter-azure-edition'
    version: 'latest'
  }
  'WindowsServer_2022-datacenter-smalldisk-g2': {
    publisher: 'MicrosoftWindowsServer'
    offer: 'WindowsServer'
    sku: 'WindowsServer_2022-datacenter-smalldisk-g2'
    version: 'latest'
  }
}
var windowsConfiguration = {
  provisionVmAgent: 'true'
}
var publicIPAddressName = 'publicIp'
var nicName = 'nic'

resource publicIPAddress 'Microsoft.Network/publicIPAddresses@2023-05-01' = {
  name: publicIPAddressName
  location: location
  properties: {
    publicIPAllocationMethod: 'Dynamic'
  }
}

resource nic 'Microsoft.Network/networkInterfaces@2023-05-01' = {
  name: nicName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIPAddress.id
          }
          subnet: {
            id: subnetRef
          }
        }
      }
    ]
    networkSecurityGroup: {
      id: nsgId
    }
  }
}

resource vm 'Microsoft.Compute/virtualMachines@2023-07-01' = {
  name: vmName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: vmName
      adminUsername: adminUsername
      adminPassword: adminPasswordOrKey
      linuxConfiguration: ((authenticationType == 'password') ? null : linuxConfiguration)
      windowsConfiguration: (isWindowsOS ? windowsConfiguration : null)
    }
    storageProfile: {
      imageReference: imageReference[operatingSystem]
    }
    securityProfile: ((securityType == 'TrustedLaunch') ? securityProfileJson : null)
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
        storageUri: reference(storageAccountId, '2023-01-01').primaryEndpoints.blob
      }
    }
  }
}

resource guestAttestationWindows 'Microsoft.Compute/virtualMachines/extensions@2023-07-01' = if (isWindowsOS && ((securityType == 'TrustedLaunch') && ((securityProfileJson.uefiSettings.secureBootEnabled == true) && (securityProfileJson.uefiSettings.vTpmEnabled == true)))) {
  parent: vm
  name: 'GuestAttestation-windows'
  location: location
  properties: {
    publisher: 'Microsoft.Azure.Security.WindowsAttestation'
    type: extensionName
    typeHandlerVersion: extensionVersion
    autoUpgradeMinorVersion: true
    enableAutomaticUpgrade: true
    settings: {
      AttestationConfig: {
        MaaSettings: {
          maaEndpoint: ''
          maaTenantName: maaTenantName
        }
        AscSettings: {
          ascReportingEndpoint: ''
          ascReportingFrequency: ''
        }
        useCustomToken: 'false'
        disableAlerts: 'false'
      }
    }
  }
}

resource guestAttestationLinux 'Microsoft.Compute/virtualMachines/extensions@2023-07-01' = if ((!isWindowsOS) && ((securityType == 'TrustedLaunch') && ((securityProfileJson.uefiSettings.secureBootEnabled == true) && (securityProfileJson.uefiSettings.vTpmEnabled == true)))) {
  parent: vm
  name: 'GuestAttestation-linux'
  location: location
  properties: {
    publisher: 'Microsoft.Azure.Security.LinuxAttestation'
    type: extensionName
    typeHandlerVersion: extensionVersion
    autoUpgradeMinorVersion: true
    enableAutomaticUpgrade: true
    settings: {
      AttestationConfig: {
        MaaSettings: {
          maaEndpoint: ''
          maaTenantName: maaTenantName
        }
        AscSettings: {
          ascReportingEndpoint: ''
          ascReportingFrequency: ''
        }
        useCustomToken: 'false'
        disableAlerts: 'false'
      }
    }
  }
}

resource cseWindows 'Microsoft.Compute/virtualMachines/extensions@2023-07-01' = if (isWindowsOS && provisionExtensions) {
  parent: vm
  name: 'cse-windows'
  location: location
  properties: {
    publisher: 'Microsoft.Compute'
    type: 'CustomScriptExtension'
    typeHandlerVersion: '1.10'
    autoUpgradeMinorVersion: true
    settings: {
      fileUris: [
        uri(_artifactsLocation, 'writeblob.ps1${_artifactsLocationSasToken}')
      ]
      commandToExecute: 'powershell -ExecutionPolicy Unrestricted -File  .\\writeblob.ps1  -SubscriptionId ${subscription().subscriptionId} -TenantId ${subscription().tenantId} -ResourceGroupName ${resourceGroup().name} -StorageAccountName ${storageAccountName} -ContainerName ${containerName} -Verbose'
    }
  }
}

resource cseLinux 'Microsoft.Compute/virtualMachines/extensions@2023-07-01' = if ((!isWindowsOS) && provisionExtensions) {
  parent: vm
  name: 'cse-linux'
  location: location
  properties: {
    publisher: 'Microsoft.Azure.Extensions'
    type: 'CustomScript'
    typeHandlerVersion: '2.0'
    autoUpgradeMinorVersion: true
    settings: {
      fileUris: [
        uri(_artifactsLocation, 'scripts/writeblob.sh${_artifactsLocationSasToken}')
        uri(_artifactsLocation, 'scripts/install-and-run-cli-2.sh${_artifactsLocationSasToken}')
      ]
    }
    protectedSettings: {
      commandToExecute: './install-and-run-cli-2.sh -i "${azureCLI2DockerImage}" -a "${storageAccountName}" -c "${containerName}" -r "${resourceGroup().name}"'
    }
  }
}

output principalId string = vm.identity.principalId
output linuxTest bool = ((!isWindowsOS) && provisionExtensions)
output windowsTest bool = (isWindowsOS && provisionExtensions)
