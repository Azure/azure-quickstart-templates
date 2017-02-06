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
        [String[]]
        $WindowsOptionalFeatureNames,

        [ValidateSet('Present', 'Absent')]
        [String]
        $Ensure = 'Present',

        [ValidateNotNullOrEmpty()]
        [String]
        $LogPath
    )

    Import-DscResource -ModuleName 'xPSDesiredStateConfiguration'

    xWindowsOptionalFeatureSet xWindowsOptionalFeatureSet1
    {
        Name = $WindowsOptionalFeatureNames
        Ensure = $Ensure
        LogPath = $LogPath
        NoWindowsUpdateCheck = $false
        RemoveFilesOnDisable = $false
    }
}
