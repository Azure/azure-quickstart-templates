<#
.EXAMPLE
    This example shows how create a new Managed Property, using the required parameters
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
            SPSearchManagedProperty MyProperty
            {
                Name = "MyProperty"
                ServiceAppName = "Search Service Application"
                PropertyType = "Text"
                Searchable = $true
                IncludeAllCrawledProperties = $false
                CrawledProperties = @("OWS_Notes, Personal:AboutMe")
                PsDscRunAsCredential = $SetupAccount
            }
        }
    }
