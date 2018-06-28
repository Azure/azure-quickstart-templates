# The configuration data section specifies which certificate and thumbprint to use for encrypting the password
$ConfigData = @{
    AllNodes = @(
        @{
            NodeName="DSCnode1";
            CertificateFile = "C:\Certificates\DSCnode1.cer" 
            Thumbprint = "E36D15C59BDBABB8525E48568844DD7079C1C3DD"
         }

)}

Configuration AllowRemoteDesktopAdminConnections
{
    param( 
            [Parameter(Mandatory=$true)] 
            [ValidateNotNullorEmpty()] 
            [PsCredential] $Credential 
         ) 

    
    Import-DscResource -Module xRemoteDesktopAdmin, xNetworking

    Node ('DSCnode1')
    {        
        xRemoteDesktopAdmin RemoteDesktopSettings
        {
           Ensure = 'Present'
           UserAuthentication = 'Secure'
        }

        xFirewall AllowRDP
        {
            Name = 'DSC - Remote Desktop Admin Connections'
            DisplayGroup = "Remote Desktop"
            Ensure = 'Present'
            State = 'Enabled'
            Access = 'Allow'
            Profile = 'Domain'
        }

        Group RDPGroup
        {
           Ensure = 'Present'
           GroupName = "Remote Desktop Users"
           Members = 'Contoso\RDP_User'
           Credential = $Credential
           
        }

         LocalConfigurationManager 
        { 
             CertificateId = $node.Thumbprint 
        } 
    }
}

# Set your working directory for the output of the MOF file
$workingdir = 'C:\RDP\MOF'

# Create MOF with configuration dataAllowRemoteDesktopAdminConnections -ConfigurationData $ConfigData -OutputPath $workingdir# Use Set-DscLocalConfigurationManager to apply the *.meta.mof
Set-DscLocalConfigurationManager -ComputerName 'DSCnode1' $workingdir -Verbose# Apply the configurationStart-DscConfiguration -ComputerName 'DSCnode1' -wait -force -verbose -path $workingdir
