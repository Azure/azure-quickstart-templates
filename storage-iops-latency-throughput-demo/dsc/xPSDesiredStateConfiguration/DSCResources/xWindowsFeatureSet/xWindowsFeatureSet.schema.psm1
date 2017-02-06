$errorActionPreference = 'Stop'
Set-StrictMode -Version 'Latest'

# Import ResourceSetHelper for New-ResourceSetConfigurationScriptBlock
$script:dscResourcesFolderFilePath = Split-Path -Path $PSScriptRoot -Parent
$script:resourceSetHelperFilePath = Join-Path -Path $script:dscResourcesFolderFilePath -ChildPath 'ResourceSetHelper.psm1'
Import-Module -Name $script:resourceSetHelperFilePath

<#
    .SYNOPSIS
        A composite DSC resource to configure a set of similar xWindowsFeature resources.

    .PARAMETER Name
        The name of the roles or features to install or uninstall.

    .PARAMETER Ensure
        Specifies whether the roles or features should be installed or uninstalled.

        To install the features, set this property to Present.
        To uninstall the features, set this property to Absent.

    .PARAMETER IncludeAllSubFeature
        Specifies whether or not all subfeatures should be installed or uninstalled alongside the specified roles or features.

        If this property is true and Ensure is set to Present, all subfeatures will be installed.
        If this property is false and Ensure is set to Present, subfeatures will not be installed or uninstalled.
        If Ensure is set to Absent, all subfeatures will be uninstalled.

    .PARAMETER Credential
        The credential of the user account under which to install or uninstall the roles or features.

    .PARAMETER LogPath
        The custom file path to which to log this operation.
        If not passed in, the default log path will be used (%windir%\logs\ServerManager.log).
#>
Configuration xWindowsFeatureSet
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String[]]
        $Name,

        [ValidateSet('Present', 'Absent')]
        [String]
        $Ensure,

        [ValidateNotNullOrEmpty()]
        [String]
        $Source,

        [Boolean]
        $IncludeAllSubFeature,

        [ValidateNotNull()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        [ValidateNotNullOrEmpty()]
        [String]
        $LogPath
    )

    $newResourceSetConfigurationParams = @{
        ResourceName = 'xWindowsFeature'
        ModuleName = 'xPSDesiredStateConfiguration'
        KeyParameterName = 'Name'
        Parameters = $PSBoundParameters
    }
    
    $configurationScriptBlock = New-ResourceSetConfigurationScriptBlock @newResourceSetConfigurationParams

    # This script block must be run directly in this configuration in order to resolve variables
    . $configurationScriptBlock
}
