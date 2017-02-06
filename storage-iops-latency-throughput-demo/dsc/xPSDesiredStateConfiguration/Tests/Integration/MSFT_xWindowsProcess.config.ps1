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
        $Path,

        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [String]
        $Arguments,

        [ValidateSet('Present', 'Absent')]
        [String]
        $Ensure = 'Present'
    )

    Import-DscResource -ModuleName 'xPSDesiredStateConfiguration'

    xWindowsProcess Process1
    {
        Path = $Path
        Arguments = $Arguments
        Ensure = $Ensure
    }
}
