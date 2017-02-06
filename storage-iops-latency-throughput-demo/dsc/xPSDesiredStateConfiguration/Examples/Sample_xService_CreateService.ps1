<#
    .SYNOPSIS
        If the service with the name Service1 does not exist, creates the service with the name
        Service1 and the executable/binary path 'C:\FilePath\MyServiceExecutable.exe'. The new
        service will be started by default.

        If the service with the name Service1 already exists, sets executable/binary path of the
        service with the name Service1 to 'C:\FilePath\MyServiceExecutable.exe' and starts the
        service by default if it is not running already.
#>
Configuration Sample_xService_CreateService
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
            Ensure = 'Present'
            Path = 'C:\FilePath\MyServiceExecutable.exe'
        }
    }
}
