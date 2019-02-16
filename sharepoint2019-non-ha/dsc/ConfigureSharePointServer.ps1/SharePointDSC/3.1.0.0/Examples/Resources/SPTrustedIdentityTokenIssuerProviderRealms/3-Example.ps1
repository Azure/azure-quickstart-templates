<#
.EXAMPLE
    This example excludes provider realms from 
    existing trusted token issuer.
    Existing and not excluded are left and not removed.
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
        $ProviderRealmsToExclude = @()
        $ProviderRealmsToExclude += MSFT_SPProviderRealm {
                                RealmUrl = "https://search.contoso.com"
                                RealmUrn = "urn:sharepoint:contoso:search"
                                }

        $ProviderRealmsToExclude += MSFT_SPProviderRealm {
                                RealmUrl = "https://intranet.contoso.com"
                                RealmUrn = "urn:sharepoint:contoso:intranet"
                                }

        SPTrustedIdentityTokenIssuerProviderRealms Farm1ExcludeExample
        {
            IssuerName               = "Contoso"
            ProviderRealmsToExclude  = $ProviderRealmsToExclude
            Ensure                   = "Present"
            PsDscRunAsCredential     = $SetupAccount
        }
    }
}
