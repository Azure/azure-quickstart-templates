<#
.EXAMPLE
    This example shows how to deploy Excel Services to the local SharePoint farm.
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
            SPExcelServiceApp ExcelServices
            {
                Name            = "Excel Services Service Application"
                ApplicationPool = "SharePoint Service Applications"
                InstallAccount  = $SetupAccount
            }
        }
    }
