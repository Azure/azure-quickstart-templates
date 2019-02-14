configuration CreateADRootDC
{
   param
   (
        [Parameter(Mandatory)]
        [String]$DomainName,
        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential]$Admincreds
    )
    Import-DscResource -ModuleName xActiveDirectory
    
    [System.Management.Automation.PSCredential]$DomainCreds = New-Object System.Management.Automation.PSCredential ("${DomainName}\$($Admincreds.UserName)", $Admincreds.Password)

    Node localhost
    {
        LocalConfigurationManager
        {
            ConfigurationMode = 'ApplyOnly'
            RebootNodeIfNeeded = $true
        }
        File ADFiles            
        {            
            DestinationPath = 'C:\Windows\NTDS'            
            Type = 'Directory'            
            Ensure = 'Present'            
        }       

		WindowsFeature ADDSInstall             
        {             
            Ensure = "Present"             
            Name = "AD-Domain-Services"             
        }         

		WindowsFeature ADTools
        {
            Ensure = "Present"
            Name = "RSAT-AD-Tools"
        }

        xADDomain FirstDS
        {
            DomainName = $DomainName
            DomainAdministratorCredential = $DomainCreds
            SafemodeAdministratorPassword = $DomainCreds
            DatabasePath = "C:\Windows\NTDS"
            LogPath = "C:\Windows\NTDS"
            SysvolPath = "C:\Windows\SYSVOL"
            DependsOn = "[WindowsFeature]ADDSInstall","[File]ADFiles"            
        }
    }
}