<#
    .SYNOPSIS
        Sets the Secure Socket Tunneling Protocol and DHCP Client services to run under the
        built-in account LocalService.
#>
Configuration xServiceSetBuiltInAccountExample
{
    Import-DscResource -ModuleName 'xPSDesiredStateConfiguration'

    xServiceSet ServiceSet1
    {
        Name           = @( 'SstpSvc', 'Dhcp'  )
        Ensure         = 'Present'
        BuiltInAccount = 'LocalService'
        State          = 'Ignore'
    }
}
