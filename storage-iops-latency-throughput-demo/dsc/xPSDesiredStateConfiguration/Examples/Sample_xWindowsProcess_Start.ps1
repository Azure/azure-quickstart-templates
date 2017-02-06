<#
    .SYNOPSIS
        Starts the gpresult process which generates a log about the group policy.
        The path to the log is provided in 'Arguments'.
#>
Configuration Sample_xWindowsProcess_Start
{
    param
    ()

    Import-DSCResource -ModuleName 'xPSDesiredStateConfiguration'

    Node localhost
    {
        xWindowsProcess GPresult
        {
            Path = 'C:\Windows\System32\gpresult.exe'
            Arguments = '/h C:\gp2.htm'
            Ensure = 'Present'
        }
    }
}

Sample_xWindowsProcess_Start

