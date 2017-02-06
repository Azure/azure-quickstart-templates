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
        $Ensure = 'Present',

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential = (Get-Credential)
    )

    Import-DscResource -ModuleName 'xPSDesiredStateConfiguration'

    Node $AllNodes.NodeName
    {
        xWindowsProcess Process1
        {
            Path = $Path
            Arguments = $Arguments
            Credential = $Credential
            Ensure = $Ensure
        }
    }
}
