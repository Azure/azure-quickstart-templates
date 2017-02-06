<#
    .SYNOPSIS
        Starts the processes with the executables at the file paths C:\Windows\cmd.exe and
        C:\TestPath\TestProcess.exe with no arguments.
#>
Configuration Sample_xProcessSet_Start
{
    [CmdletBinding()]
    param ()

    Import-DscResource -ModuleName 'xPSDesiredStateConfiguration'

    xProcessSet xProcessSet1
    {
        Path = @( 'C:\Windows\System32\cmd.exe', 'C:\TestPath\TestProcess.exe' )
        Ensure = 'Present'
    }
}
