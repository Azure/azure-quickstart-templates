@description('Name of the virtual machine.')
param vmName string = 'myTVM'

@description('The OS SKU for the virtual machine. This will pick a fully patched image of the given OS SKU.')
@allowed([
  'RS1-EnterpriseN-G2'
  'RS5-EnterpriseN-Standard-G2'
  'RS5-EnterpriseN-G2'
  '19H2-Ent-G2'
  '20H2-ProN-G2'
  '20H1-ProN-G2'
  '20H1-Pro-ZH-CN-G2'
  '20H2-Pro-G2'
  '20H2-Ent-G2'
  '20H1-Pro-G2'
  '19H2-Pro-G2'
  '20H1-Ent-G2'
  '20H2-Pro-ZH-CN-G2'
  '19H2-EntN-G2'
  '19H2-Pro-ZH-CN-G2'
  '19H2-ProN-G2'
  '20H2-EntN-G2'
  '20H1-EntN-G2'
  'RS5-Enterprise-Standard-G2'
  'RS5-Enterprise-G2'
  'RS1-Enterprise-G2'
  'DataCenter-Core-1909-With-Containers-Smalldisk-G2'
  '2016-DataCenter-With-Containers-G2'
  '2019-DataCenter-GenSecond'
  'DataCenter-Core-2004-With-Containers-Smalldisk-G2'
  '2019-DataCenter-Core-G2'
  '2019-DataCenter-Core-Smalldisk-G2'
  '2016-DataCenter-ZHCN-G2'
  'DataCenter-Core-20H2-With-Containers-Smalldisk-G2'
  '2016-DataCenter-GenSecond'
  '2016-DataCenter-Server-Core-Smalldisk-G2'
  '2019-DataCenter-Smalldisk-G2'
  '2016-DataCenter-Server-Core-G2'
  '2016-DataCenter-Smalldisk-G2'
  '2019-DataCenter-Core-With-Containers-Smalldisk-G2'
  '2019-DataCenter-ZHCN-G2'
  '2019-DataCenter-Core-With-Containers-G2'
  '2019-DataCenter-With-Containers-Smalldisk-G2'
  '2019-DataCenter-With-Containers-G2'
  '2022-datacenter-azure-edition'
  '2022-datacenter-azure-edition-core'
  '2022-datacenter-azure-edition-core-smalldisk'
  '2022-datacenter-azure-edition-smalldisk'
  '2022-datacenter-core-g2'
  '2022-datacenter-core-smalldisk-g2'
  '2022-datacenter-g2'
  '2022-datacenter-smalldisk-g2'
])
param sku string = '2022-datacenter-azure-edition'

@description('Size of the virtual machine.')
param vmSize string = 'Standard_D2s_v3'

@description('Username for the virtual machine.')
param adminUsername string

@description('Password for the virtual machine.')
@minLength(12)
@secure()
param adminPassword string

@description('Secure Boot setting of the virtual machine.')
param secureBoot bool = true

@description('vTPM setting of the virtual machine.')
param vTPM bool = true

@description('Location for all resources.')
param location string = resourceGroup().location

@description('Unique DNS Name for the Public IP used to access the virtual machine.')
param dnsLabelPrefix string = toLower('${vmName}-${uniqueString(resourceGroup().id)}')

@description('Name for the Public IP used to access the virtual machine.')
param publicIpName string = 'myPublicIP'

@description('Allocation method for the Public IP used to access the virtual machine.')
@allowed([
  'Dynamic'
  'Static'
])
param publicIPAllocationMethod string = 'Dynamic'

@description('SKU for the Public IP used to access the virtual machine.')
@allowed([
  'Basic'
  'Standard'
])
param publicIpSku string = 'Basic'

@description('Name of the network interface')
param nicName string = 'nic'

@description('Name of the virtual network')
param virtualNetworkName string = 'vnet'

@description('Name of the network security group')
param networkSecurityGroupName string = 'nsg'

@description('Custom Attestation Endpoint to attest to. By default, MAA and ASC endpoints are empty and Azure values are populated based on the location of the VM.')
param maaEndpoint string = ''

var imageReference = {
  'RS1-EnterpriseN-G2': {
    publisher: 'MicrosoftWindowsDesktop'
    offer: 'Windows-10'
    sku: sku
    version: 'latest'
  }
  'RS5-EnterpriseN-Standard-G2': {
    publisher: 'MicrosoftWindowsDesktop'
    offer: 'Windows-10'
    sku: sku
    version: 'latest'
  }
  'RS5-EnterpriseN-G2': {
    publisher: 'MicrosoftWindowsDesktop'
    offer: 'Windows-10'
    sku: sku
    version: 'latest'
  }
  '19H2-Ent-G2': {
    publisher: 'MicrosoftWindowsDesktop'
    offer: 'Windows-10'
    sku: sku
    version: 'latest'
  }
  '20H2-ProN-G2': {
    publisher: 'MicrosoftWindowsDesktop'
    offer: 'Windows-10'
    sku: sku
    version: 'latest'
  }
  '20H1-ProN-G2': {
    publisher: 'MicrosoftWindowsDesktop'
    offer: 'Windows-10'
    sku: sku
    version: 'latest'
  }
  '20H1-Pro-ZH-CN-G2': {
    publisher: 'MicrosoftWindowsDesktop'
    offer: 'Windows-10'
    sku: sku
    version: 'latest'
  }
  '20H2-Pro-G2': {
    publisher: 'MicrosoftWindowsDesktop'
    offer: 'Windows-10'
    sku: sku
    version: 'latest'
  }
  '20H2-Ent-G2': {
    publisher: 'MicrosoftWindowsDesktop'
    offer: 'Windows-10'
    sku: sku
    version: 'latest'
  }
  '20H1-Pro-G2': {
    publisher: 'MicrosoftWindowsDesktop'
    offer: 'Windows-10'
    sku: sku
    version: 'latest'
  }
  '19H2-Pro-G2': {
    publisher: 'MicrosoftWindowsDesktop'
    offer: 'Windows-10'
    sku: sku
    version: 'latest'
  }
  '20H1-Ent-G2': {
    publisher: 'MicrosoftWindowsDesktop'
    offer: 'Windows-10'
    sku: sku
    version: 'latest'
  }
  '20H2-Pro-ZH-CN-G2': {
    publisher: 'MicrosoftWindowsDesktop'
    offer: 'Windows-10'
    sku: sku
    version: 'latest'
  }
  '19H2-EntN-G2': {
    publisher: 'MicrosoftWindowsDesktop'
    offer: 'Windows-10'
    sku: sku
    version: 'latest'
  }
  '19H2-Pro-ZH-CN-G2': {
    publisher: 'MicrosoftWindowsDesktop'
    offer: 'Windows-10'
    sku: sku
    version: 'latest'
  }
  '19H2-ProN-G2': {
    publisher: 'MicrosoftWindowsDesktop'
    offer: 'Windows-10'
    sku: sku
    version: 'latest'
  }
  '20H2-EntN-G2': {
    publisher: 'MicrosoftWindowsDesktop'
    offer: 'Windows-10'
    sku: sku
    version: 'latest'
  }
  '20H1-EntN-G2': {
    publisher: 'MicrosoftWindowsDesktop'
    offer: 'Windows-10'
    sku: sku
    version: 'latest'
  }
  'RS5-Enterprise-Standard-G2': {
    publisher: 'MicrosoftWindowsDesktop'
    offer: 'Windows-10'
    sku: sku
    version: 'latest'
  }
  'RS5-Enterprise-G2': {
    publisher: 'MicrosoftWindowsDesktop'
    offer: 'Windows-10'
    sku: sku
    version: 'latest'
  }
  'RS1-Enterprise-G2': {
    publisher: 'MicrosoftWindowsDesktop'
    offer: 'Windows-10'
    sku: sku
    version: 'latest'
  }
  'DataCenter-Core-1909-With-Containers-Smalldisk-G2': {
    publisher: 'MicrosoftWindowsServer'
    offer: 'WindowsServer'
    sku: sku
    version: 'latest'
  }
  '2016-DataCenter-With-Containers-G2': {
    publisher: 'MicrosoftWindowsServer'
    offer: 'WindowsServer'
    sku: sku
    version: 'latest'
  }
  '2019-DataCenter-GenSecond': {
    publisher: 'MicrosoftWindowsServer'
    offer: 'WindowsServer'
    sku: sku
    version: 'latest'
  }
  'DataCenter-Core-2004-With-Containers-Smalldisk-G2': {
    publisher: 'MicrosoftWindowsServer'
    offer: 'WindowsServer'
    sku: sku
    version: 'latest'
  }
  '2019-DataCenter-Core-G2': {
    publisher: 'MicrosoftWindowsServer'
    offer: 'WindowsServer'
    sku: sku
    version: 'latest'
  }
  '2019-DataCenter-Core-Smalldisk-G2': {
    publisher: 'MicrosoftWindowsServer'
    offer: 'WindowsServer'
    sku: sku
    version: 'latest'
  }
  '2016-DataCenter-ZHCN-G2': {
    publisher: 'MicrosoftWindowsServer'
    offer: 'WindowsServer'
    sku: sku
    version: 'latest'
  }
  'DataCenter-Core-20H2-With-Containers-Smalldisk-G2': {
    publisher: 'MicrosoftWindowsServer'
    offer: 'WindowsServer'
    sku: sku
    version: 'latest'
  }
  '2016-DataCenter-GenSecond': {
    publisher: 'MicrosoftWindowsServer'
    offer: 'WindowsServer'
    sku: sku
    version: 'latest'
  }
  '2016-DataCenter-Server-Core-Smalldisk-G2': {
    publisher: 'MicrosoftWindowsServer'
    offer: 'WindowsServer'
    sku: sku
    version: 'latest'
  }
  '2019-DataCenter-Smalldisk-G2': {
    publisher: 'MicrosoftWindowsServer'
    offer: 'WindowsServer'
    sku: sku
    version: 'latest'
  }
  '2016-DataCenter-Server-Core-G2': {
    publisher: 'MicrosoftWindowsServer'
    offer: 'WindowsServer'
    sku: sku
    version: 'latest'
  }
  '2016-DataCenter-Smalldisk-G2': {
    publisher: 'MicrosoftWindowsServer'
    offer: 'WindowsServer'
    sku: sku
    version: 'latest'
  }
  '2019-DataCenter-Core-With-Containers-Smalldisk-G2': {
    publisher: 'MicrosoftWindowsServer'
    offer: 'WindowsServer'
    sku: sku
    version: 'latest'
  }
  '2019-DataCenter-ZHCN-G2': {
    publisher: 'MicrosoftWindowsServer'
    offer: 'WindowsServer'
    sku: sku
    version: 'latest'
  }
  '2019-DataCenter-Core-With-Containers-G2': {
    publisher: 'MicrosoftWindowsServer'
    offer: 'WindowsServer'
    sku: sku
    version: 'latest'
  }
  '2019-DataCenter-With-Containers-Smalldisk-G2': {
    publisher: 'MicrosoftWindowsServer'
    offer: 'WindowsServer'
    sku: sku
    version: 'latest'
  }
  '2019-DataCenter-With-Containers-G2': {
    publisher: 'MicrosoftWindowsServer'
    offer: 'WindowsServer'
    sku: sku
    version: 'latest'
  }
  '2022-datacenter-azure-edition': {
    publisher: 'MicrosoftWindowsServer'
    offer: 'WindowsServer'
    sku: sku
    version: 'latest'
  }
  '2022-datacenter-azure-edition-core': {
    publisher: 'MicrosoftWindowsServer'
    offer: 'WindowsServer'
    sku: sku
    version: 'latest'
  }
  '2022-datacenter-azure-edition-core-smalldisk': {
    publisher: 'MicrosoftWindowsServer'
    offer: 'WindowsServer'
    sku: sku
    version: 'latest'
  }
  '2022-datacenter-azure-edition-smalldisk': {
    publisher: 'MicrosoftWindowsServer'
    offer: 'WindowsServer'
    sku: sku
    version: 'latest'
  }
  '2022-datacenter-core-g2': {
    publisher: 'MicrosoftWindowsServer'
    offer: 'WindowsServer'
    sku: sku
    version: 'latest'
  }
  '2022-datacenter-core-smalldisk-g2': {
    publisher: 'MicrosoftWindowsServer'
    offer: 'WindowsServer'
    sku: sku
    version: 'latest'
  }
  '2022-datacenter-g2': {
    publisher: 'MicrosoftWindowsServer'
    offer: 'WindowsServer'
    sku: sku
    version: 'latest'
  }
  '2022-datacenter-smalldisk-g2': {
    publisher: 'MicrosoftWindowsServer'
    offer: 'WindowsServer'
    sku: sku
    version: 'latest'
  }
}
var addressPrefix = '10.0.0.0/16'
var disableAlerts = 'false'
var extensionName = 'GuestAttestation'
var extensionPublisher = 'Microsoft.Azure.Security.WindowsAttestation'
var extensionVersion = '1.0'
var maaTenantName = 'GuestAttestation'
var subnetName = 'Subnet'
var subnetPrefix = '10.0.0.0/24'
var subnetRef = resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetworkName, subnetName)
var useAlternateToken = 'false'

resource publicIp 'Microsoft.Network/publicIPAddresses@2022-05-01' = {
  name: publicIpName
  location: location
  sku: {
    name: publicIpSku
  }
  properties: {
    publicIPAllocationMethod: publicIPAllocationMethod
    dnsSettings: {
      domainNameLabel: dnsLabelPrefix
    }
  }
}

resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2022-05-01' = {
  name: networkSecurityGroupName
  location: location
  properties: {
    securityRules: [
      {
        name: 'default-allow-3389'
        properties: {
          priority: 1000
          access: 'Allow'
          direction: 'Inbound'
          destinationPortRange: '3389'
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2022-05-01' = {
  name: virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressPrefix
      ]
    }
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: subnetPrefix
          networkSecurityGroup: {
            id: networkSecurityGroup.id
          }
        }
      }
    ]
  }
}

resource nic 'Microsoft.Network/networkInterfaces@2022-05-01' = {
  name: nicName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIp.id
          }
          subnet: {
            id: subnetRef
          }
        }
      }
    ]
  }
  dependsOn: [

    virtualNetwork
  ]
}

resource vm 'Microsoft.Compute/virtualMachines@2022-03-01' = {
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
      adminPassword: adminPassword
    }
    storageProfile: {
      imageReference: imageReference[sku]
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'StandardSSD_LRS'
        }
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }
    securityProfile: {
      uefiSettings: {
        secureBootEnabled: secureBoot
        vTpmEnabled: vTPM
      }
      securityType: 'TrustedLaunch'
    }
  }
}

resource vmExtension 'Microsoft.Compute/virtualMachines/extensions@2022-03-01' = if (vTPM && secureBoot) {
  parent: vm
  name: extensionName
  location: location
  properties: {
    publisher: extensionPublisher
    type: extensionName
    typeHandlerVersion: extensionVersion
    autoUpgradeMinorVersion: true
    enableAutomaticUpgrade: true
    settings: {
      AttestationConfig: {
        MaaSettings: {
          maaEndpoint: maaEndpoint
          maaTenantName: maaTenantName
        }
        AscSettings: {
          ascReportingEndpoint: substring(maaEndpoint, 0, 0)
          ascReportingFrequency: substring(maaEndpoint, 0, 0)
        }
        useCustomToken: useAlternateToken
        disableAlerts: disableAlerts
      }
    }
  }
}

output hostname string = reference(publicIp.id, '2022-05-01').dnsSettings.fqdn
