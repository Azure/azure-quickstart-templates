<#
.EXAMPLE
    This module will install the prerequisites for SharePoint 2016/2019. This resource will run in
    offline mode, running all prerequisite installations from the specified paths.
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
                OnlineMode        = $false
                SXSpath           = "C:\SPInstall\Windows2012r2-SXS"
                SQLNCli           = "C:\SPInstall\prerequisiteinstallerfiles\sqlncli.msi"
                Sync              = "C:\SPInstall\prerequisiteinstallerfiles\Synchronization.msi"
                AppFabric         = "C:\SPInstall\prerequisiteinstallerfiles\WindowsServerAppFabricSetup_x64.exe"
                IDFX11            = "C:\SPInstall\prerequisiteinstallerfiles\MicrosoftIdentityExtensions-64.msi"
                MSIPCClient       = "C:\SPInstall\prerequisiteinstallerfiles\setup_msipc_x64.msi"
                WCFDataServices56 = "C:\SPInstall\prerequisiteinstallerfiles\WcfDataServices56.exe"
                MSVCRT11          = "C:\SPInstall\prerequisiteinstallerfiles\vcredist_x64.exe"
                MSVCRT14          = "C:\SPInstall\prerequisiteinstallerfiles\vc_redist.x64.exe"
                KB3092423         = "C:\SPInstall\prerequisiteinstallerfiles\AppFabric-KB3092423-x64-ENU.exe"
                ODBC              = "C:\SPInstall\prerequisiteinstallerfiles\msodbcsql.msi"
                DotNetFx          = "C:\SPInstall\prerequisiteinstallerfiles\NDP46-KB3045557-x86-x64-AllOS-ENU.exe"
            }
        }
    }
