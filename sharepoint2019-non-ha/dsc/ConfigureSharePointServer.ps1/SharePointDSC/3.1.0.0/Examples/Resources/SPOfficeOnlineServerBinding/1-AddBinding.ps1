<#
.EXAMPLE
    This example shows how to create bindings to the internal-https zone for the 
    local SharePoint farm.
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
            SPOfficeOnlineServerBinding OosBinding 
            {
                Zone                 = "internal-https"
                DnsName              = "webapps.contoso.com"
                PsDscRunAsCredential = $SetupAccount
            }
        }
    }
