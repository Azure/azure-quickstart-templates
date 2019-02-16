<#
.EXAMPLE

    This example shows how to remove a specific Access Services 2010 from the local 
    SharePoint farm. Because Application pool is a required parameters, but is not 
    acutally needed to remove the app, any text value can be supplied for these as 
    they will be ignored. 
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
            SPAccessServices2010 Access2010Services
            {
                Name                 = "Access 2010 Services Service Application"
                ApplicationPool      = "n/a" 
                Ensure               = "Absent"
                PsDscRunAsCredential = $SetupAccount
            }
        }
    }
