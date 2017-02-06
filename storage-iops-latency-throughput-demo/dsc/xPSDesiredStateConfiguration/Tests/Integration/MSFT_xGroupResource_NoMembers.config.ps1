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
        $GroupName,

        [ValidateSet('Present', 'Absent')]
        [ValidateNotNullOrEmpty()]
        [String]
        $Ensure = 'Present'
    )

    Import-DscResource -ModuleName 'xPSDesiredStateConfiguration'

    xGroup Group3
    {
        GroupName = $GroupName
        Ensure = $Ensure
    }
}
