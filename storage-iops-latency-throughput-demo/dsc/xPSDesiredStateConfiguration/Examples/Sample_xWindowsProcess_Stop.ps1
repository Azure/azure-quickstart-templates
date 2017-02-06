<#
    .SYNOPSIS
        Stops the gpresult process if it is running. 
        Since the Arguments parameter isn't needed to stop the process,
        an empty string is passed in.
#>
Configuration Sample_xWindowsProcess_Stop
{
    param
    ()

    Import-DSCResource -ModuleName 'xPSDesiredStateConfiguration'

    Node localhost
    {
        xWindowsProcess GPresult
        {
            Path = 'C:\Windows\System32\gpresult.exe'
            Arguments = ''
            Ensure = 'Absent'
        }
    }
}
 
Sample_xWindowsProcess_Stop

