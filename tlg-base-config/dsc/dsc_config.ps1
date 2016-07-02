Configuration WindowsTestConfigEnv
{
    # Parameters
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullorEmpty()]
        [PSCredential]
        $domainAdminCredential,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullorEmpty()]
        [PSCredential]
        $localAdminCredential,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullorEmpty()]
        [PSCredential]
        $safemodeAdminCredential,
        
        [Parameter(Mandatory=$true)]
        [ValidateNotNullorEmpty()]
        [PSCredential]
        $genericUserCredential
    )

    # Import our DSC Resources
    Import-DscResource -Module PSDesiredStateConfiguration, xActiveDirectory, xStorage, xNetworking, xComputerManagement, xSmbShare
  
    #Node $AllNodes.NodeName
    Node ($env:COMPUTERNAME)
    {
        if ($Node.ServiceRoles.DomainController -eq $true) {
            # Wait for Disk 2
            xWaitforDisk Disk2
            {
                DiskNumber       = 2
                RetryIntervalSec = 60
                RetryCount       = 60
            }

            # Configure Disk 2 as F:
            xDisk FVolume
            {
                DiskNumber  = 2
                DriveLetter = 'F'
                DependsOn   = '[xWaitforDisk]Disk2'
            }

            # Install Domain Services
            WindowsFeature ADDSInstall
            {
                Name   = 'AD-Domain-Services'
                Ensure = 'Present'
            }

            # Configure new forest as corp.contoso.com
            xADDomain FirstDS
            {
                DomainName                    = $ConfigurationData.NonNodeData.DomainDetails.DomainName
                DomainNetBIOSName             = $ConfigurationData.NonNodeData.DomainDetails.NetbiosName
                DomainAdministratorCredential = $localAdminCredential
                SafemodeAdministratorPassword = $safemodeAdminCredential
                DatabasePath                  = $ConfigurationData.NonNodeData.DomainDetails.DatabasePath
                SysvolPath                    = $ConfigurationData.NonNodeData.DomainDetails.SysvolPath
                DependsOn                     = '[WindowsFeature]ADDSInstall','[xDisk]FVolume'
            }

            # Wait for Forest
            xWaitForADDomain DscForestWait
            {
                DomainName       = $ConfigurationData.NonNodeData.DomainDetails.DomainName
                RetryCount       = 60
                RetryIntervalSec = 60
                DependsOn        = '[xADDomain]FirstDS'
            }

            # Install AD Management Tools
            WindowsFeature RSATADDSTools
            {
                Name   = 'RSAT-ADDS-Tools'
                Ensure = 'Present'
            }

            # Add generic user
            xADUser User_GenericUser
            {
                DomainName = $ConfigurationData.NonNodeData.DomainDetails.DomainName
                UserName   = $genericUserCredential.UserName
                Password   = $genericUserCredential
                Ensure     = 'Present'
            }

            # Put generic user in 'Domain Admins'
            xADGroup DA_GenericUser
            {
                GroupName        = 'Domain Admins'
                MembersToInclude = $genericUserCredential.UserName
                Ensure           = 'Present'
                DependsOn        = '[xADUser]User_GenericUser'
            }

            # Put generic user in 'Enterprise Admins'
            xADGroup EA_GenericUser
            {
                GroupName        = 'Enterprise Admins'
                GroupScope       = 'Universal'  #Not setting this to what it already is breaks DSC since default is 'Global' and you can't change this one. 
                MembersToInclude = $genericUserCredential.UserName
                Ensure           = 'Present'
                DependsOn        = '[xADUser]User_GenericUser'
            }

            # Open Firewall for ping
            xFirewall Enable_Ping
            {
                Name    = 'File and Printer Sharing (Echo Request - ICMPv4-In)'
                Enabled = 'True'
                Ensure  = 'Present'
            }
        }

        if ($Node.ServiceRoles.MemberServer -eq $true) {
            # WaitFor AD corp.contoso.com on DC1
            WaitForAll DC1
            {
                ResourceName     = '[xADDomain]FirstDS'
                NodeName         = 'DC1.' + $ConfigurationData.NonNodeData.DomainDetails.DomainName
                RetryIntervalSec = 60
                RetryCount       = 60
            }

            # Join corp.contoso.com
            xComputer AD_CORP
            {
                Name       = $env:COMPUTERNAME
                DomainName = $ConfigurationData.NonNodeData.DomainDetails.DomainName
                Credential = $domainAdminCredential
                DependsOn  = '[WaitForAll]DC1' 
            }
        }

        if ($Node.ServiceRoles.WebServer -eq $true) {
            # Install IIS
            WindowsFeature IIS
            {
                Name   = 'Web-Server'
                Ensure = 'Present'
            }

            # Install IIS Management Tools
            WindowsFeature IIS_ManagementTools
            {
                Name   = 'Web-Mgmt-Console'
                Ensure = 'Present'
            }

            # Create 'c:\files' for sharing
            File Folder_Files
            {
                DestinationPath = 'c:\files'
                Type            = 'Directory'
                Ensure          = 'Present'
            }

            # Create 'example.txt' in 'c:\files'
            File File_Example_txt
            {
                DestinationPath = 'c:\files\example.txt'
                Type            = 'File'
                Contents        = 'This is a shared file.'
                Ensure          = 'Present'
                DependsOn       = '[File]Folder_Files'
            }

            # Make 'c:\files' a SMB share with access to corp\User1 (Read)
            xSmbShare SMB_Files
            {
                Name        = 'Files'
                Path        = 'C:\files'
                ReadAccess  = $ConfigurationData.NonNodeData.DomainDetails.NetbiosName + '\' + $genericUserCredential.UserName
                Description = 'Our created file share'
                Ensure      = 'Present'
                DependsOn   = '[File]Folder_Files','[xComputer]AD_CORP'
            }
        }

        LocalConfigurationManager
        {
            RebootNodeIfNeeded = $true
            ConfigurationMode = 'ApplyAndAutoCorrect'
            RefreshFrequencyMins = 30
        }
    }
}