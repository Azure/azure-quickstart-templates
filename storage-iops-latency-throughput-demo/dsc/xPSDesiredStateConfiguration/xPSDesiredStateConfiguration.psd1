@{
# Version number of this module.
ModuleVersion = '6.0.0.0'

# ID used to uniquely identify this module
GUID = 'cc8dc021-fa5f-4f96-8ecf-dfd68a6d9d48'

# Author of this module
Author = 'Microsoft Corporation'

# Company or vendor of this module
CompanyName = 'Microsoft Corporation'

# Copyright statement for this module
Copyright = '(c) 2014 Microsoft Corporation. All rights reserved.'

# Description of the functionality provided by this module
Description = 'The xPSDesiredStateConfiguration module is a part of the Windows PowerShell Desired State Configuration (DSC) Resource Kit, which is a collection of DSC Resources produced by the PowerShell Team. This module contains the xDscWebService, xWindowsProcess, xService, xPackage, xArchive, xRemoteFile, xPSEndpoint and xWindowsOptionalFeature resources. Please see the Details section for more information on the functionalities provided by these resources.

All of the resources in the DSC Resource Kit are provided AS IS, and are not supported through any Microsoft standard support program or service. The "x" in xPSDesiredStateConfiguration stands for experimental, which means that these resources will be fix forward and monitored by the module owner(s).'

# Minimum version of the Windows PowerShell engine required by this module
PowerShellVersion = '4.0'

# Minimum version of the common language runtime (CLR) required by this module
CLRVersion = '4.0'

# Functions to export from this module
FunctionsToExport = '*'

# Cmdlets to export from this module
CmdletsToExport = '*'

#Root module
RootModule = 'DSCPullServerSetup\PublishModulesAndMofsToPullServer.psm1'

# Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
PrivateData = @{

    PSData = @{

        # Tags applied to this module. These help with module discovery in online galleries.
        Tags = @('DesiredStateConfiguration', 'DSC', 'DSCResourceKit', 'DSCResource')

        # A URL to the license for this module.
        LicenseUri = 'https://github.com/PowerShell/xPSDesiredStateConfiguration/blob/master/LICENSE'

        # A URL to the main website for this project.
        ProjectUri = 'https://github.com/PowerShell/xPSDesiredStateConfiguration'

        # A URL to an icon representing this module.
        # IconUri = ''

        # ReleaseNotes of this module
        ReleaseNotes = '* xEnvironment
    * Updated resource to follow HQRM guidelines.
    * Added examples.
    * Added unit and end-to-end tests.
    * Significantly cleaned the resource.
    * Minor Breaking Change where the resource will now throw an error if no value is provided, Ensure is set to present, and the variable does not exist, whereas before it would create an empty registry key on the machine in this case (if this is the desired outcome then use the Registry resource).
    * Added a new Write property "Target", which specifies whether the user wants to set the machine variable, the process variable, or both (previously it was setting both in most cases).  
* xGroup:
    * Group members in the "NT Authority", "BuiltIn" and "NT Service" scopes should now be resolved without an error. If you were seeing the errors "Exception calling ".ctor" with "4" argument(s): "Server names cannot contain a space character."" or "Exception calling ".ctor" with "2" argument(s): "Server names cannot contain a space character."", this fix should resolve those errors. If you are still seeing one of the errors, there is probably another local scope we need to add. Please let us know.
    * The resource will no longer attempt to resolve group members if Members, MembersToInclude, and MembersToExclude are not specified.

'

    } # End of PSData hashtable

} # End of PrivateData hashtable
}










