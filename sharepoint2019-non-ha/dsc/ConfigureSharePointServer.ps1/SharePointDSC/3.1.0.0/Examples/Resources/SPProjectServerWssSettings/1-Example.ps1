<#
.EXAMPLE
    This example demonstrates how to set WSS settings for a PWA site
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
        SPProjectServerWssSettings WssSettings
        {
            Url                   = "http://projects.contoso.com/pwa"
            CreateProjectSiteMode = "AutoCreate"
            PsDscRunAsCredential  = $SetupAccount
        }
    }
}
