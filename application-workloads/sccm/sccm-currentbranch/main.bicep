@description('The prefix name of machines. ')
@minLength(2)
@maxLength(12)
param prefix string

@description('The number of clients to create.')
@allowed([
  1
  2
  3
])
param ClientsCount int = 1

@description('Configuration for the environment, support both standalone and hierarchy')
@allowed([
  'Standalone'
  'Hierarchy'
])
param configuration string = 'Standalone'

@description('Size of the Virtual Machines')
param vmSize string = 'Standard_B2s'

@description('The name of the administrator account of the new VM. The domain name is contoso.com ')
@minLength(2)
@maxLength(13)
param adminUsername string

@description('Input must meet password complexity requirements as documented for property \'adminPassword\' in https://docs.microsoft.com/en-us/rest/api/compute/virtualmachines/virtualmachines-create-or-update')
@minLength(8)
@secure()
param adminPassword string

@description('The base URI where artifacts required by this template are located including a trailing \'/\'')
param _artifactsLocation string = deployment().properties.templateLink.uri

@description('The sasToken required to access _artifactsLocation.  When the template is deployed using the accompanying scripts, a sasToken will be automatically generated. Use the defaultValue if the staging location is not secured. ')
@secure()
param _artifactsLocationSasToken string = ''

@description('Location for all resources.')
param location string = resourceGroup().location

@description('SQL VM size')
param SQLVmSize string = 'Standard_B2ms'

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
var vmrole = [
  'DC'
  'DPMP'
]
var vmInfo = {
  DC: {
    name: 'DC01'
    disktype: 'Premium_LRS'
    Size: vmSize
    imageReference: {
      publisher: 'MicrosoftWindowsServer'
      offer: 'WindowsServer'
      sku: '2022-datacenter'
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
      sku: '2022-datacenter'
      version: 'latest'
    }
  }
}
var siteRole = ((configuration == 'Standalone') ? [
  'PS'
] : [
  'CS'
  'PS'
])
var siteInfo = ((configuration == 'Standalone') ? json('{"PS":{"name":"PS01","DiskType":"Premium_LRS","size":"${SQLVmSize}","imageReference":{"publisher": "MicrosoftSQLServer","offer": "SQL2019-WS2019","sku": "Standard","version": "latest"}}}') : json('{"CS":{"name":"CS01","DiskType":"Premium_LRS","size":"${SQLVmSize}","imageReference":{"publisher": "MicrosoftSQLServer","offer": "SQL2019-WS2019","sku": "Standard","version": "latest"}},"PS":{"name":"PS01","DiskType":"Premium_LRS","size":"${SQLVmSize}","imageReference":{"publisher": "MicrosoftSQLServer","offer": "SQL2019-WS2019","sku": "Standard","version": "latest"}}}'))
var ClientName = [for i in range(0, ClientsCount): '${prefix}Cl0${(i + 1)}']
var clientRole = [for i in range(0, ClientsCount): 'Client${(i + 1)}']
var clientInfo = [for i in range(0, ClientsCount): json('{"Client${(i + 1)}":{"name": "Cl0${(i + 1)}","disktype": "Premium_LRS","size": "${vmSize}","imageReference": {"publisher": "MicrosoftWindowsDesktop","offer": "Windows-11","sku": "win11-23h2-ent","version": "latest"}}}')]

resource prefix_vmInfo_vmInfo_vmRole_name_vmInfo_siteInfo_clientInfo_vmInfo_siteInfo_clientRole_vmInfo_siteInfo_name_siteInfo_siteRole_vmInfo_name 'Microsoft.Compute/virtualMachines@2019-12-01' = [for i in range(0, ((length(vmInfo) + length(siteInfo)) + length(clientRole))): {
  name: concat(toLower(prefix), toLower(((i < length(vmInfo)) ? vmInfo[vmrole[i]].name : ((i >= (length(vmInfo) + length(siteInfo))) ? clientInfo[(i - (length(vmInfo) + length(siteInfo)))][clientRole[(i - (length(vmInfo) + length(siteInfo)))]].name : siteInfo[siteRole[(i - length(vmInfo))]].name))))
  location: location
  properties: {
    osProfile: {
      computerName: concat(toLower(prefix), toLower(((i < length(vmInfo)) ? vmInfo[vmrole[i]].name : ((i >= (length(vmInfo) + length(siteInfo))) ? clientInfo[(i - (length(vmInfo) + length(siteInfo)))][clientRole[(i - (length(vmInfo) + length(siteInfo)))]].name : siteInfo[siteRole[(i - length(vmInfo))]].name))))
      adminUsername: adminUsername
      adminPassword: adminPassword
      windowsConfiguration: {
        provisionVMAgent: true
        timeZone: timeZone
      }
    }
    hardwareProfile: {
      vmSize: ((i < length(vmInfo)) ? vmInfo[vmrole[i]].size : ((i >= (length(vmInfo) + length(siteInfo))) ? clientInfo[(i - (length(vmInfo) + length(siteInfo)))][clientRole[(i - (length(vmInfo) + length(siteInfo)))]].size : siteInfo[siteRole[(i - length(vmInfo))]].size))
    }
    storageProfile: {
      imageReference: ((i < length(vmInfo)) ? vmInfo[vmrole[i]].imageReference : ((i >= (length(vmInfo) + length(siteInfo))) ? clientInfo[(i - (length(vmInfo) + length(siteInfo)))][clientRole[(i - (length(vmInfo) + length(siteInfo)))]].imageReference : siteInfo[siteRole[(i - length(vmInfo))]].imageReference))
      osDisk: {
        osType: 'Windows'
        name: '${toLower(prefix)}${toLower(((i < length(vmInfo)) ? vmInfo[vmrole[i]].name : ((i >= (length(vmInfo) + length(siteInfo))) ? clientInfo[(i - (length(vmInfo) + length(siteInfo)))][clientRole[(i - (length(vmInfo) + length(siteInfo)))]].name : siteInfo[siteRole[(i - length(vmInfo))]].name)))}-OsDisk'
        createOption: 'FromImage'
        caching: 'ReadWrite'
        managedDisk: {
          storageAccountType: ((i < length(vmInfo)) ? vmInfo[vmrole[i]].disktype : ((i >= (length(vmInfo) + length(siteInfo))) ? clientInfo[(i - (length(vmInfo) + length(siteInfo)))][clientRole[(i - (length(vmInfo) + length(siteInfo)))]].disktype : siteInfo[siteRole[(i - length(vmInfo))]].disktype))
        }
        diskSizeGB: 150
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: resourceId('Microsoft.Network/networkInterfaces', '${toLower(prefix)}${toLower(((i < length(vmInfo)) ? vmInfo[vmrole[i]].name : ((i >= (length(vmInfo) + length(siteInfo))) ? clientInfo[(i - (length(vmInfo) + length(siteInfo)))][clientRole[(i - (length(vmInfo) + length(siteInfo)))]].name : siteInfo[siteRole[(i - length(vmInfo))]].name)))}-ni')
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: false
      }
    }
}]

resource prefix_vmInfo_vmInfo_vmRole_name_vmInfo_siteInfo_clientInfo_vmInfo_siteInfo_clientRole_vmInfo_siteInfo_name_siteInfo_siteRole_vmInfo_name_WorkFlow 'Microsoft.Compute/virtualMachines/extensions@2019-12-01' = [for i in range(0, ((length(vmInfo) + length(siteInfo)) + length(clientRole))): {
  name: '${toLower(prefix)}${toLower(((i < length(vmInfo)) ? vmInfo[vmrole[i]].name : ((i >= (length(vmInfo) + length(siteInfo))) ? clientInfo[(i - (length(vmInfo) + length(siteInfo)))][clientRole[(i - (length(vmInfo) + length(siteInfo)))]].name : siteInfo[siteRole[(i - length(vmInfo))]].name)))}/WorkFlow'
  location: location
  properties: {
    publisher: 'Microsoft.Powershell'
    type: 'DSC'
    typeHandlerVersion: '2.21'
    autoUpgradeMinorVersion: true
    settings: {
      modulesUrl: uri(_artifactsLocation, concat(dscScript, _artifactsLocationSasToken))
      configurationFunction: ((i < length(vmInfo)) ? '${vmrole[i]}Configuration.ps1\\Configuration' : ((i < (length(vmInfo) + length(siteInfo))) ? '${siteRole[(i - length(vmInfo))]}Configuration.ps1\\Configuration' : 'ClientConfiguration.ps1\\Configuration'))
      Properties: {
        DomainName: domainName
        DCName: concat(prefix, vmInfo.DC.name)
        DPMPName: concat(prefix, vmInfo.DPMP.name)
        CSName: ((configuration == 'Standalone') ? 'Empty' : concat(prefix, siteInfo.CS.name))
        PSName: concat(prefix, siteInfo.PS.name)
        ClientName: ClientName
        DNSIPAddress: concat(networkSettings.virtualMachinesIPAddress, (int('0') + int('4')))
        Configuration: configuration
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
}]

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2023-09-01' = {
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

resource prefix_vmInfo_vmInfo_vmRole_name_vmInfo_siteInfo_clientInfo_vmInfo_siteInfo_clientRole_vmInfo_siteInfo_name_siteInfo_siteRole_vmInfo_name_ni 'Microsoft.Network/networkInterfaces@2020-05-01' = [for i in range(0, ((length(vmInfo) + length(siteInfo)) + length(clientRole))): {
  name: '${toLower(prefix)}${toLower(((i < length(vmInfo)) ? vmInfo[vmrole[i]].name : ((i >= (length(vmInfo) + length(siteInfo))) ? clientInfo[(i - (length(vmInfo) + length(siteInfo)))][clientRole[(i - (length(vmInfo) + length(siteInfo)))]].name : siteInfo[siteRole[(i - length(vmInfo))]].name)))}-ni'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: networkSettings.subnetRef
          }
          privateIPAllocationMethod: networkSettings.privateIPAllocationMethod
          privateIPAddress: concat(networkSettings.virtualMachinesIPAddress, (i + int('4')))
          publicIPAddress: {
            id: resourceId('Microsoft.Network/publicIpAddresses', '${toLower(prefix)}${toLower(((i < length(vmInfo)) ? vmInfo[vmrole[i]].name : ((i >= (length(vmInfo) + length(siteInfo))) ? clientInfo[(i - (length(vmInfo) + length(siteInfo)))][clientRole[(i - (length(vmInfo) + length(siteInfo)))]].name : siteInfo[siteRole[(i - length(vmInfo))]].name)))}-ip')
          }
        }
      }
    ]
    networkSecurityGroup: {
      id: prefix_nsg.id
    }
  }
  
}]

resource prefix_vmInfo_vmInfo_vmRole_name_vmInfo_siteInfo_clientInfo_vmInfo_siteInfo_clientRole_vmInfo_siteInfo_name_siteInfo_siteRole_vmInfo_name_ip 'Microsoft.Network/publicIpAddresses@2020-05-01' = [for i in range(0, ((length(vmInfo) + length(siteInfo)) + length(clientRole))): {
  name: '${toLower(prefix)}${toLower(((i < length(vmInfo)) ? vmInfo[vmrole[i]].name : ((i >= (length(vmInfo) + length(siteInfo))) ? clientInfo[(i - (length(vmInfo) + length(siteInfo)))][clientRole[(i - (length(vmInfo) + length(siteInfo)))]].name : siteInfo[siteRole[(i - length(vmInfo))]].name)))}-ip'
  location: location
  properties: {
    publicIPAllocationMethod: networkSettings.publicIpAllocationMethod
  }
}]

resource prefix_nsg 'Microsoft.Network/networkSecurityGroups@2023-09-01' = {
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
