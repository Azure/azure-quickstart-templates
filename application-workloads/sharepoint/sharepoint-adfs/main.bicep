targetScope = 'resourceGroup'
metadata description = 'Create a DC, a SQL Server 2025, and from 1 to 5 server(s) hosting a SharePoint Subscription / 2019 / 2016 farm with an extensive configuration, including trusted authentication, user profiles with personal sites, an OAuth trust (using a certificate), a dedicated IIS site for hosting high-trust add-ins, etc... The latest version of key softwares (including Fiddler, vscode, np++, 7zip, ULS Viewer) is installed. SharePoint machines have additional fine-tuning to make them immediately usable (remote administration tools, custom policies for Edge and Chrome, shortcuts, etc...).'
metadata author = 'Yvand'

@description('Location for all the resources.')
param location string = resourceGroup().location

@description('Version of the SharePoint farm to create.')
@allowed([
  'Subscription-Latest'
  'Subscription-25H2'
  'Subscription-25H1'
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

@description('The base URI where artifacts required by this template are located including a trailing \'/\'')
param _artifactsLocation string = deployment().properties.templateLink.uri

@secure()
@description('The sasToken required to access _artifactsLocation.  When the template is deployed using the accompanying scripts, a sasToken will be automatically generated. Use the defaultValue if the staging location is not secured.')
param _artifactsLocationSasToken string = ''

@description('Tags to apply on the resources.')
param tags object = {}

@description('Default tags applied on the resources. Default tags are: \'source\', \'createdOn\', and \'sharePointVersion\'.')
param defaultTags object = {
  source: 'azure-quickstart-templates:sharepoint-adfs'
  createdOn: utcNow('yyyy-MM-dd')
  sharePointVersion: sharePointVersion
}

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
      Label: '25H1'
      Packages: [
        {
          DownloadUrl: 'https://download.microsoft.com/download/0b131072-7ee6-41ea-b33a-b3410865f3a0/uber-subscription-kb5002698-fullfile-x64-glb.exe'
        }
      ]
    }
    {
      Label: '25H2'
      Packages: [
        {
          DownloadUrl: 'https://download.microsoft.com/download/0ae39b29-890d-428c-bcee-c93eeca2053b/uber-subscription-kb5002784-fullfile-x64-glb.exe'
        }
      ]
    }
    {
      Label: 'Latest'
      Packages: [
        {
          DownloadUrl: 'https://download.microsoft.com/download/2ac104e1-555a-4186-9f83-ffca3ec88258/uber-subscription-kb5002800-fullfile-x64-glb.exe'
        }
      ]
    }
  ]
}

var templateSettings = {
  vNetPrivatePrefix: '10.1.0.0/16'
  domainNameLabelScope: 'SubscriptionReuse'
  enableAutomaticUpdates: true
  vmDCName: 'DC'
  vmSQLName: 'SQL'
  vmSPName: 'SP'
  vmFEName: 'FE'
  vmDCImage: 'MicrosoftWindowsServer:WindowsServer:2025-datacenter-azure-edition-smalldisk:latest'
  vmSQLImage: 'MicrosoftSQLServer:sql2025-ws2025:stddev-gen2:latest'
  vmSharePointImage: sharePointSettings.isSharePointSubscription
    ? sharePointSettings.sharePointImagesList.Subscription
    : sharePointVersion == '2019'
        ? sharePointSettings.sharePointImagesList.sp2019
        : sharePointSettings.sharePointImagesList.sp2016
}

var environmentSettings = {
  dcPrivateIPAddress: '10.1.1.100'
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

// Azure Firewall proxy settings
var firewallProxySettings = {
  firewallAddressPrefix: cidrSubnet(templateSettings.vNetPrivatePrefix, 24, 3)
  httpPort: 8080
  httpsPort: 8443
}

var allTags = union(tags, defaultTags)

// Single-line PowerShell script that runs on the VMs to update their proxy settings, if Azure Firewall is enabled
var firewall_set_proxy_script = 'param([string]$proxyIp, [string]$proxyHttpPort, [string]$proxyHttpsPort, [string]$localDomainFqdn) $proxy = "http={0}:{1};https={0}:{2}" -f $proxyIp, $proxyHttpPort, $proxyHttpsPort; $bypasslist = "*.{0};<local>" -f $localDomainFqdn; netsh winhttp set proxy proxy-server=$proxy bypass-list=$bypasslist; $proxyEnabled = 1; New-ItemProperty -Path "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows\\CurrentVersion\\Internet Settings" -Name "ProxySettingsPerUser" -PropertyType DWORD -Value 0 -Force; $proxyBytes = [system.Text.Encoding]::ASCII.GetBytes($proxy); $bypassBytes = [system.Text.Encoding]::ASCII.GetBytes($bypasslist); $defaultConnectionSettings = [byte[]]@(@(70, 0, 0, 0, 0, 0, 0, 0, $proxyEnabled, 0, 0, 0, $proxyBytes.Length, 0, 0, 0) + $proxyBytes + @($bypassBytes.Length, 0, 0, 0) + $bypassBytes + @(1..36 | % { 0 })); $registryPaths = @("HKLM:\\Software\\Microsoft\\Windows\\CurrentVersion\\Internet Settings", "HKLM:\\Software\\WOW6432Node\\Microsoft\\Windows\\CurrentVersion\\Internet Settings"); foreach ($registryPath in $registryPaths) { Set-ItemProperty -Path $registryPath -Name ProxyServer -Value $proxy; Set-ItemProperty -Path $registryPath -Name ProxyEnable -Value $proxyEnabled; Set-ItemProperty -Path $registryPath -Name ProxyOverride -Value $bypasslist; Set-ItemProperty -Path "$registryPath\\Connections" -Name DefaultConnectionSettings -Value $defaultConnectionSettings; } Bitsadmin /util /setieproxy localsystem MANUAL_PROXY $proxy $bypasslist;'
var firewall_runCommandProperties = {
  source: {
    script: firewall_set_proxy_script
  }
  parameters: [
    {
      name: 'proxyIp'
      value: cidrHost(firewallProxySettings.firewallAddressPrefix, 3) // Typically: '10.1.3.4' (based on firewallAddressPrefix 10.1.3.0/24)
    }
    {
      name: 'proxyHttpPort'
      value: string(firewallProxySettings.httpPort)
    }
    {
      name: 'proxyHttpsPort'
      value: string(firewallProxySettings.httpsPort)
    }
    {
      name: 'localDomainFqdn'
      value: domainFqdn
    }
  ]
  timeoutInSeconds: 90
  treatFailureAsDeploymentFailure: false
}

var baseVirtualMachines = [
  {
    virtualMachineSettings: {
      adminUsername: adminUsername
      virtualMachineName: templateSettings.vmDCName
      virtualMachineSize: vmDcSize
      virtualMachineStorage: vmDcStorage
      virtualMachineDiskSizeGB: 32
      virtualMachineSecurityType: 'TrustedLaunch'
      imageReference: {
        publisher: split(templateSettings.vmDCImage, ':')[0]
        offer: split(templateSettings.vmDCImage, ':')[1]
        sku: split(templateSettings.vmDCImage, ':')[2]
        version: split(templateSettings.vmDCImage, ':')[3]
      }
      privateIPAddress: environmentSettings.dcPrivateIPAddress
      pipConfiguration: outboundAccessMethod == 'PublicIPAddress'
        ? {
            publicIpNameSuffix: '-pip-01'
            skuName: 'Standard'
            publicIPAllocationMethod: 'Static'
            availabilityZones: [] // must be '[]' to prevent error "-pip-01 does not support availability zones at location 'westus'"
            dnsSettings: addNameToPublicIpAddresses == 'Yes'
              ? {
                  domainNameLabel: toLower('${resourceGroupNameFormatted}-${templateSettings.vmDCName}')
                  domainNameLabelScope: templateSettings.domainNameLabelScope
                }
              : null
          }
        : {}
    }
    dscSettings: {
      wmfVersion: 'latest'
      configuration: {
        url: uri(_artifactsLocation, 'dsc/ConfigureDCVM.zip${_artifactsLocationSasToken}')
        script: 'ConfigureDCVM.ps1'
        function: 'ConfigureDCVM'
      }
      configurationArguments: {
        domainFQDN: domainFqdn
        PrivateIP: environmentSettings.dcPrivateIPAddress
        SPServerName: templateSettings.vmSPName
        SharePointSitesAuthority: environmentSettings.sharePointSitesAuthority
        SharePointCentralAdminPort: environmentSettings.sharePointCentralAdminPort
        ApplyBrowserPolicies: environmentSettings.applyBrowserPolicies
      }
      privacy: {
        dataCollection: 'enable'
      }
    }
    dscProtectedSettings: {
      configurationArguments: {
        AdminCreds: {
          UserName: adminUsername
          Password: adminPassword
        }
        AdfsSvcCreds: {
          UserName: environmentSettings.adfsSvcUserName
          Password: otherAccountsPassword
        }
      }
    }
  }
  {
    virtualMachineSettings: {
      adminUsername: environmentSettings.localAdminUserName
      virtualMachineName: templateSettings.vmSQLName
      virtualMachineSize: vmSqlSize
      virtualMachineStorage: vmSqlStorage
      virtualMachineDiskSizeGB: 128
      virtualMachineSecurityType: 'TrustedLaunch'
      imageReference: {
        publisher: split(templateSettings.vmSQLImage, ':')[0]
        offer: split(templateSettings.vmSQLImage, ':')[1]
        sku: split(templateSettings.vmSQLImage, ':')[2]
        version: split(templateSettings.vmSQLImage, ':')[3]
      }
      privateIPAddress: null
      pipConfiguration: outboundAccessMethod == 'PublicIPAddress'
        ? {
            publicIpNameSuffix: '-pip-01'
            skuName: 'Standard'
            publicIPAllocationMethod: 'Static'
            availabilityZones: [] // must be '[]' to prevent error "-pip-01 does not support availability zones at location 'westus'"
            dnsSettings: addNameToPublicIpAddresses == 'Yes'
              ? {
                  domainNameLabel: toLower('${resourceGroupNameFormatted}-${templateSettings.vmSQLName}')
                  domainNameLabelScope: templateSettings.domainNameLabelScope
                }
              : null
          }
        : {}
    }
    dscSettings: {
      wmfVersion: 'latest'
      configuration: {
        url: uri(_artifactsLocation, 'dsc/ConfigureSQLVM.zip${_artifactsLocationSasToken}')
        script: 'ConfigureSQLVM.ps1'
        function: 'ConfigureSQLVM'
      }
      configurationArguments: {
        DNSServerIP: environmentSettings.dcPrivateIPAddress
        DomainFQDN: domainFqdn
      }
      privacy: {
        dataCollection: 'enable'
      }
    }
    dscProtectedSettings: {
      configurationArguments: {
        DomainAdminCreds: {
          UserName: adminUsername
          Password: adminPassword
        }
        SqlSvcCreds: {
          UserName: environmentSettings.sqlSvcUserName
          Password: otherAccountsPassword
        }
        SPSetupCreds: {
          UserName: environmentSettings.spSetupUserName
          Password: otherAccountsPassword
        }
      }
    }
  }
  {
    virtualMachineSettings: {
      adminUsername: environmentSettings.localAdminUserName
      virtualMachineName: templateSettings.vmSPName
      virtualMachineSize: vmSharePointSize
      virtualMachineStorage: vmSharePointStorage
      virtualMachineDiskSizeGB: 128
      virtualMachineSecurityType: sharePointVersion == '2016' ? null : 'TrustedLaunch'
      imageReference: {
        publisher: split(templateSettings.vmSharePointImage, ':')[0]
        offer: split(templateSettings.vmSharePointImage, ':')[1]
        sku: split(templateSettings.vmSharePointImage, ':')[2]
        version: split(templateSettings.vmSharePointImage, ':')[3]
      }
      privateIPAddress: null
      pipConfiguration: outboundAccessMethod == 'PublicIPAddress'
        ? {
            publicIpNameSuffix: '-pip-01'
            skuName: 'Standard'
            publicIPAllocationMethod: 'Static'
            availabilityZones: [] // must be '[]' to prevent error "-pip-01 does not support availability zones at location 'westus'"
            dnsSettings: addNameToPublicIpAddresses == 'Yes' || addNameToPublicIpAddresses == 'SharePointVMsOnly'
              ? {
                  domainNameLabel: toLower('${resourceGroupNameFormatted}-${templateSettings.vmSPName}')
                  domainNameLabelScope: templateSettings.domainNameLabelScope
                }
              : null
          }
        : {}
    }
    dscSettings: {
      wmfVersion: 'latest'
      configuration: {
        url: uri(
          _artifactsLocation,
          '${sharePointSettings.isSharePointSubscription ? 'dsc/ConfigureSPSE.zip' : 'dsc/ConfigureSPLegacy.zip'}${_artifactsLocationSasToken}'
        )
        script: (sharePointSettings.isSharePointSubscription ? 'ConfigureSPSE.ps1' : 'ConfigureSPLegacy.ps1')
        function: 'ConfigureSPVM'
      }
      configurationArguments: {
        DNSServerIP: environmentSettings.dcPrivateIPAddress
        DomainFQDN: domainFqdn
        DCServerName: templateSettings.vmDCName
        SQLServerName: templateSettings.vmSQLName
        SQLAlias: environmentSettings.sqlAlias
        SharePointVersion: sharePointVersion
        SharePointSitesAuthority: environmentSettings.sharePointSitesAuthority
        SharePointCentralAdminPort: environmentSettings.sharePointCentralAdminPort
        EnableAnalysis: environmentSettings.enableAnalysis
        SharePointBits: environmentSettings.sharePointBitsSelected
      }
      privacy: {
        dataCollection: 'enable'
      }
    }
    dscProtectedSettings: {
      configurationArguments: {
        DomainAdminCreds: {
          UserName: adminUsername
          Password: adminPassword
        }
        SPSetupCreds: {
          UserName: environmentSettings.spSetupUserName
          Password: otherAccountsPassword
        }
        SPFarmCreds: {
          UserName: environmentSettings.spFarmUserName
          Password: otherAccountsPassword
        }
        SPSvcCreds: {
          UserName: environmentSettings.spSvcUserName
          Password: otherAccountsPassword
        }
        SPAppPoolCreds: {
          UserName: environmentSettings.spAppPoolUserName
          Password: otherAccountsPassword
        }
        SPADDirSyncCreds: {
          UserName: environmentSettings.spADDirSyncUserName
          Password: otherAccountsPassword
        }
        SPPassphraseCreds: {
          UserName: 'Passphrase'
          Password: otherAccountsPassword
        }
        SPSuperUserCreds: {
          UserName: environmentSettings.spSuperUserName
          Password: otherAccountsPassword
        }
        SPSuperReaderCreds: {
          UserName: environmentSettings.spSuperReaderName
          Password: otherAccountsPassword
        }
      }
    }
  }
]

var frontendVirtualMachinesSettings = {
  virtualMachineSettings: {
    adminUsername: environmentSettings.localAdminUserName
    virtualMachineName: templateSettings.vmFEName
    virtualMachineSize: vmSharePointSize
    virtualMachineStorage: vmSharePointStorage
    virtualMachineDiskSizeGB: 128
    virtualMachineSecurityType: sharePointVersion == '2016' ? null : 'TrustedLaunch'
    imageReference: {
      publisher: split(templateSettings.vmSharePointImage, ':')[0]
      offer: split(templateSettings.vmSharePointImage, ':')[1]
      sku: split(templateSettings.vmSharePointImage, ':')[2]
      version: split(templateSettings.vmSharePointImage, ':')[3]
    }
    privateIPAddress: null
  }
  dscSettings: {
    wmfVersion: 'latest'
    configuration: {
      url: uri(
        _artifactsLocation,
        '${(sharePointSettings.isSharePointSubscription ? 'dsc/ConfigureFESE.zip' : 'dsc/ConfigureFELegacy.zip')}${_artifactsLocationSasToken}'
      )
      script: (sharePointSettings.isSharePointSubscription ? 'ConfigureFESE.ps1' : 'ConfigureFELegacy.ps1')
      function: 'ConfigureFEVM'
    }
    configurationArguments: {
      DNSServerIP: environmentSettings.dcPrivateIPAddress
      DomainFQDN: domainFqdn
      DCServerName: templateSettings.vmDCName
      SQLServerName: templateSettings.vmSQLName
      SQLAlias: environmentSettings.sqlAlias
      SharePointVersion: sharePointVersion
      SharePointSitesAuthority: environmentSettings.sharePointSitesAuthority
      EnableAnalysis: environmentSettings.enableAnalysis
      SharePointBits: environmentSettings.sharePointBitsSelected
    }
    privacy: {
      dataCollection: 'enable'
    }
  }
  dscProtectedSettings: {
    configurationArguments: {
      DomainAdminCreds: {
        UserName: adminUsername
        Password: adminPassword
      }
      SPSetupCreds: {
        UserName: environmentSettings.spSetupUserName
        Password: otherAccountsPassword
      }
      SPFarmCreds: {
        UserName: environmentSettings.spFarmUserName
        Password: otherAccountsPassword
      }
      SPPassphraseCreds: {
        UserName: 'Passphrase'
        Password: otherAccountsPassword
      }
    }
  }
}

module virtualNetwork 'virtualNetwork.bicep' = {
  name: 'vnet-module'
  params: {
    location: location
    tags: allTags
    virtualNetworkName: 'vnet'
    addressPrefix: templateSettings.vNetPrivatePrefix
    mainSubnetAddressPrefix: cidrSubnet(templateSettings.vNetPrivatePrefix, 24, 1)
    networkSecurityRules: toLower(rdpTrafficRule) == 'no'
      ? []
      : [
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
}

//@sys.batchSize(3)
module baseVirtualMachinesModule 'virtualMachine.bicep' = [
  for baseVirtualMachine in baseVirtualMachines: {
    name: 'virtualMachine-${baseVirtualMachine.virtualMachineSettings.virtualMachineName}-module'
    params: {
      location: location
      tags: allTags
      adminPassword: adminPassword
      subnetResourceId: virtualNetwork.outputs.mainSubnetResourceId
      licenseType: enableHybridBenefitServerLicenses ? 'Windows_Server' : null
      timeZone: timeZone
      autoShutdownTime: autoShutdownTime
      adminUsername: baseVirtualMachine.virtualMachineSettings.adminUsername
      virtualMachineName: baseVirtualMachine.virtualMachineSettings.virtualMachineName
      virtualMachineDiskSizeGB: baseVirtualMachine.virtualMachineSettings.virtualMachineDiskSizeGB
      virtualMachineImageReference: baseVirtualMachine.virtualMachineSettings.imageReference
      virtualMachineSize: baseVirtualMachine.virtualMachineSettings.virtualMachineSize
      virtualMachineStorageAccountType: baseVirtualMachine.virtualMachineSettings.virtualMachineStorage
      virtualMachineSecurityType: baseVirtualMachine.virtualMachineSettings.virtualMachineSecurityType
      pipConfiguration: baseVirtualMachine.virtualMachineSettings.?pipConfiguration
      privateIPAddress: baseVirtualMachine.virtualMachineSettings.privateIPAddress
      dscSettings: baseVirtualMachine.dscSettings
      dscProtectedSettings: baseVirtualMachine.dscProtectedSettings
      runCommandProperties: outboundAccessMethod == 'AzureFirewallProxy' ? firewall_runCommandProperties : null
    }
  }
]

module frontends 'virtualMachine.bicep' = [
  for index in range(0, frontEndServersCount): {
    scope: resourceGroup()
    name: 'virtualMachine-FE-${index}-module'
    params: {
      location: location
      tags: allTags
      adminPassword: adminPassword
      subnetResourceId: virtualNetwork.outputs.mainSubnetResourceId
      licenseType: enableHybridBenefitServerLicenses ? 'Windows_Server' : null
      timeZone: timeZone
      autoShutdownTime: autoShutdownTime
      adminUsername: frontendVirtualMachinesSettings.virtualMachineSettings.adminUsername
      virtualMachineName: '${frontendVirtualMachinesSettings.virtualMachineSettings.virtualMachineName}-${index}'
      virtualMachineDiskSizeGB: frontendVirtualMachinesSettings.virtualMachineSettings.virtualMachineDiskSizeGB
      virtualMachineImageReference: frontendVirtualMachinesSettings.virtualMachineSettings.imageReference
      virtualMachineSize: frontendVirtualMachinesSettings.virtualMachineSettings.virtualMachineSize
      virtualMachineStorageAccountType: frontendVirtualMachinesSettings.virtualMachineSettings.virtualMachineStorage
      virtualMachineSecurityType: frontendVirtualMachinesSettings.virtualMachineSettings.?virtualMachineSecurityType
      pipConfiguration: outboundAccessMethod == 'PublicIPAddress'
        ? {
            publicIpNameSuffix: '-pip-01'
            skuName: 'Standard'
            publicIPAllocationMethod: 'Static'
            availabilityZones: [] // must be '[]' to prevent error "-pip-01 does not support availability zones at location 'westus'"
            dnsSettings: addNameToPublicIpAddresses == 'Yes' || addNameToPublicIpAddresses == 'SharePointVMsOnly'
              ? {
                  domainNameLabel: toLower('${resourceGroupNameFormatted}-${templateSettings.vmFEName}-${index}')
                  domainNameLabelScope: templateSettings.domainNameLabelScope
                }
              : null
          }
        : {}
      privateIPAddress: frontendVirtualMachinesSettings.virtualMachineSettings.privateIPAddress
      dscSettings: frontendVirtualMachinesSettings.dscSettings
      dscProtectedSettings: frontendVirtualMachinesSettings.dscProtectedSettings
      runCommandProperties: outboundAccessMethod == 'AzureFirewallProxy' ? firewall_runCommandProperties : null
    }
  }
]

module bastion 'bastion.bicep' = if (enableAzureBastion == true) {
  name: 'bastion-module'
  params: {
    virtualNetworkName: virtualNetwork.outputs.vnetName
    tags: allTags
  }
}

module firewall 'firewall.bicep' = if (outboundAccessMethod == 'AzureFirewallProxy') {
  name: 'firewall-module'
  params: {
    virtualNetworkName: virtualNetwork.outputs.vnetName
    tags: allTags
    addressPrefix: firewallProxySettings.firewallAddressPrefix
    http_port: firewallProxySettings.httpPort
    https_port: firewallProxySettings.httpsPort
  }
}

output domainAdminAccount string = '${substring(domainFqdn,0,indexOf(domainFqdn,'.'))}\\${adminUsername}'
output domainAdminAccountFormatForBastion string = '${adminUsername}@${domainFqdn}'
output localAdminAccount string = environmentSettings.localAdminUserName

output baseVirtualMachines_data array = [for i in range(0, 3): {
  name: baseVirtualMachinesModule[i].outputs.name
  publicIP: baseVirtualMachinesModule[i].outputs.publicIP
}]

output frontEnds_data array = [for i in range(0, frontEndServersCount): {
  name: frontends[i].outputs.name
  publicIP: frontends[i].outputs.publicIP
}]
