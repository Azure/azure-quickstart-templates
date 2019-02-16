<#
.EXAMPLE
    This example shows how to remove Excel Services from the local SharePoint farm.
    Here application pool is a required parameter, but it is not actually used when
    removing a service app and as such can be ignored and set to any value. 
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
                ApplicationPool = "n/a"
                Ensure          = "Absent"
                InstallAccount  = $SetupAccount
            }
        }
    }
