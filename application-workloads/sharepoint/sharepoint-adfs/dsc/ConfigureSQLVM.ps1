configuration ConfigureSQLVM
{
    param
    (
        [Parameter(Mandatory)] [String]$DNSServer,
        [Parameter(Mandatory)] [String]$DomainFQDN,
        [Parameter(Mandatory)] [System.Management.Automation.PSCredential]$DomainAdminCreds,
        [Parameter(Mandatory)] [System.Management.Automation.PSCredential]$SqlSvcCreds,
        [Parameter(Mandatory)] [System.Management.Automation.PSCredential]$SPSetupCreds
    )

    Import-DscResource -ModuleName ComputerManagementDsc, NetworkingDsc, ActiveDirectoryDsc, SqlServerDsc, xPSDesiredStateConfiguration

    WaitForSqlSetup
    [String] $DomainNetbiosName = (Get-NetBIOSName -DomainFQDN $DomainFQDN)
    $Interface = Get-NetAdapter| Where-Object Name -Like "Ethernet*"| Select-Object -First 1
    $InterfaceAlias = $($Interface.Name)
    [PSCredential] $DomainAdminCredsQualified = New-Object PSCredential ("${DomainNetbiosName}\$($DomainAdminCreds.UserName)", $DomainAdminCreds.Password)
    [PSCredential] $SPSetupCredsQualified = New-Object PSCredential ("${DomainNetbiosName}\$($SPSetupCreds.UserName)", $SPSetupCreds.Password)
    [PSCredential] $SQLCredsQualified = New-Object PSCredential ("${DomainNetbiosName}\$($SqlSvcCreds.UserName)", $SqlSvcCreds.Password)
    $ComputerName = Get-Content env:computername

    Node localhost
    {
        LocalConfigurationManager
        {
            ConfigurationMode = 'ApplyOnly'
            RebootNodeIfNeeded = $true
        }

        #**********************************************************
        # Initialization of VM - Do as much work as possible before waiting on AD domain to be available
        #**********************************************************
        WindowsFeature AddADTools      { Name = "RSAT-AD-Tools";      Ensure = "Present"; }
        WindowsFeature AddADPowerShell { Name = "RSAT-AD-PowerShell"; Ensure = "Present"; }
        
        DnsServerAddress SetDNS { Address = $DNSServer; InterfaceAlias = $InterfaceAlias; AddressFamily  = 'IPv4' }
        
        SqlMaxDop ConfigureMaxDOP { ServerName = $ComputerName; InstanceName = "MSSQLSERVER"; MaxDop = 1; }

        xScript EnableFileSharing
        {
            TestScript = {
                # Test if firewall rules for file sharing already exist
                $rulesSet = Get-NetFirewallRule -DisplayGroup "File And Printer Sharing" -Enabled True -ErrorAction SilentlyContinue | Where-Object{$_.Profile -eq "Domain"}
                if ($null -eq $rulesSet) {
                    return $false   # Run SetScript
                } else {
                    return $true    # Rules already set
                }
            }
            SetScript = {
                Set-NetFirewallRule -DisplayGroup "File And Printer Sharing" -Enabled True -Profile Domain -Confirm:$false
            }
            GetScript = { }
        }

        #**********************************************************
        # Join AD forest
        #**********************************************************
        # If WaitForADDomain does not find the domain whtin "WaitTimeout" secs, it will signar a restart to DSC engine "RestartCount" times
        WaitForADDomain WaitForDCReady
        {
            DomainName              = $DomainFQDN
            WaitTimeout             = 1800
            RestartCount            = 2
            WaitForValidCredentials = $True
            Credential              = $DomainAdminCredsQualified
            DependsOn               = "[DnsServerAddress]SetDNS"
        }

        # WaitForADDomain sets reboot signal only if WaitForADDomain did not find domain within "WaitTimeout" secs
        PendingReboot RebootOnSignalFromWaitForDCReady
        {
            Name             = "RebootOnSignalFromWaitForDCReady"
            SkipCcmClientSDK = $true
            DependsOn        = "[WaitForADDomain]WaitForDCReady"
        }

        Computer JoinDomain
        {
            Name       = $ComputerName
            DomainName = $DomainFQDN
            Credential = $DomainAdminCredsQualified
            DependsOn  = "[PendingReboot]RebootOnSignalFromWaitForDCReady"
        }

        PendingReboot RebootOnSignalFromJoinDomain
        {
            Name             = "RebootOnSignalFromJoinDomain"
            SkipCcmClientSDK = $true
            DependsOn        = "[Computer]JoinDomain"
        }

        #**********************************************************
        # Create accounts and configure SQL Server
        #**********************************************************
        # By default, SPNs MSSQLSvc/SQL.contoso.local:1433 and MSSQLSvc/SQL.contoso.local are set on the machine account
        # They need to be removed before they can be set on the SQL service account
        xScript RemoveSQLSpnOnSQLMachine
        {
            SetScript = 
            {
                $hostname = $using:ComputerName
                $domainFQDN = $using:DomainFQDN
                $spn1 = "MSSQLSvc/$hostname.$($domainFQDN)"
                $spn2 = "MSSQLSvc/$hostname.$($domainFQDN):1433"
                setspn -D "$spn1" "$hostname"
                setspn -D "$spn2" "$hostname"
            }
            GetScript =  
            {
                # This block must return a hashtable. The hashtable must only contain one key Result and the value must be of type String.
                return @{ "Result" = "false" }
            }
            TestScript = 
            {
                # If it returns $false, the SetScript block will run. If it returns $true, the SetScript block will not run.
				return $false
            }
            DependsOn            = "[PendingReboot]RebootOnSignalFromJoinDomain"
            PsDscRunAsCredential = $DomainAdminCredsQualified
        }

        ADUser CreateSqlSvcAccount
        {
            DomainName           = $DomainFQDN
            UserName             = $SqlSvcCreds.UserName
            UserPrincipalName    = "$($SqlSvcCreds.UserName)@$DomainFQDN"
            Password             = $SQLCredsQualified
            PasswordNeverExpires = $true
            ServicePrincipalNames = @("MSSQLSvc/$ComputerName.$($DomainFQDN):1433", "MSSQLSvc/$ComputerName.$DomainFQDN", "MSSQLSvc/$($ComputerName):1433", "MSSQLSvc/$ComputerName")
            Ensure               = "Present"
            PsDscRunAsCredential = $DomainAdminCredsQualified
            DependsOn            = "[xScript]RemoveSQLSpnOnSQLMachine"
        }

        # Tentative fix on random error on resources SqlServiceAccount/SqlLogin after computer joined domain (although SqlMaxDop Test succeeds):
        # Error on SqlServiceAccount: System.InvalidOperationException: Unable to set the service account for SQL on MSSQLSERVER. Message  ---> System.Management.Automation.MethodInvocationException: Exception calling "SetServiceAccount" with "2" argument(s): "Set service account failed. "
        # Error on SqlLogin: System.InvalidOperationException: Failed to connect to SQL instance 'SQL'. (SQLCOMMON0019) ---> System.Management.Automation.MethodInvocationException: Exception calling "Connect" with "0" argument(s): "Failed to connect to server SQL.
        # It would imply that somehow, SQL Server does not start upon computer restart
        xScript EnsureSQLServiceStarted
        {
            SetScript = 
            {
                Start-Service -Name "MSSQLSERVER"
            }
            GetScript =  
            {
                # This block must return a hashtable. The hashtable must only contain one key Result and the value must be of type String.
                return @{ "Result" = "false" }
            }
            TestScript = 
            {
                # If it returns $false, the SetScript block will run. If it returns $true, the SetScript block will not run.
				$service = Get-Service -Name "MSSQLSERVER" | Select-Object Status
                if ($service.Status -like 'Running') {
                    $true
                } else {
                    $false
                }
            }
            DependsOn            = "[PendingReboot]RebootOnSignalFromJoinDomain"
            PsDscRunAsCredential = $DomainAdminCredsQualified
        }

        SqlServiceAccount SetSqlInstanceServiceAccount
        {
            ServerName     = $ComputerName
            InstanceName   = "MSSQLSERVER"
            ServiceType    = "DatabaseEngine"
            ServiceAccount = $SQLCredsQualified
            RestartService = $true
            DependsOn      = "[xScript]EnsureSQLServiceStarted", "[ADUser]CreateSqlSvcAccount"
        }

        SqlLogin AddDomainAdminLogin
        {
            Name         = "${DomainNetbiosName}\$($DomainAdminCreds.UserName)"
            Ensure       = "Present"
            ServerName   = $ComputerName
            InstanceName = "MSSQLSERVER"
            LoginType    = "WindowsUser"
            DependsOn    = "[PendingReboot]RebootOnSignalFromJoinDomain"
        }

        ADUser CreateSPSetupAccount
        {
            DomainName           = $DomainFQDN
            UserName             = $SPSetupCreds.UserName
            UserPrincipalName    = "$($SPSetupCreds.UserName)@$DomainFQDN"
            Password             = $SPSetupCredsQualified
            PasswordNeverExpires = $true
            PsDscRunAsCredential = $DomainAdminCredsQualified
            Ensure               = "Present"
            DependsOn            = "[PendingReboot]RebootOnSignalFromJoinDomain"
        }

        SqlLogin AddSPSetupLogin
        {
            Name         = "${DomainNetbiosName}\$($SPSetupCreds.UserName)"
            Ensure       = "Present"
            ServerName   = $ComputerName
            InstanceName = "MSSQLSERVER"
            LoginType    = "WindowsUser"
            DependsOn    = "[ADUser]CreateSPSetupAccount"
        }

        SqlRole GrantSQLRoleSysadmin
        {
            ServerRoleName   = "sysadmin"
            MembersToInclude = "${DomainNetbiosName}\$($DomainAdminCreds.UserName)"
            ServerName       = $ComputerName
            InstanceName     = "MSSQLSERVER"
            Ensure           = "Present"
            DependsOn        = "[SqlLogin]AddDomainAdminLogin"
        }

        SqlRole GrantSQLRoleSecurityAdmin
        {
            ServerRoleName   = "securityadmin"
            MembersToInclude = "${DomainNetbiosName}\$($SPSetupCreds.UserName)"
            ServerName       = $ComputerName
            InstanceName     = "MSSQLSERVER"
            Ensure           = "Present"
            DependsOn        = "[SqlLogin]AddSPSetupLogin"
        }

        SqlRole GrantSQLRoleDBCreator
        {
            ServerRoleName   = "dbcreator"
            MembersToInclude = "${DomainNetbiosName}\$($SPSetupCreds.UserName)"
            ServerName       = $ComputerName
            InstanceName     = "MSSQLSERVER"
            Ensure           = "Present"
            DependsOn        = "[SqlLogin]AddSPSetupLogin"
        }

        # Since SharePointDsc 4.4.0, SPFarm "Switched from creating a Lock database to a Lock table in the TempDB. This to allow the use of precreated databases."
        # But for this to work, the SPSetup account needs specific permissions on both the tempdb and the dbo schema
        SqlDatabaseUser AddSPSetupUserToTempdb
        {
            ServerName           = $ComputerName
            InstanceName         = "MSSQLSERVER"
            DatabaseName         = "tempdb"
            UserType             = 'Login'
            Name                 = "${DomainNetbiosName}\$($SPSetupCreds.UserName)"
            LoginName            = "${DomainNetbiosName}\$($SPSetupCreds.UserName)"
            DependsOn            = "[SqlLogin]AddSPSetupLogin"
        }

        SqlDatabasePermission GrantPermissionssToTempdb
        {
            Name                 = "${DomainNetbiosName}\$($SPSetupCreds.UserName)"
            ServerName           =  $ComputerName
            InstanceName         = "MSSQLSERVER"
            DatabaseName         = "tempdb"
            Permissions          = @('Select', 'CreateTable', 'Execute')
            PermissionState      = "Grant"
            Ensure               = "Present"
            DependsOn            = "[SqlDatabaseUser]AddSPSetupUserToTempdb"
        }

        SqlDatabaseObjectPermission GrantPermissionssToDboSchema
        {
            Name                 = "${DomainNetbiosName}\$($SPSetupCreds.UserName)"
            ServerName           = $ComputerName
            InstanceName         = "MSSQLSERVER"
            DatabaseName         = "tempdb"
            SchemaName           = "dbo"
            ObjectName           = ""
            ObjectType           = "Schema"
            Permission           = @(
                DSC_DatabaseObjectPermission
                {
                    State      = "Grant"
                    Permission = @("Select", "Update", "Insert", "Execute", "Control", "References")
                }
            )
            DependsOn            = "[SqlDatabaseUser]AddSPSetupUserToTempdb"
        }

        # Open port on the firewall only when everything is ready, as SharePoint DSC is testing it to start creating the farm
        Firewall AddDatabaseEngineFirewallRule
        {
            Direction   = "Inbound"
            Name        = "SQL-Server-Database-Engine-TCP-In"
            DisplayName = "SQL Server Database Engine (TCP-In)"
            Description = "Inbound rule for SQL Server to allow TCP traffic for the Database Engine."
            Group       = "SQL Server"
            Enabled     = "True"
            Protocol    = "TCP"
            LocalPort   = "1433"
            Ensure      = "Present"
        }
    }
}

function Get-NetBIOSName
{
    [OutputType([string])]
    param(
        [string]$DomainFQDN
    )

    if ($DomainFQDN.Contains('.')) {
        $length=$DomainFQDN.IndexOf('.')
        if ( $length -ge 16) {
            $length=15
        }
        return $DomainFQDN.Substring(0,$length)
    }
    else {
        if ($DomainFQDN.Length -gt 15) {
            return $DomainFQDN.Substring(0,15)
        }
        else {
            return $DomainFQDN
        }
    }
}

function WaitForSqlSetup
{
    # Wait for SQL Server Setup to finish before proceeding.
    while ($true)
    {
        try
        {
            Get-ScheduledTaskInfo "\ConfigureSqlImageTasks\RunConfigureImage" -ErrorAction Stop
            Start-Sleep -Seconds 5
        }
        catch
        {
            break
        }
    }
}



<#
# Azure DSC extension logging: C:\WindowsAzure\Logs\Plugins\Microsoft.Powershell.DSC\2.21.0.0
# Azure DSC extension configuration: C:\Packages\Plugins\Microsoft.Powershell.DSC\2.21.0.0\DSCWork
Install-Module -Name SqlServerDsc

help ConfigureSQLVM
$DomainAdminCreds = Get-Credential -Credential "yvand"
$SqlSvcCreds = Get-Credential -Credential "sqlsvc"
$SPSetupCreds = Get-Credential -Credential "spsetup"
$DNSServer = "10.0.1.4"
$DomainFQDN = "contoso.local"

$outputPath = "C:\Packages\Plugins\Microsoft.Powershell.DSC\2.83.1.0\DSCWork\ConfigureSQLVM.0"
ConfigureSQLVM -DNSServer $DNSServer -DomainFQDN $DomainFQDN -DomainAdminCreds $DomainAdminCreds -SqlSvcCreds $SqlSvcCreds -SPSetupCreds $SPSetupCreds -ConfigurationData @{AllNodes=@(@{ NodeName="localhost"; PSDscAllowPlainTextPassword=$true })} -OutputPath $outputPath
Start-DscConfiguration -Path $outputPath -Wait -Verbose -Force

#>
