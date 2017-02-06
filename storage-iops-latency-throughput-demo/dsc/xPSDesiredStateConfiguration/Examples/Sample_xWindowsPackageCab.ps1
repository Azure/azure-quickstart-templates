<#
    .SYNOPSIS
        Installs a package from the cab file with the specified name from the specified source path
        and outputs a log to the specified log path.

    .PARAMETER Name
        The name of the package to install.

    .PARAMETER SourcePath
        The path to the cab file to install the package from.

    .PARAMETER LogPath
        The path to a file to log the install operation to.

    .NOTES
        The DISM PowerShell module must be available on the target machine.
#>
Configuration Sample_xWindowsPackageCab
{
    param
    (
        [Parameter (Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $Name,

        [Parameter (Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $SourcePath,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $LogPath
    )

    Import-DscResource -ModuleName 'xPSDesiredStateConfiguration'

    xWindowsPackageCab WindowsPackageCab1
    {
        Name = $Name
        Ensure = 'Present'
        SourcePath = $SourcePath
        LogPath = $LogPath
    }
}

Sample_xWindowsPackageCab
