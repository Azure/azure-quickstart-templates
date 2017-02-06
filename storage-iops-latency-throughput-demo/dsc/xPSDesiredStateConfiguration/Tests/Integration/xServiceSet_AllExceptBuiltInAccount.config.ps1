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
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        [ValidateSet('Running', 'Stopped', 'Ignore')]
        [String]
        $State = 'Running',

        [ValidateSet('Automatic', 'Manual', 'Disabled')]
        [String]
        $StartupType = 'Automatic'
    )

    Import-DscResource -ModuleName 'xPSDesiredStateConfiguration'

    Node localhost
    {
        xServiceSet ServiceSet1
        {
            Name        = $Name
            Ensure      = $Ensure
            Credential  = $Credential
            State       = $State
            StartupType = $StartupType     
        }
    }
}
