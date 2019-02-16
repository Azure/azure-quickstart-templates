<#
.EXAMPLE
    This example disables Project Server AD resource pool sync
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
            Ensure               = "Absent"
            Url                  = "http://projects.contoso.com/pwa"
            PsDscRunAsCredential = $SetupAccount
        }
    }
}
