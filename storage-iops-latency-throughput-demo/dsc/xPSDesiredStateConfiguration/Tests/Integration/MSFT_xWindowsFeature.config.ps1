
param 
(
    [Parameter(Mandatory)]
    [System.String]
    $ConfigurationName
)
        

Configuration $ConfigurationName
{
    param 
    (   
        [Parameter(Mandatory = $true)]     
        [System.String]
        $Name,

        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure = 'Present',

        [System.Boolean]
        $IncludeAllSubFeature = $false
    )
    
    Import-DscResource -ModuleName 'xPSDesiredStateConfiguration'
    
    Node Localhost {

        xWindowsFeature WindowsFeatureTest
        {
            Name = $Name
            Ensure = $Ensure
            IncludeAllSubFeature = $IncludeAllSubFeature
        }
    }
}
