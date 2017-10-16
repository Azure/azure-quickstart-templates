@{
# Version number of this module.
ModuleVersion = '3.0.0.0'

# ID used to uniquely identify this module
GUID = 'e6647cc3-ce9c-4c86-9eb8-2ee8919bf358'

# Author of this module
Author = 'Microsoft Corporation'

# Company or vendor of this module
CompanyName = 'Microsoft Corporation'

# Copyright statement for this module
Copyright = '(c) 2013 Microsoft Corporation. All rights reserved.'

# Description of the functionality provided by this module
Description = 'Module with DSC Resources for Networking area'

# Minimum version of the Windows PowerShell engine required by this module
PowerShellVersion = '4.0'

# Minimum version of the common language runtime (CLR) required by this module
CLRVersion = '4.0'

# Functions to export from this module
FunctionsToExport = '*'

# Cmdlets to export from this module
CmdletsToExport = '*'

NestedModules = @( 'xNetworkAdapter.psm1')

# Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
PrivateData = @{

    PSData = @{

        # Tags applied to this module. These help with module discovery in online galleries.
        Tags = @('DesiredStateConfiguration', 'DSC', 'DSCResourceKit', 'DSCResource')

        # A URL to the license for this module.
        LicenseUri = 'https://github.com/PowerShell/xNetworking/blob/master/LICENSE'

        # A URL to the main website for this project.
        ProjectUri = 'https://github.com/PowerShell/xNetworking'

        # A URL to an icon representing this module.
        # IconUri = ''

        # ReleaseNotes of this module
        ReleaseNotes = '* Corrected integration test filenames:
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

'

    } # End of PSData hashtable

} # End of PrivateData hashtable
}




