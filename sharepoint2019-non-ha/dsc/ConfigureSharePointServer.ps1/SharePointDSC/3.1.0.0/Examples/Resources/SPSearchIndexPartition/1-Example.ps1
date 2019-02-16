<#
.EXAMPLE
    This example adds an extra search partition to the local farms topology
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
            SPSearchIndexPartition AdditionalPartition
            {
                Servers              = @("Server2", "Server3")
                Index                = 1
                RootDirectory        = "I:\SearchIndexes\1"
                ServiceAppName       = "Search Service Application"
                PsDscRunAsCredential = $SetupAccount
            }
        }
    }
