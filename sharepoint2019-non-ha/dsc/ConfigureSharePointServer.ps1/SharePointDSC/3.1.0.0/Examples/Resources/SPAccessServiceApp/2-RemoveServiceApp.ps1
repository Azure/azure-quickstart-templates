<#
.EXAMPLE

    This example shows how to remove a specific Access Services 2013 from the local 
    SharePoint farm. Because Application pool and database server are both required
    parameters, but are not acutally needed to remove the app, any text value can 
    be supplied for these as they will be ignored. 
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
            SPAccessServiceApp AccessServices
            {
                Name                 = "Access Services Service Application"
                ApplicationPool      = "n/a" 
                DatabaseServer       = "n/a"
                Ensure               = "Absent"
                PsDscRunAsCredential = $SetupAccount
            }
        }
    }
