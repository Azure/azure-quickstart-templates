<#
.EXAMPLE
    This example shows how a basic SharePoint farm can be created. The database server and names
    are specified, and the accounts to run the setup as, the farm account and the passphrase are
    all passed in to the configuration to be applied. By default the central admin site in this
    example is provisioned to port 9999 using NTLM authentication.
#>

    Configuration Example
    {
        param(
            [Parameter(Mandatory = $true)]
            [PSCredential]
            $FarmAccount,

            [Parameter(Mandatory = $true)]
            [PSCredential]
            $SetupAccount,

            [Parameter(Mandatory = $true)]
            [PSCredential]
            $Passphrase
        )
        Import-DscResource -ModuleName SharePointDsc

        node localhost {
            SPFarm SharePointFarm
            {
                IsSingleInstance          = "Yes"
                DatabaseServer            = "SQL.contoso.local\SQLINSTANCE"
                FarmConfigDatabaseName    = "SP_Config"
                AdminContentDatabaseName  = "SP_AdminContent"
                Passphrase                = $Passphrase
                FarmAccount               = $FarmAccount
                RunCentralAdmin           = $true
                PsDscRunAsCredential      = $SetupAccount
            }
        }
    }
