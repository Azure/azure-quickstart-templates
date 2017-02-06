<#
    .SYNOPSIS
        Stops the processes with the executables at the file paths C:\Windows\cmd.exe and
        C:\TestPath\TestProcess.exe with no arguments and logs any output to the path
        C:\OutputPath\Output.log.
#>
Configuration Sample_xProcessSet_Stop
{
    [CmdletBinding()]
    param ()

    Import-DscResource -ModuleName 'xPSDesiredStateConfiguration'

    xProcessSet xProcessSet1
    {
        Path = @( 'C:\Windows\System32\cmd.exe', 'C:\TestPath\TestProcess.exe' )
        Ensure = 'Absent'
        StandardOutputPath = 'C:\OutputPath\Output.log'
    }
}
