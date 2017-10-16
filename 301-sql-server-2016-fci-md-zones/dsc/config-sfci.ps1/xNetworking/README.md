[![Build status](https://ci.appveyor.com/api/projects/status/obmudad7gy8usbx2/branch/master?svg=true)](https://ci.appveyor.com/project/PowerShell/xnetworking/branch/master)

# xNetworking

The **xNetworking** module contains the following resources:
* **xFirewall**
* **xIPAddress**
* **xDnsServerAddress**
* **xDnsConnectionSuffix**
* **xDefaultGatewayAddress**
* **xNetConnectionProfile**
* **xDhcpClient**
* **xRoute**
* **xNetBIOS**
* **xNetworkTeam**
* **xNetworkTeamInterface**
* **xHostsFile**
* **xNetAdapterBinding**
* **xDnsClientGlobalSetting**

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

## Contributing
Please check out common DSC Resources [contributing guidelines](https://github.com/PowerShell/DscResource.Kit/blob/master/CONTRIBUTING.md).

## Resources

* **xFirewall** sets a node's firewall rules.
* **xIPAddress** sets a node's IP address.
* **xDnsServerAddress** sets a node's DNS server.
* **xDnsConnectionSuffix** sets a node's network interface connection-specific DNS suffix.
* **xDefaultGatewayAddress** sets a node's default gateway address.
* **xNetConnectionProfile** sets a node's connection profile.

### xIPAddress

* **IPAddress**: The desired IP address.
* **InterfaceAlias**: Alias of the network interface for which the IP address should be set.
* **PrefixLength**: The prefix length of the IP Address.
* **AddressFamily**: IP address family: { IPv4 | IPv6 }

### xDnsServerAddress

* **Address**: The desired DNS Server address(es)
* **InterfaceAlias**: Alias of the network interface for which the DNS server address is set.
* **AddressFamily**: IP address family: { IPv4 | IPv6 }
* **Validate**: Requires that the DNS Server addresses be validated if they are updated. It will cause the resouce to throw a 'A general error occurred that is not covered by a more specific error code.' error if set to True and specified DNS Servers are not accessible. Defaults to False.

### xDnsConnectionSuffix

* **InterfaceAlias**: Alias of the network interface for which the DNS server address is set.
* **ConnectionSpecificSuffix**: DNS connection-specific suffix to assign to the network interface.
* **RegisterThisConnectionsAddress**: Specifies that the IP address for this connection is to be registered. The default value is True.
* **UseSuffixWhenRegistering**: Specifies that this host name and the connection specific suffix for this connection are to be registered. The default value is False.
* **Ensure**: Ensure that the network interface connection-specific suffix is present or not. { Present | Absent }

### xDefaultGatewayAddress

* **Address**: The desired default gateway address - if not provided default gateway will be removed.
* **InterfaceAlias**: Alias of the network interface for which the default gateway address is set.
* **AddressFamily**: IP address family: { IPv4 | IPv6 }

### xFirewall

* **Name**: Name of the firewall rule.
* **DisplayName**: Localized, user-facing name of the firewall rule being created.
* **Group**: Name of the firewall group where we want to put the firewall rule.
* **Ensure**: Ensure that the firewall rule is Present or Absent.
* **Enabled**: Enable or Disable the supplied configuration.
* **Action**: Allow or Block the supplied configuration: { NotConfigured | Allow | Block }
* **Profile**: Specifies one or more profiles to which the rule is assigned.
* **Direction**: Direction of the connection.
* **RemotePort**: Specific port used for filter. Specified by port number, range, or keyword.
* **LocalPort**: Local port used for the filter.
* **Protocol**: Specific protocol for filter. Specified by name, number, or range.
* **Description**: Documentation for the rule.
* **Program**: Path and filename of the program for which the rule is applied.
* **Service**: Specifies the short name of a Windows service to which the firewall rule applies.
* **Authentication**: Specifies that authentication is required on firewall rules: { NotRequired | Required | NoEncap }
* **Encryption**: Specifies that encryption in authentication is required on firewall rules: { NotRequired | Required | Dynamic }
* **InterfaceAlias**: Specifies the alias of the interface that applies to the traffic.
* **InterfaceType**: Specifies that only network connections made through the indicated interface types are subject to the requirements of this rule: { Any | Wired | Wireless | RemoteAccess }
* **LocalAddress**: Specifies that network packets with matching IP addresses match this rule. This parameter value is the first end point of an IPsec rule and specifies the computers that are subject to the requirements of this rule. This parameter value is an IPv4 or IPv6 address, hostname, subnet, range, or the following keyword: Any.
* **LocalUser**: Specifies the principals to which network traffic this firewall rule applies. The principals, represented by security identifiers (SIDs) in the security descriptor definition language (SDDL) string, are services, users, application containers, or any SID to which network traffic is associated.
* **Package**: Specifies the Windows Store application to which the firewall rule applies. This parameter is specified as a security identifier (SID).
* **Platform**: Specifies which version of Windows the associated rule applies.
* **RemoteAddress**: Specifies that network packets with matching IP addresses match this rule. This parameter value is the second end point of an IPsec rule and specifies the computers that are subject to the requirements of this rule. This parameter value is an IPv4 or IPv6 address, hostname, subnet, range, or the following keyword: Any
* **RemoteMachine**: Specifies that matching IPsec rules of the indicated computer accounts are created. This parameter specifies that only network packets that are authenticated as incoming from or outgoing to a computer identified in the list of computer accounts (SID) match this rule. This parameter value is specified as an SDDL string.
* **RemoteUser**: Specifies that matching IPsec rules of the indicated user accounts are created. This parameter specifies that only network packets that are authenticated as incoming from or outgoing to a user identified in the list of user accounts match this rule. This parameter value is specified as an SDDL string.
* **DynamicTransport**: Specifies a dynamic transport: { Any | ProximityApps | ProximitySharing | WifiDirectPrinting | WifiDirectDisplay | WifiDirectDevices }
* **EdgeTraversalPolicy**: Specifies that matching firewall rules of the indicated edge traversal policy are created: { Block | Allow | DeferToUser | DeferToApp }
* **IcmpType**: Specifies the ICMP type codes.
* **LocalOnlyMapping**: Indicates that matching firewall rules of the indicated value are created.
* **LooseSourceMapping**: Indicates that matching firewall rules of the indicated value are created.
* **OverrideBlockRules**: Indicates that matching network traffic that would otherwise be blocked are allowed.
* **Owner**: Specifies that matching firewall rules of the indicated owner are created.

### xNetConnectionProfile

* **InterfaceAlias**: Specifies the alias for the Interface that is being changed.
* **NetworkCategory**: Sets the NetworkCategory for the interface - per [the documentation ](https://technet.microsoft.com/en-us/%5Clibrary/jj899565(v=wps.630).aspx) this can only be set to { Public | Private }
* **IPv4Connectivity**: Specifies the IPv4 Connection Value { Disconnected | NoTraffic | Subnet | LocalNetwork | Internet }
* **IPv6Connectivity**: Specifies the IPv6 Connection Value { Disconnected | NoTraffic | Subnet | LocalNetwork | Internet }

### xDhcpClient

* **State**: The desired state of the DHCP Client: { Enabled | Disabled }. Mandatory.
* **InterfaceAlias**: Alias of the network interface for which the DNS server address is set. Mandatory.
* **AddressFamily**: IP address family: { IPv4 | IPv6 }. Mandatory.

### xRoute

* **InterfaceAlias**: Specifies the alias of a network interface. Mandatory.
* **AddressFamily**: Specifies the IP address family. { IPv4 | IPv6 }. Mandatory.
* **DestinationPrefix**: Specifies a destination prefix of an IP route. A destination prefix consists of an IP address prefix and a prefix length, separated by a slash (/). Mandatory.
* **NextHop**: Specifies the next hop for the IP route. Mandatory.
* **Ensure**: Specifies whether the route should exist. { Present | Absent }. Defaults: Present.
* **RouteMetric**: Specifies an integer route metric for an IP route. Default: 256.
* **Publish**: Specifies the publish setting of an IP route. { No | Yes | Age }. Default: No.
* **PreferredLifetime**: Specifies a preferred lifetime in seconds of an IP route.

### xNetBIOS

* **InterfaceAlias**: Specifies the alias of a network interface. Mandatory.
* **Setting**: xNetBIOS setting { Default | Enable | Disable }. Mandatory.

### xNetworkTeam
* **Name**: Specifies the name of the network team to create.
* **TeamMembers**: Specifies the network interfaces that should be a part of the network team. This is a comma-separated list.
* **TeamingMode**: Specifies the teaming mode configuration. { SwitchIndependent | LACP | Static}.
* **LoadBalancingAlgorithm**: Specifies the load balancing algorithm for the network team. { Dynamic | HyperVPort | IPAddresses | MacAddresses | TransportPorts }.
* **Ensure**: Specifies if the network team should be created or deleted. { Present | Absent }.

### xNetworkTeamInterface
* **Name**: Specifies the name of the network team interface to create.
* **TeamName**: Specifies the name of the network team on which this particular interface should exist.
* **VlanID**: Specifies VlanID to be set on network team interface.
* **Ensure**: Specifies if the network team interface should be created or deleted. { Present | Absent }

### xHostsFile
* **HostName**: Specifies the name of the computer that will be mapped to an IP address.
* **IPAddress**: Specifies the IP Address that should be mapped to the host name.
* **Ensure**: Specifies if the hosts file entry should be created or deleted. { Present | Absent }.

### xNetAdapterBinding
* **InterfaceAlias**: Specifies the alias of a network interface. Supports the use of '*'. Mandatory.
* **ComponentId**: Specifies the underlying name of the transport or filter in the following form - ms_xxxx, such as ms_tcpip. Mandatory.
* **State**: Specifies if the component ID for the Interface should be Enabled or Disabled. Optional. Defaults to Enabled. { Enabled | Disabled }.

### xDnsClientGlobalSetting
* **IsSingleInstance**: Specifies the resource is a single instance, the value must be 'Yes'.
* **SuffixSearchList**: Specifies a list of global suffixes that can be used in the specified order by the DNS client for resolving the IP address of the computer name.
* **UseDevolution**: Specifies that devolution is activated.
* **DevolutionLevel**: Specifies the number of labels up to which devolution should occur.

## Functions

### Get-xNetworkAdapterName
* Finds a network adapter name based on the parameters specified.  **This is investigational, names and parameters are subject to change**
* **Name**: **Mandatory**, the name of the adapter you are trying to find, to refine the results after the rest of the criteria are queried.
* **Status**: Optional, with a default of `Up`. The status of the network adapter. { Up | Disconnected | Disabled }
* **PhysicalMediaType**:   Optional, with no default. The physical media type of the network adapter. Examples: `802.3`
* Returns a structure with the following properties:
    * **Name**: The name of the first matching adapter.
    * **PhysicalMediaType**: The Physical media type of the first matching adapter.
    * **Status**: The status of the first matching adapter.
    * **MatchingAdapterCount**: The count of the matching adapters

### Test-xNetworkAdapterName
* Tests if a network adapter exists with the specified name by calling Get-xNetworkAdapterName and comparing the returned name.  **This is investigational, names and parameters are subject to change**
* **Name**: **Mandatory**, the name of the adapter you are trying to find, if an adapter by this name is found, no other parameters are used.
* **Status**: Optional, with a default of `Up`. The status of the network adapter. { Up | Disconnected | Disabled }
* **PhysicalMediaType**:   Optional, with no default. The physical media type of the network adapter. Examples: `802.3`
* Returns `$true` if the named adapter exist, `$false` if it does not.

### Set-xNetworkAdapterName
* Sets the network adapter name of the adapter found by the parameters specified.  **This is investigational, names and parameters are subject to change**
* **Name**: **Mandatory**, the name of the adapter you are trying to find, if an adapter by this name is found, no other parameters are used.
* **Status**: Optional, with a default of `Up`. The status of the network adapter. { Up | Disconnected | Disabled }
* **PhysicalMediaType**:   Optional, with no default. The physical media type of the network adapter. Examples: `802.3`
* **IgnoreMultipleMatchingAdapters**: If the function finds multiple adapters, it will error, unless this switch is specified, then it will rename the first adapter.  Since name is part of the query, further queries should return one adapter.

## Known Invalid Configurations

### xFirewall
* The exception 'One of the port keywords is invalid' will be thrown if a rule is created with the LocalPort set to PlayToDiscovery and the Protocol is not set to UDP. This is not an unexpected error, but because the New-NetFirewallRule documentation is incorrect.
This issue has been reported on [Microsoft Connect](https://connect.microsoft.com/PowerShell/feedbackdetail/view/1974268/new-set-netfirewallrule-cmdlet-localport-parameter-documentation-is-incorrect-for-playtodiscovery)

## Known Issues

### xFirewall
The following error may occur when applying xFirewall configurations on Windows Server 2012 R2 if [KB3000850](https://support.microsoft.com/en-us/kb/3000850) is not installed. Please ensure this update is installed if this error occurs.
```
The cmdlet does not fully support the Inquire action for debug messages. Cmdlet operation will continue during the prompt. Select a different action preference via -Debug switch or $DebugPreference variable, and try again.
```

## Versions

### Unreleased

### 3.0.0.0
* Corrected integration test filenames:
    * MSFT_xDefaultGatewayAddress.Integration.Tests.ps1
    * MSFT_xDhcpClient.Integration.Tests.ps1
    * MSFT_xDNSConnectionSuffix.Integration.Tests.ps1
    * MSFT_xNetAdapterBinding.Integration.Tests.ps1
* Updated all integration tests to use v1.1.0 header and script variable context.
* Updated all unit tests to use v1.1.0 header and script variable context.
* Removed uneccessary global variable from MSFT_xNetworkTeam.integration.tests.ps1
* Converted Invoke-Expression in all integration tests to &.
* Fixed unit test description in xNetworkAdapter.Tests.ps1
* xNetAdapterBinding
  * Added support for the use of wildcard (*) in InterfaceAlias parameter.
* BREAKING CHANGE - MSFT_xIPAddress: SubnetMask parameter renamed to PrefixLength.

### 2.12.0.0
* Fixed bug in MSFT_xIPAddress resource when xIPAddress follows xVMSwitch.

* Added the following resources:
    * MSFT_xNetworkTeamInterface resource to add/remove network team interfaces
* Added conditional loading of LocalizedData to MSFT_xHostsFile and MSFT_xNetworkTeam to prevent failures while loading those resources on systems with $PSUICulture other than en-US

### 2.11.0.0
* Added the following resources:
    * MSFT_xDnsClientGlobalSetting resource to configure the DNS Suffix Search List and Devolution.
* Converted AppVeyor.yml to pull Pester from PSGallery instead of Chocolatey.
* Changed AppVeyor.yml to use default image.
* Fix xNetBios unit tests to work on default appveyor image.
* Fix bug in xRoute when removing an existing route.
* Updated xRoute integration tests to use v1.1.0 test header.
* Extended xRoute integration tests to perform both add and remove route tests.

### 2.10.0.0

* Added the following resources:
    * MSFT_xNetAdapterBinding resource to enable/disable network adapter bindings.
* Fixed bug where xHostsFile would duplicate an entry instead of updating an existing one
* Updated Sample_xIPAddress_*.ps1 examples to show correct usage of setting a Static IP address to prevent issue when DHCP assigned IP address already matches staticly assigned IP address.

### 2.9.0.0

* MSFT_xDefaultGatewayAddress: Added Integration Tests.
* MSFT_xDhcpClient: Added Integration Tests.
* MSFT_xDnsConnectionSuffix: Added Integration Tests.
* MSFT_xDnsServerAddress: Added Integration Tests.
* MSFT_xIPAddress: Added Integration Tests.
* MSFT_xDhcpClient: Fixed logged message in Test-TargetResource.
* Added functions:
    * Get-xNetworkAdapterName
    * Test-xNetworkAdapterName
    * Set-xNetworkAdapterName


### 2.8.0.0

* Templates folder removed. Use the test templates in the [Tests.Template folder in the DSCResources repository](https://github.com/PowerShell/DscResources/tree/master/Tests.Template) instead.
* Added the following resources:
    * MSFT_xHostsFile resource to manage hosts file entries.
* MSFT_xFirewall: Fix test of Profile parameter status.
* MSFT_xIPAddress: Fix false negative when desired IP is a substring of current IP.

### 2.7.0.0

* Added the following resources:
    * MSFT_xNetworkTeam resource to manage native network adapter teaming.

### 2.6.0.0

* Added the following resources:
    * MSFT_xDhcpClient resource to enable/disable DHCP on individual interfaces.
    * MSFT_xRoute resource to manage network routes.
    * MSFT_xNetBIOS resource to configure NetBIOS over TCP/IP settings on individual interfaces.
* MSFT_*: Unit and Integration tests updated to use DSCResource.Tests\TestHelper.psm1 functions.
* MSFT_*: Resource Name added to all unit test Desribes.
* Templates update to use DSCResource.Tests\TestHelper.psm1 functions.
* MSFT_xNetConnectionProfile: Integration tests fixed when more than one connection profile present.
* Changed AppVeyor.yml to use WMF 5 build environment.
* MSFT_xIPAddress: Removed test for DHCP Status.
* MSFT_xFirewall: New parameters added:
    * DynamicTransport
    * EdgeTraversalPolicy
    * LocalOnlyMapping
    * LooseSourceMapping
    * OverrideBlockRules
    * Owner
* All unit & integration tests updated to be able to be run from any folder under tests directory.
* Unit & Integration test template headers updated to match DSCResource templates.

### 2.5.0.0
* Added the following resources:
    * MSFT_xDNSConnectionSuffix resource to manage connection-specific DNS suffixes.
    * MSFT_xNetConnectionProfile resource to manage Connection Profiles for interfaces.
* MSFT_xDNSServerAddress: Corrected Verbose logging messages when multiple DNS adddressed specified.
* MSFT_xDNSServerAddress: Change to ensure resource terminates if DNS Server validation fails.
* MSFT_xDNSServerAddress: Added Validate parameter to enable DNS server validation when changing server addresses.
* MSFT_xFirewall: ApplicationPath Parameter renamed to Program for consistency with Cmdlets.
* MSFT_xFirewall: Fix to prevent error when DisplayName parameter is set on an existing rule.
* MSFT_xFirewall: Setting a different DisplayName parameter on an existing rule now correctly reports as needs change.
* MSFT_xFirewall: Changed DisplayGroup parameter to Group for consistency with Cmdlets and reduce confusion.
* MSFT_xFirewall: Changing the Group of an existing Firewall rule will recreate the Firewall rule rather than change it.
* MSFT_xFirewall: New parameters added:
    * Authentication
    * Encryption
    * InterfaceAlias
    * InterfaceType
    * LocalAddress
    * LocalUser
    * Package
    * Platform
    * RemoteAddress
    * RemoteMachine
    * RemoteUser
* MSFT_xFirewall: Profile parameter now handled as an Array.

### 2.4.0.0
* Added following resources:
    * MSFT_xDefaultGatewayAddress
* MSFT_xFirewall: Removed code using DisplayGroup to lookup Firewall Rule because it was redundant.
* MSFT_xFirewall: Set-TargetResource now updates firewall rules instead of recreating them.
* MSFT_xFirewall: Added message localization support.
* MSFT_xFirewall: Removed unessesary code for handling multiple rules with same name.
* MSFT_xDefaultGatewayAddress: Removed unessesary try/catch logic from around networking cmdlets.
* MSFT_xIPAddress: Removed unessesary try/catch logic from around networking cmdlets.
* MSFT_xDNSServerAddress: Removed unessesary try/catch logic from around networking cmdlets.
* MSFT_xDefaultGatewayAddress: Refactored to add more unit tests and cleanup logic.
* MSFT_xIPAddress: Network Connection Profile no longer forced to Private when IP address changed.
* MSFT_xIPAddress: Refactored to add more unit tests and cleanup logic.
* MSFT_xDNSServerAddress: Refactored to add more unit tests and cleanup logic.
* MSFT_xFirewall: Refactored to add more unit tests and cleanup logic.
* MSFT_xIPAddress: Removed default gateway parameter - use xDefaultGatewayAddress resource.
* MSFT_xIPAddress: Added check for IP address format not matching address family.
* MSFT_xDNSServerAddress: Corrected error message when address format doesn't match address family.

### 2.3.0.0

* MSFT_xDNSServerAddress: Added support for setting DNS for both IPv4 and IPv6 on the same Interface
* MSFT_xDNSServerAddress: AddressFamily parameter has been changed to mandatory.
* Removed xDscResourceDesigner tests (moved to common tests)
* Fixed Test-TargetResource to test against all provided parameters
* Modified tests to not copy file to Program Files

* Changes to xFirewall causes Get-DSCConfiguration to no longer crash
    * Modified Schema to reduce needed functions.
    * General re-factoring and clean up of xFirewall.
    * Added Unit and Integration tests to resource.

### 2.2.0.0

* Changes in xFirewall resources to meet Test-xDscResource criteria

### 2.1.1.1

* Updated to fix issue with Get-DscConfiguration and xFirewall

### 2.1.0

* Added validity check that IPAddress and IPAddressFamily conforms with each other

### 2.0.0.0

* Adding the xFirewall resource

### 1.0.0.0

* Initial release with the following resources:
    - xIPAddress
    - xDnsServerAddress


## Examples

### Set IP Address on an ethernet NIC

This configuration will set the IP Address with some typical values for a network interface with the alias 'Ethernet'.

```powershell
Configuration Sample_xIPAddress_FixedValue
{
    param
    (
        [string[]]$NodeName = 'localhost'
    )
    Import-DscResource -Module xNetworking
    Node $NodeName
    {
        xIPAddress NewIPAddress
        {
            IPAddress      = "2001:4898:200:7:6c71:a102:ebd8:f482"
            InterfaceAlias = "Ethernet"
            PrefixLength   = 24
            AddressFamily  = "IPV6"
        }
    }
}
```

### Set IP Address with parameterized values

This configuration will set the IP Address on a network interface that is identified by its alias.

``` powershell
Configuration Sample_xIPAddress_Parameterized
{
    param
    (
        [string[]]$NodeName = 'localhost',
        [Parameter(Mandatory)]
        [string]$IPAddress,
        [Parameter(Mandatory)]
        [string]$InterfaceAlias,
        [int]$PrefixLength = 16,
        [ValidateSet("IPv4","IPv6")]
        [string]$AddressFamily = 'IPv4'
    )
    Import-DscResource -Module xNetworking
    Node $NodeName
    {
        xIPAddress NewIPAddress
        {
            IPAddress      = $IPAddress
            InterfaceAlias = $InterfaceAlias
            PrefixLength   = $PrefixLength
            AddressFamily  = $AddressFamily
        }
    }
}
```

### Set DNS server address

This configuration will set the DNS server address on a network interface that is identified by its alias.

```powershell
Configuration Sample_xDnsServerAddress
{
    param
    (
        [string[]]$NodeName = 'localhost',
        [Parameter(Mandatory)]
        [string]$DnsServerAddress,
        [Parameter(Mandatory)]
        [string]$InterfaceAlias,
        [ValidateSet("IPv4","IPv6")]
        [string]$AddressFamily = 'IPv4',
        [Boolean]$Validate
    )
    Import-DscResource -Module xNetworking
    Node $NodeName
    {
        xDnsServerAddress DnsServerAddress
        {
            Address        = $DnsServerAddress
            InterfaceAlias = $InterfaceAlias
            AddressFamily  = $AddressFamily
            Validate       = $Validate
        }
    }
}
```

### Set a DNS connection suffix

This configuration will set a DNS connection-specific suffix on a network interface that is identified by its alias.

```powershell
Configuration Sample_xDnsConnectionSuffix
{
    param
    (
        [string[]]$NodeName = 'localhost',
        [Parameter(Mandatory)]
        [string]$InterfaceAlias,
        [Parameter(Mandatory)]
        [string]$DnsSuffix
    )
    Import-DscResource -Module xNetworking
    Node $NodeName
    {
        xDnsConnectionSuffix DnsConnectionSuffix
        {
            InterfaceAlias           = $InterfaceAlias
            ConnectionSpecificSuffix = $DnsSuffix
        }
    }
}
```

### Set Default Gateway server address

This configuration will set the default gateway address on a network interface that is identified by its alias.

```powershell
Configuration Sample_xDefaultGatewayAddress_Set
{
    param
    (
        [string[]]$NodeName = 'localhost',
        [Parameter(Mandatory)]
        [string]$DefaultGateway,
        [Parameter(Mandatory)]
        [string]$InterfaceAlias,
        [ValidateSet("IPv4","IPv6")]
        [string]$AddressFamily = 'IPv4'
    )
    Import-DscResource -Module xNetworking
    Node $NodeName
    {
        xDefaultGatewayAddress SetDefaultGateway
        {
            Address        = $DefaultGateway
            InterfaceAlias = $InterfaceAlias
            AddressFamily  = $AddressFamily
        }
    }
}
```

### Remove Default Gateway server address

This configuration will remove the default gateway address on a network interface that is identified by its alias.

```powershell
Configuration Sample_xDefaultGatewayAddress_Remove
{
    param
    (
        [string[]]$NodeName = 'localhost',
        [Parameter(Mandatory)]
        [string]$InterfaceAlias,
        [ValidateSet("IPv4","IPv6")]
        [string]$AddressFamily = 'IPv4'
    )
    Import-DscResource -Module xNetworking
    Node $NodeName
    {
        xDefaultGatewayAddress RemoveDefaultGateway
        {
            InterfaceAlias = $InterfaceAlias
            AddressFamily  = $AddressFamily
        }
    }
}
```

### Adding a firewall rule

This configuration will ensure that a firewall rule is present.

```powershell
# DSC configuration for Firewall
Configuration Add_FirewallRule
{
    param
    (
        [string[]]$NodeName = 'localhost'
    )

    Import-DSCResource -ModuleName xNetworking

    Node $NodeName
    {
        xFirewall Firewall
        {
            Name                  = "MyAppFirewallRule"
            Program               = "c:\windows\system32\MyApp.exe"
        }
    }
}
```

### Add a firewall rule to an existing group

This configuration ensures that two firewall rules are present on the target node, both within the same group.

```powershell
Configuration Add_FirewallRuleToExistingGroup
{
    param
    (
        [string[]]$NodeName = 'localhost'
    )

    Import-DSCResource -ModuleName xNetworking

    Node $NodeName
    {
        xFirewall Firewall
        {
            Name                  = "MyFirewallRule"
            DisplayName           = "My Firewall Rule"
            Group                 = "My Firewall Rule Group"
        }

        xFirewall Firewall1
        {
            Name                  = "MyFirewallRule1"
            DisplayName           = "My Firewall Rule"
            Group                 = "My Firewall Rule Group"
            Ensure                = "Present"
            Enabled               = "True"
            Profile               = ("Domain", "Private")
        }
    }
}
```

### Disable access to an application

This example ensures that notepad.exe is blocked by the firewall.
```powershell
Configuration Disable_AccessToApplication
{
    param
    (
        [string[]]$NodeName = 'localhost'
    )

    Import-DSCResource -ModuleName xNetworking

    Node $NodeName
    {
        xFirewall Firewall
        {
            Name                  = "NotePadFirewallRule"
            DisplayName           = "Firewall Rule for Notepad.exe"
            Group                 = "NotePad Firewall Rule Group"
            Ensure                = "Present"
            Action                = 'Blocked'
            Description           = "Firewall Rule for Notepad.exe"
            Program               = "c:\windows\system32\notepad.exe"
        }
    }
}
```

### Disable access with additional parameters

This example will disable notepad.exe's outbound access.

```powershell
# DSC configuration for Firewall

configuration Sample_xFirewall_AddFirewallRule
{
    param
    (
        [string[]]$NodeName = 'localhost'
    )

    Import-DSCResource -ModuleName xNetworking

    Node $NodeName
    {
        xFirewall Firewall
        {
            Name                  = "NotePadFirewallRule"
            DisplayName           = "Firewall Rule for Notepad.exe"
            Group                 = "NotePad Firewall Rule Group"
            Ensure                = "Present"
            Enabled               = "True"
            Profile               = ("Domain", "Private")
            Direction             = "OutBound"
            RemotePort            = ("8080", "8081")
            LocalPort             = ("9080", "9081")
            Protocol              = "TCP"
            Description           = "Firewall Rule for Notepad.exe"
            Program               = "c:\windows\system32\notepad.exe"
            Service               = "WinRM"
        }
    }
 }

Sample_xFirewall_AddFirewallRule
Start-DscConfiguration -Path Sample_xFirewall_AddFirewallRule -Wait -Verbose -Force
```

### Enable a built-in Firewall Rule

This example enables the built-in Firewall Rule 'World Wide Web Services (HTTP Traffic-In)'.
```powershell
configuration Sample_xFirewall_EnableBuiltInFirewallRule
{
    param
    (
        [string[]]$NodeName = 'localhost'
    )

    Import-DSCResource -ModuleName xNetworking

    Node $NodeName
    {
        xFirewall Firewall
        {
            Name                  = "IIS-WebServerRole-HTTP-In-TCP"
            Ensure                = "Present"
            Enabled               = "True"
        }
    }
 }
```

### Create a Firewall Rule using all available Parameters

This example will create a firewall rule using all available xFirewall resource parameters. This rule is not meaningful and would not be used like this in reality. It is used to show the expected formats of the different parameters.
```powershell
configuration Sample_xFirewall_AddFirewallRule_AllParameters
{
    param
    (
        [string[]]$NodeName = 'localhost'
    )

    Import-DSCResource -ModuleName xNetworking

    Node $NodeName
    {
        xFirewall Firewall
        {
            Name                  = "NotePadFirewallRule"
            DisplayName           = "Firewall Rule for Notepad.exe"
            Group                 = "NotePad Firewall Rule Group"
            Ensure                = "Present"
            Enabled               = "True"
            Profile               = ("Domain", "Private")
            Direction             = "OutBound"
            RemotePort            = ("8080", "8081")
            LocalPort             = ("9080", "9081")
            Protocol              = "TCP"
            Description           = "Firewall Rule for Notepad.exe"
            Program               = "c:\windows\system32\notepad.exe"
            Service               = "WinRM"
            Authentication        = "Required"
            Encryption            = "Required"
            InterfaceAlias        = "Ethernet"
            InterfaceType         = "Wired"
            LocalAddress          = @("192.168.2.0-192.168.2.128","192.168.1.0/255.255.255.0")
            LocalUser             = "O:LSD:(D;;CC;;;S-1-15-3-4)(A;;CC;;;S-1-5-21-3337988176-3917481366-464002247-1001)"
            Package               = "S-1-15-2-3676279713-3632409675-756843784-3388909659-2454753834-4233625902-1413163418"
            Platform              = "6.1"
            RemoteAddress         = @("192.168.2.0-192.168.2.128","192.168.1.0/255.255.255.0")
            RemoteMachine         = "O:LSD:(D;;CC;;;S-1-5-21-1915925333-479612515-2636650677-1621)(A;;CC;;;S-1-5-21-1915925333-479612515-2636650677-1620)"
            RemoteUser            = "O:LSD:(D;;CC;;;S-1-15-3-4)(A;;CC;;;S-1-5-21-3337988176-3917481366-464002247-1001)"
            DynamicTransport      = "ProximitySharing"
            EdgeTraversalPolicy   = "Block"
            IcmpType              = ("51","52")
            LocalOnlyMapping      = $true
            LooseSourceMapping    = $true
            OverrideBlockRules    = $true
            Owner                 = "S-1-5-21-3337988176-3917481366-464002247-500"
        }
    }
 }

Sample_xFirewall_AddFirewallRule_AllParameters
Start-DscConfiguration -Path Sample_xFirewall_AddFirewallRule_AllParameters -Wait -Verbose -Force
```

### Set the NetConnectionProfile to Public

```powershell
configuration MSFT_xNetConnectionProfile_Config {
    Import-DscResource -ModuleName xNetworking
    node localhost {
        xNetConnectionProfile Integration_Test {
            InterfaceAlias   = 'Wi-Fi'
            NetworkCategory  = 'Public'
            IPv4Connectivity = 'Internet'
            IPv6Connectivity = 'Disconncted'
        }
    }
}
```

### Set the DHCP Client state
This example would set the DHCP Client State to enabled.

```powershell
configuration Sample_xDhcpClient_Enabled
{
    param
    (
        [string[]]$NodeName = 'localhost',

        [Parameter(Mandatory)]
        [string]$InterfaceAlias,

        [Parameter(Mandatory)]
        [ValidateSet("IPv4","IPv6")]
        [string]$AddressFamily
    )

    Import-DscResource -Module xDhcpClient

    Node $NodeName
    {
        xDhcpClient EnableDhcpClient
        {
            State          = 'Enabled'
            InterfaceAlias = $InterfaceAlias
            AddressFamily  = $AddressFamily
        }
    }
}
```

### Add a Route
This example will add an IPv4 route on interface Ethernet.

```powershell
configuration Sample_xRoute_AddRoute
{
    param
    (
        [string[]]$NodeName = 'localhost'
    )

    Import-DSCResource -ModuleName xNetworking

    Node $NodeName
    {
        xRoute NetRoute1
        {
            Ensure = 'Present'
            InterfaceAlias = 'Ethernet'
            AddressFamily = 'IPv4'
            DestinationPrefix = '192.168.0.0/16'
            NextHop = '192.168.120.0'
            RouteMetric = 200
        }
    }
 }

Sample_xRoute_AddRoute
Start-DscConfiguration -Path Sample_xRoute_AddRoute -Wait -Verbose -Force
```

### Create a network team
This example shows creating a native network team.

```powershell
configuration Sample_xNetworkTeam_AddTeam
{
    param
    (
        [string[]]$NodeName = 'localhost'
    )

    Import-DSCResource -ModuleName xNetworking

    Node $NodeName
    {
        xNetworkTeam HostTeam
        {
          Name = 'HostTeam'
          TeamingMode = 'SwitchIndependent'
          LoadBalancingAlgorithm = 'HyperVPort'
          TeamMembers = 'NIC1','NIC2'
          Ensure = 'Present'
        }
    }
 }

Sample_xNetworkTeam_AddTeam
Start-DscConfiguration -Path Sample_xNetworkTeam_AddTeam -Wait -Verbose -Force
```

## Create a network team interface
This example shows adding a network team interface to native network team.

```powershell
configuration Sample_xNetworkTeamInterface_AddInterface
{
    param
    (
        [string[]]$NodeName = 'localhost'
    )

    Import-DSCResource -ModuleName xNetworking

    Node $NodeName
    {
        xNetworkTeam HostTeam
        {
          Name = 'HostTeam'
          TeamingMode = 'SwitchIndependent'
          LoadBalancingAlgorithm = 'HyperVPort'
          TeamMembers = 'NIC1','NIC2'
          Ensure = 'Present'
        }

        xNetworkTeamInterface NewInterface {
            Name = 'NewInterface'
            TeamName = 'HostTeam'
            VlanID = 100
            Ensure = 'Present'
            DependsOn = '[xNetworkTeam]HostTeam'
        }
    }
 }

Sample_xNetworkTeamInterface_AddInterface
Start-DscConfiguration -Path Sample_xNetworkTeamInterface_AddInterface -Wait -Verbose -Force
```

### Add a hosts file entry
This example will add an hosts file entry.

```powershell
configuration Sample_xHostsFile_AddEntry
{
    param
    (
        [string[]]$NodeName = 'localhost'
    )

    Import-DSCResource -ModuleName xNetworking

    Node $NodeName
    {
        xHostsFile HostEntry
        {
          HostName  = 'Host01'
          IPAddress = '192.168.0.1'
          Ensure    = 'Present'
        }
    }
 }

Sample_xHostsFile_AddEntry
Start-DscConfiguration -Path Sample_xHostsFile_AddEntry -Wait -Verbose -Force
```

### Disable IPv6 on a Network Adapter.
This example will disable the IPv6 binding on the network adapter 'Ethernet'.

```powershell
configuration Sample_xNetAdapterBinding_DisableIPv6
{
    param
    (
        [string[]]$NodeName = 'localhost'
    )

    Import-DSCResource -ModuleName xNetworking

    Node $NodeName
    {
        xNetAdapterBinding DisableIPv6
        {
            InterfaceAlias = 'Ethernet'
            ComponentId = 'ms_tcpip6'
            State = 'Disabled'
        }
    }
}

Sample_xNetAdapterBinding_DisableIPv6
Start-DscConfiguration -Path Sample_xNetAdapterBinding_DisableIPv6 -Wait -Verbose -Force
```

### Set a node to use itself as a DNS server

**Note** this sample assumes you have already setup DNS on the machine for brevity.

**This is investigational, names and parameters are subject to change.  The DSC team is investigating a better way to do this.**

Sample of using *-xNetworkAdapterName Functions

```PowerShell
Configuration SetDns
{
    param
    (
        [string[]]$NodeName = 'localhost'
    )

    Import-DSCResource -ModuleName xNetworking

    Node $NodeName
    {
        script NetAdapterName
        {
            GetScript = {
                Import-module xNetworking
                $getResult = Get-xNetworkAdapterName -Name 'Ethernet1'
                return @{
                    result = $getResult
                }
            }
            TestScript = {
                Import-module xNetworking
                Test-xNetworkAdapterName -Name 'Ethernet1'
            }
            SetScript = {
                Import-module xNetworking
                Set-xNetworkAdapterName -Name 'Ethernet1' -IgnoreMultipleMatchingAdapters
            }
        }
        xDnsServerAddress DnsServerAddress
        {
            Address        = '127.0.0.1'
            InterfaceAlias = 'Ethernet1'
            AddressFamily  = 'IPv4'
            DependsOn = @('[Script]NetAdapterName')
        }
    }
}
```

### Set the DNS Client Global Setting Suffix Search List
This example will set the DNS Global Suffix Search list to 'contoso.com'.

```PowerShell
configuration Sample_xDnsClientGlobalSetting_SuffixSearchList
{
    param
    (
        [string[]]$NodeName = 'localhost',

        [Parameter(Mandatory)]
        [string[]]$SuffixSearchList,

        [Parameter(Mandatory)]
        [boolean]$UseDevolution = $true,

        [Parameter(Mandatory)]
        [uint32]$DevolutionLevel = 0
    )

    Import-DscResource -Module xDnsClientGlobalSetting

    Node $NodeName
    {
        xDhcpClient EnableDhcpClient
        {
            IsSingleInstance = 'Yes'
            SuffixSearchList = $SuffixSearchList
            UseDevolution    = $UseDevolution
            DevolutionLevel  = $DevolutionLevel
        }
    }
}

Sample_xDnsClientGlobalSetting_SuffixSearchList -SuffixSearchList 'contoso.com'
Start-DscConfiguration -Path Sample_xDnsClientGlobalSetting_SuffixSearchList -Wait -Verbose -Force
```
