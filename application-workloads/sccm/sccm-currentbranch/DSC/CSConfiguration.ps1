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
    $CM = "CMCB"
    $LogPath = "c:\$LogFolder"
    $DName = $DomainName.Split(".")[0]
    $DCComputerAccount = "$DName\$DCName$"
    $PSComputerAccount = "$DName\$PSName$"
    $DPMPComputerAccount = "$DName\$DPMPName$"
    [String]$Clients = [system.String]::Join(",", $ClientName)
    $CurrentRole = "CS"
    $PrimarySiteName = $PSName.split(".")[0] + "$"
    
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

        AddBuiltinPermission AddSQLPermission
        {
            Ensure = "Present"
            DependsOn = "[SetCustomPagingFile]PagingSettings"
        }

        InstallFeatureForSCCM InstallFeature
        {
            NAME = "CS"
            Role = "Site Server"
            DependsOn = "[AddBuiltinPermission]AddSQLPermission"
        }

        InstallADK ADKInstall
        {
            ADKPath = "C:\adksetup.exe"
            ADKWinPEPath = "c:\adksetupwinpe.exe"
            Ensure = "Present"
            DependsOn = "[InstallFeatureForSCCM]InstallFeature"
        }

        DownloadSCCM DownLoadSCCM
        {
            CM = $CM
            Ensure = "Present"
            DependsOn = "[InstallADK]ADKInstall"
        }

        SetDNS DnsServerAddress
        {
            DNSIPAddress = $DNSIPAddress
            Ensure = "Present"
            DependsOn = "[DownloadSCCM]DownLoadSCCM"
        }

        WaitForDomainReady WaitForDomain
        {
            Ensure = "Present"
            DCName = $DCName
            WaitSeconds = 0
            DependsOn = "[SetDNS]DnsServerAddress"
        }

        JoinDomain JoinDomain
        {
            DomainName = $DomainName
            Credential = $DomainCreds
            DependsOn = "[WaitForDomainReady]WaitForDomain"
        }
        
        File ShareFolder
        {            
            DestinationPath = $LogPath     
            Type = 'Directory'            
            Ensure = 'Present'
            DependsOn = "[JoinDomain]JoinDomain"
        }

        WaitForConfigurationFile WaitPSJoinDomain
        {
            Role = "DC"
            MachineName = $DCName
            LogFolder = $LogFolder
            ReadNode = "PSJoinDomain"
            Ensure = "Present"
            DependsOn = "[File]ShareFolder"
        }

        FileReadAccessShare DomainSMBShare
        {
            Name = $LogFolder
            Path = $LogPath
            Account = $DCComputerAccount,$PSComputerAccount
            DependsOn = "[WaitForConfigurationFile]WaitPSJoinDomain"
        }
        
        OpenFirewallPortForSCCM OpenFirewall
        {
            Name = "CS"
            Role = "Site Server"
            DependsOn = "[JoinDomain]JoinDomain"
        }

        WaitForConfigurationFile DelegateControl
        {
            Role = "DC"
            MachineName = $DCName
            LogFolder = $LogFolder
            ReadNode = "DelegateControl"
            Ensure = "Present"
            DependsOn = "[OpenFirewallPortForSCCM]OpenFirewall"
        }

        ChangeSQLServicesAccount ChangeToLocalSystem
        {
            SQLInstanceName = "MSSQLSERVER"
            Ensure = "Present"
            DependsOn = "[WaitForConfigurationFile]DelegateControl"
        }

        FileReadAccessShare CMSourceSMBShare
        {
            Name = $CM
            Path = "c:\$CM"
            Account = $DCComputerAccount
            DependsOn = "[ChangeSQLServicesAccount]ChangeToLocalSystem"
        }

        AddUserToLocalAdminGroup AddADComputerToLocalAdminGroup {
            Name = "$PrimarySiteName"
            DomainName = $DomainName
            DependsOn = "[FileReadAccessShare]CMSourceSMBShare"
        }

        RegisterTaskScheduler InstallAndUpdateSCCM
        {
            TaskName = "ScriptWorkFlow"
            ScriptName = "ScriptWorkFlow.ps1"
            ScriptPath = $PSScriptRoot
            ScriptArgument = "$DomainName $CM $DName\$($Admincreds.UserName) $DPMPName $Clients $Configuration $CurrentRole $LogFolder $CSName $PSName"
            Ensure = "Present"
            DependsOn = "[AddUserToLocalAdminGroup]AddADComputerToLocalAdminGroup"
        }
    }
}