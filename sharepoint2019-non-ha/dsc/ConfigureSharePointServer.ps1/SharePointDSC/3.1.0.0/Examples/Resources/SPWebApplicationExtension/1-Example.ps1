<#
.EXAMPLE
    This example shows how to create a new web application extension in the local farm
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
            SPWebApplicationExtension IntranetZone
            {
                WebAppUrl              = "http://example.contoso.local"
                Name                   = "Contoso Intranet Zone"
                AllowAnonymous         = $false
                Url                    = "http://intranet.contoso.local"
                Zone                   = "Intranet"
                HostHeader             = "intranet.contoso.local"
                Path                   = "c:\inetpub\wwwroot\wss\VirtualDirectories\intranet"
                UseSSL                 = $false
                Port                   = 80
                Ensure                 = "Present"
                PsDscRunAsCredential   = $SetupAccount
            }
        }
    }
