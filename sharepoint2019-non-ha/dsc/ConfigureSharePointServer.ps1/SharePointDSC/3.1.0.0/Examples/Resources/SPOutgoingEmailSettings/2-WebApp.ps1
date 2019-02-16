<#
.EXAMPLE
    This example shows to set outgoing email settings for a specific web app
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
            SPOutgoingEmailSettings FarmWideEmailSettings
            {
                WebAppUrl             = "http://site.contoso.com"
                SMTPServer            = "smtp.contoso.com"
                FromAddress           = "sharepoint`@contoso.com"
                ReplyToAddress        = "noreply`@contoso.com"
                CharacterSet          = "65001"
                PsDscRunAsCredential  = $SetupAccount
            }
        }
    }
