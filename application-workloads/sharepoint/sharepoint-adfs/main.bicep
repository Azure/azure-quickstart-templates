@description('Location for all resources.')
param location string = resourceGroup().location

@description('Version of SharePoint farm to create.')
@allowed([
  '2013'
  '2016'
  '2019'
  'Subscription-RTM'
  'Subscription-22H2'
  'Subscription-Latest'
])
param sharePointVersion string = 'Subscription-Latest'

@description('FQDN of the AD forest to create.')
@minLength(5)
param domainFQDN string = 'contoso.local'

@description('Number of MinRole Front-end to add to the farm. The MinRole type can be changed later as needed.')
@allowed([
  0
  1
  2
  3
  4
])
param numberOfAdditionalFrontEnd int = 0

@description('Specify if Azure Bastion should be provisioned. See https://azure.microsoft.com/en-us/services/azure-bastion for more information.')
param addAzureBastion bool = false

@description('Specify if each VM should have a public IP and be reachable from Internet.')
@allowed([
  'Yes'
  'No'
  'SharePointVMsOnly'
])
param addPublicIPAddress string = 'SharePointVMsOnly'

@description('Specify if RDP traffic is allowed:<br>- If \'No\' (default): Firewall denies all incoming RDP traffic.<br>- If \'*\' or \'Internet\': Firewall accepts all incoming RDP traffic from Internet.<br>- If CIDR notation (e.g. 192.168.99.0/24 or 2001:1234::/64) or IP address (e.g. 192.168.99.0 or 2001:1234::): Firewall accepts incoming RDP traffic from the IP addresses specified.')
@minLength(1)
param RDPTrafficAllowed string = 'No'

@description('Name of the AD and SharePoint administrator. \'admin\' and \'administrator\' are not allowed.')
@minLength(1)
param adminUserName string

@description('Input must meet password complexity requirements as documented in https://learn.microsoft.com/azure/virtual-machines/windows/faq#what-are-the-password-requirements-when-creating-a-vm-')
@minLength(8)
@secure()
param adminPassword string

@description('Password for all service accounts and SharePoint passphrase. Input must meet password complexity requirements as documented in https://learn.microsoft.com/azure/virtual-machines/windows/faq#what-are-the-password-requirements-when-creating-a-vm-')
@minLength(8)
@secure()
param serviceAccountsPassword string

@description('Time zone of the virtual machines. Type "[TimeZoneInfo]::GetSystemTimeZones().Id" in PowerShell to get the list.')
@minLength(2)
@allowed([
  'Dateline Standard Time'
  'UTC-11'
  'Aleutian Standard Time'
  'Hawaiian Standard Time'
  'Marquesas Standard Time'
  'Alaskan Standard Time'
  'UTC-09'
  'Pacific Standard Time (Mexico)'
  'UTC-08'
  'Pacific Standard Time'
  'US Mountain Standard Time'
  'Mountain Standard Time (Mexico)'
  'Mountain Standard Time'
  'Central America Standard Time'
  'Central Standard Time'
  'Easter Island Standard Time'
  'Central Standard Time (Mexico)'
  'Canada Central Standard Time'
  'SA Pacific Standard Time'
  'Eastern Standard Time (Mexico)'
  'Eastern Standard Time'
  'Haiti Standard Time'
  'Cuba Standard Time'
  'US Eastern Standard Time'
  'Turks And Caicos Standard Time'
  'Paraguay Standard Time'
  'Atlantic Standard Time'
  'Venezuela Standard Time'
  'Central Brazilian Standard Time'
  'SA Western Standard Time'
  'Pacific SA Standard Time'
  'Newfoundland Standard Time'
  'Tocantins Standard Time'
  'E. South America Standard Time'
  'SA Eastern Standard Time'
  'Argentina Standard Time'
  'Greenland Standard Time'
  'Montevideo Standard Time'
  'Magallanes Standard Time'
  'Saint Pierre Standard Time'
  'Bahia Standard Time'
  'UTC-02'
  'Mid-Atlantic Standard Time'
  'Azores Standard Time'
  'Cape Verde Standard Time'
  'UTC'
  'GMT Standard Time'
  'Greenwich Standard Time'
  'Sao Tome Standard Time'
  'Morocco Standard Time'
  'W. Europe Standard Time'
  'Central Europe Standard Time'
  'Romance Standard Time'
  'Central European Standard Time'
  'W. Central Africa Standard Time'
  'Jordan Standard Time'
  'GTB Standard Time'
  'Middle East Standard Time'
  'Egypt Standard Time'
  'E. Europe Standard Time'
  'Syria Standard Time'
  'West Bank Standard Time'
  'South Africa Standard Time'
  'FLE Standard Time'
  'Israel Standard Time'
  'Kaliningrad Standard Time'
  'Sudan Standard Time'
  'Libya Standard Time'
  'Namibia Standard Time'
  'Arabic Standard Time'
  'Turkey Standard Time'
  'Arab Standard Time'
  'Belarus Standard Time'
  'Russian Standard Time'
  'E. Africa Standard Time'
  'Iran Standard Time'
  'Arabian Standard Time'
  'Astrakhan Standard Time'
  'Azerbaijan Standard Time'
  'Russia Time Zone 3'
  'Mauritius Standard Time'
  'Saratov Standard Time'
  'Georgian Standard Time'
  'Volgograd Standard Time'
  'Caucasus Standard Time'
  'Afghanistan Standard Time'
  'West Asia Standard Time'
  'Ekaterinburg Standard Time'
  'Pakistan Standard Time'
  'Qyzylorda Standard Time'
  'India Standard Time'
  'Sri Lanka Standard Time'
  'Nepal Standard Time'
  'Central Asia Standard Time'
  'Bangladesh Standard Time'
  'Omsk Standard Time'
  'Myanmar Standard Time'
  'SE Asia Standard Time'
  'Altai Standard Time'
  'W. Mongolia Standard Time'
  'North Asia Standard Time'
  'N. Central Asia Standard Time'
  'Tomsk Standard Time'
  'China Standard Time'
  'North Asia East Standard Time'
  'Singapore Standard Time'
  'W. Australia Standard Time'
  'Taipei Standard Time'
  'Ulaanbaatar Standard Time'
  'Aus Central W. Standard Time'
  'Transbaikal Standard Time'
  'Tokyo Standard Time'
  'North Korea Standard Time'
  'Korea Standard Time'
  'Yakutsk Standard Time'
  'Cen. Australia Standard Time'
  'AUS Central Standard Time'
  'E. Australia Standard Time'
  'AUS Eastern Standard Time'
  'West Pacific Standard Time'
  'Tasmania Standard Time'
  'Vladivostok Standard Time'
  'Lord Howe Standard Time'
  'Bougainville Standard Time'
  'Russia Time Zone 10'
  'Magadan Standard Time'
  'Norfolk Standard Time'
  'Sakhalin Standard Time'
  'Central Pacific Standard Time'
  'Russia Time Zone 11'
  'New Zealand Standard Time'
  'UTC+12'
  'Fiji Standard Time'
  'Kamchatka Standard Time'
  'Chatham Islands Standard Time'
  'UTC+13'
  'Tonga Standard Time'
  'Samoa Standard Time'
  'Line Islands Standard Time'
])
param vmsTimeZone string = 'Romance Standard Time'

@description('The time at which VMs will be automatically shutdown (24h HHmm format). Set value to \'9999\' to NOT configure the auto shutdown.')
@minLength(4)
@maxLength(4)
param vmsAutoShutdownTime string = '1900'

@description('Enable automatic Windows Updates.')
param enableAutomaticUpdates bool = true

@description('Enable Azure Hybrid Benefit to use your on-premises Windows Server licenses and reduce cost. See https://docs.microsoft.com/en-us/azure/virtual-machines/windows/hybrid-use-benefit-licensing for more information.')
param enableHybridBenefitServerLicenses bool = false

@description('Size in Gb of the additional data disk attached to SharePoint VMs. Set to 0 to not create it')
param sharePointDataDiskSize int = 0

@description('Size of the DC VM')
param vmDCSize string = 'Standard_B2s'

@description('Type of storage for the managed disks. Visit \'https://docs.microsoft.com/en-us/rest/api/compute/disks/list#diskstorageaccounttypes\' for more information')
@allowed([
  'Standard_LRS'
  'StandardSSD_LRS'
  'Premium_LRS'
  'Premium_ZRS'
  'StandardSSD_ZRS'
  'UltraSSD_LRS'
])
param vmDCStorageAccountType string = 'StandardSSD_LRS'

@description('Size of the SQL VM')
param vmSQLSize string = 'Standard_B2ms'

@description('Type of storage for the managed disks. Visit \'https://docs.microsoft.com/en-us/rest/api/compute/disks/list#diskstorageaccounttypes\' for more information')
@allowed([
  'Standard_LRS'
  'StandardSSD_LRS'
  'Premium_LRS'
  'Premium_ZRS'
  'StandardSSD_ZRS'
  'UltraSSD_LRS'
])
param vmSQLStorageAccountType string = 'StandardSSD_LRS'

@description('Size of the SharePoint VM')
param vmSPSize string = 'Standard_B4ms'

@description('Type of storage for the managed disks. Visit \'https://docs.microsoft.com/en-us/rest/api/compute/disks/list#diskstorageaccounttypes\' for more information')
@allowed([
  'Standard_LRS'
  'StandardSSD_LRS'
  'Premium_LRS'
  'Premium_ZRS'
  'StandardSSD_ZRS'
  'UltraSSD_LRS'
])
param vmSPStorageAccountType string = 'StandardSSD_LRS'

@description('The base URI where artifacts required by this template are located. When the template is deployed using the accompanying scripts, a private location in the subscription will be used and this value will be automatically generated.')
param _artifactsLocation string = deployment().properties.templateLink.uri

@description('The sasToken required to access _artifactsLocation. When the template is deployed using the accompanying scripts, a sasToken will be automatically generated.')
@secure()
param _artifactsLocationSasToken string = ''

var resourceGroupNameFormatted = replace(replace(replace(replace(resourceGroup().name, '.', '-'), '(', '-'), ')', '-'), '_', '-')
var sharePointSettings = {
  isSharePointSubscription: (startsWith(sharePointVersion, 'subscription') ? true : false)
  sharePointImagesList: {
    Subscription: 'MicrosoftWindowsServer:WindowsServer:2022-datacenter-azure-edition-smalldisk:latest'
    sp2019: 'MicrosoftSharePoint:MicrosoftSharePointServer:sp2019gen2smalldisk:latest'
    sp2016: 'MicrosoftSharePoint:MicrosoftSharePointServer:sp2016:latest'
    sp2013: 'MicrosoftSharePoint:MicrosoftSharePointServer:sp2013:latest'
  }
  sharePointSubscriptionBits: [
    {
      Label: 'RTM'
      Packages: [
        {
          DownloadUrl: 'https://download.microsoft.com/download/3/f/5/3f5f8a7e-462b-41ff-a5b2-04bdf5821ceb/OfficeServer.iso'
          ChecksumType: 'SHA256'
          Checksum: 'C576B847C573234B68FC602A0318F5794D7A61D8149EB6AE537AF04470B7FC05'
        }
      ]
    }
    {
      Label: '22H2'
      Packages: [
        {
          DownloadUrl: 'https://download.microsoft.com/download/8/d/f/8dfcb515-6e49-42e5-b20f-5ebdfd19d8e7/wssloc-subscription-kb5002270-fullfile-x64-glb.exe'
          ChecksumType: 'SHA256'
          Checksum: '7E496530EB873146650A9E0653DE835CB2CAD9AF8D154CBD7387BB0F2297C9FC'
        }
        {
          DownloadUrl: 'https://download.microsoft.com/download/3/f/5/3f5b1ee0-3336-45d7-b2f4-1e6af977d574/sts-subscription-kb5002271-fullfile-x64-glb.exe'
          ChecksumType: 'SHA256'
          Checksum: '247011443AC573D4F03B1622065A7350B8B3DAE04D6A5A6DC64C8270A3BE7636'
        }
      ]
    }
    {
      Label: 'Latest'
      Packages: [
        {
          DownloadUrl: 'https://download.microsoft.com/download/d/6/d/d6dcc9e7-744e-43e1-b4be-206a6acd4f88/sts-subscription-kb5002331-fullfile-x64-glb.exe'
        }
        {
          DownloadUrl: 'https://download.microsoft.com/download/d/3/5/d354b6e2-fa16-48e0-b3f8-423f7ca279a0/wssloc-subscription-kb5002326-fullfile-x64-glb.exe'
        }
      ]
    }
  ]
}
var networkSettings = {
  vNetPrivatePrefix: '10.1.0.0/16'
  subnetDCPrefix: '10.1.1.0/24'
  dcPrivateIPAddress: '10.1.1.4'
  subnetSQLPrefix: '10.1.2.0/24'
  subnetSPPrefix: '10.1.3.0/24'
  vNetPrivateName: '${resourceGroupNameFormatted}-vnet'
  subnetDCName: 'Subnet-DC'
  subnetSQLName: 'Subnet-SQL'
  subnetSPName: 'Subnet-SP'
  nsgSubnetDCName: 'NSG-Subnet-DC'
  nsgSubnetSQLName: 'NSG-Subnet-SQL'
  nsgSubnetSPName: 'NSG-Subnet-SP'
  vmDCPublicIPNicAssociation: {
    id: vmsResourcesNames_vmDCPublicIP.id
  }
  vmSQLPublicIPNicAssociation: {
    id: vmsResourcesNames_vmSQLPublicIP.id
  }
  vmSPPublicIPNicAssociation: {
    id: vmsResourcesNames_vmSPPublicIP.id
  }
  nsgRuleAllowIncomingRdp: [
    {
      name: 'allow-rdp-rule'
      properties: {
        description: 'Allow RDP'
        protocol: 'Tcp'
        sourcePortRange: '*'
        destinationPortRange: '3389'
        sourceAddressPrefix: RDPTrafficAllowed
        destinationAddressPrefix: '*'
        access: 'Allow'
        priority: 110
        direction: 'Inbound'
      }
    }
  ]
}
var vmsSettings = {
  vmDCName: 'DC'
  vmSQLName: 'SQL'
  vmSPName: 'SP'
  vmFEName: 'FE'
  vmDCImage: 'MicrosoftWindowsServer:WindowsServer:2022-datacenter-azure-edition-smalldisk:latest'
  vmSQLImage: ((sharePointVersion == '2013') ? 'MicrosoftSQLServer:sql2014sp3-ws2012r2:sqldev:latest' : 'MicrosoftSQLServer:sql2019-ws2022:sqldev-gen2:latest')
  vmSharePointImage: (sharePointSettings.isSharePointSubscription ? sharePointSettings.sharePointImagesList.Subscription : ((sharePointVersion == '2019') ? sharePointSettings.sharePointImagesList.sp2019 : ((sharePointVersion == '2016') ? sharePointSettings.sharePointImagesList.sp2016 : sharePointSettings.sharePointImagesList.sp2013)))
}
var vmsResourcesNames = {
  vmDCNicName: 'NIC-${vmsSettings.vmDCName}-0'
  vmDCPublicIPName: 'PublicIP-${vmsSettings.vmDCName}'
  vmSQLNicName: 'NIC-${vmsSettings.vmSQLName}-0'
  vmSQLPublicIPName: 'PublicIP-${vmsSettings.vmSQLName}'
  vmSPNicName: 'NIC-${vmsSettings.vmSPName}-0'
  vmSPPublicIPName: 'PublicIP-${vmsSettings.vmSPName}'
  vmFENicName: 'NIC-${vmsSettings.vmFEName}-0'
  vmFEPublicIPName: 'PublicIP-${vmsSettings.vmFEName}'
}
var dscSettings = {
  forceUpdateTag: '1.0'
  vmDCScriptFileUri: uri(_artifactsLocation, 'dsc/ConfigureDCVM.zip${_artifactsLocationSasToken}')
  vmDCScript: 'ConfigureDCVM.ps1'
  vmDCFunction: 'ConfigureDCVM'
  vmSQLScriptFileUri: uri(_artifactsLocation, 'dsc/ConfigureSQLVM.zip${_artifactsLocationSasToken}')
  vmSQLScript: 'ConfigureSQLVM.ps1'
  vmSQLFunction: 'ConfigureSQLVM'
  vmSPScriptFileUri: uri(_artifactsLocation, '${(sharePointSettings.isSharePointSubscription ? 'dsc/ConfigureSPSE.zip' : 'dsc/ConfigureSPLegacy.zip')}${_artifactsLocationSasToken}')
  vmSPScript: (sharePointSettings.isSharePointSubscription ? 'ConfigureSPSE.ps1' : 'ConfigureSPLegacy.ps1')
  vmSPFunction: 'ConfigureSPVM'
  vmFEScriptFileUri: uri(_artifactsLocation, '${(sharePointSettings.isSharePointSubscription ? 'dsc/ConfigureFESE.zip' : 'dsc/ConfigureFELegacy.zip')}${_artifactsLocationSasToken}')
  vmFEScript: (sharePointSettings.isSharePointSubscription ? 'ConfigureFESE.ps1' : 'ConfigureFELegacy.ps1')
  vmFEFunction: 'ConfigureFEVM'
}
var deploymentSettings = {
  sharePointSitesAuthority: 'spsites'
  sharePointCentralAdminPort: 5000
  sharePointBitsSelected: (sharePointSettings.isSharePointSubscription ? sharePointSettings.sharePointSubscriptionBits : 'fake')
  localAdminUserName: 'local-${uniqueString(subscription().subscriptionId)}'
  enableAnalysis: false
  applyBrowserPolicies: true
  sqlAlias: 'SQLAlias'
  spSuperUserName: 'spSuperUser'
  spSuperReaderName: 'spSuperReader'
  adfsSvcUserName: 'adfssvc'
  sqlSvcUserName: 'sqlsvc'
  spSetupUserName: 'spsetup'
  spFarmUserName: 'spfarm'
  spSvcUserName: 'spsvc'
  spAppPoolUserName: 'spapppool'
  spADDirSyncUserName: 'spdirsync'
}
var vmSPDataDisk = [
  {
    lun: 0
    name: 'Disk-SP-Data'
    caching: 'ReadWrite'
    createOption: 'Empty'
    diskSizeGB: sharePointDataDiskSize
  }
]

resource networkSettings_nsgSubnetDC 'Microsoft.Network/networkSecurityGroups@2022-07-01' = {
  name: networkSettings.nsgSubnetDCName
  location: location
  properties: {
    securityRules: ((toLower(RDPTrafficAllowed) == 'no') ? null : networkSettings.nsgRuleAllowIncomingRdp)
  }
}

resource networkSettings_nsgSubnetSQL 'Microsoft.Network/networkSecurityGroups@2022-07-01' = {
  name: networkSettings.nsgSubnetSQLName
  location: location
  properties: {
    securityRules: ((toLower(RDPTrafficAllowed) == 'no') ? null : networkSettings.nsgRuleAllowIncomingRdp)
  }
}

resource networkSettings_nsgSubnetSP 'Microsoft.Network/networkSecurityGroups@2022-07-01' = {
  name: networkSettings.nsgSubnetSPName
  location: location
  properties: {
    securityRules: ((toLower(RDPTrafficAllowed) == 'no') ? null : networkSettings.nsgRuleAllowIncomingRdp)
  }
}

resource networkSettings_vNetPrivate 'Microsoft.Network/virtualNetworks@2022-07-01' = {
  name: networkSettings.vNetPrivateName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        networkSettings.vNetPrivatePrefix
      ]
    }
    subnets: [
      {
        name: networkSettings.subnetDCName
        properties: {
          addressPrefix: networkSettings.subnetDCPrefix
          networkSecurityGroup: {
            id: networkSettings_nsgSubnetDC.id
          }
        }
      }
      {
        name: networkSettings.subnetSQLName
        properties: {
          addressPrefix: networkSettings.subnetSQLPrefix
          networkSecurityGroup: {
            id: networkSettings_nsgSubnetSQL.id
          }
        }
      }
      {
        name: networkSettings.subnetSPName
        properties: {
          addressPrefix: networkSettings.subnetSPPrefix
          networkSecurityGroup: {
            id: networkSettings_nsgSubnetSP.id
          }
        }
      }
    ]
  }
}

resource vmsResourcesNames_vmDCPublicIP 'Microsoft.Network/publicIPAddresses@2022-07-01' = if (addPublicIPAddress == 'Yes') {
  name: vmsResourcesNames.vmDCPublicIPName
  location: location
  sku: {
    name: 'Basic'
    tier: 'Regional'
  }
  properties: {
    publicIPAllocationMethod: 'Dynamic'
    dnsSettings: {
      domainNameLabel: toLower('${resourceGroupNameFormatted}-${vmsSettings.vmDCName}')
    }
  }
}

resource vmsResourcesNames_vmDCNic 'Microsoft.Network/networkInterfaces@2022-07-01' = {
  name: vmsResourcesNames.vmDCNicName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Static'
          privateIPAddress: networkSettings.dcPrivateIPAddress
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', networkSettings.vNetPrivateName, networkSettings.subnetDCName)
          }
          publicIPAddress: ((addPublicIPAddress == 'Yes') ? networkSettings.vmDCPublicIPNicAssociation : null)
        }
      }
    ]
  }
  dependsOn: [
    networkSettings_vNetPrivate

  ]
}

resource vmsSettings_vmDC 'Microsoft.Compute/virtualMachines@2022-08-01' = {
  name: vmsSettings.vmDCName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmDCSize
    }
    osProfile: {
      computerName: vmsSettings.vmDCName
      adminUsername: adminUserName
      adminPassword: adminPassword
      windowsConfiguration: {
        timeZone: vmsTimeZone
        enableAutomaticUpdates: enableAutomaticUpdates
        provisionVMAgent: true
        patchSettings: {
          patchMode: (enableAutomaticUpdates ? 'AutomaticByOS' : 'Manual')
          assessmentMode: 'ImageDefault'
        }
      }
    }
    storageProfile: {
      imageReference: {
        publisher: split(vmsSettings.vmDCImage, ':')[0]
        offer: split(vmsSettings.vmDCImage, ':')[1]
        sku: split(vmsSettings.vmDCImage, ':')[2]
        version: split(vmsSettings.vmDCImage, ':')[3]
      }
      osDisk: {
        name: 'Disk-${vmsSettings.vmDCName}-OS'
        caching: 'ReadWrite'
        osType: 'Windows'
        createOption: 'FromImage'
        diskSizeGB: 32
        managedDisk: {
          storageAccountType: vmDCStorageAccountType
        }
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: vmsResourcesNames_vmDCNic.id
        }
      ]
    }
    licenseType: (enableHybridBenefitServerLicenses ? 'Windows_Server' : null)
  }
}

resource vmsSettings_vmDCName_ConfigureDCVM 'Microsoft.Compute/virtualMachines/extensions@2022-08-01' = {
  parent: vmsSettings_vmDC
  name: 'ConfigureDCVM'
  location: location
  properties: {
    publisher: 'Microsoft.Powershell'
    type: 'DSC'
    typeHandlerVersion: '2.9'
    autoUpgradeMinorVersion: true
    forceUpdateTag: dscSettings.forceUpdateTag
    settings: {
      wmfVersion: 'latest'
      configuration: {
        url: dscSettings.vmDCScriptFileUri
        script: dscSettings.vmDCScript
        function: dscSettings.vmDCFunction
      }
      configurationArguments: {
        domainFQDN: domainFQDN
        PrivateIP: networkSettings.dcPrivateIPAddress
        SPServerName: vmsSettings.vmSPName
        SharePointSitesAuthority: deploymentSettings.sharePointSitesAuthority
        SharePointCentralAdminPort: deploymentSettings.sharePointCentralAdminPort
        ApplyBrowserPolicies: deploymentSettings.applyBrowserPolicies
      }
      privacy: {
        dataCollection: 'enable'
      }
    }
    protectedSettings: {
      configurationArguments: {
        AdminCreds: {
          UserName: adminUserName
          Password: adminPassword
        }
        AdfsSvcCreds: {
          UserName: deploymentSettings.adfsSvcUserName
          Password: serviceAccountsPassword
        }
      }
    }
  }
}

resource vmsResourcesNames_vmSQLPublicIP 'Microsoft.Network/publicIPAddresses@2022-07-01' = if (addPublicIPAddress == 'Yes') {
  name: vmsResourcesNames.vmSQLPublicIPName
  location: location
  sku: {
    name: 'Basic'
    tier: 'Regional'
  }
  properties: {
    publicIPAllocationMethod: 'Dynamic'
    dnsSettings: {
      domainNameLabel: toLower('${resourceGroupNameFormatted}-${vmsSettings.vmSQLName}')
    }
  }
}

resource vmsResourcesNames_vmSQLNic 'Microsoft.Network/networkInterfaces@2022-07-01' = {
  name: vmsResourcesNames.vmSQLNicName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', networkSettings.vNetPrivateName, networkSettings.subnetSQLName)
          }
          publicIPAddress: ((addPublicIPAddress == 'Yes') ? networkSettings.vmSQLPublicIPNicAssociation : null)
        }
      }
    ]
  }
  dependsOn: [
    networkSettings_vNetPrivate

  ]
}

resource vmsSettings_vmSQL 'Microsoft.Compute/virtualMachines@2022-08-01' = {
  name: vmsSettings.vmSQLName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSQLSize
    }
    osProfile: {
      computerName: vmsSettings.vmSQLName
      adminUsername: deploymentSettings.localAdminUserName
      adminPassword: adminPassword
      windowsConfiguration: {
        timeZone: vmsTimeZone
        enableAutomaticUpdates: enableAutomaticUpdates
        provisionVMAgent: true
        patchSettings: {
          patchMode: (enableAutomaticUpdates ? 'AutomaticByOS' : 'Manual')
          assessmentMode: 'ImageDefault'
        }
      }
    }
    storageProfile: {
      imageReference: {
        publisher: split(vmsSettings.vmSQLImage, ':')[0]
        offer: split(vmsSettings.vmSQLImage, ':')[1]
        sku: split(vmsSettings.vmSQLImage, ':')[2]
        version: split(vmsSettings.vmSQLImage, ':')[3]
      }
      osDisk: {
        name: 'Disk-${vmsSettings.vmSQLName}-OS'
        caching: 'ReadWrite'
        osType: 'Windows'
        createOption: 'FromImage'
        diskSizeGB: 128
        managedDisk: {
          storageAccountType: vmSQLStorageAccountType
        }
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: vmsResourcesNames_vmSQLNic.id
        }
      ]
    }
    licenseType: (enableHybridBenefitServerLicenses ? 'Windows_Server' : null)
  }
}

resource vmsResourcesNames_vmSPPublicIP 'Microsoft.Network/publicIPAddresses@2022-07-01' = if ((addPublicIPAddress == 'Yes') || (addPublicIPAddress == 'SharePointVMsOnly')) {
  name: vmsResourcesNames.vmSPPublicIPName
  location: location
  sku: {
    name: 'Basic'
    tier: 'Regional'
  }
  properties: {
    publicIPAllocationMethod: 'Dynamic'
    dnsSettings: {
      domainNameLabel: toLower('${resourceGroupNameFormatted}-${vmsSettings.vmSPName}')
    }
  }
}

resource vmsResourcesNames_vmSPNic 'Microsoft.Network/networkInterfaces@2022-07-01' = {
  name: vmsResourcesNames.vmSPNicName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', networkSettings.vNetPrivateName, networkSettings.subnetSPName)
          }
          publicIPAddress: (((addPublicIPAddress == 'Yes') || (addPublicIPAddress == 'SharePointVMsOnly')) ? networkSettings.vmSPPublicIPNicAssociation : null)
        }
      }
    ]
  }
  dependsOn: [
    networkSettings_vNetPrivate

  ]
}

resource vmsSettings_vmSP 'Microsoft.Compute/virtualMachines@2022-08-01' = {
  name: vmsSettings.vmSPName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSPSize
    }
    osProfile: {
      computerName: vmsSettings.vmSPName
      adminUsername: deploymentSettings.localAdminUserName
      adminPassword: adminPassword
      windowsConfiguration: {
        timeZone: vmsTimeZone
        enableAutomaticUpdates: enableAutomaticUpdates
        provisionVMAgent: true
        patchSettings: {
          patchMode: (enableAutomaticUpdates ? 'AutomaticByOS' : 'Manual')
          assessmentMode: 'ImageDefault'
        }
      }
    }
    storageProfile: {
      imageReference: {
        publisher: split(vmsSettings.vmSharePointImage, ':')[0]
        offer: split(vmsSettings.vmSharePointImage, ':')[1]
        sku: split(vmsSettings.vmSharePointImage, ':')[2]
        version: split(vmsSettings.vmSharePointImage, ':')[3]
      }
      osDisk: {
        name: 'Disk-${vmsSettings.vmSPName}-OS'
        caching: 'ReadWrite'
        osType: 'Windows'
        createOption: 'FromImage'
        diskSizeGB: 128
        managedDisk: {
          storageAccountType: vmSPStorageAccountType
        }
      }
      dataDisks: ((sharePointDataDiskSize == 0) ? null : vmSPDataDisk)
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: vmsResourcesNames_vmSPNic.id
        }
      ]
    }
    licenseType: (enableHybridBenefitServerLicenses ? 'Windows_Server' : null)
  }
}

resource vmsSettings_vmSQLName_ConfigureSQLVM 'Microsoft.Compute/virtualMachines/extensions@2022-08-01' = {
  parent: vmsSettings_vmSQL
  name: 'ConfigureSQLVM'
  location: location
  properties: {
    publisher: 'Microsoft.Powershell'
    type: 'DSC'
    typeHandlerVersion: '2.9'
    autoUpgradeMinorVersion: true
    forceUpdateTag: dscSettings.forceUpdateTag
    settings: {
      wmfVersion: 'latest'
      configuration: {
        url: dscSettings.vmSQLScriptFileUri
        script: dscSettings.vmSQLScript
        function: dscSettings.vmSQLFunction
      }
      configurationArguments: {
        DNSServerIP: networkSettings.dcPrivateIPAddress
        DomainFQDN: domainFQDN
      }
      privacy: {
        dataCollection: 'enable'
      }
    }
    protectedSettings: {
      configurationArguments: {
        DomainAdminCreds: {
          UserName: adminUserName
          Password: adminPassword
        }
        SqlSvcCreds: {
          UserName: deploymentSettings.sqlSvcUserName
          Password: serviceAccountsPassword
        }
        SPSetupCreds: {
          UserName: deploymentSettings.spSetupUserName
          Password: serviceAccountsPassword
        }
      }
    }
  }
}

resource vmsSettings_vmSPName_ConfigureSPVM 'Microsoft.Compute/virtualMachines/extensions@2022-08-01' = {
  parent: vmsSettings_vmSP
  name: 'ConfigureSPVM'
  location: location
  properties: {
    publisher: 'Microsoft.Powershell'
    type: 'DSC'
    typeHandlerVersion: '2.9'
    autoUpgradeMinorVersion: true
    forceUpdateTag: dscSettings.forceUpdateTag
    settings: {
      wmfVersion: 'latest'
      configuration: {
        url: dscSettings.vmSPScriptFileUri
        script: dscSettings.vmSPScript
        function: dscSettings.vmSPFunction
      }
      configurationArguments: {
        DNSServerIP: networkSettings.dcPrivateIPAddress
        DomainFQDN: domainFQDN
        DCServerName: vmsSettings.vmDCName
        SQLServerName: vmsSettings.vmSQLName
        SQLAlias: deploymentSettings.sqlAlias
        SharePointVersion: sharePointVersion
        SharePointSitesAuthority: deploymentSettings.sharePointSitesAuthority
        SharePointCentralAdminPort: deploymentSettings.sharePointCentralAdminPort
        EnableAnalysis: deploymentSettings.enableAnalysis
        SharePointBits: deploymentSettings.sharePointBitsSelected
      }
      privacy: {
        dataCollection: 'enable'
      }
    }
    protectedSettings: {
      configurationArguments: {
        DomainAdminCreds: {
          UserName: adminUserName
          Password: adminPassword
        }
        SPSetupCreds: {
          UserName: deploymentSettings.spSetupUserName
          Password: serviceAccountsPassword
        }
        SPFarmCreds: {
          UserName: deploymentSettings.spFarmUserName
          Password: serviceAccountsPassword
        }
        SPSvcCreds: {
          UserName: deploymentSettings.spSvcUserName
          Password: serviceAccountsPassword
        }
        SPAppPoolCreds: {
          UserName: deploymentSettings.spAppPoolUserName
          Password: serviceAccountsPassword
        }
        SPADDirSyncCreds: {
          UserName: deploymentSettings.spADDirSyncUserName
          Password: serviceAccountsPassword
        }
        SPPassphraseCreds: {
          UserName: 'Passphrase'
          Password: serviceAccountsPassword
        }
        SPSuperUserCreds: {
          UserName: deploymentSettings.spSuperUserName
          Password: serviceAccountsPassword
        }
        SPSuperReaderCreds: {
          UserName: deploymentSettings.spSuperReaderName
          Password: serviceAccountsPassword
        }
      }
    }
  }
}

resource vmsResourcesNames_vmFEPublicIP 'Microsoft.Network/publicIPAddresses@2022-07-01' = [for i in range(0, numberOfAdditionalFrontEnd): if ((numberOfAdditionalFrontEnd >= 1) && ((addPublicIPAddress == 'Yes') || (addPublicIPAddress == 'SharePointVMsOnly'))) {
  name: '${vmsResourcesNames.vmFEPublicIPName}-${i}'
  location: location
  sku: {
    name: 'Basic'
    tier: 'Regional'
  }
  properties: {
    publicIPAllocationMethod: 'Dynamic'
    dnsSettings: {
      domainNameLabel: '${toLower('${resourceGroupNameFormatted}-${vmsSettings.vmFEName}')}-${i}'
    }
  }
}]

resource vmsResourcesNames_vmFENic 'Microsoft.Network/networkInterfaces@2022-07-01' = [for i in range(0, numberOfAdditionalFrontEnd): if (numberOfAdditionalFrontEnd >= 1) {
  name: '${vmsResourcesNames.vmFENicName}-${i}'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', networkSettings.vNetPrivateName, networkSettings.subnetSPName)
          }
          publicIPAddress: (((addPublicIPAddress == 'Yes') || (addPublicIPAddress == 'SharePointVMsOnly')) ? json('{"id": "${resourceId('Microsoft.Network/publicIPAddresses', '${vmsResourcesNames.vmFEPublicIPName}-${i}')}" }') : null)
        }
      }
    ]
  }
  dependsOn: [
    networkSettings_vNetPrivate
    vmsResourcesNames_vmFEPublicIP
  ]
}]

resource vmsSettings_vmFE 'Microsoft.Compute/virtualMachines@2022-08-01' = [for i in range(0, numberOfAdditionalFrontEnd): if (numberOfAdditionalFrontEnd >= 1) {
  name: '${vmsSettings.vmFEName}-${i}'
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSPSize
    }
    osProfile: {
      computerName: '${vmsSettings.vmFEName}-${i}'
      adminUsername: deploymentSettings.localAdminUserName
      adminPassword: adminPassword
      windowsConfiguration: {
        timeZone: vmsTimeZone
        enableAutomaticUpdates: enableAutomaticUpdates
        provisionVMAgent: true
        patchSettings: {
          patchMode: (enableAutomaticUpdates ? 'AutomaticByOS' : 'Manual')
          assessmentMode: 'ImageDefault'
        }
      }
    }
    storageProfile: {
      imageReference: {
        publisher: split(vmsSettings.vmSharePointImage, ':')[0]
        offer: split(vmsSettings.vmSharePointImage, ':')[1]
        sku: split(vmsSettings.vmSharePointImage, ':')[2]
        version: split(vmsSettings.vmSharePointImage, ':')[3]
      }
      osDisk: {
        name: 'Disk-${vmsSettings.vmFEName}-${i}-OS'
        caching: 'ReadWrite'
        osType: 'Windows'
        createOption: 'FromImage'
        diskSizeGB: 128
        managedDisk: {
          storageAccountType: vmSPStorageAccountType
        }
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: resourceId('Microsoft.Network/networkInterfaces', '${vmsResourcesNames.vmFENicName}-${i}')
        }
      ]
    }
    licenseType: (enableHybridBenefitServerLicenses ? 'Windows_Server' : null)
  }
  dependsOn: [
    vmsResourcesNames_vmFENic
  ]
}]

resource vmsSettings_vmFEName_ConfigureFEVM 'Microsoft.Compute/virtualMachines/extensions@2022-08-01' = [for i in range(0, numberOfAdditionalFrontEnd): if (numberOfAdditionalFrontEnd >= 1) {
  name: '${vmsSettings.vmFEName}-${i}/ConfigureFEVM'
  location: location
  properties: {
    publisher: 'Microsoft.Powershell'
    type: 'DSC'
    typeHandlerVersion: '2.9'
    autoUpgradeMinorVersion: true
    forceUpdateTag: dscSettings.forceUpdateTag
    settings: {
      wmfVersion: 'latest'
      configuration: {
        url: dscSettings.vmFEScriptFileUri
        script: dscSettings.vmFEScript
        function: dscSettings.vmFEFunction
      }
      configurationArguments: {
        DNSServerIP: networkSettings.dcPrivateIPAddress
        DomainFQDN: domainFQDN
        DCServerName: vmsSettings.vmDCName
        SQLServerName: vmsSettings.vmSQLName
        SQLAlias: deploymentSettings.sqlAlias
        SharePointVersion: sharePointVersion
        SharePointSitesAuthority: deploymentSettings.sharePointSitesAuthority
        EnableAnalysis: deploymentSettings.enableAnalysis
        SharePointBits: deploymentSettings.sharePointBitsSelected
      }
      privacy: {
        dataCollection: 'enable'
      }
    }
    protectedSettings: {
      configurationArguments: {
        DomainAdminCreds: {
          UserName: adminUserName
          Password: adminPassword
        }
        SPSetupCreds: {
          UserName: deploymentSettings.spSetupUserName
          Password: serviceAccountsPassword
        }
        SPFarmCreds: {
          UserName: deploymentSettings.spFarmUserName
          Password: serviceAccountsPassword
        }
        SPPassphraseCreds: {
          UserName: 'Passphrase'
          Password: serviceAccountsPassword
        }
      }
    }
  }
  dependsOn: [
    vmsSettings_vmFE
  ]
}]

resource shutdown_computevm_vmsSettings_vmDC 'Microsoft.DevTestLab/schedules@2018-09-15' = if (vmsAutoShutdownTime != '9999') {
  name: 'shutdown-computevm-${vmsSettings.vmDCName}'
  location: location
  properties: {
    status: 'Enabled'
    taskType: 'ComputeVmShutdownTask'
    dailyRecurrence: {
      time: vmsAutoShutdownTime
    }
    timeZoneId: vmsTimeZone
    notificationSettings: {
      status: 'Disabled'
      timeInMinutes: 30
    }
    targetResourceId: vmsSettings_vmDC.id
  }
}

resource shutdown_computevm_vmsSettings_vmSQL 'Microsoft.DevTestLab/schedules@2018-09-15' = if (vmsAutoShutdownTime != '9999') {
  name: 'shutdown-computevm-${vmsSettings.vmSQLName}'
  location: location
  properties: {
    status: 'Enabled'
    taskType: 'ComputeVmShutdownTask'
    dailyRecurrence: {
      time: vmsAutoShutdownTime
    }
    timeZoneId: vmsTimeZone
    notificationSettings: {
      status: 'Disabled'
      timeInMinutes: 30
    }
    targetResourceId: vmsSettings_vmSQL.id
  }
}

resource shutdown_computevm_vmsSettings_vmSP 'Microsoft.DevTestLab/schedules@2018-09-15' = if (vmsAutoShutdownTime != '9999') {
  name: 'shutdown-computevm-${vmsSettings.vmSPName}'
  location: location
  properties: {
    status: 'Enabled'
    taskType: 'ComputeVmShutdownTask'
    dailyRecurrence: {
      time: vmsAutoShutdownTime
    }
    timeZoneId: vmsTimeZone
    notificationSettings: {
      status: 'Disabled'
      timeInMinutes: 30
    }
    targetResourceId: vmsSettings_vmSP.id
  }
}

resource shutdown_computevm_vmsSettings_vmFE 'Microsoft.DevTestLab/schedules@2018-09-15' = [for i in range(0, numberOfAdditionalFrontEnd): if ((numberOfAdditionalFrontEnd >= 1) && (vmsAutoShutdownTime != '9999')) {
  name: 'shutdown-computevm-${vmsSettings.vmFEName}-${i}'
  location: location
  properties: {
    status: 'Enabled'
    taskType: 'ComputeVmShutdownTask'
    dailyRecurrence: {
      time: vmsAutoShutdownTime
    }
    timeZoneId: vmsTimeZone
    notificationSettings: {
      status: 'Disabled'
      timeInMinutes: 30
    }
    targetResourceId: resourceId('Microsoft.Compute/virtualMachines', '${vmsSettings.vmFEName}-${i}')
  }
  dependsOn: [
    vmsSettings_vmFE
  ]
}]

resource NSG_Subnet_AzureBastion 'Microsoft.Network/networkSecurityGroups@2022-07-01' = if (addAzureBastion == true) {
  name: 'NSG-Subnet-AzureBastion'
  location: location
  properties: {
    securityRules: [
      {
        name: 'AllowHttpsInBound'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: 'Internet'
          destinationPortRange: '443'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
      {
        name: 'AllowGatewayManagerInBound'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: 'GatewayManager'
          destinationPortRange: '443'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 110
          direction: 'Inbound'
        }
      }
      {
        name: 'AllowLoadBalancerInBound'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: 'AzureLoadBalancer'
          destinationPortRange: '443'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 120
          direction: 'Inbound'
        }
      }
      {
        name: 'AllowBastionHostCommunicationInBound'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationPortRanges: [
            '8080'
            '5701'
          ]
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 130
          direction: 'Inbound'
        }
      }
      {
        name: 'DenyAllInBound'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationPortRange: '*'
          destinationAddressPrefix: '*'
          access: 'Deny'
          priority: 1000
          direction: 'Inbound'
        }
      }
      {
        name: 'AllowSshRdpOutBound'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationPortRanges: [
            '22'
            '3389'
          ]
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 100
          direction: 'Outbound'
        }
      }
      {
        name: 'AllowAzureCloudCommunicationOutBound'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationPortRange: '443'
          destinationAddressPrefix: 'AzureCloud'
          access: 'Allow'
          priority: 110
          direction: 'Outbound'
        }
      }
      {
        name: 'AllowBastionHostCommunicationOutBound'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationPortRanges: [
            '8080'
            '5701'
          ]
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 120
          direction: 'Outbound'
        }
      }
      {
        name: 'AllowGetSessionInformationOutBound'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: 'Internet'
          destinationPortRanges: [
            '80'
            '443'
          ]
          access: 'Allow'
          priority: 130
          direction: 'Outbound'
        }
      }
      {
        name: 'DenyAllOutBound'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Deny'
          priority: 1000
          direction: 'Outbound'
        }
      }
    ]
  }
}

resource networkSettings_vNetPrivateName_AzureBastionSubnet 'Microsoft.Network/virtualNetworks/subnets@2022-07-01' = if (addAzureBastion == true) {
  parent: networkSettings_vNetPrivate
  name: 'AzureBastionSubnet'
  properties: {
    addressPrefix: '10.1.4.0/24'
    networkSecurityGroup: {
      id: NSG_Subnet_AzureBastion.id
    }
  }
}

resource PublicIP_Bastion 'Microsoft.Network/publicIPAddresses@2022-07-01' = if (addAzureBastion == true) {
  name: 'PublicIP-Bastion'
  location: location
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    dnsSettings: {
      domainNameLabel: toLower(replace('${resourceGroupNameFormatted}-Bastion', '_', '-'))
    }
  }
}

resource Bastion 'Microsoft.Network/bastionHosts@2022-07-01' = if (addAzureBastion == true) {
  name: 'Bastion'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'IpConf'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: PublicIP_Bastion.id
          }
          subnet: {
            id: networkSettings_vNetPrivateName_AzureBastionSubnet.id
          }
        }
      }
    ]
  }
}

output publicIPAddressSP string = vmsResourcesNames_vmSPPublicIP.properties.dnsSettings.fqdn
output publicIPAddressFEs array = [for i in range(0, numberOfAdditionalFrontEnd): reference(resourceId('Microsoft.Network/publicIPAddresses', '${vmsResourcesNames.vmFEPublicIPName}-${i}')).dnsSettings.fqdn]
output publicIPAddressSQL string = vmsResourcesNames_vmSQLPublicIP.properties.dnsSettings.fqdn
output publicIPAddressDC string = vmsResourcesNames_vmDCPublicIP.properties.dnsSettings.fqdn
output domainAdminAccount string = '${substring(domainFQDN, 0, indexOf(domainFQDN, '.'))}\\${adminUserName}'
output domainAdminAccountFormatForBastion string = '${adminUserName}@${domainFQDN}'
output localAdminAccount string = deploymentSettings.localAdminUserName
