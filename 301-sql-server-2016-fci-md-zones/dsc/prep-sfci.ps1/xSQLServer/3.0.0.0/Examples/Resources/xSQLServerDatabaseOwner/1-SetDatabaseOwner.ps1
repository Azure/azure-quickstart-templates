<#
.EXAMPLE
    This example shows how to ensure that the user account CONTOSO\SQLAdmin
    is "Owner" of SQL database "AdventureWorks". 
#>

    Configuration Example 
    {
        param
        (
            [Parameter(Mandatory = $true)]
            [System.Management.Automation.PSCredential]
            [System.Management.Automation.Credential()]
            $SysAdminAccount
        )

        Import-DscResource -ModuleName xSqlServer

        node localhost 
        {
            xSQLServerLogin Add_SqlServerLogin_SQLAdmin
            {
                DependsOn = '[xSqlServerSetup]SETUP_SqlMSSQLSERVER'
                Ensure = 'Present'
                Name = 'CONTOSO\SQLAdmin'
                LoginType = 'WindowsUser'        
                SQLServer = 'SQLServer'
                SQLInstanceName = 'DSC'
                PsDscRunAsCredential = $SysAdminAccount
            }

            xSQLServerDatabaseOwner Set_SqlDatabaseOwner_SQLAdmin
            {
                DependsOn = '[xSQLServerLogin]Add_SqlServerLogin_SQLAdmin'
                Name = 'CONTOSO\SQLAdmin'
                Database = 'AdventureWorks'
                SQLServer = 'SQLServer'
                SQLInstanceName = 'DSC'
                PsDscRunAsCredential = $SysAdminAccount
            }
        }
    }
