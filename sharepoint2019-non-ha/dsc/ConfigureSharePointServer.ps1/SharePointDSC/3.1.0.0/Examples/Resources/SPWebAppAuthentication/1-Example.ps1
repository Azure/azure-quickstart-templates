<#
.EXAMPLE
    This example shows how to configure the authentication of a web application in the local farm using a custom
    claim provider. A SPTrustedIdentityTokenIssuer is created named Contoso, then this SPTrustedIdentityTokenIssuer
    is referenced by the SPWebAppAuthentication as the AuthenticationProvider and the AuthenticationMethod is set
    to "Federated" value.
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

            SPWebAppAuthentication ContosoAuthentication
            {
                WebAppUrl   = "http://sharepoint.contoso.com"
                Default = @(
                    MSFT_SPWebAppAuthenticationMode {
                        AuthenticationMethod = "NTLM"
                    }
                )
                Extranet = @(
                    MSFT_SPWebAppAuthenticationMode {
                        AuthenticationMethod = "FBA"
                        MembershipProvider = "MemberPRovider"
                        RoleProvider = "RoleProvider"
                    }
                )
            }
        }
    }
