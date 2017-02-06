param
(
    [Parameter(Mandatory = $true)]
    [String]
    $ConfigurationName
)

Configuration $ConfigurationName
{
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $Name,

        [ValidateSet('Present', 'Absent')]
        [ValidateNotNullOrEmpty()]
        [String]
        $Ensure = 'Present',

        [ValidateNotNullOrEmpty()]
        [String]
        $LogPath = (Join-Path -Path (Get-Location) -ChildPath 'WOFTestLog.txt'),

        [Boolean]
        $RemoveFilesOnDisable = $false,

        [Boolean]
        $NoWindowsUpdateCheck = $true
    )

    Import-DscResource -ModuleName 'xPSDesiredStateConfiguration'

    xWindowsOptionalFeature WindowsOptionalFeature1
    {
        Name = $Name
        Ensure = $Ensure
        LogPath = $LogPath
        NoWindowsUpdateCheck = $NoWindowsUpdateCheck
        RemoveFilesOnDisable = $RemoveFilesOnDisable
    }
}
