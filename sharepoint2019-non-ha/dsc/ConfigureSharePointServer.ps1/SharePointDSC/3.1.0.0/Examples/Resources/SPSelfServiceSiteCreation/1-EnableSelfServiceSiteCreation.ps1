<#
.EXAMPLE
    This example shows how to configure self-service site creation for a web application
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
            SPSelfServiceSiteCreation SSC
            {
                WebAppUrl               = "http://example.contoso.local"
                Enabled                 = $true
                OnlineEnabled           = $false
                QuotaTemplate           = "SSCQoutaTemplate"
                ShowStartASiteMenuItem  = $true
                CreateIndividualSite    = $true
                PolicyOption            = "CanHavePolicy"
                RequireSecondaryContact = $false
                PsDscRunAsCredential    = $SetupAccount
            }
        }
    }
