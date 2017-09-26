configuration ConfigureSQLVM
{
    param
    (
        [Parameter(Mandatory)]
        [String]$DNSServer,

        [Parameter(Mandatory)]
        [String]$DomainFQDN,

        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential]$DomainAdminCreds,

        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential]$SqlSvcCreds,

        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential]$SPSetupCreds,

        [Int] $RetryCount = 30,
        [Int] $RetryIntervalSec = 30
    )

    Import-DscResource -ModuleName xComputerManagement, xNetworking, xDisk, cDisk, xActiveDirectory, xSQLServer

    WaitForSqlSetup
    [String] $DomainNetbiosName = (Get-NetBIOSName -DomainFQDN $DomainFQDN)
    $Interface = Get-NetAdapter| Where-Object Name -Like "Ethernet*"| Select-Object -First 1
    $InterfaceAlias = $($Interface.Name)
    [PSCredential] $DomainCreds = New-Object PSCredential ("${DomainNetbiosName}\$($DomainAdminCreds.UserName)", $DomainAdminCreds.Password)
    [PSCredential] $SPSCreds = New-Object PSCredential ("${DomainNetbiosName}\$($SPSetupCreds.UserName)", $SPSetupCreds.Password)
    [PSCredential] $SQLCreds = New-Object PSCredential ("${DomainNetbiosName}\$($SqlSvcCreds.UserName)", $SqlSvcCreds.Password)
    $ComputerName = Get-Content env:computername

    Node localhost
    {
        LocalConfigurationManager
        {
            ConfigurationMode = 'ApplyOnly'
            RebootNodeIfNeeded = $true
        }

        #**********************************************************
        # Initialization of VM
        #**********************************************************

        xWaitforDisk Disk2
        {
            DiskNumber = 2
            RetryIntervalSec =$RetryIntervalSec
            RetryCount = $RetryCount
        }
        cDiskNoRestart SQLDataDisk
        {
            DiskNumber = 2
            DriveLetter = "F"
            DependsOn="[xWaitForDisk]Disk2"
        }
        xFirewall DatabaseEngineFirewallRule
        {
            Direction = "Inbound"
            Name = "SQL-Server-Database-Engine-TCP-In"
            DisplayName = "SQL Server Database Engine (TCP-In)"
            Description = "Inbound rule for SQL Server to allow TCP traffic for the Database Engine."
            Group = "SQL Server"
            Enabled = "True"
            Protocol = "TCP"
            LocalPort = "1433"
            Ensure = "Present"
        }
        WindowsFeature ADPS
        {
            Name = "RSAT-AD-PowerShell"
            Ensure = "Present"
            DependsOn = "[cDiskNoRestart]SQLDataDisk"

        }
        xDnsServerAddress DnsServerAddress
        {
            Address        = $DNSServer
            InterfaceAlias = $InterfaceAlias
            AddressFamily  = 'IPv4'
            DependsOn="[WindowsFeature]ADPS"
        }

        #**********************************************************
        # Join AD forest
        #**********************************************************
        xWaitForADDomain DscForestWait
        {
            DomainName = $DomainFQDN
            DomainUserCredential= $DomainCreds
            RetryCount = $RetryCount
            RetryIntervalSec = $RetryIntervalSec
            DependsOn = "[xDnsServerAddress]DnsServerAddress"
        }

        xComputer DomainJoin
        {
            Name = $ComputerName
            DomainName = $DomainFQDN
            Credential = $DomainCreds
            DependsOn = "[xWaitForADDomain]DscForestWait"
        }

        #**********************************************************
        # Create accounts and configure SQL Server
        #**********************************************************
        xADUser CreateSqlSvcAccount
        {
            DomainAdministratorCredential = $DomainCreds
            DomainName = $DomainFQDN
            UserName = $SqlSvcCreds.UserName
            Password = $SQLCreds
            PasswordNeverExpires = $true
            Ensure = "Present"
            DependsOn = "[xComputer]DomainJoin"
        }

        xADUser CreateSPSetupAccount
        {
            DomainAdministratorCredential = $DomainCreds
            DomainName = $DomainFQDN
            UserName = $SPSetupCreds.UserName
            Password = $SPSCreds
            PasswordNeverExpires = $true
            Ensure = "Present"
            DependsOn = "[xComputer]DomainJoin"
        }

        xSQLServerLogin AddDomainAdminLogin
        {
            Name = "${DomainNetbiosName}\$($DomainAdminCreds.UserName)"
            Ensure = "Present"
            SQLServer = $ComputerName
            SQLInstanceName = "MSSQLSERVER"
            LoginType = "WindowsUser"
            DependsOn = "[xComputer]DomainJoin"
        }

        xSQLServerLogin AddSPSetupLogin
        {
            Name = "${DomainNetbiosName}\$($SPSetupCreds.UserName)"
            Ensure = "Present"
            SQLServer = $ComputerName
            SQLInstanceName = "MSSQLSERVER"
            LoginType = "WindowsUser"
            DependsOn = "[xADUser]CreateSPSetupAccount"
        }

        xSQLServerRole GrantSQLRoleSysadmin
        {
            ServerRoleName = "sysadmin"
            MembersToInclude = "${DomainNetbiosName}\$($DomainAdminCreds.UserName)"
            Ensure = "Present"
            SQLServer = $ComputerName
            SQLInstanceName = "MSSQLSERVER"
            DependsOn = "[xSQLServerLogin]AddDomainAdminLogin"
        }

        xSQLServerRole GrantSQLRoleSecurityAdmin
        {
            ServerRoleName = "securityadmin"
            MembersToInclude = "${DomainNetbiosName}\$($SPSetupCreds.UserName)"
            SQLServer = $ComputerName
            SQLInstanceName = "MSSQLSERVER"
            Ensure = "Present"
            DependsOn = "[xSQLServerLogin]AddSPSetupLogin"
        }

        xSQLServerRole GrantSQLRoleDBCreator
        {
            ServerRoleName = "dbcreator"
            MembersToInclude = "${DomainNetbiosName}\$($SPSetupCreds.UserName)"
            SQLServer = $ComputerName
            SQLInstanceName = "MSSQLSERVER"
            Ensure = "Present"
            DependsOn = "[xSQLServerLogin]AddSPSetupLogin"
        }

        xSQLServerMaxDop ConfigureMaxDOP
        {
            SQLServer = $ComputerName
            SQLInstanceName = "MSSQLSERVER"
            MaxDop = 1
            DependsOn = "[xComputer]DomainJoin"
        }

        <#
        xSQLServerSetup ConfigureSQLServer
        {
            SetupCredential = $DomainAdminCreds
            InstanceName = "MSSQLSERVER"
            SQLUserDBDir = "F:\DATA"
            SQLUserDBLogDir = "G:\LOG"
        }
        #>
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

help ConfigureSQLVM
$DomainAdminCreds = Get-Credential -Credential "yvand"
$SqlSvcCreds = Get-Credential -Credential "sqlsvc"
$SPSetupCreds = Get-Credential -Credential "spsetup"
$DNSServer = "10.0.1.4"
$DomainFQDN = "contoso.local"

ConfigureSQLVM -DNSServer $DNSServer -DomainFQDN $DomainFQDN -DomainAdminCreds $DomainAdminCreds -SqlSvcCreds $SqlSvcCreds -SPSetupCreds $SPSetupCreds -ConfigurationData @{AllNodes=@(@{ NodeName="localhost"; PSDscAllowPlainTextPassword=$true })} -OutputPath "C:\Data\\output"
Start-DscConfiguration -Path "C:\Data\output" -Wait -Verbose -Force

#>
