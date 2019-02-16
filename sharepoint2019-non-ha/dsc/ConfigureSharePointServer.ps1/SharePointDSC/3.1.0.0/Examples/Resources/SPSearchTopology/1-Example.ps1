<#
.EXAMPLE
    This example shows how to apply a specific topology to the search service app
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
            SPSearchTopology LocalSearchTopology
            {
                ServiceAppName          = "Search Service Application"
                Admin                   = @("Server1","Server2")
                Crawler                 = @("Server1","Server2")
                ContentProcessing       = @("Server1","Server2")
                AnalyticsProcessing     = @("Server1","Server2")
                QueryProcessing         = @("Server3","Server4")
                PsDscRunAsCredential    = $SetupAccount
                FirstPartitionDirectory = "I:\SearchIndexes\0"
                IndexPartition          = @("Server3","Server4")
            }
        }
    }
