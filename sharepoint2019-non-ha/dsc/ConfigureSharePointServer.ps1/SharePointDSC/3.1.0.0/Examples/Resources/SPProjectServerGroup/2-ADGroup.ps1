<#
.EXAMPLE
    This example shows how to create a PWA group mapped to a group in AD
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
        SPProjectServerGroup Group
        {
            Url = "http://projects.contoso.com"
            Name = "My group"
            ADGroup = "Domain\Group"
            PSDscRunAsCredential = $SetupAccount
        }
    }
}
