#requires -Version 5
$computers = 'OHSQL9034N1','OHSQL9034N2','OHSQL9034N3'
$OutputPath = 'F:\DSCConfig'

Configuration FCISQL
{
    Import-DscResource –Module PSDesiredStateConfiguration
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

       WindowsFeature RSATClusteringMgmt
       {
           Ensure = "Present"
           Name = "RSAT-Clustering-Mgmt"
       }

       WindowsFeature RSATClusteringPowerShell
       {
           Ensure = "Present"
           Name   = "RSAT-Clustering-PowerShell"   
       }

       WindowsFeature RSATClusteringCmdInterface
       {
           Ensure = "Present"
           Name   = "RSAT-Clustering-CmdInterface"
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
            Features = $Node.Features
            InstanceName = $Node.InstanceName
            FailoverClusterNetworkName = $Node.FailoverClusterNetworkName
            SQLSvcAccount = $Node.InstallerServiceAccount
        }

        xSqlServerFirewall "FirewallMSSQLSERVER"
        {
            DependsOn = "[xSQLServerFailoverClusterSetup]PrepareMSSQLSERVER"
            SourcePath = $Node.SourcePath
            InstanceName = $Node.InstanceName
            Features = $Node.Features
        }

    If ($node.Role -eq "PrimaryServerNode")
    {
            xCluster "CLDBx"
            {
                DependsOn = @(
                    "[WindowsFeature]RSATClusteringMgmt",
                    "[WindowsFeature]RSATClusteringPowerShell"
                )
                Name = $Node.ClusterName
                StaticIPAddress = $Node.ClusterIPAddress
                DomainAdministratorCredential = $Node.InstallerServiceAccount
            }

            xClusterDisk "iSCSI"
            {
                Ensure = "Present"
                Number = 1

                DependsOn = "[xCluster]CLDBx"
            }
           
        }
        If ($node.Role -eq "ReplicaServerNode" )
        {
            xWaitForCluster waitForCluster 
            { 
                Name = $Node.ClusterName 
                RetryIntervalSec = 10 
                RetryCount = 20
            } 
       
            xCluster joinCluster 
            { 
                Name = $Node.ClusterName 
                StaticIPAddress = $Node.ClusterIPAddress 
                DomainAdministratorCredential = $Node.InstallerServiceAccount
            
                DependsOn = "[xWaitForCluster]waitForCluster" 
            }
        }
        If ($node.Role -eq "PrimaryServerNode")
        {
           
            WaitForAll "SqlPrep"
            {                
                NodeName = @($computers)
                ResourceName = "[xSQLServerFailoverClusterSetup]PrepareMSSQLSERVER"
                PsDscRunAsCredential = $Node.InstallerServiceAccount
                RetryIntervalSec = 5
                RetryCount = 720
            }
            xSQLServerFailoverClusterSetup "CompleteMSSQLSERVER"
            {
                Action = "Complete"
                SourcePath = $Node.SourcePath
                SetupCredential = $Node.InstallerServiceAccount
                Features = $Node.Features
                InstanceName = $Node.InstanceName
                FailoverClusterNetworkName = $Node.FailoverClusterNetworkName
                InstallSQLDataDir = "D:\"
                FailoverClusterIPAddress = "10.0.75.60"
                SQLSvcAccount = $Node.SQLServiceAccount
                SQLSysAdminAccounts = $Node.AdminAccount

                PsDscRunAsCredential = $Node.InstallerServiceAccount
                
                DependsOn = @(
                    "[WaitForAll]SqlPrep",
                    "[xClusterDisk]iSCSI"
                )
            }
        } 
    }
}

$InstallerServiceAccount = Get-Credential -UserName CORP\AutoSvc -Message "Credentials to Install SQL Server"

$firstComputer = $computers | Select-Object -First 1
$ConfigurationData = @{
    AllNodes = @(
        @{
            NodeName = "*"
            PSDscAllowPlainTextPassword = $true
            PSDscAllowDomainUser =$true
            NETPath = "\\ohdc9000\SQLAutoBuilds\SQL2014\WindowsServer2012R2\sources\sxs"
            SourcePath = "\\ohdc9000\SQLAutoBuilds\SQL2014\"
            InstallerServiceAccount = $InstallerServiceAccount
            SQLServiceAccount = $InstallerServiceAccount
            AdminAccount = "CORP\Administrator"
            ClusterName = "CLDBx6" 
            ClusterIPAddress = "10.0.75.55"
            FailoverClusterNetworkName = "CLSCDB6"
        }
        )}

        ForEach ($computer in $computers) {
        
            if($firstComputer -eq $computer)
            {
                    $ConfigurationData.AllNodes += @{
                    NodeName        = $computer
                    InstanceName    = "MSSQLSERVER"
                    Features        = "SQLENGINE"
                    Role = "PrimaryServerNode"        
                    }
            }
            else 
            {
                    $ConfigurationData.AllNodes += @{
                    NodeName        = $computer
                    InstanceName    = "MSSQLSERVER"
                    Features        = "SQLENGINE"
                    Role = "ReplicaServerNode"    
                    }
            }
           $Destination = "\\"+$computer+"\\c$\Program Files\WindowsPowerShell\Modules"
           if (Test-Path "$Destination\xFailoverCluster"){Remove-Item -Path "$Destination\xFailoverCluster" -Recurse -Force}
           if (Test-Path "$Destination\xSqlServer"){Remove-Item -Path "$Destination\xSqlServer"-Recurse -Force}
           Copy-Item 'C:\Program Files\WindowsPowerShell\Modules\xFailoverCluster' -Destination $Destination -Recurse -Force
           Copy-Item 'C:\Program Files\WindowsPowerShell\Modules\xSqlServer' -Destination $Destination -Recurse -Force
 }
        


FCISQL -ConfigurationData $ConfigurationData -OutputPath $OutputPath


Workflow StartConfigs 
{ 
    param([string[]]$computers,
        [System.string] $Path)
 
    foreach –parallel ($Computer in $Computers) 
    {
    
        Start-DscConfiguration -ComputerName $Computer -Path $Path -Verbose -Wait -Force
    }
}

StartConfigs -Computers $computers -Path $OutputPath

