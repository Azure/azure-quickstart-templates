<#
.EXAMPLE
    This example shows to set outgoing email settings for the entire farm. Use the URL
    of the central admin site for the web app URL to apply for the entire farm.
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
                WebAppUrl             = "http://sharepoint1:2013"
                SMTPServer            = "smtp.contoso.com"
                FromAddress           = "sharepoint`@contoso.com"
                ReplyToAddress        = "noreply`@contoso.com"
                CharacterSet          = "65001"
                PsDscRunAsCredential  = $SetupAccount
            }
        }
    }
