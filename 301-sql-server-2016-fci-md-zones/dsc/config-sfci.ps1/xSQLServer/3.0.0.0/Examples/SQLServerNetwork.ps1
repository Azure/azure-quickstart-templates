[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingConvertToSecureStringWithPlainText", "")]
param ()

Configuration SQLNetwork
{
    Import-DscResource -Module xSQLServer

    # A Configuration expects at least one Node
    Node $AllNodes.NodeName
    {
        # Set DCM Settings for each Node 
        LocalConfigurationManager 
        { 
            RebootNodeIfNeeded = $true 
            ConfigurationMode = "ApplyOnly" 
        } 

        WindowsFeature "NET-Framework-Core"
        {
            Ensure = "Present"
            Name = "NET-Framework-Core"
        }

        xSqlServerSetup "RDBMS"
        {
            DependsOn = @("[WindowsFeature]NET-Framework-Core")
            SourcePath = $Node.SourcePath
            SourceFolder = $Node.SQL2012FolderPath
            InstanceName = $Node.Instance
            Features = $Node.Features
            SetupCredential = $Node.InstallerServiceAccount
            SQLCollation = "Latin1_General_CI_AS"
            SQLSysAdminAccounts = $Node.AdminAccount
            SQLSvcAccount = $Node.LocalSystemAccount
            AgtSvcAccount = $Node.LocalSystemAccount
        }

        xSqlServerFirewall "RDBMS"
        {
            DependsOn = @("[xSqlServerSetup]RDBMS")
            SourcePath = $Node.SourcePath
            SourceFolder = $Node.SQL2012FolderPath
            InstanceName = $Node.Instance
            Features = $Node.Features
        }

        # This will enable TCP/IP protocol and set custom static port, this will also restart sql service
        xSQLServerNetwork "RDBMS"
        {
            DependsOn = @("[xSqlServerSetup]RDBMS")
            InstanceName = $Node.Instance
            ProtocolName = "tcp"
            IsEnabled = $true
            TCPPort = 4509
            RestartService = $true 
        }        
    } 
}

#Following example of how to use credentials is intended only for demo and test purposes
#For production environments please use SSencryption, more info can be found here:
#http://blogs.msdn.com/b/powershell/archive/2014/01/31/want-to-secure-credentials-in-windows-powershell-desired-state-configuration.aspx
$InstallerServiceAccount = Get-Credential "CONTOSO\!Installer"
$LocalSystemAccount = Get-Credential "SYSTEM"

$ConfigurationData = @{
    AllNodes = @(
        #AllNodes
        @{
            NodeName = "*"
            PSDscAllowPlainTextPassword = $true
            SourcePath = "\\FileServer\Installs"
            SQL2012FolderPath = "SqlServer2012_Developer_SP3_x64"
            InstallerServiceAccount = $InstallerServiceAccount
            LocalSystemAccount = $LocalSystemAccount
            AdminAccount = "CONTOSO\Administrator"
        }
        @{
            NodeName = "nodename"
            Instance = "MSSQLSERVER"
            Features = "SQLENGINE"
        } 
    )
}
