//targetScope = 'subscription'
metadata description = 'Create a DC, a SQL Server 2022, and from 1 to 5 server(s) hosting a SharePoint Subscription / 2019 / 2016 farm with an extensive configuration, including trusted authentication, user profiles with personal sites, an OAuth trust (using a certificate), a dedicated IIS site for hosting high-trust add-ins, etc... The latest version of key softwares (including Fiddler, vscode, np++, 7zip, ULS Viewer) is installed. SharePoint machines have additional fine-tuning to make them immediately usable (remote administration tools, custom policies for Edge and Chrome, shortcuts, etc...).'
metadata author = 'Yvand'

@description('Location for all the resources.')
param location string = 'france central'

@description('Optional. The name of the resource group to deploy for testing purposes.')
@maxLength(90)
param resourceGroupName string

// @description('Optional. A token to inject into the name of each resource.')
// param namePrefix string = '_namePrefix_'

// @description('Optional. A short identifier for the kind of deployment. Should be kept short to not run into resource-name length-constraints.')
// param serviceShort string = 'cvmwinguest'

@description('Version of the SharePoint farm to create.')
@allowed([
  'Subscription-Latest'
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

// Local variables
var resourceGroupNameFormatted = replace(
  replace(replace(replace(resourceGroupName, '.', '-'), '(', '-'), ')', '-'),
  '_',
  '-'
)


