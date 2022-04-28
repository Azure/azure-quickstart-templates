@description('Resource Location.')
param location string = resourceGroup().location

@description('Virtual Machine Size.')
param vmSize string = 'Standard_NV12s_v3'

@description('Virtual Machine Name.')
param vmName string = 'gamedevvm'

@description('Virtual Machine User Name .')
param adminName string

@metadata({
  type: 'password'
  description: 'Admin password.'
})
@secure()
param adminPass string

@description('Operating System type')
param osType string = 'win10'

@description('Game Engine')
@allowed([
  'ue_4_27'
  'ue_5_0ea'
  'unity_2020_3_19f1'
])
param gameEngine string = 'ue_4_27'

@description('GDK Version')
param gdkVersion string = 'June_2021_Update_4'

@description('Incredibuild License Key')
@secure()
param ibLicenseKey string = ''

@description('Remote Access technology')
@allowed([
  'RDP'
  'Teradici'
  'Parsec'
])
param remoteAccessTechnology string = 'RDP'

@description('Teradici Registration Key')
@secure()
param teradiciRegKey string = ''

@description('Parsec Team ID')
param parsec_teamId string = ''

@description('Parsec Team Key')
@secure()
param parsec_teamKey string = ''

@description('Parsec Hostname')
param parsec_host string = ''

@description('Parsec User Email')
param parsec_userEmail string = ''

@description('Parsec Is Guest Access')
param parsec_isGuestAccess bool = false

@description('Number of data disks')
param numDataDisks int = 0

@description('Disk Performance Tier')
param dataDiskSize int = 1024

@description('File Share Storage Account name')
param fileShareStorageAccount string = ''

@description('File Share Storage Account key')
@secure()
param fileShareStorageAccountKey string = ''

@description('File Share name')
param fileShareName string = ''

@description('Perforce Port address')
param p4Port string = ''

@description('Perforce User')
param p4Username string = ''

@description('Perforce User password')
@secure()
param p4Password string = ''

@description('Perforce Client Workspace')
param p4Workspace string = ''

@description('Perforce Stream')
param p4Stream string = ''

@description('Perforce Depot Client View mappings')
param p4ClientViews string = ''

@description('Virtual Network name')
param vnetName string = 'gamedev-vnet'

@description('Address prefix of the virtual network')
param vnetARPrefixes array = [
  '10.0.0.0/26'
]

@description('Virtual network is new or existing')
param vnetNewOrExisting string = 'new'

@description('Resource Group of the Virtual network')
param vnetRGName string = resourceGroup().name

@description('VM Subnet name')
param subNetName string = 'gamedev-vnet-subnet1'

@description('Subnet prefix of the virtual network')
param subNetARPrefix string = '10.0.0.0/28'

@description('Unique public ip address name')
param publicIpName string = 'GameDevVM-IP'

@description('Unique DNS Public IP attached the VM')
param publicIpDns string = 'gamedevvm${uniqueString(resourceGroup().id)}'

@description('Public IP Allocoation Method')
param publicIpAllocationMethod string = 'Dynamic'

@description('SKU number')
@allowed([
  'Basic'
  'Standard'
])
param publicIpSku string = 'Basic'

@description('Public IP With or None?')
@allowed([
  'new'
  'existing'
  'none'
])
param publicIpNewOrExisting string = 'new'

@description('Resource Group of the Public IP Address')
param publicIpRGName string = resourceGroup().name

@description('Select Image Deployment for debugging only')
@allowed([
  'development'
  'production'
])
param environment string = 'production'

@description('Tags by resource.')
param outTagsByResource object = {}

@description('The base URI where artifacts required by this template are located including a trailing \'/\'')
param _artifactsLocation string = deployment().properties.templateLink.id

@description('The sasToken required to access _artifactsLocation.')
@secure()
param _artifactsLocationSasToken string = ''

@description('Enable or disable Unreal Pixel Streaming port.')
param unrealPixelStreamingEnabled bool = false

@description('Enable Managed Identity')
param enableManagedIdentity bool = false

@description('Enable Azure Active Directory Login')
param enableAAD bool = false

var environmentMapping = {
  ue_4_27: 'unreal_4_27'
  ue_5_0ea: 'unreal_5_0ea'
  unity_2020_3_19f1: 'unity_2020_3_19f1'
}

var environments = {
  development: {
    vmImage: {
      publisher: 'microsoft-agci-gaming'
      offer: 'agci-gamedev-image'
      sku: 'gamedev-${gameEngine}-${osType}'
      version: 'latest'
    }
    vmPlan: {
      publisher: 'microsoft-agci-gaming'
      product: 'agci-gamedev-image'
      name: 'gamedev-${gameEngine}-${osType}'
    }
  }
  production: {
    vmImage: {
      publisher: 'microsoftcorporation1602274591143'
      offer: 'game-dev-vm'
      sku: '${osType}_${environmentMapping[gameEngine]}'
      version: 'latest'
    }
    vmPlan: {
      publisher: 'microsoftcorporation1602274591143'
      product: 'game-dev-vm'
      name: '${osType}_${environmentMapping[gameEngine]}'
    }
  }
}

var vmImage = environments[environment].vmImage
var vmPlan = environments[environment].vmPlan

var ipconfName = '${vmName}-ipconf'
var nicName = '${vmName}-nic'
var nsgName = '${vmName}-nsg'

var storageType = (bool(length(split(vmSize, '_')) > 2) ? 'Premium_LRS' : 'Standard_LRS')

var tags = {
  'solution': 'Game Development Virtual Machine'
  'engine': gameEngine
  'ostype': osType
  'remotesoftware': remoteAccessTechnology
}

var cmdGDKInstall = '(Get-Content \'C:\\ProgramData\\Microsoft\\Windows\\Start Menu\\Programs\\Startup\\gdkinstall.cmd\').replace(\'[VERSION]\', \'${gdkVersion}\') | Set-Content \'C:\\ProgramData\\Microsoft\\Windows\\Start Menu\\Programs\\Startup\\gdkinstall.cmd\''
var userData = 'team_id=${parsec_teamId}:key=${parsec_teamKey}:name=${parsec_host}:user_email=${parsec_userEmail}:is_guest_access=${parsec_isGuestAccess}:ibLicenseKey=${ibLicenseKey}'
var Script2Run = 'TeradiciRegCAS.ps1'
var CSEParams = ' -pcoip_registration_code ${teradiciRegKey}'
var cmdTeradiciRegistration = './${Script2Run}${CSEParams}'

resource partnercenter 'Microsoft.Resources/deployments@2021-04-01' = {
  name: 'pid-7837dd60-4ba8-419a-a26f-237bbe170773-partnercenter'
  properties: {
    mode: 'Incremental'
    template: {
      '$schema': 'https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#'
      contentVersion: '1.0.0.0'
      resources: []
    }
  }
}

resource publicIp 'Microsoft.Network/publicIPAddresses@2021-05-01' = if (publicIpNewOrExisting == 'new') {
  name: publicIpName
  location: location
  sku: {
    name: publicIpSku
  }
  properties: {
    publicIPAllocationMethod: publicIpAllocationMethod
    dnsSettings: {
      domainNameLabel: publicIpDns
    }
  }
}

resource nsg 'Microsoft.Network/networkSecurityGroups@2021-05-01' = {
  name: nsgName
  location: location
  properties: {
    securityRules: {
      'nsgRules-RDP': !unrealPixelStreamingEnabled ? [
        {
          name: 'RDP'
          properties: {
            priority: 1010
            protocol: '*'
            access: 'Allow'
            direction: 'Inbound'
            sourceAddressPrefix: '*'
            sourcePortRange: '*'
            destinationAddressPrefix: '*'
            destinationPortRange: '3389'
          }
        }
      ] : [
        {
          name: 'RDP'
          properties: {
            priority: 1010
            protocol: '*'
            access: 'Allow'
            direction: 'Inbound'
            sourceAddressPrefix: '*'
            sourcePortRange: '*'
            destinationAddressPrefix: '*'
            destinationPortRange: '3389'
          }
        }
        {
          name: 'PixelStream'
          properties: {
            priority: 1020
            protocol: '*'
            access: 'Allow'
            direction: 'Inbound'
            sourceAddressPrefix: '*'
            sourcePortRange: '*'
            destinationAddressPrefix: '*'
            destinationPortRange: '80'
          }
        }
      ]
      'nsgRules-Teradici': !unrealPixelStreamingEnabled ? [
        {
          name: 'RDP'
          properties: {
            priority: 1010
            protocol: '*'
            access: 'Allow'
            direction: 'Inbound'
            sourceAddressPrefix: '*'
            sourcePortRange: '*'
            destinationAddressPrefix: '*'
            destinationPortRange: '3389'
          }
        }
        {
          name: 'PCoIPtcp'
          properties: {
            priority: 1020
            protocol: 'TCP'
            access: 'Allow'
            direction: 'Inbound'
            sourceAddressPrefix: '*'
            sourcePortRange: '*'
            destinationAddressPrefix: '*'
            destinationPortRange: '4172'
          }
        }
        {
          name: 'PCoIPudp'
          properties: {
            priority: 1030
            protocol: 'UDP'
            access: 'Allow'
            direction: 'Inbound'
            sourceAddressPrefix: '*'
            sourcePortRange: '*'
            destinationAddressPrefix: '*'
            destinationPortRange: '4172'
          }
        }
        {
          name: 'CertAuthHTTPS'
          properties: {
            priority: 1040
            protocol: 'TCP'
            access: 'Allow'
            direction: 'Inbound'
            sourceAddressPrefix: '*'
            sourcePortRange: '*'
            destinationAddressPrefix: '*'
            destinationPortRange: '443'
          }
        }
        {
          name: 'TeradiciCom'
          properties: {
            priority: 1050
            protocol: 'TCP'
            access: 'Allow'
            direction: 'Inbound'
            sourceAddressPrefix: '*'
            sourcePortRange: '*'
            destinationAddressPrefix: '*'
            destinationPortRange: '60443'
          }
        }
      ] : [
        {
          name: 'RDP'
          properties: {
            priority: 1010
            protocol: '*'
            access: 'Allow'
            direction: 'Inbound'
            sourceAddressPrefix: '*'
            sourcePortRange: '*'
            destinationAddressPrefix: '*'
            destinationPortRange: '3389'
          }
        }
        {
          name: 'PCoIPtcp'
          properties: {
            priority: 1020
            protocol: 'TCP'
            access: 'Allow'
            direction: 'Inbound'
            sourceAddressPrefix: '*'
            sourcePortRange: '*'
            destinationAddressPrefix: '*'
            destinationPortRange: '4172'
          }
        }
        {
          name: 'PCoIPudp'
          properties: {
            priority: 1030
            protocol: 'UDP'
            access: 'Allow'
            direction: 'Inbound'
            sourceAddressPrefix: '*'
            sourcePortRange: '*'
            destinationAddressPrefix: '*'
            destinationPortRange: '4172'
          }
        }
        {
          name: 'CertAuthHTTPS'
          properties: {
            priority: 1040
            protocol: 'TCP'
            access: 'Allow'
            direction: 'Inbound'
            sourceAddressPrefix: '*'
            sourcePortRange: '*'
            destinationAddressPrefix: '*'
            destinationPortRange: '443'
          }
        }
        {
          name: 'TeradiciCom'
          properties: {
            priority: 1050
            protocol: 'TCP'
            access: 'Allow'
            direction: 'Inbound'
            sourceAddressPrefix: '*'
            sourcePortRange: '*'
            destinationAddressPrefix: '*'
            destinationPortRange: '60443'
          }
        }
        {
          name: 'PixelStream'
          properties: {
            priority: 1060
            protocol: '*'
            access: 'Allow'
            direction: 'Inbound'
            sourceAddressPrefix: '*'
            sourcePortRange: '*'
            destinationAddressPrefix: '*'
            destinationPortRange: '80'
          }
        }
      ]
      'nsgRules-Parsec': !unrealPixelStreamingEnabled ? [
        {
          name: 'RDP'
          properties: {
            priority: 1010
            protocol: '*'
            access: 'Allow'
            direction: 'Inbound'
            sourceAddressPrefix: '*'
            sourcePortRange: '*'
            destinationAddressPrefix: '*'
            destinationPortRange: '3389'
          }
        }
      ] : [
        {
          name: 'RDP'
          properties: {
            priority: 1010
            protocol: '*'
            access: 'Allow'
            direction: 'Inbound'
            sourceAddressPrefix: '*'
            sourcePortRange: '*'
            destinationAddressPrefix: '*'
            destinationPortRange: '3389'
          }
        }
        {
          name: 'PixelStream'
          properties: {
            priority: 1020
            protocol: '*'
            access: 'Allow'
            direction: 'Inbound'
            sourceAddressPrefix: '*'
            sourcePortRange: '*'
            destinationAddressPrefix: '*'
            destinationPortRange: '80'
          }
        }
      ]
    }['nsgRules-${remoteAccessTechnology}']
  }
}

resource vnet 'Microsoft.Network/virtualNetworks@2021-05-01' = if (vnetNewOrExisting == 'new') {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        first(vnetARPrefixes)
      ]
    }
    subnets: [
      {
        name: subNetName
        properties: {
          addressPrefix: subNetARPrefix
        }
      }
    ]
  }
}

resource nic 'Microsoft.Network/networkInterfaces@2021-05-01' = {
  name: nicName
  location: location
  dependsOn: [
    vnet
  ]
  properties: {
    enableAcceleratedNetworking: (bool(length(split(vmSize, '_')) > 2) ? true : false)
    ipConfigurations: [
      {
        name: ipconfName
        properties: {
          subnet: {
            id: resourceId(vnetRGName, 'Microsoft.Network/virtualNetworks/subnets', vnetName, subNetName)
          }
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: publicIpNewOrExisting == 'none' ? null: {
            id: resourceId(publicIpRGName, 'Microsoft.Network/publicIpAddresses', publicIpName)
          }
        }
      }
    ]
    networkSecurityGroup: {
      id: nsg.id
    }
  }
}

resource virtualMachine 'Microsoft.Compute/virtualMachines@2021-11-01' = {
  name: vmName
  location: location
  plan: vmPlan
  identity: enableAAD || enableManagedIdentity ? {
    type: 'systemAssigned'
  } : null
  tags: (contains(outTagsByResource, 'Microsoft.Compute/virtualMachines') ? union(tags, outTagsByResource['Microsoft.Compute/virtualMachines']) : tags)
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    storageProfile: {
      imageReference: vmImage
      osDisk: {
        name: '${vmName}-osdisk'
        createOption: 'FromImage'
        caching: 'ReadWrite'
        diskSizeGB: 255
        managedDisk: {
          storageAccountType: storageType
        }
      }
      dataDisks: [for i in range(0, numDataDisks): {
        lun: i
        createOption: 'Empty'
        diskSizeGB: dataDiskSize
      }]
    }
    osProfile: {
      computerName: vmName
      adminUsername: adminName
      adminPassword: adminPass
    }
    userData: base64(userData)
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }
  }
}

module remoteAccess 'remoteAccessExtension.bicep' = {
  name: 'runRemoteAccess'
  params: {
    cmdGDKInstall: cmdGDKInstall
    cmdTeradiciRegistration: cmdTeradiciRegistration
    _artifactsLocation: _artifactsLocation
    _artifactsLocationSasToken: _artifactsLocationSasToken
    virtualMachineName: virtualMachine.name
    remoteAccessTechnology: remoteAccessTechnology
    location: location
    fileShareStorageAccount: fileShareStorageAccount
    fileShareStorageAccountKey: fileShareStorageAccountKey
    fileShareName: fileShareName
    p4Port: p4Port
    p4Username: p4Username
    p4Password: p4Password
    p4Workspace: p4Workspace
    p4Stream: p4Stream
    p4ClientViews: p4ClientViews
  }
}

resource virtualMachine_enableAAD 'Microsoft.Compute/virtualMachines/extensions@2021-11-01' = if (enableAAD) {
  name: '${virtualMachine.name}/AADLoginForWindows'
  location: location
  dependsOn: [
    remoteAccess
  ]
  properties: {
    publisher: 'Microsoft.Azure.ActiveDirectory'
    type: 'AADLoginForWindows'
    typeHandlerVersion: '1.0'
    autoUpgradeMinorVersion: true
  }
}
