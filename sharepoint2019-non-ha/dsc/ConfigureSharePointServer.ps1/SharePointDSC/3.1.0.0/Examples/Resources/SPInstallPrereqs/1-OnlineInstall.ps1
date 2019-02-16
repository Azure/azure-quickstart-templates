<#
.EXAMPLE
    This module will install the prerequisites for SharePoint. This resource will run in
    online mode, looking to download all prerequisites from the internet.
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
            SPInstallPrereqs InstallPrerequisites
            {
                IsSingleInstance  = "Yes"
                InstallerPath     = "C:\SPInstall\Prerequisiteinstaller.exe"
                OnlineMode        = $true
            }
        }
    }
