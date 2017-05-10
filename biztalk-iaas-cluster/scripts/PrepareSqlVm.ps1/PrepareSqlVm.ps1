#.SYNOPSIS
# Prepares a SQL Server VM for use in a cluster.
#.DESCRIPTION
# Joins the domain, joins a cluster, enables Windows features, create SQL logins, etc. 
configuration PrepareSqlVm
{
    param
    (
        [Parameter(Mandatory)]
        [string]$DomainName,

		# Names of the SQL Server machines to be added to the cluster.  
		[parameter(Mandatory)][ValidateCount(1,2)] [string[]] $SqlNodeNames,

        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential]$AdminCreds,

        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential]$SqlServiceCreds,

        [UInt32]$DatabaseEnginePort = 1433,

        [Parameter(Mandatory)]
        [UInt32]$NumberOfDisks,

        [Parameter(Mandatory)]
        [String]$WorkloadType,

        [String]$DomainNetbiosName=(Get-NetBIOSName -DomainName $DomainName),

        [Int]$RetryCount=20,
        [Int]$RetryIntervalSec=30
    )

    Import-DscResource -ModuleName xComputerManagement
    Import-DscResource -ModuleName xActiveDirectory
    Import-DscResource -ModuleName xFailOverCluster
    Import-DscResource -ModuleName xSQL
    Import-DscResource -ModuleName xNetworking

    $DomainCreds = New-Object System.Management.Automation.PSCredential `
            ("$DomainNetbiosName\$($AdminCreds.UserName)", $AdminCreds.Password)
#    $DomainFQDNCreds = New-Object System.Management.Automation.PSCredential `
#            ("$DomainName\$($AdminCreds.UserName)", $AdminCreds.Password)
    $SqlServiceDomainCreds = New-Object System.Management.Automation.PSCredential `
            ("$DomainNetbiosName\$($SqlServiceCreds.UserName)", $SqlServiceCreds.Password)

    $RebootVirtualMachine = $false
    if ($DomainName)
    {
        $RebootVirtualMachine = $true
    }

    WaitForSqlSetup

    Node localhost
    {
        # from module xSQL
        # does nothing specific to SQL -- just OS disk actions
        # The physical disks should already be attached to the VM; this then
        #  pools, mounts, partitions, and formats the disks to drive F. 
        # OptimizationType dictates the created vdisk's 'Interleave' size when
        #  NumberOfColumns (or NumberOfDisks) -gt 1
        # harded-coded to drive letter F
        xSqlCreateVirtualDisk CreateVirtualDisk
        {
            DriveSize = $NumberOfDisks
            NumberOfColumns = $NumberOfDisks
            BytesPerDisk = 1TB
            OptimizationType = $WorkloadType
            RebootVirtualMachine = $RebootVirtualMachine
        }

        WindowsFeature Clustering
        {
            Name = "Failover-Clustering"
            Ensure = "Present"
        }

        WindowsFeature ClusteringTools 
        { 
            Name = "RSAT-Clustering-Mgmt"
            Ensure = "Present" 
            DependsOn = "[WindowsFeature]Clustering"
        } 

        WindowsFeature ClusteringPowerShell
        {
            Name = "RSAT-Clustering-PowerShell"
            Ensure = "Present"
        }

        WindowsFeature DistTransaction
        {
            Name = "AS-Dist-Transaction"
            IncludeAllSubFeature = $true
            Ensure = "Present"
        }

        WindowsFeature ADPowerShell
        {
            Name = "RSAT-AD-PowerShell"
            Ensure = "Present"
        }

        xWaitForADDomain DscForestWait 
        { 
            DomainName = $DomainName 
            DomainUserCredential= $DomainCreds
            RetryCount = $RetryCount 
            RetryIntervalSec = $RetryIntervalSec 
            DependsOn = "[WindowsFeature]ADPowerShell"
        }
        
        xComputer DomainJoin
        {
            Name = $env:COMPUTERNAME
            DomainName = $DomainName
            Credential = $DomainCreds
            DependsOn = "[xWaitForADDomain]DscForestWait"
        }

        # enable firewall rules in the Distributed Transaction Coordinator group
        foreach ($rule in 'MSDTC-In-TCP', 'MSDTC-Out-TCP', 'MSDTC-KTMRM-In-TCP', 'MSDTC-RPCSS-In-TCP')
        {
            xFirewall "Firewall-$rule"
            {
                Name = "$rule"
                Ensure = "Present"
                Enabled = "True"
                DependsOn = "[xComputer]DomainJoin"
            }
        }

        ## all below are specific to an instance of SQL: the default instance in our case 
        ##

        xFirewall DatabaseEngineFirewallRule
        {
            Direction = "Inbound"
            Name = "SQL-Server-Database-Engine-TCP-In"
            DisplayName = "SQL Server Database Engine (TCP-In)"
            Description = "Inbound rule for SQL Server to allow TCP traffic for the Database Engine."
            Group = "SQL Server"
            Enabled = "True"
            Action = "Allow"
            Protocol = "TCP"
            LocalPort = $DatabaseEnginePort -as [String]
            Ensure = "Present"
        }

<#
        xFirewall DatabaseMirroringFirewallRule
        {
            Direction = "Inbound"
            Name = "SQL-Server-Database-Mirroring-TCP-In"
            DisplayName = "SQL Server Database Mirroring (TCP-In)"
            Description = "Inbound rule for SQL Server to allow TCP traffic for the Database Mirroring."
            Group = "SQL Server"
            Enabled = "True"
            Action = "Allow"
            Protocol = "TCP"
            LocalPort = "5022"
            Ensure = "Present"
        }

        xFirewall ListenerFirewallRule
        {
            Direction = "Inbound"
            Name = "SQL-Server-Availability-Group-Listener-TCP-In"
            DisplayName = "SQL Server Availability Group Listener (TCP-In)"
            Description = "Inbound rule for SQL Server to allow TCP traffic for the Availability Group listener."
            Group = "SQL Server"
            Enabled = "True"
            Action = "Allow"
            Protocol = "TCP"
            LocalPort = "59999"
            Ensure = "Present"
        }
#>

        # from module xSQL
        # Grant domain admin account, e.g., 'contoso\domainadmin'
        # xSqlServer v3.0.0.0 has xSqlServerLogin and xSqlServerRole
        #  xSqlServerLogin includes support for required 'SqlInstanceName'
        # can't tell from code if this one is hard-coded to a specific instance but probably is
        xSqlLogin AddDomainAdminAccountToSysadminServerRole
        {
            Name = $DomainCreds.UserName
            LoginType = "WindowsUser"
            ServerRoles = "sysadmin"
            Enabled = $true
            Credential = $AdminCreds
        }

        # creates a *domain* account for use by sql
        # e.g., 'contoso\sqlservice'
        xADUser CreateSqlServerServiceAccount
        {
            DomainAdministratorCredential = $DomainCreds
            DomainName = $DomainName
            UserName = $SqlServiceCreds.UserName
            Password = $SqlServiceCreds
            Ensure = "Present"
            DependsOn = "[xSqlLogin]AddDomainAdminAccountToSysadminServerRole"
        }

        # from module xSQL
        # Grant to domain sql account, e.g., 'contoso\sqlservice' 
        # xSqlServer v3.0.0.0 has xSqlServerLogin and xSqlServerRole
        #  xSqlServerLogin includes support for required 'SqlInstanceName'
        # can't tell from code if this one is hard-coded to a specific instance but probably is
        xSqlLogin AddSqlServerServiceAccountToSysadminServerRole
        {
            Name = $SqlServiceDomainCreds.UserName
            LoginType = "WindowsUser"
            ServerRoles = "sysadmin"
            Enabled = $true
            Credential = $AdminCreds
            DependsOn = "[xADUser]CreateSqlServerServiceAccount"
        }
        
        # from module xSQL
        # In SQL Server Configuration Manager, for the specified sql instance,
        #  set the TCP/IP Protocol to use port 1433, and no dynamic ports.
        # Does not enable TCP/IP (if not already enabled), apparently.
        # xSqlServer v3.0.0.0 has xSqlServerNetwork, which supports IsEnabled
        #  and its name is way less confusing
        xSqlTsqlEndpoint AddSqlServerEndpoint
        {
            InstanceName = "MSSQLSERVER"
            PortNumber = $DatabaseEnginePort
            SqlAdministratorCredential = $AdminCreds
            DependsOn = "[xSqlLogin]AddSqlServerServiceAccountToSysadminServerRole"
        }

        # from module xSQL
        # per log, this claims it fails: CONSIDER: just drop it
        xSQLServerStorageSettings AddSQLServerStorageSettings
        {
            InstanceName = "MSSQLSERVER"
            OptimizationType = $WorkloadType
            DependsOn = "[xSqlTsqlEndpoint]AddSqlServerEndpoint"
        }

<#
        xSqlServer ConfigureSqlServerWithAlwaysOn
        {
            InstanceName = $env:COMPUTERNAME
            SqlAdministratorCredential = $AdminCreds
            ServiceCredential = $SQLCreds
            MaxDegreeOfParallelism = 1
            FilePath = "F:\DATA"
            LogPath = "F:\LOG"
            DomainAdministratorCredential = $DomainFQDNCreds
            DependsOn = "[xSqlLogin]AddSqlServerServiceAccountToSysadminServerRole"
        }
#>

        LocalConfigurationManager 
        {
            RebootNodeIfNeeded = $true
        }

    }
}

function Get-NetBIOSName
{ 
    [OutputType([string])]
    param(
        [string]$DomainName
    )

    if ($DomainName.Contains('.')) {
        $length=$DomainName.IndexOf('.')
        if ( $length -ge 16) {
            $length=15
        }
        return $DomainName.Substring(0,$length)
    }
    else {
        if ($DomainName.Length -gt 15) {
            return $DomainName.Substring(0,15)
        }
        else {
            return $DomainName
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
