<#
.EXAMPLE
    This example deploys/updates the WorkEmail2 property in the user profile service
    app
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

        SPUserProfileProperty WorkEmailProperty
        {
            Name                 = "WorkEmail2"
            Ensure               = "Present"
            UserProfileService   = "User Profile Service Application"
            DisplayName          = "Work Email"
            Type                 = "Email"
            Description          = "" #implementation isn't using it yet
            PolicySetting        = "Mandatory"
            PrivacySetting       = "Public"
            PropertyMappings     = @(
                MSFT_SPUserProfilePropertyMapping {
                    ConnectionName = "contoso.com"
                    PropertyName   = "mail"
                    Direction      = "Import"
                }
            )
            Length               = 10
            DisplayOrder         = 25
            IsEventLog           = $false
            IsVisibleOnEditor    = $true
            IsVisibleOnViewer    = $true
            IsUserEditable       = $true
            IsAlias              = $false
            IsSearchable         = $false
            TermStore            = ""
            TermGroup            = ""
            TermSet              = ""
            UserOverridePrivacy  = $false
            PsDscRunAsCredential = $SetupAccount
        }
    }
}
