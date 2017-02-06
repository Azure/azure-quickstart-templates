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
        [ValidateNotNullOrEmpty()]
        [String]
        $Path,

        [ValidateSet('Present', 'Absent')]
        [ValidateNotNullOrEmpty()]
        [String]
        $Ensure = 'Present',

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [String]
        $DisplayName = "$Name DisplayName",

        [Parameter()]
        [String]
        $Description = 'TestDescription',

        [Parameter()]
        [String[]]
        [AllowEmptyCollection()]
        $Dependencies = @(),

        [Parameter()]
        [ValidateSet('LocalSystem', 'LocalService', 'NetworkService')]
        [String]
        $BuiltInAccount = 'LocalSystem',

        [Parameter()]
        [Boolean]
        $DesktopInteract = $false,

        [Parameter()]
        [ValidateSet('Automatic', 'Manual', 'Disabled')]
        [String]
        $StartupType = 'Automatic',

        [Parameter()]
        [ValidateSet('Running', 'Stopped', 'Ignore')]
        [String]
        $State = 'Running',

        [Parameter()]
        [UInt32]
        $StartupTimeout = 30000,

        [Parameter()]
        [UInt32]
        $TerminateTimeout = 30000
    )

    Import-DscResource -ModuleName 'xPSDesiredStateConfiguration'

    Node localhost
    {
        xService Service1
        {
            Name             = $Name
            Ensure           = $Ensure
            Path             = $Path
            StartupType      = $StartupType
            BuiltInAccount   = $BuiltInAccount
            DesktopInteract  = $DesktopInteract
            State            = $State
            DisplayName      = $DisplayName
            Description      = $Description
            Dependencies     = $Dependencies
            StartupTimeout   = $StartupTimeout
            TerminateTimeout = $TerminateTimeout
        }
    }
}
