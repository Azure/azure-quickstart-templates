<#
.EXAMPLE
    This example configures the Security Token Service
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
            SPSecurityTokenServiceConfig SecurityTokenService
            {
                IsSingleInstance      = "Yes"
                Name                  = "SPSecurityTokenService"
                NameIdentifier        = "00000003-0000-0ff1-ce00-000000000000@9f11c5ea-2df9-4950-8dcf-da8cd7aa4eff"
                UseSessionCookies     = $false
                AllowOAuthOverHttp    = $false
                AllowMetadataOverHttp = $false
                PsDscRunAsCredential  = $SetupAccount
            }
        }
    }
