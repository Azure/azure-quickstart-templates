metadata description = 'Create a DC, a SQL Server 2022, and from 1 to 5 server(s) hosting a SharePoint Subscription / 2019 / 2016 farm with an extensive configuration, including trusted authentication, user profiles with personal sites, an OAuth trust (using a certificate), a dedicated IIS site for hosting high-trust add-ins, etc... The latest version of key softwares (including Fiddler, vscode, np++, 7zip, ULS Viewer) is installed. SharePoint machines have additional fine-tuning to make them immediately usable (remote administration tools, custom policies for Edge and Chrome, shortcuts, etc...).'
metadata author = 'Yvand'

@description('Location for all the resources.')
param location string = resourceGroup().location

@description('Version of the SharePoint farm to create.')
@allowed([
  'Subscription-Latest'
  'Subscription-24H2'
  'Subscription-24H1'
  'Subscription-23H2'
  'Subscription-23H1'
  'Subscription-22H2'
  'Subscription-RTM'
  '2019'
  '2016'
])
param sharePointVersion string = 'Subscription-Latest'

@description('FQDN of the Active Directory forest.')
@minLength(5)
param domainFqdn string = 'contoso.local'

@description('Number of servers with MinRole Front-end to add to the farm.')
@allowed([
  0
  1
  2
  3
  4
])
param frontEndServersCount int = 0

@description('Name of the Active Directory and SharePoint administrator. "admin" and "administrator" are not allowed.')
@minLength(1)
param adminUsername string

@description('Password for the admin account. Input must meet password complexity requirements as documented in https://learn.microsoft.com/azure/virtual-machines/windows/faq#what-are-the-password-requirements-when-creating-a-vm-')
@minLength(8)
@secure()
param adminPassword string

@description('Password for all the other accounts and the SharePoint passphrase. Input must meet password complexity requirements as documented in https://learn.microsoft.com/azure/virtual-machines/windows/faq#what-are-the-password-requirements-when-creating-a-vm-')
@minLength(8)
@secure()
param otherAccountsPassword string

@description('''
Specify if a rule in the network security groups should allow the inbound RDP traffic:
- "No" (default): No rule is created, RDP traffic is blocked.
- "*" or "Internet": RDP traffic is allowed from everywhere.
- CIDR notation (e.g. 192.168.99.0/24 or 2001:1234::/64) or an IP address (e.g. 192.168.99.0 or 2001:1234::): RDP traffic is allowed from the IP address / pattern specified.
''')
@minLength(1)
param rdpTrafficRule string = 'No'

@description('''
Select how the virtual machines connect to internet.
IMPORTANT: With AzureFirewallProxy, you need to either enable Azure Bastion, or manually add a public IP address to a virtual machine, to be able to connect to it.
''')
@allowed([
  'PublicIPAddress'
  'AzureFirewallProxy'
])
param outboundAccessMethod string = 'PublicIPAddress'

@description('Set if the Public IP addresses of virtual machines should have a name label.')
@allowed([
  'No'
  'SharePointVMsOnly'
  'Yes'
])
param addNameToPublicIpAddresses string = 'SharePointVMsOnly'

@description('Specify if Azure Bastion should be provisioned. See https://azure.microsoft.com/en-us/services/azure-bastion for more information.')
param enableAzureBastion bool = false

@description('Enable the Azure Hybrid Benefit on virtual machines, to use your on-premises Windows Server licenses and reduce cost. See https://docs.microsoft.com/en-us/azure/virtual-machines/windows/hybrid-use-benefit-licensing for more information.')
param enableHybridBenefitServerLicenses bool = false

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
param timeZone string = 'Romance Standard Time'

@description('The time (24h HHmm format) at which the virtual machines will automatically be shutdown and deallocated. Set value to "9999" to NOT configure the auto shutdown.')
@minLength(4)
@maxLength(4)
param autoShutdownTime string = '1900'

@description('Size of the DC virtual machine.')
param vmDcSize string = 'Standard_B2als_v2'

@description('Type of storage for the managed disk. Visit https://docs.microsoft.com/en-us/rest/api/compute/disks/list#diskstorageaccounttypes for more information.')
@allowed([
  'Standard_LRS'
  'StandardSSD_LRS'
  'StandardSSD_ZRS'
  'Premium_LRS'
  'PremiumV2_LRS'
  'Premium_ZRS'
  'UltraSSD_LRS'
])
param vmDcStorage string = 'StandardSSD_LRS'

@description('Size of the SQL virtual machine.')
param vmSqlSize string = 'Standard_B2as_v2'

@description('Type of storage for the managed disk. Visit https://docs.microsoft.com/en-us/rest/api/compute/disks/list#diskstorageaccounttypes for more information.')
@allowed([
  'Standard_LRS'
  'StandardSSD_LRS'
  'StandardSSD_ZRS'
  'Premium_LRS'
  'PremiumV2_LRS'
  'Premium_ZRS'
  'UltraSSD_LRS'
])
param vmSqlStorage string = 'StandardSSD_LRS'

@description('Size of the SharePoint virtual machine(s).')
param vmSharePointSize string = 'Standard_B4as_v2'

@description('Type of storage for the managed disk. Visit https://docs.microsoft.com/en-us/rest/api/compute/disks/list#diskstorageaccounttypes for more information.')
@allowed([
  'Standard_LRS'
  'StandardSSD_LRS'
  'StandardSSD_ZRS'
  'Premium_LRS'
  'PremiumV2_LRS'
  'Premium_ZRS'
  'UltraSSD_LRS'
])
param vmSharePointStorage string = 'StandardSSD_LRS'

@description('The base URI where artifacts required by this template are located. When the template is deployed using the accompanying scripts, a private location in the subscription will be used and this value will be automatically generated.')
param _artifactsLocation string = deployment().properties.templateLink.uri

@description('The sasToken required to access _artifactsLocation. When the template is deployed using the accompanying scripts, a sasToken will be automatically generated.')
@secure()
param _artifactsLocationSasToken string = ''

// Local variables
var resourceGroupNameFormatted = replace(
  replace(replace(replace(resourceGroup().name, '.', '-'), '(', '-'), ')', '-'),
  '_',
  '-'
)
var sharePointSettings = {
  isSharePointSubscription: (startsWith(sharePointVersion, 'subscription') ? true : false)
  sharePointImagesList: {
    Subscription: 'MicrosoftWindowsServer:WindowsServer:2025-datacenter-azure-edition:latest'
    sp2019: 'MicrosoftSharePoint:MicrosoftSharePointServer:sp2019gen2smalldisk:latest'
    sp2016: 'MicrosoftSharePoint:MicrosoftSharePointServer:sp2016:latest'
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
      Label: '23H1'
      Packages: [
        {
          DownloadUrl: 'https://download.microsoft.com/download/c/6/a/c6a17105-3d86-42ad-888d-49b22383bfa1/uber-subscription-kb5002355-fullfile-x64-glb.exe'
        }
      ]
    }
    {
      Label: '23H2'
      Packages: [
        {
          DownloadUrl: 'https://download.microsoft.com/download/f/5/5/f5559e3f-8b24-419f-b238-b09cf986e927/uber-subscription-kb5002474-fullfile-x64-glb.exe'
        }
      ]
    }
    {
      Label: '24H1'
      Packages: [
        {
          DownloadUrl: 'https://download.microsoft.com/download/b/a/b/bab0c7cc-0454-474b-8538-7927f75e6486/uber-subscription-kb5002564-fullfile-x64-glb.exe'
        }
      ]
    }
    {
      Label: '24H2'
      Packages: [
        {
          DownloadUrl: 'https://download.microsoft.com/download/6/6/a/66a0057f-79af-4307-8263-103ee75ef5c6/uber-subscription-kb5002640-fullfile-x64-glb.exe'
        }
      ]
    }
    {
      Label: 'Latest'
      Packages: [
        {
          DownloadUrl: 'https://download.microsoft.com/download/1/5/a/15a07d07-02eb-4abb-a3fc-f6ba153fed91/uber-subscription-kb5002676-fullfile-x64-glb.exe'
        }
      ]
    }
  ]
}

var networkSettings = {
  vNetPrivatePrefix: '10.1.0.0/16'
  mainSubnetName: 'vnet-subnet-main'
  mainSubnetPrefix: '10.1.1.0/24'
  dcPrivateIPAddress: '10.1.1.4'
  nsgRuleAllowIncomingRdp: [
    {
      name: 'nsg-rule-allow-rdp'
      properties: {
        description: 'Allow RDP'
        protocol: 'Tcp'
        sourcePortRange: '*'
        destinationPortRange: '3389'
        sourceAddressPrefix: rdpTrafficRule
        destinationAddressPrefix: '*'
        access: 'Allow'
        priority: 110
        direction: 'Inbound'
      }
    }
  ]
}
var vmsSettings = {
  enableAutomaticUpdates: true
  vmDCName: 'DC'
  vmSQLName: 'SQL'
  vmSPName: 'SP'
  vmFEName: 'FE'
  vmDCImage: 'MicrosoftWindowsServer:WindowsServer:2025-datacenter-azure-edition-smalldisk:latest'
  vmSQLImage: 'MicrosoftSQLServer:sql2022-ws2022:sqldev-gen2:latest'
  vmSharePointImage: (sharePointSettings.isSharePointSubscription
    ? sharePointSettings.sharePointImagesList.Subscription
    : ((sharePointVersion == '2019')
        ? sharePointSettings.sharePointImagesList.sp2019
        : sharePointSettings.sharePointImagesList.sp2016))
  vmSharePointSecurityProfile: sharePointVersion == '2016'
    ? null
    : {
        securityType: 'TrustedLaunch'
        uefiSettings: {
          secureBootEnabled: true
          vTpmEnabled: true
        }
      }
}

var dscSettings = {
  forceUpdateTag: '1.0'
  vmDCScriptFileUri: uri(_artifactsLocation, 'dsc/ConfigureDCVM.zip${_artifactsLocationSasToken}')
  vmDCScript: 'ConfigureDCVM.ps1'
  vmDCFunction: 'ConfigureDCVM'
  vmSQLScriptFileUri: uri(_artifactsLocation, 'dsc/ConfigureSQLVM.zip${_artifactsLocationSasToken}')
  vmSQLScript: 'ConfigureSQLVM.ps1'
  vmSQLFunction: 'ConfigureSQLVM'
  vmSPScriptFileUri: uri(
    _artifactsLocation,
    '${(sharePointSettings.isSharePointSubscription ? 'dsc/ConfigureSPSE.zip' : 'dsc/ConfigureSPLegacy.zip')}${_artifactsLocationSasToken}'
  )
  vmSPScript: (sharePointSettings.isSharePointSubscription ? 'ConfigureSPSE.ps1' : 'ConfigureSPLegacy.ps1')
  vmSPFunction: 'ConfigureSPVM'
  vmFEScriptFileUri: uri(
    _artifactsLocation,
    '${(sharePointSettings.isSharePointSubscription ? 'dsc/ConfigureFESE.zip' : 'dsc/ConfigureFELegacy.zip')}${_artifactsLocationSasToken}'
  )
  vmFEScript: (sharePointSettings.isSharePointSubscription ? 'ConfigureFESE.ps1' : 'ConfigureFELegacy.ps1')
  vmFEFunction: 'ConfigureFEVM'
}

var deploymentSettings = {
  sharePointSitesAuthority: 'spsites'
  sharePointCentralAdminPort: 5000
  sharePointBitsSelected: (sharePointSettings.isSharePointSubscription
    ? sharePointSettings.sharePointSubscriptionBits
    : '')
  localAdminUserName: 'l-${uniqueString(subscription().subscriptionId)}'
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

var firewall_proxy_settings = {
  vNetAzureFirewallPrefix: '10.1.3.0/24'
  azureFirewallIPAddress: '10.1.3.4'
  http_port: 8080
  https_port: 8443
}

// Single-line PowerShell script that runs on the VMs to update their proxy settings, if Azure Firewall is enabled
var set_proxy_script = 'param([string]$proxyIp, [string]$proxyHttpPort, [string]$proxyHttpsPort, [string]$localDomainFqdn) $proxy = "http={0}:{1};https={0}:{2}" -f $proxyIp, $proxyHttpPort, $proxyHttpsPort; $bypasslist = "*.{0};<local>" -f $localDomainFqdn; netsh winhttp set proxy proxy-server=$proxy bypass-list=$bypasslist; $proxyEnabled = 1; New-ItemProperty -Path "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows\\CurrentVersion\\Internet Settings" -Name "ProxySettingsPerUser" -PropertyType DWORD -Value 0 -Force; $proxyBytes = [system.Text.Encoding]::ASCII.GetBytes($proxy); $bypassBytes = [system.Text.Encoding]::ASCII.GetBytes($bypasslist); $defaultConnectionSettings = [byte[]]@(@(70, 0, 0, 0, 0, 0, 0, 0, $proxyEnabled, 0, 0, 0, $proxyBytes.Length, 0, 0, 0) + $proxyBytes + @($bypassBytes.Length, 0, 0, 0) + $bypassBytes + @(1..36 | % { 0 })); $registryPaths = @("HKLM:\\Software\\Microsoft\\Windows\\CurrentVersion\\Internet Settings", "HKLM:\\Software\\WOW6432Node\\Microsoft\\Windows\\CurrentVersion\\Internet Settings"); foreach ($registryPath in $registryPaths) { Set-ItemProperty -Path $registryPath -Name ProxyServer -Value $proxy; Set-ItemProperty -Path $registryPath -Name ProxyEnable -Value $proxyEnabled; Set-ItemProperty -Path $registryPath -Name ProxyOverride -Value $bypasslist; Set-ItemProperty -Path "$registryPath\\Connections" -Name DefaultConnectionSettings -Value $defaultConnectionSettings; } Bitsadmin /util /setieproxy localsystem MANUAL_PROXY $proxy $bypasslist;'

// Start creating resources
// Network security groups for each subnet
resource nsg_subnet_main 'Microsoft.Network/networkSecurityGroups@2023-11-01' = {
  name: 'vnet-subnet-dc-nsg'
  location: location
  properties: {
    securityRules: ((toLower(rdpTrafficRule) == 'no') ? null : networkSettings.nsgRuleAllowIncomingRdp)
  }
}

// Setup the network
resource virtual_network 'Microsoft.Network/virtualNetworks@2023-11-01' = {
  name: 'vnet-${uniqueString(resourceGroup().id)}'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        networkSettings.vNetPrivatePrefix
      ]
    }
    subnets: [
      {
        name: networkSettings.mainSubnetName
        properties: {
          defaultOutboundAccess: false
          addressPrefix: networkSettings.mainSubnetPrefix
          networkSecurityGroup: {
            id: nsg_subnet_main.id
          }
        }
      }
    ]
  }
}

// Create resources for VM DC
resource vm_dc_pip 'Microsoft.Network/publicIPAddresses@2023-11-01' = if (outboundAccessMethod == 'PublicIPAddress') {
  name: 'vm-dc-pip'
  location: location
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    dnsSettings: addNameToPublicIpAddresses == 'Yes'
      ? {
          domainNameLabel: toLower('${resourceGroupNameFormatted}-${vmsSettings.vmDCName}')
        }
      : null
  }
}

resource vm_dc_nic 'Microsoft.Network/networkInterfaces@2023-11-01' = {
  name: 'vm-dc-nic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Static'
          privateIPAddress: networkSettings.dcPrivateIPAddress
          subnet: {
            id: resourceId(
              'Microsoft.Network/virtualNetworks/subnets',
              virtual_network.name,
              networkSettings.mainSubnetName
            )
          }
          publicIPAddress: ((outboundAccessMethod == 'PublicIPAddress') ? { id: vm_dc_pip.id } : null)
        }
      }
    ]
  }
}

resource vm_dc_def 'Microsoft.Compute/virtualMachines@2024-07-01' = {
  name: 'vm-dc'
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmDcSize
    }
    osProfile: {
      computerName: vmsSettings.vmDCName
      adminUsername: adminUsername
      adminPassword: adminPassword
      windowsConfiguration: {
        timeZone: timeZone
        enableAutomaticUpdates: vmsSettings.enableAutomaticUpdates
        provisionVMAgent: true
        patchSettings: {
          patchMode: (vmsSettings.enableAutomaticUpdates ? 'AutomaticByPlatform' : 'Manual')
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
        name: 'vm-dc-disk-os'
        caching: 'ReadWrite'
        osType: 'Windows'
        createOption: 'FromImage'
        diskSizeGB: 32
        managedDisk: {
          storageAccountType: vmDcStorage
        }
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: vm_dc_nic.id
        }
      ]
    }
    licenseType: (enableHybridBenefitServerLicenses ? 'Windows_Server' : null)
    securityProfile: {
      securityType: 'TrustedLaunch'
      uefiSettings: {
        secureBootEnabled: true
        vTpmEnabled: true
      }
    }
  }
}

resource vm_dc_runcommand_setproxy 'Microsoft.Compute/virtualMachines/runCommands@2024-07-01' = if (outboundAccessMethod == 'AzureFirewallProxy') {
  parent: vm_dc_def
  name: 'runcommand-setproxy'
  location: location
  properties: {
    source: {
      script: set_proxy_script
    }
    parameters: [
      {
        name: 'proxyIp'
        value: firewall_proxy_settings.azureFirewallIPAddress
      }
      {
        name: 'proxyHttpPort'
        value: string(firewall_proxy_settings.http_port)
      }
      {
        name: 'proxyHttpsPort'
        value: string(firewall_proxy_settings.https_port)
      }
      {
        name: 'localDomainFqdn'
        value: domainFqdn
      }
    ]
    timeoutInSeconds: 90
    treatFailureAsDeploymentFailure: false
  }
}

resource vm_dc_ext_applydsc 'Microsoft.Compute/virtualMachines/extensions@2024-07-01' = {
  parent: vm_dc_def
  name: 'apply-dsc'
  location: location
  dependsOn: [
    vm_dc_runcommand_setproxy
  ]
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
        domainFQDN: domainFqdn
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
          UserName: adminUsername
          Password: adminPassword
        }
        AdfsSvcCreds: {
          UserName: deploymentSettings.adfsSvcUserName
          Password: otherAccountsPassword
        }
      }
    }
  }
}

resource vm_dc_autoshutdown 'Microsoft.DevTestLab/schedules@2018-09-15' = if (autoShutdownTime != '9999') {
  name: 'shutdown-computevm-${vm_dc_def.name}'
  location: location
  properties: {
    targetResourceId: vm_dc_def.id
    status: 'Enabled'
    taskType: 'ComputeVmShutdownTask'
    timeZoneId: timeZone
    dailyRecurrence: {
      time: autoShutdownTime
    }
  }
}

// Create resources for VM SQL
resource vm_sql_pip 'Microsoft.Network/publicIPAddresses@2023-11-01' = if (outboundAccessMethod == 'PublicIPAddress') {
  name: 'vm-sql-pip'
  location: location
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    dnsSettings: addNameToPublicIpAddresses == 'Yes'
      ? {
          domainNameLabel: toLower('${resourceGroupNameFormatted}-${vmsSettings.vmSQLName}')
        }
      : null
  }
}

resource vm_sql_nic 'Microsoft.Network/networkInterfaces@2023-11-01' = {
  name: 'vm-sql-nic'
  location: location
  dependsOn: [
    vm_dc_nic
  ]
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: resourceId(
              'Microsoft.Network/virtualNetworks/subnets',
              virtual_network.name,
              networkSettings.mainSubnetName
            )
          }
          publicIPAddress: ((outboundAccessMethod == 'PublicIPAddress') ? { id: vm_sql_pip.id } : null)
        }
      }
    ]
  }
}

resource vm_sql_def 'Microsoft.Compute/virtualMachines@2024-07-01' = {
  name: 'vm-sql'
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSqlSize
    }
    osProfile: {
      computerName: vmsSettings.vmSQLName
      adminUsername: deploymentSettings.localAdminUserName
      adminPassword: adminPassword
      windowsConfiguration: {
        timeZone: timeZone
        enableAutomaticUpdates: vmsSettings.enableAutomaticUpdates
        provisionVMAgent: true
        patchSettings: {
          patchMode: (vmsSettings.enableAutomaticUpdates ? 'AutomaticByOS' : 'Manual')
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
        name: 'vm-sql-disk-os'
        caching: 'ReadWrite'
        osType: 'Windows'
        createOption: 'FromImage'
        diskSizeGB: 128
        managedDisk: {
          storageAccountType: vmSqlStorage
        }
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: vm_sql_nic.id
        }
      ]
    }
    licenseType: (enableHybridBenefitServerLicenses ? 'Windows_Server' : null)
    securityProfile: {
      securityType: 'TrustedLaunch'
      uefiSettings: {
        secureBootEnabled: true
        vTpmEnabled: true
      }
    }
  }
}

resource vm_sql_runcommand_setproxy 'Microsoft.Compute/virtualMachines/runCommands@2024-07-01' = if (outboundAccessMethod == 'AzureFirewallProxy') {
  parent: vm_sql_def
  name: 'runcommand-setproxy'
  location: location
  properties: {
    source: {
      script: set_proxy_script
    }
    parameters: [
      {
        name: 'proxyIp'
        value: firewall_proxy_settings.azureFirewallIPAddress
      }
      {
        name: 'proxyHttpPort'
        value: string(firewall_proxy_settings.http_port)
      }
      {
        name: 'proxyHttpsPort'
        value: string(firewall_proxy_settings.https_port)
      }
      {
        name: 'localDomainFqdn'
        value: domainFqdn
      }
    ]
    timeoutInSeconds: 90
    treatFailureAsDeploymentFailure: false
  }
}

resource vm_sql_ext_applydsc 'Microsoft.Compute/virtualMachines/extensions@2024-07-01' = {
  parent: vm_sql_def
  name: 'apply-dsc'
  location: location
  dependsOn: [
    vm_sql_runcommand_setproxy
  ]
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
        DomainFQDN: domainFqdn
      }
      privacy: {
        dataCollection: 'enable'
      }
    }
    protectedSettings: {
      configurationArguments: {
        DomainAdminCreds: {
          UserName: adminUsername
          Password: adminPassword
        }
        SqlSvcCreds: {
          UserName: deploymentSettings.sqlSvcUserName
          Password: otherAccountsPassword
        }
        SPSetupCreds: {
          UserName: deploymentSettings.spSetupUserName
          Password: otherAccountsPassword
        }
      }
    }
  }
}

resource vm_sql_autoshutdown 'Microsoft.DevTestLab/schedules@2018-09-15' = if (autoShutdownTime != '9999') {
  name: 'shutdown-computevm-${vm_sql_def.name}'
  location: location
  properties: {
    targetResourceId: vm_sql_def.id
    status: 'Enabled'
    taskType: 'ComputeVmShutdownTask'
    timeZoneId: timeZone
    dailyRecurrence: {
      time: autoShutdownTime
    }
  }
}

// Create resources for VM SP
resource vm_sp_pip 'Microsoft.Network/publicIPAddresses@2023-11-01' = if (outboundAccessMethod == 'PublicIPAddress') {
  name: 'vm-sp-pip'
  location: location
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    dnsSettings: addNameToPublicIpAddresses == 'Yes' || addNameToPublicIpAddresses == 'SharePointVMsOnly'
      ? {
          domainNameLabel: toLower('${resourceGroupNameFormatted}-${vmsSettings.vmSPName}')
        }
      : null
  }
}

resource vm_sp_nic 'Microsoft.Network/networkInterfaces@2023-11-01' = {
  name: 'vm-sp-nic'
  location: location
  dependsOn: [
    vm_dc_nic
  ]
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: resourceId(
              'Microsoft.Network/virtualNetworks/subnets',
              virtual_network.name,
              networkSettings.mainSubnetName
            )
          }
          publicIPAddress: ((outboundAccessMethod == 'PublicIPAddress') ? { id: vm_sp_pip.id } : null)
        }
      }
    ]
  }
}

resource vm_sp_def 'Microsoft.Compute/virtualMachines@2024-07-01' = {
  name: 'vm-sp'
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSharePointSize
    }
    osProfile: {
      computerName: vmsSettings.vmSPName
      adminUsername: deploymentSettings.localAdminUserName
      adminPassword: adminPassword
      windowsConfiguration: {
        timeZone: timeZone
        enableAutomaticUpdates: vmsSettings.enableAutomaticUpdates
        provisionVMAgent: true
        patchSettings: {
          patchMode: (vmsSettings.enableAutomaticUpdates
            ? sharePointSettings.isSharePointSubscription ? 'AutomaticByPlatform' : 'AutomaticByOS'
            : 'Manual')
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
        name: 'vm-sp-disk-os'
        caching: 'ReadWrite'
        osType: 'Windows'
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: vmSharePointStorage
        }
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: vm_sp_nic.id
        }
      ]
    }
    licenseType: (enableHybridBenefitServerLicenses ? 'Windows_Server' : null)
    securityProfile: vmsSettings.vmSharePointSecurityProfile
  }
}

resource vm_sp_runcommand_setproxy 'Microsoft.Compute/virtualMachines/runCommands@2024-07-01' = if (outboundAccessMethod == 'AzureFirewallProxy') {
  parent: vm_sp_def
  name: 'runcommand-setproxy'
  location: location
  properties: {
    source: {
      script: set_proxy_script
    }
    parameters: [
      {
        name: 'proxyIp'
        value: firewall_proxy_settings.azureFirewallIPAddress
      }
      {
        name: 'proxyHttpPort'
        value: string(firewall_proxy_settings.http_port)
      }
      {
        name: 'proxyHttpsPort'
        value: string(firewall_proxy_settings.https_port)
      }
      {
        name: 'localDomainFqdn'
        value: domainFqdn
      }
    ]
    timeoutInSeconds: 90
    treatFailureAsDeploymentFailure: false
  }
}

resource vm_sp_runcommand_increase_dsc_quota 'Microsoft.Compute/virtualMachines/runCommands@2023-03-01' = {
  parent: vm_sp_def
  name: 'runcommand-increase-dsc-quota'
  location: location
  properties: {
    source: {
      script: 'Set-Item -Path WSMan:\\localhost\\MaxEnvelopeSizeKb -Value 2048'
    }
    timeoutInSeconds: 90
    treatFailureAsDeploymentFailure: false
  }
}

resource vm_sp_ext_applydsc 'Microsoft.Compute/virtualMachines/extensions@2024-07-01' = {
  parent: vm_sp_def
  name: 'apply-dsc'
  location: location
  dependsOn: [
    vm_sp_runcommand_setproxy
    vm_sp_runcommand_increase_dsc_quota
  ]
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
        DomainFQDN: domainFqdn
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
          UserName: adminUsername
          Password: adminPassword
        }
        SPSetupCreds: {
          UserName: deploymentSettings.spSetupUserName
          Password: otherAccountsPassword
        }
        SPFarmCreds: {
          UserName: deploymentSettings.spFarmUserName
          Password: otherAccountsPassword
        }
        SPSvcCreds: {
          UserName: deploymentSettings.spSvcUserName
          Password: otherAccountsPassword
        }
        SPAppPoolCreds: {
          UserName: deploymentSettings.spAppPoolUserName
          Password: otherAccountsPassword
        }
        SPADDirSyncCreds: {
          UserName: deploymentSettings.spADDirSyncUserName
          Password: otherAccountsPassword
        }
        SPPassphraseCreds: {
          UserName: 'Passphrase'
          Password: otherAccountsPassword
        }
        SPSuperUserCreds: {
          UserName: deploymentSettings.spSuperUserName
          Password: otherAccountsPassword
        }
        SPSuperReaderCreds: {
          UserName: deploymentSettings.spSuperReaderName
          Password: otherAccountsPassword
        }
      }
    }
  }
}

resource vm_sp_autoshutdown 'Microsoft.DevTestLab/schedules@2018-09-15' = if (autoShutdownTime != '9999') {
  name: 'shutdown-computevm-${vm_sp_def.name}'
  location: location
  properties: {
    targetResourceId: vm_sp_def.id
    status: 'Enabled'
    taskType: 'ComputeVmShutdownTask'
    timeZoneId: timeZone
    dailyRecurrence: {
      time: autoShutdownTime
    }
  }
}

// Create resources for VMs FEs
resource vm_fe_pip 'Microsoft.Network/publicIPAddresses@2023-11-01' = [
  for i in range(0, frontEndServersCount): if (frontEndServersCount >= 1 && outboundAccessMethod == 'PublicIPAddress') {
    name: 'vm-fe${i}-pip'
    location: location
    sku: {
      name: 'Standard'
      tier: 'Regional'
    }
    properties: {
      publicIPAllocationMethod: 'Static'
      dnsSettings: addNameToPublicIpAddresses == 'Yes' || addNameToPublicIpAddresses == 'SharePointVMsOnly'
        ? {
            domainNameLabel: '${toLower('${resourceGroupNameFormatted}-${vmsSettings.vmFEName}')}-${i}'
          }
        : null
    }
  }
]

resource vm_fe_nic 'Microsoft.Network/networkInterfaces@2023-11-01' = [
  for i in range(0, frontEndServersCount): if (frontEndServersCount >= 1) {
    name: 'vm-fe${i}-nic'
    location: location
    properties: {
      ipConfigurations: [
        {
          name: 'ipconfig1'
          properties: {
            privateIPAllocationMethod: 'Dynamic'
            subnet: {
              id: resourceId(
                'Microsoft.Network/virtualNetworks/subnets',
                virtual_network.name,
                networkSettings.mainSubnetName
              )
            }
            publicIPAddress: (outboundAccessMethod == 'PublicIPAddress' ? json('{"id": "${vm_fe_pip[i].id}"}') : null)
          }
        }
      ]
    }
    dependsOn: [
      vm_fe_pip[i]
      vm_dc_nic
    ]
  }
]

resource vm_fe_def 'Microsoft.Compute/virtualMachines@2024-07-01' = [
  for i in range(0, frontEndServersCount): if (frontEndServersCount >= 1) {
    name: 'vm-fe${i}'
    location: location
    dependsOn: [
      vm_fe_nic[i]
    ]
    properties: {
      hardwareProfile: {
        vmSize: vmSharePointSize
      }
      osProfile: {
        computerName: '${vmsSettings.vmFEName}-${i}'
        adminUsername: deploymentSettings.localAdminUserName
        adminPassword: adminPassword
        windowsConfiguration: {
          timeZone: timeZone
          enableAutomaticUpdates: vmsSettings.enableAutomaticUpdates
          provisionVMAgent: true
          patchSettings: {
            patchMode: (vmsSettings.enableAutomaticUpdates
              ? sharePointSettings.isSharePointSubscription ? 'AutomaticByPlatform' : 'AutomaticByOS'
              : 'Manual')
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
          name: 'vm-fe${i}-disk-os'
          caching: 'ReadWrite'
          osType: 'Windows'
          createOption: 'FromImage'
          managedDisk: {
            storageAccountType: vmSharePointStorage
          }
        }
      }
      networkProfile: {
        networkInterfaces: [
          {
            id: vm_fe_nic[i].id
          }
        ]
      }
      licenseType: (enableHybridBenefitServerLicenses ? 'Windows_Server' : null)
      securityProfile: vmsSettings.vmSharePointSecurityProfile
    }
  }
]

resource vm_fe_runcommand_setproxy 'Microsoft.Compute/virtualMachines/runCommands@2024-07-01' = [
  for i in range(0, frontEndServersCount): if (frontEndServersCount >= 1 && outboundAccessMethod == 'AzureFirewallProxy') {
    parent: vm_fe_def[i]
    name: 'runcommand-setproxy'
    location: location
    properties: {
      source: {
        script: set_proxy_script
      }
      parameters: [
        {
          name: 'proxyIp'
          value: firewall_proxy_settings.azureFirewallIPAddress
        }
        {
          name: 'proxyHttpPort'
          value: string(firewall_proxy_settings.http_port)
        }
        {
          name: 'proxyHttpsPort'
          value: string(firewall_proxy_settings.https_port)
        }
        {
          name: 'localDomainFqdn'
          value: domainFqdn
        }
      ]
      timeoutInSeconds: 90
      treatFailureAsDeploymentFailure: false
    }
  }
]

resource vm_fe_ext_applydsc 'Microsoft.Compute/virtualMachines/extensions@2024-07-01' = [
  for i in range(0, frontEndServersCount): if (frontEndServersCount >= 1) {
    parent: vm_fe_def[i]
    name: 'apply-dsc'
    location: location
    dependsOn: [
      vm_fe_runcommand_setproxy[i]
    ]
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
          DomainFQDN: domainFqdn
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
            UserName: adminUsername
            Password: adminPassword
          }
          SPSetupCreds: {
            UserName: deploymentSettings.spSetupUserName
            Password: otherAccountsPassword
          }
          SPFarmCreds: {
            UserName: deploymentSettings.spFarmUserName
            Password: otherAccountsPassword
          }
          SPPassphraseCreds: {
            UserName: 'Passphrase'
            Password: otherAccountsPassword
          }
        }
      }
    }
  }
]

resource vm_fe_autoshutdown 'Microsoft.DevTestLab/schedules@2018-09-15' = [
  for i in range(0, frontEndServersCount): if (frontEndServersCount >= 1 && autoShutdownTime != '9999') {
    name: 'shutdown-computevm-${vm_fe_def[i].name}'
    location: location
    properties: {
      targetResourceId: vm_fe_def[i].id
      status: 'Enabled'
      taskType: 'ComputeVmShutdownTask'
      timeZoneId: timeZone
      dailyRecurrence: {
        time: autoShutdownTime
      }
    }
  }
]

// Resources for Azure Bastion
resource bastion_subnet_nsg 'Microsoft.Network/networkSecurityGroups@2023-11-01' = if (enableAzureBastion == true) {
  name: 'bastion-subnet-nsg'
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

resource bastion_subnet 'Microsoft.Network/virtualNetworks/subnets@2023-11-01' = if (enableAzureBastion == true) {
  parent: virtual_network
  name: 'AzureBastionSubnet'
  properties: {
    addressPrefix: '10.1.2.0/24'
    networkSecurityGroup: {
      id: bastion_subnet_nsg.id
    }
  }
}

resource bastion_pip 'Microsoft.Network/publicIPAddresses@2023-11-01' = if (enableAzureBastion == true) {
  name: 'bastion-pip'
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

resource bastion_def 'Microsoft.Network/bastionHosts@2023-11-01' = if (enableAzureBastion == true) {
  name: 'bastion'
  location: location
  properties: {
    // Preparing for Developer SKU
    // virtualNetwork: {
    //   id: virtual_network.id
    // }
    ipConfigurations: [
      {
        name: 'IpConf'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: bastion_pip.id
          }
          subnet: {
            id: bastion_subnet.id
          }
        }
      }
    ]
  }
}

// Resources for Azure Firewall
resource firewall_subnet 'Microsoft.Network/virtualNetworks/subnets@2023-11-01' = if (outboundAccessMethod == 'AzureFirewallProxy') {
  parent: virtual_network
  name: 'AzureFirewallSubnet'
  properties: {
    addressPrefix: firewall_proxy_settings.vNetAzureFirewallPrefix
    defaultOutboundAccess: false
  }
}

resource firewall_pip 'Microsoft.Network/publicIPAddresses@2023-11-01' = if (outboundAccessMethod == 'AzureFirewallProxy') {
  name: 'firewall-pip'
  location: location
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    dnsSettings: {
      domainNameLabel: toLower('${resourceGroupNameFormatted}-Firewall')
    }
  }
}

resource firewall_policy_proxy 'Microsoft.Network/firewallPolicies@2023-11-01' = if (outboundAccessMethod == 'AzureFirewallProxy') {
  name: 'firewall-policy-proxy'
  location: location
  properties: {
    sku: {
      tier: 'Standard'
    }
    threatIntelMode: 'Alert'
    explicitProxy: {
      enableExplicitProxy: true
      httpPort: firewall_proxy_settings.http_port
      httpsPort: firewall_proxy_settings.https_port
      enablePacFile: false
    }
  }
}

resource firewall_proxy_rules 'Microsoft.Network/firewallPolicies/ruleCollectionGroups@2023-11-01' = if (outboundAccessMethod == 'AzureFirewallProxy') {
  name: 'rules'
  parent: firewall_policy_proxy
  properties: {
    priority: 100
    ruleCollections: [
      {
        name: 'proxy-allow-all-outbound'
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        action: {
          type: 'Allow'
        }
        priority: 100
        rules: [
          {
            ruleType: 'ApplicationRule'
            sourceAddresses: [
              '*'
            ]
            targetFqdns: [
              '*'
            ]
            protocols: [
              {
                port: 443
                protocolType: 'Https'
              }
              {
                port: 80
                protocolType: 'Http'
              }
            ]
          }
        ]
      }
    ]
  }
}

resource firewall_def 'Microsoft.Network/azureFirewalls@2023-11-01' = if (outboundAccessMethod == 'AzureFirewallProxy') {
  name: 'firewall'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'IpConf'
        properties: {
          subnet: {
            id: firewall_subnet.id
          }
          publicIPAddress: {
            id: firewall_pip.id
          }
        }
      }
    ]
    firewallPolicy: {
      id: firewall_policy_proxy.id
    }
    sku: {
      name: 'AZFW_VNet'
      tier: 'Standard'
    }
    threatIntelMode: 'Alert'
  }
}

output publicIPAddressDC string = outboundAccessMethod == 'PublicIPAddress'
  ? addNameToPublicIpAddresses == 'Yes' ? vm_dc_pip.properties.dnsSettings.fqdn : vm_dc_pip.properties.ipAddress
  : ''
output publicIPAddressSQL string = outboundAccessMethod == 'PublicIPAddress'
  ? addNameToPublicIpAddresses == 'Yes' ? vm_sql_pip.properties.dnsSettings.fqdn : vm_sql_pip.properties.ipAddress
  : ''
output publicIPAddressSP string = outboundAccessMethod == 'PublicIPAddress'
  ? addNameToPublicIpAddresses == 'Yes' || addNameToPublicIpAddresses == 'SharePointVMsOnly'
      ? vm_sp_pip.properties.dnsSettings.fqdn
      : vm_sp_pip.properties.ipAddress
  : ''
output vm_fe_public_dns array = [
  for i in range(0, frontEndServersCount): (outboundAccessMethod == 'PublicIPAddress')
    ? addNameToPublicIpAddresses == 'Yes' || addNameToPublicIpAddresses == 'SharePointVMsOnly'
        ? vm_fe_pip[i].properties.dnsSettings.fqdn
        : vm_fe_pip[i].properties.ipAddress
    : null
]
output domainAdminAccount string = '${substring(domainFqdn,0,indexOf(domainFqdn,'.'))}\\${adminUsername}'
output domainAdminAccountFormatForBastion string = '${adminUsername}@${domainFqdn}'
output localAdminAccount string = deploymentSettings.localAdminUserName
