#
# Copyright="© Microsoft Corporation. All rights reserved."
#
configuration PrepareSqlServerSa
{
    param
    (
        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential]$SQLAdminAuthCreds,

        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential]$SQLAuthCreds,

        [Parameter(Mandatory)]
        [UInt32]$DisksCount,

        [Parameter(Mandatory)]
        [UInt64]$DiskSizeInGB,

        [Parameter(Mandatory)]
        [UInt32]$DatabaseEnginePort,

        [Parameter(Mandatory)]
        [String]$WorkloadType,

        [Parameter(Mandatory)]
        [String]$ConnectionType
    )

    Import-DscResource -ModuleName xComputerManagement,CDisk,xActiveDirectory,XDisk,xSql, xSQLServer, xSQLps,xNetworking
    [System.Management.Automation.PSCredential]$DomainCreds = New-Object System.Management.Automation.PSCredential($SQLAdminAuthCreds.UserName, $SQLAdminAuthCreds.Password)

    . "$PSScriptRoot\Common.ps1"

    Node localhost
    {
        $setFirewallRules = Set-SqlFirewallRule -ConnectionType $ConnectionType

        if($setFirewallRules -eq $true)
        {
            xFirewall DatabaseEngineFirewallRule
            {
                Direction = "Inbound"
                Name = "SQL-Server-Database-Engine-TCP-In"
                DisplayName = "SQL Server Database Engine (TCP-In)"
                Description = "Inbound rule for SQL Server to allow TCP traffic for the Database Engine."
                DisplayGroup = "SQL Server"
                State = "Enabled"
                Access = "Allow"
                Protocol = "TCP"
                LocalPort = $DatabaseEnginePort -as [String]
                Ensure = "Present"
            }
        }

        xSqlTsqlEndpoint AddSqlServerEndpoint
        {
            InstanceName = "MSSQLSERVER"
            PortNumber = $DatabaseEnginePort
            SqlAdministratorCredential = $SQLAdminAuthCreds
        }

        xSQLServerStorageSettings AddSQLServerStorageSettings
        {
            InstanceName = "MSSQLSERVER"
            OptimizationType = $WorkloadType
            DependsOn = "[xSqlTsqlEndpoint]AddSqlServerEndpoint"
        }
        
        xSqlLogin AddSQLAUTH
        {
            Name = $SQLAuthCreds.UserName
            Password = $SQLAuthCreds
            LoginType = "SqlLogin"
            ServerRoles = "sysadmin"
            Enabled = $true
            Credential = $SQLAdminAuthCreds
            DependsOn = "[xSQLServerStorageSettings]AddSQLServerStorageSettings"
        }

        xSqlCreateVirtualDisk AddVirtualDisk
        {
            DriveSize = $DisksCount
            NumberOfColumns = $DisksCount
            BytesPerDisk = $DiskSizeInGB * 1073741824
            OptimizationType = $WorkloadType
            DependsOn = "[xSqlLogin]AddSQLAUTH"
        }

        xSQLServerSettings UpdateSqlServerSettings
        {
            InstanceName = "MSSQLSERVER"
            SqlAdministratorCredential = $SQLAdminAuthCreds
            SqlAuthEnabled = "Disabled"
            FilePath = "F:\DATA"
            LogPath = "F:\LOG"
            DependsOn = "[xSqlCreateVirtualDisk]AddVirtualDisk"
        }

        LocalConfigurationManager 
        {
            RebootNodeIfNeeded = $true
        }
    }
}