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
        [String]$CSName,
        [Parameter(Mandatory)]
        [String]$PSName,
        [Parameter(Mandatory)]
        [System.Array]$ClientName,
        [Parameter(Mandatory)]
        [String]$Configuration,
        [Parameter(Mandatory)]
        [String]$DNSIPAddress,
        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential]$Admincreds
    )

    Import-DscResource -ModuleName TemplateHelpDSC

    $LogFolder = "TempLog"
    $LogPath = "c:\$LogFolder"
    $CM = "CMCB"
    $DName = $DomainName.Split(".")[0]
    if($Configuration -ne "Standalone")
    {
        $CSComputerAccount = "$DName\$CSName$"
    }
    $PSComputerAccount = "$DName\$PSName$"
    $DPMPComputerAccount = "$DName\$DPMPName$"
    $Clients = [system.String]::Join(",", $ClientName)
    $ClientComputerAccount = "$DName\$Clients$"

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

        InstallCA InstallCA
        {
            HashAlgorithm = "SHA256"
            DependsOn = "[SetupDomain]FirstDS"
        }

        VerifyComputerJoinDomain WaitForPS
        {
            ComputerName = $PSName
            Ensure = "Present"
            DependsOn = "[InstallCA]InstallCA"
        }

        VerifyComputerJoinDomain WaitForDPMP
        {
            ComputerName = $DPMPName
            Ensure = "Present"
            DependsOn = "[InstallCA]InstallCA"
        }

        VerifyComputerJoinDomain WaitForClient
        {
            ComputerName = $Clients
            Ensure = "Present"
            DependsOn = "[InstallCA]InstallCA"
        }

        if ($Configuration -eq 'Standalone') {
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
        else {
            VerifyComputerJoinDomain WaitForCS
            {
                ComputerName = $CSName
                Ensure = "Present"
                DependsOn = "[InstallCA]InstallCA"
            }

            File ShareFolder
            {            
                DestinationPath = $LogPath     
                Type = 'Directory'            
                Ensure = 'Present'
                DependsOn = @("[VerifyComputerJoinDomain]WaitForCS","[VerifyComputerJoinDomain]WaitForPS","[VerifyComputerJoinDomain]WaitForDPMP","[VerifyComputerJoinDomain]WaitForClient")
            }

            FileReadAccessShare DomainSMBShare
            {
                Name = $LogFolder
                Path = $LogPath
                Account = $CSComputerAccount,$PSComputerAccount,$DPMPComputerAccount,$ClientComputerAccount
                DependsOn = "[File]ShareFolder"
            }
            
            WriteConfigurationFile WriteCSJoinDomain
            {
                Role = "DC"
                LogPath = $LogPath
                WriteNode = "CSJoinDomain"
                Status = "Passed"
                Ensure = "Present"
                DependsOn = "[FileReadAccessShare]DomainSMBShare"
            }

            DelegateControl AddCS
            {
                Machine = $CSName
                DomainFullName = $DomainName
                Ensure = "Present"
                DependsOn = "[WriteConfigurationFile]WriteCSJoinDomain"
            }

            WriteConfigurationFile WriteDelegateControlfinished
            {
                Role = "DC"
                LogPath = $LogPath
                WriteNode = "DelegateControl"
                Status = "Passed"
                Ensure = "Present"
                DependsOn = @("[DelegateControl]AddCS","[DelegateControl]AddPS","[DelegateControl]AddDPMP")
            }

            WaitForExtendSchemaFile WaitForExtendSchemaFile
            {
                MachineName = $CSName
                ExtFolder = $CM
                Ensure = "Present"
                DependsOn = "[WriteConfigurationFile]WriteDelegateControlfinished"
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

        WriteConfigurationFile WriteClientJoinDomain
        {
            Role = "DC"
            LogPath = $LogPath
            WriteNode = "ClientJoinDomain"
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
    }
}