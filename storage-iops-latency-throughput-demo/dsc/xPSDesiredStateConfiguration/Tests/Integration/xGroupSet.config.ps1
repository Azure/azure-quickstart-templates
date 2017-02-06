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
        $GroupName,

        [ValidateSet('Present', 'Absent')]
        [ValidateNotNullOrEmpty()]
        [String]
        $Ensure = 'Present',

        [String[]]
        $MembersToInclude = @(),

        [String[]]
        $MembersToExclude = @()
    )

    Import-DscResource -ModuleName 'xPSDesiredStateConfiguration'

    xGroupSet GroupSet1
    {
        GroupName = $GroupName
        Ensure = $Ensure
        MembersToInclude = $MembersToInclude
        MembersToExclude = $MembersToExclude
    }
}
