@description('The prefix name of machines. ')
@minLength(2)
@maxLength(12)
param prefix string

@description('The number of clients to create.')
@allowed([
  0
  1
  2
  3
])
param clientsCount int = 0

@description('The name of the administrator account of the new VM. The domain name is contoso.com ')
@minLength(2)
@maxLength(13)
param adminUsername string

@description('Input must meet password complexity requirements as documented for property \'adminPassword\' in https://docs.microsoft.com/en-us/rest/api/compute/virtualmachines/virtualmachines-create-or-update')
@minLength(8)
@secure()
param adminPassword string

@description('The base URI where artifacts required by this template are located including a trailing \'/\'')
param artifactsLocation string = deployment().properties.templateLink.uri

@description('The sasToken required to access _artifactsLocation.  When the template is deployed using the accompanying scripts, a sasToken will be automatically generated. Use the defaultValue if the staging location is not secured.')
@secure()
param artifactsLocationSasToken string = ''

@description('Location for all resources.')
param location string = resourceGroup().location

@description('Domain Controller VM size')
param vmSize string = 'Standard_B2s'

@description('SQL VM size')
param sqlVmSize string = 'Standard_B2ms'

var dscScript = 'DSC/DCConfiguration.zip'
var virtualNetworkName = '${toLower(prefix)}-vnet'
var domainName = 'contoso.com'
var timeZone = 'UTC'
var networkSettings = {
  virtualNetworkAddressPrefix: '10.0.0.0/16'
  subnetAddressPrefix: '10.0.0.0/24'
  virtualMachinesIPAddress: '10.0.0.'
  subnetRef: resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetworkName, 'default')
  privateIPAllocationMethod: 'Static'
  publicIpAllocationMethod: 'Dynamic'
}
var securityGroupRuleName = 'default-allow-rdp'
var securityGroupRule = {
  priority: 1000
  sourceAddressPrefix: '*'
  protocol: 'Tcp'
  destinationPortRange: '3389'
  access: 'Allow'
  direction: 'Inbound'
  sourcePortRange: '*'
  destinationAddressPrefix: '*'
}
var vmInfoNoClient = {
  DC: {
    name: 'DC01'
    disktype: 'Premium_LRS'
    size: vmSize
    imageReference: {
      publisher: 'MicrosoftWindowsServer'
      offer: 'WindowsServer'
      sku: '2022-Datacenter'
      version: 'latest'
    }
  }
  DPMP: {
    name: 'DPMP01'
    disktype: 'Premium_LRS'
    size: vmSize
    imageReference: {
      publisher: 'MicrosoftWindowsServer'
      offer: 'WindowsServer'
      sku: '2019-Datacenter'
      version: 'latest'
    }
  }
}
var vmrole = [
  'DC'
  'DPMP'
]
var vmInfo = vmInfoNoClient
var siterole = [
  'PS'
]
var siteInfo = {
  PS: {
    name: 'PS01'
    disktype: 'Premium_LRS'
    size: sqlVmSize
    imageReference: {
      publisher: 'MicrosoftSQLServer'
      offer: 'SQL2019-WS2019'
      sku: 'Standard'
      version: 'latest'
    }
  }
}
var clientName = [for i in range(0, clientsCount): '${prefix}Cl0${(i + 1)}']
var clientRole = [for i in range(0, clientsCount): 'Client${(i + 1)}']
var clientInfo = [for i in range(0, clientsCount): json('{"Client${(i + 1)}":{"name": "Cl0${(i + 1)}","disktype": "Premium_LRS","size": "${vmSize}","imageReference": {"publisher": "MicrosoftWindowsDesktop","offer": "Windows-11","sku": "win11-22h2-ent","version": "latest"}}}')]

resource vm 'Microsoft.Compute/virtualMachines@2023-03-01' = [for i in range(0, ((length(vmInfo) + length(siteInfo)) + length(clientRole))): {
  name: '${toLower(prefix)}${toLower(((i < length(vmInfo)) ? vmInfo[vmrole[i]].name : ((i >= (length(vmInfo) + length(siteInfo))) ? clientInfo[(i - (length(vmInfo) + length(siteInfo)))][clientRole[(i - (length(vmInfo) + length(siteInfo)))]].name : siteInfo[siterole[(i - length(vmInfo))]].name)))}'
  location: location
  properties: {
    osProfile: {
      computerName: '${toLower(prefix)}${toLower(((i < length(vmInfo)) ? vmInfo[vmrole[i]].name : ((i >= (length(vmInfo) + length(siteInfo))) ? clientInfo[(i - (length(vmInfo) + length(siteInfo)))][clientRole[(i - (length(vmInfo) + length(siteInfo)))]].name : siteInfo[siterole[(i - length(vmInfo))]].name)))}'
      adminUsername: adminUsername
      adminPassword: adminPassword
      windowsConfiguration: {
        provisionVMAgent: true
        timeZone: timeZone
      }
    }
    hardwareProfile: {
      vmSize: ((i < length(vmInfo)) ? vmInfo[vmrole[i]].size : ((i >= (length(vmInfo) + length(siteInfo))) ? clientInfo[(i - (length(vmInfo) + length(siteInfo)))][clientRole[(i - (length(vmInfo) + length(siteInfo)))]].size : siteInfo[siterole[(i - length(vmInfo))]].size))
    }
    storageProfile: {
      imageReference: ((i < length(vmInfo)) ? vmInfo[vmrole[i]].imageReference : ((i >= (length(vmInfo) + length(siteInfo))) ? clientInfo[(i - (length(vmInfo) + length(siteInfo)))][clientRole[(i - (length(vmInfo) + length(siteInfo)))]].imageReference : siteInfo[siterole[(i - length(vmInfo))]].imageReference))
      osDisk: {
        osType: 'Windows'
        name: '${toLower(prefix)}${toLower(((i < length(vmInfo)) ? vmInfo[vmrole[i]].name : ((i >= (length(vmInfo) + length(siteInfo))) ? clientInfo[(i - (length(vmInfo) + length(siteInfo)))][clientRole[(i - (length(vmInfo) + length(siteInfo)))]].name : siteInfo[siterole[(i - length(vmInfo))]].name)))}-OsDisk'
        createOption: 'FromImage'
        caching: 'ReadWrite'
        managedDisk: {
          storageAccountType: ((i < length(vmInfo)) ? vmInfo[vmrole[i]].disktype : ((i >= (length(vmInfo) + length(siteInfo))) ? clientInfo[(i - (length(vmInfo) + length(siteInfo)))][clientRole[(i - (length(vmInfo) + length(siteInfo)))]].disktype : siteInfo[siterole[(i - length(vmInfo))]].disktype))
        }
        diskSizeGB: 150
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic[i].id
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: false
      }
    }
  }
  dependsOn: [
    nic[i]
  ]
}]

resource vmExtension 'Microsoft.Compute/virtualMachines/extensions@2023-03-01' = [for i in range(0, ((length(vmInfo) + length(siteInfo)) + length(clientRole))): {
  name: '${toLower(prefix)}${toLower(((i < length(vmInfo)) ? vmInfo[vmrole[i]].name : ((i >= (length(vmInfo) + length(siteInfo))) ? clientInfo[(i - (length(vmInfo) + length(siteInfo)))][clientRole[(i - (length(vmInfo) + length(siteInfo)))]].name : siteInfo[siterole[(i - length(vmInfo))]].name)))}/WorkFlow'
  location: location
  properties: {
    publisher: 'Microsoft.Powershell'
    type: 'DSC'
    typeHandlerVersion: '2.21'
    autoUpgradeMinorVersion: true
    settings: {
      modulesUrl: uri(artifactsLocation, '${dscScript}${artifactsLocationSasToken}')
      configurationFunction: ((i < length(vmInfo)) ? '${vmrole[i]}Configuration.ps1\\Configuration' : ((i < (length(vmInfo) + length(siteInfo))) ? '${siterole[(i - length(vmInfo))]}Configuration.ps1\\Configuration' : 'ClientConfiguration.ps1\\Configuration'))
      Properties: {
        DomainName: domainName
        DCName: '${prefix}${vmInfo.DC.name}'
        DPMPName: '${prefix}${vmInfo.DPMP.name}'
        PSName: '${prefix}${siteInfo.PS.name}'
        ClientName: ((clientsCount == 0) ? 'Empty' : clientName)
        DNSIPAddress: '${networkSettings.virtualMachinesIPAddress}${(int('0') + int('4'))}'
        AdminCreds: {
          UserName: adminUsername
          Password: 'PrivateSettingsRef:AdminPassword'
        }
      }
    }
    protectedSettings: {
      Items: {
        AdminPassword: adminPassword
      }
    }
  }
  dependsOn: [
    vm[i]
  ]
}]

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2023-04-01' = {
  name: virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        networkSettings.virtualNetworkAddressPrefix
      ]
    }
    subnets: [
      {
        name: 'default'
        properties: {
          addressPrefix: networkSettings.subnetAddressPrefix
        }
      }
    ]
  }
}

resource nic 'Microsoft.Network/networkInterfaces@2023-04-01' = [for i in range(0, ((length(vmInfo) + length(siteInfo)) + length(clientRole))): {
  name: '${toLower(prefix)}${toLower(((i < length(vmInfo)) ? vmInfo[vmrole[i]].name : ((i >= (length(vmInfo) + length(siteInfo))) ? clientInfo[(i - (length(vmInfo) + length(siteInfo)))][clientRole[(i - (length(vmInfo) + length(siteInfo)))]].name : siteInfo[siterole[(i - length(vmInfo))]].name)))}-ni'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetworkName, 'default')
          }
          privateIPAllocationMethod: networkSettings.privateIPAllocationMethod
          privateIPAddress: '${networkSettings.virtualMachinesIPAddress}${(i + int('4'))}'
          publicIPAddress: {
            id: publicIpAddress[i].id
          }
        }
      }
    ]
    networkSecurityGroup: {
      id: nsg.id
    }
  }
  dependsOn: [
    virtualNetwork
    publicIpAddress[i]
  ]
}]

resource publicIpAddress 'Microsoft.Network/publicIpAddresses@2023-04-01' = [for i in range(0, ((length(vmInfo) + length(siteInfo)) + length(clientRole))): {
  name: '${toLower(prefix)}${toLower(((i < length(vmInfo)) ? vmInfo[vmrole[i]].name : ((i >= (length(vmInfo) + length(siteInfo))) ? clientInfo[(i - (length(vmInfo) + length(siteInfo)))][clientRole[(i - (length(vmInfo) + length(siteInfo)))]].name : siteInfo[siterole[(i - length(vmInfo))]].name)))}-ip'
  location: location
  properties: {
    publicIPAllocationMethod: networkSettings.publicIpAllocationMethod
  }
}]

resource nsg 'Microsoft.Network/networkSecurityGroups@2023-04-01' = {
  name: '${toLower(prefix)}-nsg'
  location: location
  properties: {
    securityRules: [
      {
        name: securityGroupRuleName
        properties: securityGroupRule
      }
    ]
  }
}
