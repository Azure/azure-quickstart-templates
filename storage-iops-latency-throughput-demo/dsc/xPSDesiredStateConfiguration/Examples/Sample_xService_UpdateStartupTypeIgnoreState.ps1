<#
    .SYNOPSIS
        If the service with the name Service1 does not exist, this configuration would throw an
        error since the Path is not included here.

        If the service with the name Service1 already exists, sets the startup type of the service
        with the name Service1 to Manual and ignores the state that the service is currently in.
        If State is not specified, the configuration will ensure that the state of the service is
        Running by default.
#>
Configuration Sample_xService_UpdateStartupTypeIgnoreState
{
    [CmdletBinding()]
    param ()

    Import-DscResource -ModuleName 'xPSDesiredStateConfiguration'

    Node localhost
    {
        xService ServiceResource1
        {
            Name = 'Service1'
            Ensure = 'Present'
            StartupType = 'Manual'
            State = 'Ignore'
        }
    }
}
