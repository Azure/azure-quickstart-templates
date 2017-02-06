$errorActionPreference = 'Stop'
Set-StrictMode -Version 'Latest'

# Import ResourceSetHelper for New-ResourceSetConfigurationScriptBlock
$script:dscResourcesFolderFilePath = Split-Path -Path $PSScriptRoot -Parent
$script:resourceSetHelperFilePath = Join-Path -Path $script:dscResourcesFolderFilePath -ChildPath 'ResourceSetHelper.psm1'
Import-Module -Name $script:resourceSetHelperFilePath

<#
    .SYNOPSIS
        A composite DSC resource to configure a set of similar xGroup resources.

    .PARAMETER GroupName
        An array of the names of the groups to configure.

    .PARAMETER Ensure
        Specifies whether or not the set of groups should exist.
        
        Set this property to Present to create or modify a set of groups.
        Set this property to Absent to remove a set of groups.

    .PARAMETER MembersToInclude
        The members that should be included in each group in the set.

    .PARAMETER MembersToExclude
        The members that should be excluded from each group in the set.

    .PARAMETER Credential
        The credential to resolve all groups and user accounts.
#>
Configuration xGroupSet
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String[]]
        $GroupName,

        [ValidateSet('Present', 'Absent')]
        [String]
        $Ensure,

        [String[]]
        $MembersToInclude,

        [String[]]
        $MembersToExclude,

        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential
    )

    $newResourceSetConfigurationParams = @{
        ResourceName = 'xGroup'
        ModuleName = 'xPSDesiredStateConfiguration'
        KeyParameterName = 'GroupName'
        Parameters = $PSBoundParameters
    }

    $configurationScriptBlock = New-ResourceSetConfigurationScriptBlock @newResourceSetConfigurationParams

    # This script block must be run directly in this configuration in order to resolve variables
    . $configurationScriptBlock
}
