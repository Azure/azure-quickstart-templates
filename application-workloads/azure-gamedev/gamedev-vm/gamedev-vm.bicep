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

@description('Public IP New or Existing or None?')
param publicIpNewOrExisting string = 'new'

@description('Resource Group of the Public IP Address')
param publicIpRGName string = resourceGroup().name

@allowed([
  'development'
  'production'
])
param environment string = 'production'

@description('Tags by resource.')
param outTagsByResource object = {}

@description('The base URI where artifacts required by this template are located including a trailing \'/\'')
param _artifactsLocation string = deployment().properties.templateLink.uri

@description('The sasToken required to access _artifactsLocation.')
@secure()
param _artifactsLocationSasToken string = ''

@description('Enable or disable Unreal Pixel Streaming port.')
param unrealPixelStreamingEnabled bool = false

param enableManagedIdentity bool = false
param enableAAD             bool = false

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

var vmName_var = vmName
var ipconfName = '${vmName_var}-ipconf'
var nicName_var = '${vmName_var}-nic'
var nsgName_var = '${vmName_var}-nsg'

var storageType_var = (bool(length(split(vmSize, '_')) > 2) ? 'Premium_LRS' : 'Standard_LRS')

var tags_var = {
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

var vnetId = {
  'new'     : resourceId('Microsoft.Network/virtualNetworks', vnetName)
  'existing': resourceId(vnetRGName, 'Microsoft.Network/virtualNetworks', vnetName)
}
var subnetId = '${vnetId[vnetNewOrExisting]}/subnets/${subNetName}'

var publicIpId = {
  'new': resourceId('Microsoft.Network/publicIPAddresses', publicIpName)
  'existing': resourceId(publicIpRGName, 'Microsoft.Network/publicIPAddresses', publicIpName) 
  'none': ''
}[publicIpNewOrExisting]

resource partnercenter 'Microsoft.Resources/deployments@2020-06-01' = {
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

resource publicIp 'Microsoft.Network/publicIPAddresses@2021-03-01' = if (publicIpNewOrExisting == 'new') {
  name: publicIpName
  sku: {
    name: publicIpSku
  }
  location: location
  properties: {
    publicIPAllocationMethod: publicIpAllocationMethod
    dnsSettings: {
      domainNameLabel: publicIpDns
    }
  }
}

module nsg_rules 'nsgRules.bicep' = {
  name: 'nsg_rules'
  params: {
    addPixelStreamingPorts: unrealPixelStreamingEnabled
  }
}

resource nsg 'Microsoft.Network/networkSecurityGroups@2021-03-01' = {
  name: nsgName_var
  location: location
  properties: {
    securityRules: nsg_rules.outputs.nsgRules['nsgRules-${remoteAccessTechnology}']
  }
}

resource vnet 'Microsoft.Network/virtualNetworks@2021-03-01' = if (vnetNewOrExisting == 'new') {
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

resource nic 'Microsoft.Network/networkInterfaces@2021-03-01' = {
  name: nicName_var
  location: location
  dependsOn: [
    vnet
  ]
  properties: {
    enableAcceleratedNetworking: (bool(length(split(vmSize, '_')) > 2) ? true : false)
    ipConfigurations: [
      {
        name: ipconfName
        properties: union( {
              subnet: { 
                id: subnetId
              }
            }, { 
              privateIPAllocationMethod: 'Dynamic' 
            }, (!empty(publicIpId)) ? { 
              publicIPAddress: {
                id: publicIpId
              }
            } : {} )
      }
    ]
    networkSecurityGroup: {
      id: nsg.id
    }
  }
}

resource virtualMachine 'Microsoft.Compute/virtualMachines@2021-03-01' = {
  name: vmName_var
  location: location
  plan: vmPlan
  identity: enableAAD || enableManagedIdentity ? {
    type: 'systemAssigned'
  } : null
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    storageProfile: {
      imageReference: vmImage
      osDisk: {
        name: '${vmName_var}-osdisk'
        createOption: 'FromImage'
        caching: 'ReadWrite'
        diskSizeGB: 255
        managedDisk: {
          storageAccountType: storageType_var
        }
      }
      dataDisks: [for i in range(0, numDataDisks): {
        lun: i
        createOption: 'Empty'
        diskSizeGB: dataDiskSize
      }]
    }
    osProfile: {
      computerName: vmName_var
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
  tags: (contains(outTagsByResource, 'Microsoft.Compute/virtualMachines') ? union(tags_var, outTagsByResource['Microsoft.Compute/virtualMachines']) : tags_var)
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

resource virtualMachine_enableAAD 'Microsoft.Compute/virtualMachines/extensions@2019-12-01' = if(enableAAD) {
  name      : '${virtualMachine.name}/AADLoginForWindows'
  location  : location
  dependsOn : [
    remoteAccess
  ]
  properties: {
    publisher: 'Microsoft.Azure.ActiveDirectory'
    type: 'AADLoginForWindows'
    typeHandlerVersion: '1.0'
    autoUpgradeMinorVersion: true
  }
}

output Host_Name string = (!empty(publicIpId) ? reference(publicIpId, '2021-03-01').dnsSettings.fqdn : '')
output UserName string = adminName
output IPAddress string = (!empty(publicIpId) ? publicIpId : '')
