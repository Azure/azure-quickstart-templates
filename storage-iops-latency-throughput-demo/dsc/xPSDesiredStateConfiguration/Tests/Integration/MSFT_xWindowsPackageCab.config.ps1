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

        [Parameter(Mandatory = $true)]
        [ValidateSet('Present', 'Absent')]
        [String]
        $Ensure,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $SourcePath,

        [ValidateNotNullOrEmpty()]
        [String]
        $LogPath = (Join-Path -Path (Get-Location) -ChildPath 'WindowsPackageCabTestLog.txt')
    )

    Import-DscResource -ModuleName 'xPSDesiredStateConfiguration'

    xWindowsPackageCab WindowsPackageCab1
    {
        Name = $Name
        Ensure = $Ensure
        SourcePath = $SourcePath
        LogPath = $LogPath
    }
}
