#requires -Version 5

[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingConvertToSecureStringWithPlainText", "")]
param ()

Configuration SQL
{
    Import-DscResource -Module xSQLServer
    Import-DscResource -Module xFailoverCluster

    Node $AllNodes.NodeName
    {
        # Set LCM to reboot if needed
        LocalConfigurationManager
        {
            DebugMode = "ForceModuleImport"
            RebootNodeIfNeeded = $true
        }

        WindowsFeature "NET-Framework-Core"
        {
            Ensure = "Present"
            Name = "NET-Framework-Core"
            Source = $Node.SourcePath + "\WindowsServer2012R2\sources\sxs"
        }

        WindowsFeature "Failover-Clustering"
        {
            Ensure = "Present"
            Name = "Failover-Clustering"
        }

        WindowsFeature "RSAT-Clustering-PowerShell"
        {
            Ensure = "Present"
            Name = "RSAT-Clustering-PowerShell"
        }

        if($Node.NodeName -eq "CLDBA.contoso.com")
        {
            xCluster "CLDBx"
            {
                DependsOn = @(
                    "[WindowsFeature]Failover-Clustering",
                    "[WindowsFeature]RSAT-Clustering-PowerShell"
                )
                Name = "CLDBx"
                StaticIPAddress = "192.168.1.251"
                DomainAdministratorCredential = $Node.InstallerServiceAccount
            }

            WaitForAll "CLDBx"
            {
                ResourceName = "[xCluster]CLDBx"
                NodeName = @(
                    "CLDBB.contoso.com",
                    "CLDBC.contoso.com",
                    "CLDBD.contoso.com"
                )
                Credential = $Node.InstallerServiceAccount
                RetryIntervalSec = 5
                RetryCount = 720
            }

            xClusterDisk "iSCSI"
            {
                DependsOn = "[WaitForAll]CLDBx"
                DiskFriendlyName = "MSFT Virtual HD SCSI Disk Device"
                DiskNumbers = ""
            }
        }
        else
        {
            WaitForAll "CLDBx"
            {
                ResourceName = "[xCluster]CLDBx"
                NodeName = "CLDBA.contoso.com"
                Credential = $Node.InstallerServiceAccount
                RetryIntervalSec = 5
                RetryCount = 720
            }

            xCluster "CLDBx"
            {
                DependsOn = "[WaitForAll]CLDBx"
                Name = "CLDBx"
                StaticIPAddress = "192.168.1.251"
                DomainAdministratorCredential = $Node.InstallerServiceAccount
            }
        }

        xSQLServerFailoverClusterSetup "PrepareMSSQLSERVER"
        {
            DependsOn = @(
                "[WindowsFeature]NET-Framework-Core",
                "[WindowsFeature]Failover-Clustering"
            )
            Action = "Prepare"
            SourcePath = $Node.SourcePath
            SetupCredential = $Node.InstallerServiceAccount
            Features = "SQLENGINE,AS,IS"
            InstanceName = "MSSQLSERVER"
            FailoverClusterNetworkName = "CLSCDB"
            SQLSvcAccount = $Node.SQLServiceAccount
        }

        xSqlServerFirewall "FirewallMSSQLSERVER"
        {
            DependsOn = "[xSQLServerFailoverClusterSetup]PrepareMSSQLSERVER"
            SourcePath = $Node.SourcePath
            InstanceName = "MSSQLSERVER"
            Features = "SQLENGINE,AS,IS"
        }

        if($Node.NodeName -eq "CLDBA.contoso.com")
        {
            WaitForAll "Cluster"
            {
                NodeName = @(
                    "CLDBB.contoso.com",
                    "CLDBC.contoso.com",
                    "CLDBD.contoso.com"
                )
                ResourceName = "[xSQLServerFailoverClusterSetup]PrepareMSSQLSERVER"
                Credential = $Node.InstallerServiceAccount
                RetryIntervalSec = 5
                RetryCount = 720
            }
            
            xSQLServerFailoverClusterSetup "CompleteMSSQLSERVER"
            {
                DependsOn = @(
                    "[WaitForAll]Cluster",
                    "[xClusterDisk]iSCSI"
                )
                Action = "Complete"
                SourcePath = $Node.SourcePath
                SetupCredential = $Node.InstallerServiceAccount
                Features = "SQLENGINE,AS,IS"
                InstanceName = "MSSQLSERVER"
                FailoverClusterNetworkName = "CLSCDB"
                InstallSQLDataDir = "E:\"
                ASDataDir = "F:\OLAP\Data"
                ASLogDir = "F:\OLAP\Log"
                ASBackupDir = "F:\OLAP\Backup"
                ASTempDir = "F:\OLAP\Temp"
                ASConfigDir = "F:\OLAP\Config"
                ISFileSystemFolder = "E:\Pacakges"
                FailoverClusterIPAddress = "192.168.1.250"
                SQLSvcAccount = $Node.SQLServiceAccount
                SQLSysAdminAccounts = $Node.AdminAccount
                ASSysAdminAccounts = $Node.AdminAccount
            }
        }
    }
}

$DomainAdministratorCredential = Get-Credential "CONTOSO\Administrator"
$InstallerServiceAccount = Get-Credential "CONTOSO\!Installer"
$LocalSystemAccount = Get-Credential "SYSTEM"
$SQLServiceAccount = Get-Credential "CONTOSO\!sql"

$ConfigurationData = @{
    AllNodes = @(
        @{
            NodeName = "*"
            PSDscAllowPlainTextPassword = $true

            SourcePath = "\\RD01\Installer"
            DomainAdministratorCredential = $DomainAdministratorCredential
            InstallerServiceAccount = $InstallerServiceAccount
            LocalSystemAccount = $LocalSystemAccount
            SQLServiceAccount = $SQLServiceAccount
            AdminAccount = "CONTOSO\Administrator"

        }
        @{
            NodeName = "CLDBA.contoso.com"
        }
        @{
            NodeName = "CLDBB.contoso.com"
        }
        @{
            NodeName = "CLDBC.contoso.com"
        }
        @{
            NodeName = "CLDBD.contoso.com"
        }
    )
}

foreach($Node in $ConfigurationData.AllNodes)
{
    if($Node.NodeName -ne "*")
    {
        Start-Process -FilePath "robocopy.exe" -ArgumentList ("`"C:\Program Files\WindowsPowerShell\Modules`" `"\\" + $Node.NodeName + "\c$\Program Files\WindowsPowerShell\Modules`" /e /purge /xf") -NoNewWindow -Wait
    }
}

SQL -ConfigurationData $ConfigurationData
Set-DscLocalConfigurationManager -Path .\SQL -Verbose
Start-DscConfiguration -Path .\SQL -Verbose -Wait -Force

