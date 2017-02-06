<#
    .SYNOPSIS
        Removes the environment variable 'TestEnvironmentVariable' from
        both the machine and the process.
#>
Configuration Sample_xEnvironment_Remove 
{
    param ()

    Import-DscResource -ModuleName 'xPSDesiredStateConfiguration'

    Node localhost
    {
        xEnvironment RemoveEnvironmentVariable
        {
            Name = 'TestEnvironmentVariable'
            Ensure = 'Absent'
            Path = $false
            Target = @('Process', 'Machine')
        }
    }
}

Sample_xEnvironment_Remove
