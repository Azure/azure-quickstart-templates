# The configuration data section specifies to allow using a plain text stored password
$ConfigData = @{
    AllNodes = @(
        @{
            NodeName="DSCnode1";
            PSDscAllowPlainTextPassword = $true
            
         }

)}

Configuration AllowRemoteDesktopAdminConnections
{
    $password = ConvertTo-SecureString "YourPasswordHere" -AsPlainText -Force
    $Credential = New-Object System.Management.Automation.PSCredential ("Contoso\RDP_User", $password)
    
    Import-DscResource -Module xRemoteDesktopAdmin, xNetworking

    node ('DSCnode1')
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
         
    }
}

# Set your working directory for the output of the MOF file
$workingdir = 'C:\RDP\MOF'

# Create MOF with configuration dataAllowRemoteDesktopAdminConnections -ConfigurationData $ConfigData -OutputPath $workingdir# Apply the configurationStart-DscConfiguration -ComputerName 'DSCnode1' -wait -force -verbose -path $workingdir
