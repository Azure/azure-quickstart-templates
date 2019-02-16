<#
.EXAMPLE
    This module will install the SharePoint Language Pack in the specified timeframe.
    The binaries for SharePoint in this scenario are stored at C:\SPInstall (so it
    will look to run C:\SPInstall\Setup.exe)
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
            SPInstallLanguagePack InstallLPBinaries
            {
                BinaryDir         = "C:\SPInstall"
                BinaryInstallDays = "sat", "sun"
                BinaryInstallTime = "12:00am to 2:00am"
                Ensure            = "Present"
            }
        }
    }
