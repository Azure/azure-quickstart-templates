Configuration AllowRemoteDesktopAdminConnections
{
    Import-DscResource -Module xRemoteDesktopAdmin, xNetworking

    Node ('localhost')
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
    }
}

$workingdir = 'C:\RDP\MOF'

# Create MOFAllowRemoteDesktopAdminConnections -OutputPath $workingdir# Apply MOFStart-DscConfiguration -ComputerName 'localhost' -wait -force -verbose -path $workingdir
