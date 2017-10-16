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
        # Add permission
        xSQLServerPermission SQLConfigureAlwaysOnPermissionHealthDetectionAccount
        {
            Ensure = "Present"
            NodeName = $Node.NodeName
            InstanceName = $Node.SqlInstanceName
            Principal = "NT AUTHORITY\SYSTEM" 
            Permission = "AlterAnyAvailabilityGroup","ViewServerState"

            PsDscRunAsCredential = $SqlAdministratorCredential
        }

        # Remove permission
        xSQLServerPermission RemoveAlwaysOnPermissionHealthDetectionAccount
        {
            Ensure = "Absent"
            NodeName = $Node.NodeName
            InstanceName = $Node.SqlInstanceName
            Principal = "NT AUTHORITY\SYSTEM" 
            Permission = "AlterAnyAvailabilityGroup","ViewServerState"

            PsDscRunAsCredential = $SqlAdministratorCredential

            DependsOn = "[xSQLServerPermission]SQLConfigureAlwaysOnPermissionHealthDetectionAccount"
        }
    }

    Node $AllNodes.Where{ $_.Role -eq "SecondaryReplica" }.NodeName
    {         
        # Add permission
        xSQLServerPermission SQLConfigureAlwaysOnPermissionHealthDetectionAccount
        {
            Ensure = "Present"
            NodeName = $Node.NodeName
            InstanceName = $Node.SqlInstanceName
            Principal = "NT AUTHORITY\SYSTEM" 
            Permission = "AlterAnyAvailabilityGroup","ViewServerState"

            PsDscRunAsCredential = $SqlAdministratorCredential
        }

        # Remove permission
        xSQLServerPermission RemoveAlwaysOnPermissionHealthDetectionAccount
        {
            Ensure = "Absent"
            NodeName = $Node.NodeName
            InstanceName = $Node.SqlInstanceName
            Principal = "NT AUTHORITY\SYSTEM" 
            Permission = "AlterAnyAvailabilityGroup","ViewServerState"

            PsDscRunAsCredential = $SqlAdministratorCredential

            DependsOn = "[xSQLServerPermission]SQLConfigureAlwaysOnPermissionHealthDetectionAccount"
        }
    }
}

$SqlAdministratorCredential = Get-Credential -Message "Enter credentials for SQL Server administrator account"

SQLAlwaysOnNodeConfig `
    -SqlAdministratorCredential $SqlAdministratorCredential `
    -ConfigurationData $ConfigData `
    -OutputPath 'C:\Configuration'
