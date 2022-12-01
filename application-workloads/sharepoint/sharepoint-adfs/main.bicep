@description('Location for all resources.')
param location string = resourceGroup().location

@description('Version of SharePoint farm to create.')
@allowed([
  '2013'
  '2016'
  '2019'
  'Subscription-RTM'
  'Subscription-22H2'
])
param sharePointVersion string = 'Subscription-22H2'

@description('"[Prefix]" of public DNS name of VMs, as used in "[Prefix]-[VMName].[region].cloudapp.azure.com"')
@minLength(2)
param dnsLabelPrefix string

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

var generalSettings = {
  vmDCName: 'DC'
  vmSQLName: 'SQL'
  vmSPName: 'SP'
  vmFEName: 'FE'
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
  localAdminUserName: 'local-${uniqueString(subscription().subscriptionId)}'
  enableAnalysis: false
  isSharePointSubscription: (startsWith(sharePointVersion, 'subscription') ? true : false)
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
  ]
}
var networkSettings = {
  vNetPrivateName: '${resourceGroup().name}-vnet'
  vNetPrivatePrefix: '10.1.0.0/16'
  subnetDCName: 'Subnet-DC'
  subnetDCPrefix: '10.1.1.0/24'
  dcPrivateIPAddress: '10.1.1.4'
  subnetSQLName: 'Subnet-SQL'
  subnetSQLPrefix: '10.1.2.0/24'
  subnetSPName: 'Subnet-SP'
  subnetSPPrefix: '10.1.3.0/24'
  nsgSubnetDCName: 'NSG-Subnet-DC'
  nsgSubnetSQLName: 'NSG-Subnet-SQL'
  nsgSubnetSPName: 'NSG-Subnet-SP'
  vmDCPublicIPNicAssociation: {
    id: vmPublicIP.id
  }
  vmSQLPublicIPNicAssociation: {
    id: vmSQL_vmPublicIP.id
  }
  vmSPPublicIPNicAssociation: {
    id: vmSP_vmPublicIP.id
  }
  nsgRuleAllowIncomingTraffic: [
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
var vmDCSettings = {
  vmImagePublisher: 'MicrosoftWindowsServer'
  vmImageOffer: 'WindowsServer'
  vmImageSKU: '2022-datacenter-azure-edition-smalldisk'
  vmOSDiskName: 'Disk-DC-OS'
  vmVmSize: vmDCSize
  vmNicName: 'NIC-${generalSettings.vmDCName}-0'
  vmPublicIPName: 'PublicIP-${generalSettings.vmDCName}'
  vmPublicIPDnsName: toLower(replace('${dnsLabelPrefix}-${generalSettings.vmDCName}', '_', '-'))
  shutdownResourceName: 'shutdown-computevm-${generalSettings.vmDCName}'
}
var vmSQLSettings = {
  vmImagePublisher: 'MicrosoftSQLServer'
  vmImageOffer: 'sql2019-ws2022'
  vmImageSKU: 'sqldev-gen2'
  vmOSDiskName: 'Disk-SQL-OS'
  vmVmSize: vmSQLSize
  vmNicName: 'NIC-${generalSettings.vmSQLName}-0'
  vmPublicIPName: 'PublicIP-${generalSettings.vmSQLName}'
  vmPublicIPDnsName: toLower(replace('${dnsLabelPrefix}-${generalSettings.vmSQLName}', '_', '-'))
  shutdownResourceName: 'shutdown-computevm-${generalSettings.vmSQLName}'
}
var vmSPSettings = {
  vmImagePublisher: (generalSettings.isSharePointSubscription ? 'MicrosoftWindowsServer' : 'MicrosoftSharePoint')
  vmImageOffer: (generalSettings.isSharePointSubscription ? 'WindowsServer' : 'MicrosoftSharePointServer')
  vmImageSKU: (generalSettings.isSharePointSubscription ? '2022-datacenter-azure-edition' : 'sp${sharePointVersion}')
  vmOSDiskName: 'Disk-SP-OS'
  vmDataDiskName: 'Disk-SP-Data'
  vmVmSize: vmSPSize
  vmNicName: 'NIC-${generalSettings.vmSPName}-0'
  vmPublicIPName: 'PublicIP-${generalSettings.vmSPName}'
  vmPublicIPDnsName: toLower(replace('${dnsLabelPrefix}-${generalSettings.vmSPName}', '_', '-'))
  shutdownResourceName: 'shutdown-computevm-${generalSettings.vmSPName}'
}
var vmFESettings = {
  vmOSDiskName: 'Disk-FE-OS'
  vmDataDiskName: 'Disk-FE-Data'
  vmNicName: 'NIC-${generalSettings.vmFEName}-0'
  vmPublicIPName: 'PublicIP-${generalSettings.vmFEName}'
  vmPublicIPDnsName: toLower(replace('${dnsLabelPrefix}-${generalSettings.vmFEName}', '_', '-'))
  shutdownResourceName: 'shutdown-computevm-${generalSettings.vmFEName}'
}
var dscConfigureDCVM = {
  scriptFileUri: uri(_artifactsLocation, 'dsc/ConfigureDCVM.zip${_artifactsLocationSasToken}')
  script: 'ConfigureDCVM.ps1'
  function: 'ConfigureDCVM'
  forceUpdateTag: '1.0'
}
var dscConfigureSQLVM = {
  scriptFileUri: uri(_artifactsLocation, 'dsc/ConfigureSQLVM.zip${_artifactsLocationSasToken}')
  script: 'ConfigureSQLVM.ps1'
  function: 'ConfigureSQLVM'
  forceUpdateTag: '1.0'
}
var dscConfigureSPVM = {
  scriptFileUri: uri(_artifactsLocation, format('{0}{1}', (generalSettings.isSharePointSubscription ? 'dsc/ConfigureSPSE.zip' : 'dsc/ConfigureSPLegacy.zip'), _artifactsLocationSasToken))
  script: (generalSettings.isSharePointSubscription ? 'ConfigureSPSE.ps1' : 'ConfigureSPLegacy.ps1')
  function: 'ConfigureSPVM'
  forceUpdateTag: '1.0'
  sharePointBitsSelected: (generalSettings.isSharePointSubscription ? generalSettings.sharePointSubscriptionBits : 'fake')
}
var dscConfigureFEVM = {
  scriptFileUri: uri(_artifactsLocation, format('{0}{1}', (generalSettings.isSharePointSubscription ? 'dsc/ConfigureFESE.zip' : 'dsc/ConfigureFELegacy.zip'), _artifactsLocationSasToken))
  script: (generalSettings.isSharePointSubscription ? 'ConfigureFESE.ps1' : 'ConfigureFELegacy.ps1')
  function: 'ConfigureFEVM'
  forceUpdateTag: '1.0'
}
var vmSPDataDisk = [
  {
    lun: 0
    name: vmSPSettings.vmDataDiskName
    caching: 'ReadWrite'
    createOption: 'Empty'
    diskSizeGB: sharePointDataDiskSize
  }
]
var azureBastion = {
  subnetPrefix: '10.1.4.0/24'
  publicIPDnsName: toLower(replace('${dnsLabelPrefix}-Bastion', '_', '-'))
}

resource nsgSubnetDC 'Microsoft.Network/networkSecurityGroups@2022-05-01' = {
  name: networkSettings.nsgSubnetDCName
  location: location
  properties: {
    securityRules: ((toLower(RDPTrafficAllowed) == 'no') ? json('null') : networkSettings.nsgRuleAllowIncomingTraffic)
  }
}

resource nsgSubnetSQL 'Microsoft.Network/networkSecurityGroups@2022-05-01' = {
  name: networkSettings.nsgSubnetSQLName
  location: location
  properties: {
    securityRules: ((toLower(RDPTrafficAllowed) == 'no') ? json('null') : networkSettings.nsgRuleAllowIncomingTraffic)
  }
}

resource nsgSubnetSP 'Microsoft.Network/networkSecurityGroups@2022-05-01' = {
  name: networkSettings.nsgSubnetSPName
  location: location
  properties: {
    securityRules: ((toLower(RDPTrafficAllowed) == 'no') ? json('null') : networkSettings.nsgRuleAllowIncomingTraffic)
  }
}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2022-05-01' = {
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
            id: nsgSubnetDC.id
          }
        }
      }
      {
        name: networkSettings.subnetSQLName
        properties: {
          addressPrefix: networkSettings.subnetSQLPrefix
          networkSecurityGroup: {
            id: nsgSubnetSQL.id
          }
        }
      }
      {
        name: networkSettings.subnetSPName
        properties: {
          addressPrefix: networkSettings.subnetSPPrefix
          networkSecurityGroup: {
            id: nsgSubnetSP.id
          }
        }
      }
    ]
  }
}

resource vmPublicIP 'Microsoft.Network/publicIPAddresses@2022-05-01' = if (addPublicIPAddress == 'Yes') {
  name: vmDCSettings.vmPublicIPName
  location: location
  sku: {
    name: 'Basic'
    tier: 'Regional'
  }
  properties: {
    publicIPAllocationMethod: 'Dynamic'
    dnsSettings: {
      domainNameLabel: vmDCSettings.vmPublicIPDnsName
    }
  }
}

resource vmNic 'Microsoft.Network/networkInterfaces@2022-05-01' = {
  name: vmDCSettings.vmNicName
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
          publicIPAddress: ((addPublicIPAddress == 'Yes') ? networkSettings.vmDCPublicIPNicAssociation : json('null'))
        }
      }
    ]
  }
  dependsOn: [
    virtualNetwork

  ]
}

resource vmDC 'Microsoft.Compute/virtualMachines@2022-08-01' = {
  name: generalSettings.vmDCName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmDCSettings.vmVmSize
    }
    osProfile: {
      computerName: generalSettings.vmDCName
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
        publisher: vmDCSettings.vmImagePublisher
        offer: vmDCSettings.vmImageOffer
        sku: vmDCSettings.vmImageSKU
        version: 'latest'
      }
      osDisk: {
        name: vmDCSettings.vmOSDiskName
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
          id: vmNic.id
        }
      ]
    }
    licenseType: (enableHybridBenefitServerLicenses ? 'Windows_Server' : json('null'))
  }
}

resource configureDCVM 'Microsoft.Compute/virtualMachines/extensions@2022-08-01' = {
  name: '${generalSettings.vmDCName}/ConfigureDCVM'
  location: location
  properties: {
    publisher: 'Microsoft.Powershell'
    type: 'DSC'
    typeHandlerVersion: '2.9'
    autoUpgradeMinorVersion: true
    forceUpdateTag: dscConfigureDCVM.forceUpdateTag
    settings: {
      wmfVersion: 'latest'
      configuration: {
        url: dscConfigureDCVM.scriptFileUri
        script: dscConfigureDCVM.script
        function: dscConfigureDCVM.function
      }
      configurationArguments: {
        domainFQDN: domainFQDN
        PrivateIP: networkSettings.dcPrivateIPAddress
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
          UserName: generalSettings.adfsSvcUserName
          Password: serviceAccountsPassword
        }
      }
    }
  }
  dependsOn: [
    vmDC
  ]
}

resource vmSQL_vmPublicIP 'Microsoft.Network/publicIPAddresses@2022-05-01' = if (addPublicIPAddress == 'Yes') {
  name: vmSQLSettings.vmPublicIPName
  location: location
  sku: {
    name: 'Basic'
    tier: 'Regional'
  }
  properties: {
    publicIPAllocationMethod: 'Dynamic'
    dnsSettings: {
      domainNameLabel: vmSQLSettings.vmPublicIPDnsName
    }
  }
}

resource vmSQL_vmNic 'Microsoft.Network/networkInterfaces@2022-05-01' = {
  name: vmSQLSettings.vmNicName
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
          publicIPAddress: ((addPublicIPAddress == 'Yes') ? networkSettings.vmSQLPublicIPNicAssociation : json('null'))
        }
      }
    ]
  }
  dependsOn: [
    virtualNetwork

  ]
}

resource vmSQL 'Microsoft.Compute/virtualMachines@2022-08-01' = {
  name: generalSettings.vmSQLName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSQLSettings.vmVmSize
    }
    osProfile: {
      computerName: generalSettings.vmSQLName
      adminUsername: generalSettings.localAdminUserName
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
        publisher: vmSQLSettings.vmImagePublisher
        offer: vmSQLSettings.vmImageOffer
        sku: vmSQLSettings.vmImageSKU
        version: 'latest'
      }
      osDisk: {
        name: vmSQLSettings.vmOSDiskName
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
          id: vmSQL_vmNic.id
        }
      ]
    }
    licenseType: (enableHybridBenefitServerLicenses ? 'Windows_Server' : json('null'))
  }
}

resource vmSP_vmPublicIP 'Microsoft.Network/publicIPAddresses@2022-05-01' = if ((addPublicIPAddress == 'Yes') || (addPublicIPAddress == 'SharePointVMsOnly')) {
  name: vmSPSettings.vmPublicIPName
  location: location
  sku: {
    name: 'Basic'
    tier: 'Regional'
  }
  properties: {
    publicIPAllocationMethod: 'Dynamic'
    dnsSettings: {
      domainNameLabel: vmSPSettings.vmPublicIPDnsName
    }
  }
}

resource vmSP_vmNic 'Microsoft.Network/networkInterfaces@2022-05-01' = {
  name: vmSPSettings.vmNicName
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
          publicIPAddress: (((addPublicIPAddress == 'Yes') || (addPublicIPAddress == 'SharePointVMsOnly')) ? networkSettings.vmSPPublicIPNicAssociation : json('null'))
        }
      }
    ]
  }
  dependsOn: [
    virtualNetwork

  ]
}

resource vmSP 'Microsoft.Compute/virtualMachines@2022-08-01' = {
  name: generalSettings.vmSPName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSPSettings.vmVmSize
    }
    osProfile: {
      computerName: generalSettings.vmSPName
      adminUsername: generalSettings.localAdminUserName
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
        publisher: vmSPSettings.vmImagePublisher
        offer: vmSPSettings.vmImageOffer
        sku: vmSPSettings.vmImageSKU
        version: 'latest'
      }
      osDisk: {
        name: vmSPSettings.vmOSDiskName
        caching: 'ReadWrite'
        osType: 'Windows'
        createOption: 'FromImage'
        diskSizeGB: 128
        managedDisk: {
          storageAccountType: vmSPStorageAccountType
        }
      }
      dataDisks: ((sharePointDataDiskSize == 0) ? json('null') : vmSPDataDisk)
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: vmSP_vmNic.id
        }
      ]
    }
    licenseType: (enableHybridBenefitServerLicenses ? 'Windows_Server' : json('null'))
  }
}

resource configureSQLVM 'Microsoft.Compute/virtualMachines/extensions@2022-08-01' = {
  name: '${generalSettings.vmSQLName}/ConfigureSQLVM'
  location: location
  properties: {
    publisher: 'Microsoft.Powershell'
    type: 'DSC'
    typeHandlerVersion: '2.9'
    autoUpgradeMinorVersion: true
    forceUpdateTag: dscConfigureSQLVM.forceUpdateTag
    settings: {
      wmfVersion: 'latest'
      configuration: {
        url: dscConfigureSQLVM.scriptFileUri
        script: dscConfigureSQLVM.script
        function: dscConfigureSQLVM.function
      }
      configurationArguments: {
        DNSServer: networkSettings.dcPrivateIPAddress
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
          UserName: generalSettings.sqlSvcUserName
          Password: serviceAccountsPassword
        }
        SPSetupCreds: {
          UserName: generalSettings.spSetupUserName
          Password: serviceAccountsPassword
        }
      }
    }
  }
  dependsOn: [
    vmSQL
  ]
}

resource configureSPVM 'Microsoft.Compute/virtualMachines/extensions@2022-08-01' = {
  name: '${generalSettings.vmSPName}/ConfigureSPVM'
  location: location
  properties: {
    publisher: 'Microsoft.Powershell'
    type: 'DSC'
    typeHandlerVersion: '2.9'
    autoUpgradeMinorVersion: true
    forceUpdateTag: dscConfigureSPVM.forceUpdateTag
    settings: {
      wmfVersion: 'latest'
      configuration: {
        url: dscConfigureSPVM.scriptFileUri
        script: dscConfigureSPVM.script
        function: dscConfigureSPVM.function
      }
      configurationArguments: {
        DNSServer: networkSettings.dcPrivateIPAddress
        DomainFQDN: domainFQDN
        DCName: generalSettings.vmDCName
        SQLName: generalSettings.vmSQLName
        SQLAlias: generalSettings.sqlAlias
        SharePointVersion: sharePointVersion
        EnableAnalysis: generalSettings.enableAnalysis
        SharePointBits: dscConfigureSPVM.sharePointBitsSelected
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
          UserName: generalSettings.spSetupUserName
          Password: serviceAccountsPassword
        }
        SPFarmCreds: {
          UserName: generalSettings.spFarmUserName
          Password: serviceAccountsPassword
        }
        SPSvcCreds: {
          UserName: generalSettings.spSvcUserName
          Password: serviceAccountsPassword
        }
        SPAppPoolCreds: {
          UserName: generalSettings.spAppPoolUserName
          Password: serviceAccountsPassword
        }
        SPADDirSyncCreds: {
          UserName: generalSettings.spADDirSyncUserName
          Password: serviceAccountsPassword
        }
        SPPassphraseCreds: {
          UserName: 'Passphrase'
          Password: serviceAccountsPassword
        }
        SPSuperUserCreds: {
          UserName: generalSettings.spSuperUserName
          Password: serviceAccountsPassword
        }
        SPSuperReaderCreds: {
          UserName: generalSettings.spSuperReaderName
          Password: serviceAccountsPassword
        }
      }
    }
  }
  dependsOn: [
    vmSP
  ]
}

resource vmFE_vmPublicIP 'Microsoft.Network/publicIPAddresses@2022-05-01' = [for i in range(0, numberOfAdditionalFrontEnd): if ((numberOfAdditionalFrontEnd >= 1) && ((addPublicIPAddress == 'Yes') || (addPublicIPAddress == 'SharePointVMsOnly'))) {
  name: '${vmFESettings.vmPublicIPName}-${i}'
  location: location
  sku: {
    name: 'Basic'
    tier: 'Regional'
  }
  properties: {
    publicIPAllocationMethod: 'Dynamic'
    dnsSettings: {
      domainNameLabel: '${vmFESettings.vmPublicIPDnsName}-${i}'
    }
  }
}]

resource vmFE_vmNic 'Microsoft.Network/networkInterfaces@2022-05-01' = [for i in range(0, numberOfAdditionalFrontEnd): if (numberOfAdditionalFrontEnd >= 1) {
  name: '${vmFESettings.vmNicName}-${i}'
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
          publicIPAddress: (((addPublicIPAddress == 'Yes') || (addPublicIPAddress == 'SharePointVMsOnly')) ? json('{"id": "${resourceId('Microsoft.Network/publicIPAddresses', '${vmFESettings.vmPublicIPName}-${i}')}" }') : json('null'))
        }
      }
    ]
  }
  dependsOn: [
    virtualNetwork
    vmFE_vmPublicIP
  ]
}]

resource vmFE 'Microsoft.Compute/virtualMachines@2022-08-01' = [for i in range(0, numberOfAdditionalFrontEnd): if (numberOfAdditionalFrontEnd >= 1) {
  name: '${generalSettings.vmFEName}-${i}'
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSPSettings.vmVmSize
    }
    osProfile: {
      computerName: '${generalSettings.vmFEName}-${i}'
      adminUsername: generalSettings.localAdminUserName
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
        publisher: vmSPSettings.vmImagePublisher
        offer: vmSPSettings.vmImageOffer
        sku: vmSPSettings.vmImageSKU
        version: 'latest'
      }
      osDisk: {
        name: '${vmFESettings.vmOSDiskName}-${i}'
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
          id: resourceId('Microsoft.Network/networkInterfaces', '${vmFESettings.vmNicName}-${i}')
        }
      ]
    }
    licenseType: (enableHybridBenefitServerLicenses ? 'Windows_Server' : json('null'))
  }
  dependsOn: [
    vmFE_vmNic
  ]
}]

resource configureFEVM 'Microsoft.Compute/virtualMachines/extensions@2022-08-01' = [for i in range(0, numberOfAdditionalFrontEnd): if (numberOfAdditionalFrontEnd >= 1) {
  name: '${generalSettings.vmFEName}-${i}/ConfigureFEVM'
  location: location
  properties: {
    publisher: 'Microsoft.Powershell'
    type: 'DSC'
    typeHandlerVersion: '2.9'
    autoUpgradeMinorVersion: true
    forceUpdateTag: dscConfigureFEVM.forceUpdateTag
    settings: {
      wmfVersion: 'latest'
      configuration: {
        url: dscConfigureFEVM.scriptFileUri
        script: dscConfigureFEVM.script
        function: dscConfigureFEVM.function
      }
      configurationArguments: {
        DNSServer: networkSettings.dcPrivateIPAddress
        DomainFQDN: domainFQDN
        DCName: generalSettings.vmDCName
        SQLName: generalSettings.vmSQLName
        SQLAlias: generalSettings.sqlAlias
        SharePointVersion: sharePointVersion
        EnableAnalysis: generalSettings.enableAnalysis
        SharePointBits: dscConfigureSPVM.sharePointBitsSelected
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
          UserName: generalSettings.spSetupUserName
          Password: serviceAccountsPassword
        }
        SPFarmCreds: {
          UserName: generalSettings.spFarmUserName
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
    vmFE
  ]
}]

resource vmDC_shutdownResource 'Microsoft.DevTestLab/schedules@2018-09-15' = if (vmsAutoShutdownTime != '9999') {
  name: vmDCSettings.shutdownResourceName
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
    targetResourceId: vmDC.id
  }
}

resource vmSQL_shutdownResource 'Microsoft.DevTestLab/schedules@2018-09-15' = if (vmsAutoShutdownTime != '9999') {
  name: vmSQLSettings.shutdownResourceName
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
    targetResourceId: vmSQL.id
  }
}

resource vmSP_shutdownResource 'Microsoft.DevTestLab/schedules@2018-09-15' = if (vmsAutoShutdownTime != '9999') {
  name: vmSPSettings.shutdownResourceName
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
    targetResourceId: vmSP.id
  }
}

resource vmFE_shutdownResource 'Microsoft.DevTestLab/schedules@2018-09-15' = [for i in range(0, numberOfAdditionalFrontEnd): if ((numberOfAdditionalFrontEnd >= 1) && (vmsAutoShutdownTime != '9999')) {
  name: '${vmFESettings.shutdownResourceName}-${i}'
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
    targetResourceId: resourceId('Microsoft.Compute/virtualMachines', '${generalSettings.vmFEName}-${i}')
  }
  dependsOn: [
    vmFE
  ]
}]

resource NSG_Subnet_AzureBastion 'Microsoft.Network/networkSecurityGroups@2022-01-01' = if (addAzureBastion == true) {
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

resource bastionSubnet 'Microsoft.Network/virtualNetworks/subnets@2022-05-01' = if (addAzureBastion == true) {
  name: '${networkSettings.vNetPrivateName}/AzureBastionSubnet'
  location: location
  properties: {
    addressPrefix: azureBastion.subnetPrefix
    networkSecurityGroup: {
      id: NSG_Subnet_AzureBastion.id
    }
  }
  dependsOn: [
    virtualNetwork

  ]
}

resource PublicIP_Bastion 'Microsoft.Network/publicIPAddresses@2022-05-01' = if (addAzureBastion == true) {
  name: 'PublicIP-Bastion'
  location: location
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    dnsSettings: {
      domainNameLabel: azureBastion.publicIPDnsName
    }
  }
}

resource Bastion 'Microsoft.Network/bastionHosts@2022-05-01' = if (addAzureBastion == true) {
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
            id: bastionSubnet.id
          }
        }
      }
    ]
  }
}

output publicIPAddressSP string = vmSP_vmPublicIP.properties.dnsSettings.fqdn
output publicIPAddressFEs array = [for i in range(0, numberOfAdditionalFrontEnd): reference(resourceId('Microsoft.Network/publicIPAddresses', '${vmFESettings.vmPublicIPName}-${i}')).dnsSettings.fqdn]
output publicIPAddressSQL string = vmSQL_vmPublicIP.properties.dnsSettings.fqdn
output publicIPAddressDC string = vmPublicIP.properties.dnsSettings.fqdn
output domainAdminAccount string = '${substring(domainFQDN, 0, indexOf(domainFQDN, '.'))}\\${adminUserName}'
output domainAdminAccountFormatForBastion string = '${adminUserName}@${domainFQDN}'
output localAdminAccount string = generalSettings.localAdminUserName
