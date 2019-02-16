<#
.EXAMPLE
    This example shows how to configure the blob cache settings on the local server for the
    specified web application and zone 
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
            SPBlobCacheSettings BlobCacheSettings 
            {
                WebAppUrl = "http://intranet.contoso.com"
                Zone = "Default"
                EnableCache = $true
                Location = "F:\BlobCache"
                MaxSizeInGB = 10
                FileTypes = "\.(gif|jpg|png|css|js)$"
                PsDscRunAsCredential = $SetupAccount
            }
        }
    }
