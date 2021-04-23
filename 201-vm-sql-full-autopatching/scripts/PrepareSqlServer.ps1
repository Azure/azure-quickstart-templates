#
# Copyright="© Microsoft Corporation. All rights reserved."
#
configuration PrepareSqlServer
{
    param
    (
        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential]$SQLAdminAuthCreds,

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

        xSQLServerStorageSettings AddSQLServerStorageSettings
        {
            InstanceName = "MSSQLSERVER"
            OptimizationType = $WorkloadType
        }
        
        xSqlCreateVirtualDisk AddVirtualDisk
        {
            DriveSize = $DisksCount
            NumberOfColumns = $DisksCount
            BytesPerDisk = $DiskSizeInGB * 1073741824
            OptimizationType = $WorkloadType
            DependsOn = "[xSQLServerStorageSettings]AddSQLServerStorageSettings"
        }

        xSqlTsqlEndpoint AddSqlServerEndpoint
        {
            InstanceName = "MSSQLSERVER"
            PortNumber = $DatabaseEnginePort
            SqlAdministratorCredential = $SQLAdminAuthCreds
            DependsOn = "[xSqlCreateVirtualDisk]AddVirtualDisk"
        }
        
        xSQLServerSettings UpdateSqlServerSettings
        {
            InstanceName = "MSSQLSERVER"
            SqlAdministratorCredential = $SQLAdminAuthCreds
            SqlAuthEnabled = "Disabled"
            FilePath = "F:\DATA"
            LogPath = "F:\LOG"
            DependsOn = "[xSqlTsqlEndpoint]AddSqlServerEndpoint"
        }

        LocalConfigurationManager 
        {
            RebootNodeIfNeeded = $true
        }
    }
}