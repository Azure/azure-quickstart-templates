<#
.EXAMPLE
    This example shows how to apply settings to a specific file type in search, using the required parameters
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
            SPSearchFileType PDF
            {
                FileType = "pdf"
                ServiceAppName = "Search Service Application"
                Description = "PDF"
                MimeType = "application/pdf"
                Ensure = "Present"
                PsDscRunAsCredential = $SetupAccount
            }
        }
    }
