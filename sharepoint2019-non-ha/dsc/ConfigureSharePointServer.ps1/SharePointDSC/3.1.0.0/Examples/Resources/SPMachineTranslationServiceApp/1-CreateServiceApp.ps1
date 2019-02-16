<#
.EXAMPLE
    This example shows how to deploy the SP Machine Translation Service App to the local SharePoint farm.
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
        SPMachineTranslationServiceApp MachineTranslationServiceApp
        {
            Name                   = "Translation Service Application"
            ApplicationPool        = "SharePoint Service Applications"
            DatabaseServer         = "SQL.contoso.local"
            DatabaseName           = "Translation"
            Ensure                 = "Present"
            PsDscRunAsCredential   = $SetupAccount
        }
    }
}
