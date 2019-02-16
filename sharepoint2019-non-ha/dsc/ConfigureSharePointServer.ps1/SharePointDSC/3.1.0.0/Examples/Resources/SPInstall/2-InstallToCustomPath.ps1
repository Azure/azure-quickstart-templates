<#
.EXAMPLE
    This module will install SharePoint to the specific locations set for the
    InstallPath and DataPath directories.
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
            SPInstall InstallBinaries
            {
                IsSingleInstance = "Yes"
                BinaryDir        = "D:\SharePoint\Binaries"
                InstallPath      = "D:\SharePoint\Install"
                DataPath         = "D:\SharePoint\Data"
                ProductKey       = "XXXXX-XXXXX-XXXXX-XXXXX-XXXXX"
            }
        }
    }
