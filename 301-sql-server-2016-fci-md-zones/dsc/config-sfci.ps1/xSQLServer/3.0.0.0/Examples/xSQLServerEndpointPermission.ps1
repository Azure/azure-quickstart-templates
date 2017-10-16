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
        [PsCredential] $SqlAdministratorCredential,

        [Parameter(Mandatory=$true)] 
        [ValidateNotNullorEmpty()] 
        [PsCredential] $SqlServiceCredentialNode1, 

        [Parameter(Mandatory=$true)] 
        [ValidateNotNullorEmpty()] 
        [PsCredential] $SqlServiceCredentialNode2
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName xSqlServer

    Node $AllNodes.Where{$_.Role -eq "PrimaryReplica" }.NodeName
    {
        #region Remove endpoint permissions       
        xSQLServerEndpointPermission SQLConfigureEndpointPermissionPrimary
        {
            Ensure = "Present"
            NodeName = $Node.NodeName
            InstanceName = $Node.SqlInstanceName
            Name = "DefaultMirrorEndpoint"
            Principal = $SqlServiceCredentialNode1.UserName 
            Permission = "CONNECT"

            PsDscRunAsCredential = $SqlAdministratorCredential
        }

        xSQLServerEndpointPermission SQLConfigureEndpointPermissionSecondary
        {
           Ensure = "Present"
           NodeName = $Node.NodeName
           InstanceName = $Node.SqlInstanceName
           Name = "DefaultMirrorEndpoint"
           Principal = $SqlServiceCredentialNode2.UserName 
           Permission = "CONNECT"
        
           PsDscRunAsCredential = $SqlAdministratorCredential
        }
        #endregion
        
        #region Remove endpoint permissions       
        xSQLServerEndpointPermission RemoveSQLConfigureEndpointPermissionPrimary
        {
           Ensure = "Absent"
           NodeName = $Node.NodeName
           InstanceName = $Node.SqlInstanceName
           Name = "DefaultMirrorEndpoint"
           Principal = $SqlServiceCredentialNode2.UserName 
           Permission = "CONNECT"
        
           PsDscRunAsCredential = $SqlAdministratorCredential
        
           DependsOn = "[xSQLServerEndpointPermission]SQLConfigureEndpointPermissionPrimary"
        }

        xSQLServerEndpointPermission RemoveSQLConfigureEndpointPermissionSecondary
        {
           Ensure = "Absent"
           NodeName = $Node.NodeName
           InstanceName = $Node.SqlInstanceName
           Name = "DefaultMirrorEndpoint"
           Principal = $SqlServiceCredentialNode2.UserName 
           Permission = "CONNECT"
        
           PsDscRunAsCredential = $SqlAdministratorCredential
        
           DependsOn = "[xSQLServerEndpointPermission]SQLConfigureEndpointPermissionSecondary"
        }
        #endregion
   }

    Node $AllNodes.Where{ $_.Role -eq "SecondaryReplica" }.NodeName
    {         
        xSQLServerEndpointPermission SQLConfigureEndpointPermissionPrimary
        {
            Ensure = "Present"
            NodeName = $Node.NodeName
            InstanceName = $Node.SqlInstanceName
            Name = "DefaultMirrorEndpoint"
            Principal = $SqlServiceCredentialNode1.UserName 
            Permission = "CONNECT"
        
            PsDscRunAsCredential = $SqlAdministratorCredential
        
            DependsOn = "[xSQLServerEndpoint]SQLConfigureEndpoint"
        }

        xSQLServerEndpointPermission SQLConfigureEndpointPermissionSecondary
        {
            Ensure = "Present"
            NodeName = $Node.NodeName
            InstanceName = $Node.SqlInstanceName
            Name = "DefaultMirrorEndpoint"
            Principal = $SqlServiceCredentialNode2.UserName 
            Permission = "CONNECT"
        
            PsDscRunAsCredential = $SqlAdministratorCredential
        
            DependsOn = "[xSQLServerEndpoint]SQLConfigureEndpoint"
        }

        # Remove endpoint permissions       
        xSQLServerEndpointPermission RemoveSQLConfigureEndpointPermissionPrimary
        {
           Ensure = "Absent"
           NodeName = $Node.NodeName
           InstanceName = $Node.SqlInstanceName
           Name = "DefaultMirrorEndpoint"
           Principal = $SqlServiceCredentialNode2.UserName 
           Permission = "CONNECT"
        
           PsDscRunAsCredential = $SqlAdministratorCredential
        
           DependsOn = "[xSQLServerEndpointPermission]SQLConfigureEndpointPermissionPrimary"
        }

        xSQLServerEndpointPermission RemoveSQLConfigureEndpointPermissionSecondary
        {
           Ensure = "Absent"
           NodeName = $Node.NodeName
           InstanceName = $Node.SqlInstanceName
           Name = "DefaultMirrorEndpoint"
           Principal = $SqlServiceCredentialNode2.UserName 
           Permission = "CONNECT"
        
           PsDscRunAsCredential = $SqlAdministratorCredential
        
           DependsOn = "[xSQLServerEndpointPermission]SQLConfigureEndpointPermissionSecondary"
        } 
    }
}

$SqlAdministratorCredential = Get-Credential -Message "Enter credentials for SQL Server administrator account"
$SqlServiceCredentialNode1 = Get-Credential -Message "Enter credentials for SQL Service account for primary replica"
$SqlServiceCredentialNode2 = Get-Credential -Message "Enter credentials for SQL Service account for secondary replica" 

SQLAlwaysOnNodeConfig `
    -SqlAdministratorCredential $SqlAdministratorCredential `
    -SqlServiceCredentialNode1 $SqlServiceCredentialNode1 `
    -SqlServiceCredentialNode2 $SqlServiceCredentialNode2 `
    -ConfigurationData $ConfigData `
    -OutputPath 'C:\Configuration'
