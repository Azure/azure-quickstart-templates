<#
.EXAMPLE
    This example includes and excludes provider realms 
    from existing trusted token issuer.
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
        $ProviderRealmsToInclude = @()
        $ProviderRealmsToInclude += MSFT_SPProviderRealm {
                                RealmUrl = "https://search.contoso.com"
                                RealmUrn = "urn:sharepoint:contoso:search"
                                }

        $ProviderRealmsToInclude += MSFT_SPProviderRealm {
                                RealmUrl = "https://intranet.contoso.com"
                                RealmUrn = "urn:sharepoint:contoso:intranet"
                                }

        $ProviderRealmsToExclude = @()
        $ProviderRealmsToExclude += MSFT_SPProviderRealm {
                                RealmUrl = "https://search1.contoso.com"
                                RealmUrn = "urn:sharepoint:contoso:search1"
                                }

        $ProviderRealmsToExclude += MSFT_SPProviderRealm {
                                RealmUrl = "https://intranet.contoso.com"
                                RealmUrn = "urn:sharepoint:contoso:intranet"
                                }

        SPTrustedIdentityTokenIssuerProviderRealms Farm1IncludeExcludeExample
        {
            IssuerName               = "Contoso"
            ProviderRealmsToInclude  = $ProviderRealmsToInclude
            ProviderRealmsToExclude  = $ProviderRealmsToExclude
            Ensure                   = "Present"
            PsDscRunAsCredential     = $SetupAccount
        }
    }
}
