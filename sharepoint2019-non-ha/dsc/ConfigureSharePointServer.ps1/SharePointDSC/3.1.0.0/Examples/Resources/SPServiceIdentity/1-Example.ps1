<#
.EXAMPLE
    This example shows how to set the SandBox Code Service to run under a specifed service account. 
    The account must already be registered as a managed account.
#>

Configuration Example 
    {
        param(
            [Parameter(Mandatory = $true)]
            [PSCredential]
            $SetupAccount
        )

 Import-DscResource -ModuleName SharePointDsc

        node localhost {
 
            SPServiceIdentity SandBoxUserAccount
            {
                Name           = "Microsoft SharePoint Foundation Sandboxed Code Service"
                ManagedAccount = "CONTOSO\SPUserCode"
                PsDscRunAsCredential = $SetupAccount
            }
        }
    }
