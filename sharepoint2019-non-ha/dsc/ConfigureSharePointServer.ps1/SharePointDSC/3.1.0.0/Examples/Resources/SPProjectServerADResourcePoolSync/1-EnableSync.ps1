<#
.EXAMPLE
    This example enables Project Server AD resource pool sync
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
        SPProjectServerADResourcePoolSync EnableSync
        {
            Ensure               = "Present"
            Url                  = "http://projects.contoso.com/pwa"
            GroupNames           = @("DOMAIN\Group 1", "DOMAIN\Group 2")
            PsDscRunAsCredential = $SetupAccount
        }
    }
}
