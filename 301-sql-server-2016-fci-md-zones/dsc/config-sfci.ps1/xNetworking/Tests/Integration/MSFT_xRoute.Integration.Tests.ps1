$script:DSCModuleName      = 'xNetworking'
$script:DSCResourceName    = 'MSFT_xRoute'

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
    $InterfaceAlias = (Get-NetAdapter -Physical | Select-Object -First 1).Name
    $TestRoute = [PSObject]@{
        InterfaceAlias          = $InterfaceAlias
        AddressFamily           = 'IPv4'
        DestinationPrefix       = '10.0.0.0/8'
        NextHop                 = '10.0.1.0'
        RouteMetric             = 200
        Publish                 = 'No'
    }

    $ConfigFile = Join-Path -Path $PSScriptRoot -ChildPath "$($script:DSCResourceName)_Add.config.ps1"
    . $ConfigFile -Verbose -ErrorAction Stop

    Describe "$($script:DSCResourceName)_Add_Integration" {
        #region DEFAULT TESTS
        It 'Should compile without throwing' {
            {
                & "$($script:DSCResourceName)_Add_Config" -OutputPath $TestEnvironment.WorkingFolder
                Start-DscConfiguration -Path $TestEnvironment.WorkingFolder -ComputerName localhost -Wait -Verbose -Force
            } | Should not throw
        }

        It 'should be able to call Get-DscConfiguration without throwing' {
            { Get-DscConfiguration -Verbose -ErrorAction Stop } | Should Not throw
        }
        #endregion

        It 'Should have set the resource and all the parameters should match' {
            $current = Get-DscConfiguration | Where-Object {$_.ConfigurationName -eq "$($script:DSCResourceName)_Add_Config"}
            $current.InterfaceAlias    | Should Be $TestRoute.InterfaceAlias
            $current.AddressFamily     | Should Be $TestRoute.AddressFamily
            $current.DestinationPrefix | Should Be $TestRoute.DestinationPrefix
            $current.NextHop           | Should Be $TestRoute.NextHop
            $current.Ensure            | Should Be 'Present'
            $current.RouteMetric       | Should Be $TestRoute.RouteMetric
            $current.Publish           | Should Be $TestRoute.Publish
        }
    }

    # This is a dummy route that will be added to ensure that only a specific route
    # is deleted by the resource.
    $DummyRoute = [PSObject]@{
        InterfaceAlias          = $InterfaceAlias
        AddressFamily           = 'IPv4'
        DestinationPrefix       = '11.0.0.0/8'
        NextHop                 = '11.0.1.0'
        RouteMetric             = 200
    }
    $null = New-NetRoute @DummyRoute

    $ConfigFile = Join-Path -Path $PSScriptRoot -ChildPath "$($script:DSCResourceName)_Remove.config.ps1"
    . $ConfigFile -Verbose -ErrorAction Stop

    Describe "$($script:DSCResourceName)_Remove_Integration" {
        #region DEFAULT TESTS
        It 'Should compile without throwing' {
            {
                & "$($script:DSCResourceName)_Remove_Config" -OutputPath $TestEnvironment.WorkingFolder
                Start-DscConfiguration -Path $TestEnvironment.WorkingFolder -ComputerName localhost -Wait -Verbose -Force
            } | Should not throw
        }

        It 'should be able to call Get-DscConfiguration without throwing' {
            { Get-DscConfiguration -Verbose -ErrorAction Stop } | Should Not throw
        }
        #endregion

        It 'Should have set the resource and all the parameters should match' {
            $current = Get-DscConfiguration | Where-Object {$_.ConfigurationName -eq "$($script:DSCResourceName)_Remove_Config"}
            $current.InterfaceAlias    | Should Be $TestRoute.InterfaceAlias
            $current.AddressFamily     | Should Be $TestRoute.AddressFamily
            $current.DestinationPrefix | Should Be $TestRoute.DestinationPrefix
            $current.NextHop           | Should Be $TestRoute.NextHop
            $current.Ensure            | Should Be 'Absent'
        }

        It 'Should not delete the dummy route' {
            Get-NetRoute @DummyRoute | Should Not BeNullOrEmpty
        }
    }
    #endregion
}
finally
{
    # Clean up any created routes just in case the integration tests fail
    $null = Remove-NetRoute @DummyRoute `
        -Confirm:$false `
        -ErrorAction SilentlyContinue
    $null = Remove-NetRoute `
        -InterfaceAlias $TestRoute.InterfaceAlias `
        -AddressFamily $TestRoute.AddressFamily `
        -DestinationPrefix $TestRoute.DestinationPrefix `
        -NextHop $TestRoute.NextHop `
        -Confirm:$false `
        -ErrorAction SilentlyContinue

    #region FOOTER
    Restore-TestEnvironment -TestEnvironment $TestEnvironment
    #endregion
}
