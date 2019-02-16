<#
.EXAMPLE
    This module will install SharePoint to the default locations. The binaries for
    SharePoint in this scenario are stored at C:\SPInstall (so it will look to run
    C:\SPInstall\Setup.exe)
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
                BinaryDir        = "C:\SPInstall"
                ProductKey       = "XXXXX-XXXXX-XXXXX-XXXXX-XXXXX"
            }
        }
    }
