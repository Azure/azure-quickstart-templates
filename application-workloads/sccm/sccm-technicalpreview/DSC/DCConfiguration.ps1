configuration Configuration
{
   param
   (
        [Parameter(Mandatory)]
        [String]$DomainName,
        [Parameter(Mandatory)]
        [String]$DCName,
        [Parameter(Mandatory)]
        [String]$DPMPName,
        [Parameter(Mandatory)]
        [String]$PSName,
        [Parameter(Mandatory)]
        [System.Array]$ClientName,
        [Parameter(Mandatory)]
        [String]$DNSIPAddress,
        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential]$Admincreds
    )

    Import-DscResource -ModuleName TemplateHelpDSC

    $LogFolder = "TempLog"
    $LogPath = "c:\$LogFolder"
    $CM = "CMTP"
    $DName = $DomainName.Split(".")[0]
    $PSComputerAccount = "$DName\$PSName$"
    $DPMPComputerAccount = "$DName\$DPMPName$"
    $Clients = [system.String]::Join(",", $ClientName)
    $ClientComputerAccount = "$DName\"+[system.String]::Join(",", $ClientName)+"$"   
    [System.Management.Automation.PSCredential]$DomainCreds = New-Object System.Management.Automation.PSCredential ("${DomainName}\$($Admincreds.UserName)", $Admincreds.Password)

    Node LOCALHOST
    {
        LocalConfigurationManager
        {
            ConfigurationMode = 'ApplyOnly'
            RebootNodeIfNeeded = $true
        }

        SetCustomPagingFile PagingSettings
        {
            Drive       = 'C:'
            InitialSize = '8192'
            MaximumSize = '8192'
        }

        InstallFeatureForSCCM InstallFeature
        {
            Name = 'DC'
            Role = 'DC'
            DependsOn = "[SetCustomPagingFile]PagingSettings"
        }
        
        SetupDomain FirstDS
        {
            DomainFullName = $DomainName
            SafemodeAdministratorPassword = $DomainCreds
            DependsOn = "[InstallFeatureForSCCM]InstallFeature"
        }

        VerifyComputerJoinDomain WaitForPS
        {
            ComputerName = $PSName
            Ensure = "Present"
            DependsOn = "[SetupDomain]FirstDS"
        }

        VerifyComputerJoinDomain WaitForDPMP
        {
            ComputerName = $DPMPName
            Ensure = "Present"
            DependsOn = "[SetupDomain]FirstDS"
        }

        if ($ClientName -eq 'Empty')
        {
            File ShareFolder
            {
                DestinationPath = $LogPath     
                Type = 'Directory'            
                Ensure = 'Present'
                DependsOn = @("[VerifyComputerJoinDomain]WaitForPS","[VerifyComputerJoinDomain]WaitForDPMP")
            }

            FileReadAccessShare DomainSMBShare
            {
                Name   = $LogFolder
                Path =  $LogPath
                Account = $PSComputerAccount,$DPMPComputerAccount
                DependsOn = "[File]ShareFolder"
            }
        }
        else
        {
            VerifyComputerJoinDomain WaitForClient
            {
                ComputerName = $Clients
                Ensure = "Present"
                DependsOn = "[SetupDomain]FirstDS"
            }

            File ShareFolder
            {
                DestinationPath = $LogPath     
                Type = 'Directory'            
                Ensure = 'Present'
                DependsOn = @("[VerifyComputerJoinDomain]WaitForPS","[VerifyComputerJoinDomain]WaitForDPMP","[VerifyComputerJoinDomain]WaitForClient")
            }

            FileReadAccessShare DomainSMBShare
            {
                Name = $LogFolder
                Path = $LogPath
                Account = $PSComputerAccount,$DPMPComputerAccount,$ClientComputerAccount
                DependsOn = "[File]ShareFolder"
            }

            WriteConfigurationFile WriteClientJoinDomain
            {
                Role = "DC"
                LogPath = $LogPath
                WriteNode = "ClientJoinDomain"
                Status = "Passed"
                Ensure = "Present"
                DependsOn = "[FileReadAccessShare]DomainSMBShare"
            }
        }

        WriteConfigurationFile WritePSJoinDomain
        {
            Role = "DC"
            LogPath = $LogPath
            WriteNode = "PSJoinDomain"
            Status = "Passed"
            Ensure = "Present"
            DependsOn = "[FileReadAccessShare]DomainSMBShare"
        }

        WriteConfigurationFile WriteDPMPJoinDomain
        {
            Role = "DC"
            LogPath = $LogPath
            WriteNode = "DPMPJoinDomain"
            Status = "Passed"
            Ensure = "Present"
            DependsOn = "[FileReadAccessShare]DomainSMBShare"
        }

        DelegateControl AddPS
        {
            Machine = $PSName
            DomainFullName = $DomainName
            Ensure = "Present"
            DependsOn = "[WriteConfigurationFile]WritePSJoinDomain"
        }

        DelegateControl AddDPMP
        {
            Machine = $DPMPName
            DomainFullName = $DomainName
            Ensure = "Present"
            DependsOn = "[WriteConfigurationFile]WriteDPMPJoinDomain"
        }

        WriteConfigurationFile WriteDelegateControlfinished
        {
            Role = "DC"
            LogPath = $LogPath
            WriteNode = "DelegateControl"
            Status = "Passed"
            Ensure = "Present"
            DependsOn = @("[DelegateControl]AddPS","[DelegateControl]AddDPMP")
        }

        WaitForExtendSchemaFile WaitForExtendSchemaFile
        {
            MachineName = $PSName
            ExtFolder = $CM
            Ensure = "Present"
            DependsOn = "[WriteConfigurationFile]WriteDelegateControlfinished"
        }
    }
}