<#
.EXAMPLE
    This module will install SharePoint Foundation 2013 to the local server
#>

    Configuration Example
    {
        param(
            [Parameter(Mandatory = $true)]
            [PSCredential]
            $SetupAccount
        )
        Import-DscResource -ModuleName PSDesiredStateConfiguration

        node localhost {
            Package InstallSharePointFoundation
            {
                Ensure             = "Present"
                Name               = "Microsoft SharePoint Foundation 2013 Core"
                Path               = "E:\SharePoint2013\Setup.exe"
                Arguments          = "/config E:\SharePoint2013\files\setupfarmsilent\config.xml"
                ProductID          = "90150000-1014-0000-1000-0000000FF1CE"
                ReturnCode         = 0
            }
        }
    }
