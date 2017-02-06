<#
    .SYNOPSIS
        Ensures that the DHCP Client and Windows Firewall services are running.
#>
Configuration xServiceSetStartExample
{
    Import-DscResource -ModuleName 'xPSDesiredStateConfiguration'

    xServiceSet ServiceSet1
    {
        Name   = @( 'Dhcp', 'MpsSvc' )
        Ensure = 'Present'
        State  = 'Running'
    }
}
