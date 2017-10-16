#requires -Version 5
$computers = 'OHSQL1016'
$OutputPath = 'D:\DSCLocal'
$cim = New-CimSession -ComputerName $computers

#requires -Version 5

[DSCLocalConfigurationManager()]
Configuration LCM_Push
{    
    Param(
        [string[]]$ComputerName
    )
    Node $ComputerName
    {
    Settings
        {
            AllowModuleOverwrite = $True
            ConfigurationMode = 'ApplyAndAutoCorrect'
            RefreshMode = 'Push'
            RebootNodeIfNeeded = $True    
        }
    }
}

foreach ($computer in $computers)
{
    $GUID = (New-Guid).Guid
    LCM_Push -ComputerName $Computer -OutputPath $OutputPath 
    Set-DSCLocalConfigurationManager -Path $OutputPath  -CimSession $computer 
}

Configuration SQLSA
{
    Import-DscResource –Module PSDesiredStateConfiguration
    Import-DscResource -Module xSQLServer

    Node $AllNodes.NodeName
    {
        # Set LCM to reboot if needed
        LocalConfigurationManager
        {
            AllowModuleOverwrite = $true
            RebootNodeIfNeeded = $true
        }
        WindowsFeature "NET"
        {
            Ensure = "Present"
            Name = "NET-Framework-Core"
            Source = $Node.NETPath 
        }

        if($Node.Features)
        {
           xSqlServerSetup ($Node.NodeName)
           {
               DependsOn = '[WindowsFeature]NET'
               SourcePath = $Node.SourcePath
               SetupCredential = $Node.InstallerServiceAccount
               InstanceName = $Node.InstanceName
               Features = $Node.Features
               SQLSysAdminAccounts = $Node.AdminAccount
               InstallSharedDir = "G:\Program Files\Microsoft SQL Server"
               InstallSharedWOWDir = "G:\Program Files (x86)\Microsoft SQL Server"
               InstanceDir = "G:\Program Files\Microsoft SQL Server"
               InstallSQLDataDir = "G:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\Data"
               SQLUserDBDir = "G:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\Data"
               SQLUserDBLogDir = "L:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\Data"
               SQLTempDBDir = "T:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\Data"
               SQLTempDBLogDir = "L:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\Data"
               SQLBackupDir = "G:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\Data"
           }
         
           xSqlServerFirewall ($Node.NodeName)
           {
               DependsOn = ("[xSqlServerSetup]" + $Node.NodeName)
               SourcePath = $Node.SourcePath
               InstanceName = $Node.InstanceName
               Features = $Node.Features
           }
           xSQLServerPowerPlan ($Node.Nodename)
           {
               Ensure = "Present"
           }
           xSQLServerMemory ($Node.Nodename)
           {
               DependsOn = ("[xSqlServerSetup]" + $Node.NodeName)
               Ensure = "Present"
               DynamicAlloc = $false
               MinMemory = "256"
               MaxMemory ="1024"
           }
           xSQLServerMaxDop($Node.Nodename)
           {
               DependsOn = ("[xSqlServerSetup]" + $Node.NodeName)
               Ensure = "Present"
               DynamicAlloc = $true
           }
           xSQLServerLogin($Node.Nodename+"TestUser2")
           {
                DependsOn = ("[xSqlServerSetup]" + $Node.NodeName)
                Ensure = "Present"
                Name = "TestUser2"
                LoginCredential = $Node.InstallerServiceAccount
                LoginType = "SQLLogin"
           }
           xSQLServerLogin($Node.Nodename+"TestUser1")
           {
                DependsOn = ("[xSqlServerSetup]" + $Node.NodeName)
                Ensure = "Present"
                Name = "TestUser1"
                LoginCredential = $Node.InstallerServiceAccount
                LoginType = "SQLLogin"
           }
           xSQLServerDatabaseRole($Node.Nodename)
           {
                DependsOn = ("[xSqlServerSetup]" + $Node.NodeName)
                Ensure = "Present"
                Name = "TestUser1"
                Database = "model"
                Role ="db_Datareader"
           }
           xSQLDatabaseRecoveryModel($Node.Nodename)
           {
                DatabaseName = "TestDB"
                RecoveryModel = "Full"
                SqlServerInstance ="$($Node.NodeName)\$($Node.SQLInstanceName)"  
           }
           xSQLServerDatabaseOwner($Node.Nodename)
           {
                Database = "TestDB"
                Name = "TestUser2"
           }
           xSQLServerDatabasePermissions($Node.Nodename)
           {
                Database = "Model"
                Name = "TestUser1"
                Permissions ="SELECT","DELETE"
           }
           xSQLServerDatabase($Node.Nodename)
           {
                Database = "Test3"
                Ensure = "Present"
           }
        }
    }
}

$ConfigurationData = @{
    AllNodes = @(
        @{
            NodeName = "*"
            PSDscAllowPlainTextPassword = $true
            PSDscAllowDomainUser =$true
            NETPath = "\\ohhv003\SQLBuilds\SQLAutoInstall\WIN2012R2\sxs"
            SourcePath = "\\ohhv003\SQLBuilds\SQLAutoInstall\SQL2012"
            InstallerServiceAccount = Get-Credential -UserName Contoso\SQLAutoSvc -Message "Credentials to Install SQL Server"
            AdminAccount = "Contoso\sqladmin"  
        }
    )
}

ForEach ($computer in $computers) {
    $ConfigurationData.AllNodes += @{
            NodeName        = $computer
            InstanceName    = "MSSQLSERVER"
            Features        = "SQLENGINE,IS,SSMS,ADV_SSMS"       

    }
   $Destination = "\\"+$computer+"\\c$\Program Files\WindowsPowerShell\Modules"
   Copy-Item 'C:\Program Files\WindowsPowerShell\Modules\xSQLServer' -Destination $Destination -Recurse -Force
}

SQLSA -ConfigurationData $ConfigurationData -OutputPath $OutputPath

#Push################################
foreach($Computer in $Computers) 
{

    Start-DscConfiguration -ComputerName $Computer -Path $OutputPath -Verbose -Wait -Force
}

#Ttest
foreach($Computer in $Computers) 
{
    test-dscconfiguration -ComputerName $Computer
}

