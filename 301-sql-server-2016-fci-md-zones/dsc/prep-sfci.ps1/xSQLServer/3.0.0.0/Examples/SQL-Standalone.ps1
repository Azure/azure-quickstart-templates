#requires -Version 5

[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingConvertToSecureStringWithPlainText", "")]
param ()

Configuration SQLSA
{
    Import-DscResource -Module xSQLServer

    # Set role and instance variables
    $Roles = $AllNodes.Roles | Sort-Object -Unique
    foreach($Role in $Roles)
    {
        $Servers = @($AllNodes.Where{$_.Roles | Where-Object {$_ -eq $Role}}.NodeName)
        Set-Variable -Name ($Role.Replace(" ","").Replace(".","") + "s") -Value $Servers
        if($Servers.Count -eq 1)
        {
            Set-Variable -Name ($Role.Replace(" ","").Replace(".","")) -Value $Servers[0]
            if(
                $Role.Contains("Database") -or
                $Role.Contains("Datawarehouse") -or
                $Role.Contains("Reporting") -or
                $Role.Contains("Analysis") -or 
                $Role.Contains("Integration")
            )
            {
                $Instance = $AllNodes.Where{$_.NodeName -eq $Servers[0]}.SQLServers.Where{$_.Roles | Where-Object {$_ -eq $Role}}.InstanceName
                Set-Variable -Name ($Role.Replace(" ","").Replace(".","").Replace("Server","Instance")) -Value $Instance
            }
        }
    }    

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

        # Install SQL Instances
        foreach($SQLServer in $Node.SQLServers)
        {
            $SQLInstanceName = $SQLServer.InstanceName

            $Features = "SQLENGINE,FULLTEXT,RS,AS,IS"

            if($Features -ne "")
            {
                xSqlServerSetup ($Node.NodeName + $SQLInstanceName)
                {
                    DependsOn = "[WindowsFeature]NET-Framework-Core"
                    SourcePath = $Node.SourcePath
                    SetupCredential = $Node.InstallerServiceAccount
                    InstanceName = $SQLInstanceName
                    Features = $Features
                    SQLSysAdminAccounts = $Node.AdminAccount
                    InstallSharedDir = "C:\Program Files\Microsoft SQL Server"
                    InstallSharedWOWDir = "C:\Program Files (x86)\Microsoft SQL Server"
                    InstanceDir = "D:\Program Files\Microsoft SQL Server"
                    InstallSQLDataDir = "E:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\Data"
                    SQLUserDBDir = "F:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\Data"
                    SQLUserDBLogDir = "G:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\Data"
                    SQLTempDBDir = "H:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\Data"
                    SQLTempDBLogDir = "I:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\Data"
                    SQLBackupDir = "J:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\Data"
                    ASDataDir = "K:\Program Files\Microsoft SQL Server\MSAS11.MSSQLSERVER\OLAP\Data"
                    ASLogDir = "L:\Program Files\Microsoft SQL Server\MSAS11.MSSQLSERVER\OLAP\Log"
                    ASBackupDir = "M:\Program Files\Microsoft SQL Server\MSAS11.MSSQLSERVER\OLAP\Backup"
                    ASTempDir = "N:\Program Files\Microsoft SQL Server\MSAS11.MSSQLSERVER\OLAP\Temp"
                    ASConfigDir = "O:\Program Files\Microsoft SQL Server\MSAS11.MSSQLSERVER\OLAP\Config"
                }

                xSqlServerFirewall ($Node.NodeName + $SQLInstanceName)
                {
                    DependsOn = ("[xSqlServerSetup]" + $Node.NodeName + $SQLInstanceName)
                    SourcePath = $Node.SourcePath
                    InstanceName = $SQLInstanceName
                    Features = $Features
                }
            }
        }

        # Install SQL Management Tools
        if($SQLServer2012ManagementTools | Where-Object {$_ -eq $Node.NodeName})
        {
            xSqlServerSetup "SQLMT"
            {
                DependsOn = "[WindowsFeature]NET-Framework-Core"
                SourcePath = $Node.SourcePath
                SetupCredential = $Node.InstallerServiceAccount
                InstanceName = "NULL"
                Features = "SSMS,ADV_SSMS"
            }
        }
    }
}

$InstallerServiceAccount = Get-Credential "CONTOSO\!Installer"
$LocalSystemAccount = Get-Credential "SYSTEM"

$ConfigurationData = @{
    AllNodes = @(
        @{
            NodeName = "*"
            PSDscAllowPlainTextPassword = $true

            SourcePath = "\\RD01\Installer"
            InstallerServiceAccount = $InstallerServiceAccount
            LocalSystemAccount = $LocalSystemAccount

            AdminAccount = "CONTOSO\Administrator"

        }
        @{
            NodeName = "SCDB.contoso.com"
            SQLServers = @(
                @{
                    InstanceName = "MSSQLSERVER"
                }
            )
        }
        @{
            NodeName = "RD01.contoso.com"
            Roles = @("SQL Server 2012 Management Tools")
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

SQLSA -ConfigurationData $ConfigurationData
Set-DscLocalConfigurationManager -Path .\SQLSA -Verbose
Start-DscConfiguration -Path .\SQLSA -Verbose -Wait -Force

