<#
    .SYNOPSIS
        Creates the environment variable 'TestPathEnvironmentVariable' and sets the value to 'TestValue'
        if it doesn't already exist or appends the value 'TestValue' to the existing path if it does
        already exist on the machine and within the process.
#>
Configuration Sample_xEnvironment_CreatePathVariable 
{
    param ()

    Import-DscResource -ModuleName 'xPSDesiredStateConfiguration'

    Node localhost
    {
        xEnvironment CreatePathEnvironmentVariable
        {
            Name = 'TestPathEnvironmentVariable'
            Value = 'TestValue'
            Ensure = 'Present'
            Path = $true
            Target = @('Process', 'Machine')
        }
    }
}

Sample_xEnvironment_CreatePathVariable
