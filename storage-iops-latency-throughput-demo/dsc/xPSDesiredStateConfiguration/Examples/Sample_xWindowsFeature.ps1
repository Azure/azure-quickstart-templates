<#
    Create a custom configuration by passing in whatever values you need. 
    $Name is the only parameter that is required which indicates which
    Windows Feature you want to install (or uninstall if you set Ensure to Absent).
    LogPath and Credential are not included here, but if you would like to specify
    a custom log path or need a credential just pass in the desired values and add
    LogPath = $LogPath and/or Credential = $Credential to the configuration here
#>      

Configuration 'Install_Feature_Telnet_Client'
{
    param 
    (       
        [System.String]
        $Name = 'Telnet-Client',

        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure = 'Present',

        [System.Boolean]
        $IncludeAllSubFeature = $false,

        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        [ValidateNotNullOrEmpty()]
        [System.String]
        $LogPath
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

