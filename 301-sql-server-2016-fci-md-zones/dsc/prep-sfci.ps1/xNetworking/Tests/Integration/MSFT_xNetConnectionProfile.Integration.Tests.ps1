$script:DSCModuleName      = 'xNetworking'
$script:DSCResourceName    = 'MSFT_xNetConnectionProfile'

#region HEADER
# Integration Test Template Version: 1.1.0
[String] $script:moduleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
if ( (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests'))) -or `
     (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1'))) )
{
    & git @('clone','https://github.com/PowerShell/DscResource.Tests.git',(Join-Path -Path $script:moduleRoot -ChildPath '\DSCResource.Tests\'))
}

Import-Module (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1') -Force
$TestEnvironment = Initialize-TestEnvironment `
    -DSCModuleName $script:DSCModuleName `
    -DSCResourceName $script:DSCResourceName `
    -TestType Integration
#endregion

# Using try/finally to always cleanup even if something awful happens.
try
{
    #region Integration Tests
    $ConfigFile = Join-Path -Path $PSScriptRoot -ChildPath "$($script:DSCResourceName).config.ps1"
    . $ConfigFile -Verbose -ErrorAction Stop

    Describe "$($script:DSCResourceName)_Integration" {
        #region DEFAULT TESTS
        It 'Should compile without throwing' {
            {
                & "$($script:DSCResourceName)_Config" -OutputPath $TestEnvironment.WorkingFolder
                Start-DscConfiguration -Path $TestEnvironment.WorkingFolder -ComputerName localhost -Wait -Verbose -Force
            } | Should not throw
        }

        It 'should be able to call Get-DscConfiguration without throwing' {
            { Get-DscConfiguration -Verbose -ErrorAction Stop } | Should Not throw
        }
        #endregion

        It 'Should have set the resource and all the parameters should match' {
            $current = Get-DscConfiguration | Where-Object {$_.ConfigurationName -eq "$($script:DSCResourceName)_Config"}
            $rule.InterfaceAlias   | Should Be $current.InterfaceAlias
            $rule.NetworkCategory  | Should Be $current.NetworkCategory
            $rule.IPv4Connectivity | Should Be $current.IPv4Connectivity
            $rule.IPv6Connectivity | Should Be $current.IPv6Connectivity
            $rule.Address          | Should Be $current.Address
            $rule.AddressFamily    | Should Be $current.AddressFamily
        }
    }
    #endregion
}
finally
{
    #region FOOTER
    Restore-TestEnvironment -TestEnvironment $TestEnvironment
    #endregion
}
