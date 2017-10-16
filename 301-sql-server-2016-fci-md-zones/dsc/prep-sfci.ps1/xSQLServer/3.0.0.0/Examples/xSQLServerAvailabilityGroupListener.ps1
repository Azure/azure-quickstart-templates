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
        #region Example to add listeners
        xSQLServerAvailabilityGroupListener AvailabilityGroupListenerWithSameNameAsVCO
        {
            Ensure = "Present"
            NodeName = $Node.NodeName
            InstanceName = $Node.SqlInstanceName
            AvailabilityGroup = "AG-01"
            Name = "AG-01"
            IpAddress = "192.168.0.73/255.255.255.0"
            Port = 5301

            PsDscRunAsCredential = $SqlAdministratorCredential
            
            DependsOn = "[xSQLServerAvailabilityGroup]AvailabilityGroupForSynchronousCommitAndAutomaticFailover"
        }

        xSQLServerAvailabilityGroupListener AvailabilityGroupListenerWithDifferentNameAsVCO
        {
            Ensure = "Present"
            NodeName = $Node.NodeName
            InstanceName = $Node.SqlInstanceName
            AvailabilityGroup = "AvailabilityGroup-02"
            Name = "AG-02"
            IpAddress = "192.168.0.74/255.255.255.0"
            Port = 5302

            PsDscRunAsCredential = $SqlAdministratorCredential
            
            DependsOn = "[xSQLServerAvailabilityGroup]AvailabilityGroupForAsynchronousCommitAndManualFailover"
        }
        #endregion
        
        #region Example to remove listeners
        xSQLServerAvailabilityGroupListener RemoveAvailabilityGroupListenerWithSameNameAsVCO
        {
            Ensure = "Absent"
            NodeName = $Node.NodeName
            InstanceName = $Node.SqlInstanceName
            AvailabilityGroup = "AG-01"
            Name = "AG-01"

            PsDscRunAsCredential = $SqlAdministratorCredential
            
            DependsOn = "[xSQLServerAvailabilityGroupListener]AvailabilityGroupListenerWithSameNameAsVCO"
        }

        xSQLServerAvailabilityGroupListener RemoveAvailabilityGroupListenerWithDifferentNameAsVCO
        {
            Ensure = "Absent"
            NodeName = $Node.NodeName
            InstanceName = $Node.SqlInstanceName
            AvailabilityGroup = "AvailabilityGroup-02"
            Name = "AG-02"

            PsDscRunAsCredential = $SqlAdministratorCredential
            
            DependsOn = "[xSQLServerAvailabilityGroupListener]AvailabilityGroupListenerWithDifferentNameAsVCO"
        }
        #endregion
    }

    Node $AllNodes.Where{ $_.Role -eq "SecondaryReplica" }.NodeName
    {         
    }
}

$SqlAdministratorCredential = Get-Credential -Message "Enter credentials for SQL Server administrator account"

SQLAlwaysOnNodeConfig `
    -SqlAdministratorCredential $SqlAdministratorCredential `
    -ConfigurationData $ConfigData `
    -OutputPath 'C:\Configuration'
