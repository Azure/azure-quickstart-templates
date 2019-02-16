<#
.EXAMPLE
    This example shows how to deploy Access Services 2010 to the local SharePoint farm.
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
            SPAccessServices2010 Access2010Services
            {
                Name                 = "Access 2010 Services Service Application"
                ApplicationPool      = "SharePoint Service Applications" 
                PsDscRunAsCredential = $SetupAccount
            }
        }
    }
