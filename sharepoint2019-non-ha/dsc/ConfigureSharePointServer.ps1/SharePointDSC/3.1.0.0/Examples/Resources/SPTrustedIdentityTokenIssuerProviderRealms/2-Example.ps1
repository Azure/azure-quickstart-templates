<#
.EXAMPLE
    This example adds provider realms to existing trusted token issuer.
    Existing are left and not removed.
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

        $ProviderRealmsToInclude = @()
        $ProviderRealmsToInclude += MSFT_SPProviderRealm {
                                RealmUrl = "https://search.contoso.com"
                                RealmUrn = "urn:sharepoint:contoso:search"
                                }

        $ProviderRealmsToInclude += MSFT_SPProviderRealm {
                                RealmUrl = "https://intranet.contoso.com"
                                RealmUrn = "urn:sharepoint:contoso:intranet"
                                }

        SPTrustedIdentityTokenIssuerProviderRealms Farm1IncludeExample
        {
            IssuerName               = "Contoso"
            ProviderRealmsToInclude  = $ProviderRealmsToInclude
            Ensure                   = "Present"
            PsDscRunAsCredential     = $SetupAccount
        }
    }
}
