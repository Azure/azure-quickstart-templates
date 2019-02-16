<#
.EXAMPLE
    This module will install the SharePoint Language Pack. The binaries for
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
            SPInstallLanguagePack InstallLPBinaries
            {
                BinaryDir  = "C:\SPInstall"
                Ensure     = "Present"
            }
        }
    }
