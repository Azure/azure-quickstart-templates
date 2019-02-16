<#
.EXAMPLE
    This example installs the Cumulative Update only in the specified window.
    It also shuts down services to speed up the installation process.
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
            SPProductUpdate InstallCUMay2016
            {
                SetupFile            = "C:\Install\CUMay2016\ubersrv2013-kb3115029-fullfile-x64-glb.exe"
                ShutdownServices     = $true
                BinaryInstallDays    = "sat", "sun"
                BinaryInstallTime    = "12:00am to 2:00am"
                Ensure               = "Present"
                PsDscRunAsCredential = $SetupAccount
            }
        }
    }
