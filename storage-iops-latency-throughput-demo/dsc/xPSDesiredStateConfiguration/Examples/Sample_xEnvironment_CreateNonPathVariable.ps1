<#
    .SYNOPSIS
        Creates the environment variable 'TestEnvironmentVariable' and sets the value to 'TestValue'
        both on the machine and within the process.
#>
Configuration Sample_xEnvironment_CreateNonPathVariable 
{
    param ()

    Import-DscResource -ModuleName 'xPSDesiredStateConfiguration'

    Node localhost
    {
        xEnvironment CreateEnvironmentVariable
        {
            Name = 'TestEnvironmentVariable'
            Value = 'TestValue'
            Ensure = 'Present'
            Path = $false
            Target = @('Process', 'Machine')
        }
    }
}

Sample_xEnvironment_CreateNonPathVariable
