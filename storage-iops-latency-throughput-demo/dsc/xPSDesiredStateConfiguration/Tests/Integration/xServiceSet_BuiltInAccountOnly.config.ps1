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
        $Name,

        [ValidateSet('Present', 'Absent')]
        [ValidateNotNullOrEmpty()]
        [String]
        $Ensure = 'Present',

        [Parameter(Mandatory = $true)]
        [ValidateSet('LocalSystem', 'LocalService', 'NetworkService')]
        [String]
        $BuiltInAccount
    )

    Import-DscResource -ModuleName 'xPSDesiredStateConfiguration'

    Node localhost
    {
        xServiceSet ServiceSet1
        {
            Name           = $Name
            Ensure         = $Ensure
            BuiltInAccount = $BuiltInAccount
        }
    }
}
