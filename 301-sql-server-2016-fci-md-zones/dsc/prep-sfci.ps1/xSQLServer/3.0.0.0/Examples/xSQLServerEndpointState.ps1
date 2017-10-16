$ConfigData = @{
    AllNodes = @(
        @{
            NodeName= "*"
            CertificateFile = "C:\Certificates\dsc-public.cer" 
            Thumbprint = "D6F57B6BE46A7162138687FB74DBAA1D4EB1A59B" 
            SqlInstanceName = "MSSQLSERVER"
            PSDscAllowDomainUser = $true
        },

        @{ 
            NodeName = 'SQLNODE01.company.local'
            Role = "PrimaryReplica"
        },

        @{
            NodeName = 'SQLNODE02.company.local' 
            Role = "SecondaryReplica" 
        }
    )
}
 
Configuration SQLAlwaysOnNodeConfig 
{
    param
    (
        [Parameter(Mandatory=$false)] 
        [ValidateNotNullorEmpty()] 
        [PsCredential] $SqlAdministratorCredential
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName xSqlServer

    Node $AllNodes.Where{$_.Role -eq "PrimaryReplica" }.NodeName
    {
        # Start the endpoint
        xSQLServerEndpointState StartAlwaysOnEndpoint
        {
            NodeName = $Node.NodeName
            InstanceName = $Node.SqlInstanceName
            Name = "DefaultMirrorEndpoint"
            State = "Started"

            PsDscRunAsCredential = $SqlAdministratorCredential
        }

        # Stop the endpoint
        xSQLServerEndpointState StopAlwaysOnEndpoint
        {
            NodeName = $Node.NodeName
            InstanceName = $Node.SqlInstanceName
            Name = "DefaultMirrorEndpoint"
            State = "Stopped"

            PsDscRunAsCredential = $SqlAdministratorCredential

            DependsOn = "[xSQLServerEndpointState]StartAlwaysOnEndpoint"
        }
    }

    Node $AllNodes.Where{ $_.Role -eq "SecondaryReplica" }.NodeName
    {         
        # Start the endpoint
        xSQLServerEndpointState StartAlwaysOnEndpoint
        {
            NodeName = $Node.NodeName
            InstanceName = $Node.SqlInstanceName
            Name = "DefaultMirrorEndpoint"
            State = "Started"

            PsDscRunAsCredential = $SqlAdministratorCredential
        }

        # Stop the endpoint
        xSQLServerEndpointState StopAlwaysOnEndpoint
        {
            NodeName = $Node.NodeName
            InstanceName = $Node.SqlInstanceName
            Name = "DefaultMirrorEndpoint"
            State = "Stopped"

            PsDscRunAsCredential = $SqlAdministratorCredential

            DependsOn = "[xSQLServerEndpointState]StartAlwaysOnEndpoint"
        }
    }
}

$SqlAdministratorCredential = Get-Credential -Message "Enter credentials for SQL Server administrator account"

SQLAlwaysOnNodeConfig `
    -SqlAdministratorCredential $SqlAdministratorCredential `
    -ConfigurationData $ConfigData `
    -OutputPath 'C:\Configuration'
