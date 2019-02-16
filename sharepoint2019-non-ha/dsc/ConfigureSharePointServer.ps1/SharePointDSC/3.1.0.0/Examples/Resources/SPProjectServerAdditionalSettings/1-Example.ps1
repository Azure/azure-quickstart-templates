<#
.EXAMPLE
    This example shows how to apply additional settings to the PWA site
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
        SPProjectServerAdditionalSettings Settings
        {
            Url                   = "http://projects.contoso.com/pwa"
            ServerCurrency        = "AUD"
            EnforceServerCurrency = $true 
            PsDscRunAsCredential  = $SetupAccount
        }
    }
}
