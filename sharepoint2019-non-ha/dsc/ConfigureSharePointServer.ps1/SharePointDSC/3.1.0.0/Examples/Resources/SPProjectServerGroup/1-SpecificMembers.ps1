<#
.EXAMPLE
    This example shows how to create a group with a specific list of members in a PWA site
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
            Members = @(
                "Domain\User1"
                "Domain\User2"
            )
            PSDscRunAsCredential = $SetupAccount
        }
    }
}
