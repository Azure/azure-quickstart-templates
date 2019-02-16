<#
.EXAMPLE
    This example shows how to a specific PWA site to use Project server 
    permission mode.
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
        SPProjectServerPermissionMode PermissionMode
        {
            Url = "http://projects.contoso.com"
            PermissionMode = "ProjectServer"
            InstallAccount  = $SetupAccount
        }
    }
}
