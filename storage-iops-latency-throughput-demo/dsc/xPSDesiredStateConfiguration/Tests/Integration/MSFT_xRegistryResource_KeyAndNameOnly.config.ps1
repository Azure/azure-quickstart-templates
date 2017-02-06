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
        $Key,

        [ValidateSet('Present', 'Absent')]
        [String]
        $Ensure = 'Present',

        [Parameter(Mandatory = $true)]
        [String]
        [AllowEmptyString()]
        $ValueName
    )

    Import-DscResource -ModuleName 'xPSDesiredStateConfiguration'

    Node localhost
    {
        xRegistry Registry1
        {
            Key = $Key
            Ensure = $Ensure
            ValueName = $ValueName
            Force = $true
        }
    }
}
