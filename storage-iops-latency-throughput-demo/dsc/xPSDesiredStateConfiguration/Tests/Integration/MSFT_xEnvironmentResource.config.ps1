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
        
        [ValidateNotNull()]
        [String]
        $Value = [String]::Empty,
        
        [ValidateSet('Present', 'Absent')]
        [String]
        $Ensure = 'Present',
        
        [Boolean]
        $Path = $false,

        [ValidateSet('Process', 'Machine')]
        [String[]]
        $Target = ('Process', 'Machine')
    )

    Import-DscResource -ModuleName 'xPSDesiredStateConfiguration'

    xEnvironment Environment1
    {
        Name = $Name
        Value = $Value
        Ensure = $Ensure
        Path = $Path
        Target = $Target
    }
}

