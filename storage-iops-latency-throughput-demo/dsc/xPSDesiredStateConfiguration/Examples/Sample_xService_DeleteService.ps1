<#
    .SYNOPSIS
        Stops and then removes the service with the name Service1.
#>
Configuration Sample_xService_DeleteService
{
    [CmdletBinding()]
    param
    ()

    Import-DscResource -ModuleName 'xPSDesiredStateConfiguration'

    Node localhost
    {
        xService ServiceResource1
        {
            Name = 'Service1'
            Ensure = 'Absent'
        }
    }
}
