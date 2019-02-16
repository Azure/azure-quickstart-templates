<#
.EXAMPLE
    This example demonstrates how to set user sync settings for a PWA site
#>

Configuration Example 
{
    param(
        [Parameter(Mandatory = $true)]
        [PSCredential]
        $SetupAccount
    )
    Import-DscResource -ModuleName SharePointDsc

    node localhost 
    {
        SPProjectServerUserSyncSettings UserSyncSettings
        {
            Url                                 = "http://projects.contoso.com/pwa"
            EnableProjectWebAppSync             = $true
            EnableProjectSiteSync               = $true
            EnableProjectSiteSyncForSPTaskLists = $true  
            PsDscRunAsCredential                = $SetupAccount
        }
    }
}
