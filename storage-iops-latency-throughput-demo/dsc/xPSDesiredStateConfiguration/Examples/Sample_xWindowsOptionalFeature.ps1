<#
    .SYNOPSIS
        Enables the Windows optional feature with the specified name and outputs a log to the specified path.

    .PARAMETER FeatureName
        The name of the Windows optional feature to enable.

    .PARAMETER LogPath
        The path to the file to log the enable operation to.

    .NOTES
        Can only be run on Windows client operating systems and Windows Server 2012 or later.
        The DISM PowerShell module must be available on the target machine.
#>
Configuration Sample_xWindowsOptionalFeature
{
    param
    (
        [Parameter (Mandatory = $true)]
        [String]
        $FeatureName,

        [Parameter(Mandatory = $true)]
        [String]
        $LogPath
    )

    Import-DscResource -ModuleName 'xPSDesiredStateConfiguration'

    xWindowsOptionalFeature TelnetClient
    {
        Name = $FeatureName
        Ensure = 'Present'
        LogPath = $LogPath
    }
}

Sample_xWindowsOptionalFeature
