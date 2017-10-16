#this example should be used on local machine where two sql instances are installed
#DEFAULT instance will be configured as distributor
#PUBLISHER instance will be configured as publisher with remote distributor as default instance

$credentials = Get-Credential 'AdminLink'
$runAsCredentials = Get-Credential

configuration ReplicationTest
{
    Import-DscResource -ModuleName xSQLServer

    Node $AllNodes.NodeName
    {
        LocalConfigurationManager
        {
            #this option should only be used during testing, remove it in production environment
            DebugMode = 'ForceModuleImport'
        }

        xSQLServerReplication distributor
        {
            InstanceName = 'MSSQLSERVER'
            AdminLinkCredentials = $credentials
            DistributorMode = 'Local'
            WorkingDirectory = 'C:\temp'
            Ensure = 'Present'
            PsDscRunAsCredential = $runAsCredentials
        }

        xSQLServerReplication publisher
        {
            InstanceName = 'PUBLISHER'
            AdminLinkCredentials = $credentials
            DistributorMode = 'Remote'
            WorkingDirectory = 'C:\temp'
            RemoteDistributor = $Node.NodeName
            Ensure = 'Present'
            PsDscRunAsCredential = $runAsCredentials
        }
    }
}

$ConfigurationData = @{
    AllNodes = @(
        @{
            NodeName = $($env:COMPUTERNAME)
            #this option should only be used during testing, remove it in production environment
            PSDscAllowPlainTextPassword = $true
        } 
    )
}

ReplicationTest -ConfigurationData $ConfigurationData
Set-DscLocalConfigurationManager .\ReplicationTest -Force -Verbose
Start-DscConfiguration .\ReplicationTest -Wait -Force -Verbose
