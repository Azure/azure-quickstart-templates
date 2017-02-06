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
        $ValueName,

        [Parameter(Mandatory = $true)]
        [ValidateSet('String', 'Binary', 'DWord', 'QWord', 'MultiString', 'ExpandString')]
        [String]
        $ValueType,

        [Parameter(Mandatory = $true)]
        [String[]]
        [AllowEmptyCollection()]
        $ValueData
    )

    Import-DscResource -ModuleName 'xPSDesiredStateConfiguration'

    Node localhost
    {
        xRegistry Registry1
        {
            Key = $Key
            Ensure = $Ensure
            ValueName = $ValueName
            ValueType = $ValueType
            ValueData = $ValueData
            Force = $true
        }
    }
}
