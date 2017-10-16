$script:DSCModuleName   = 'xNetworking'
$script:DSCResourceName = 'MSFT_xRoute'

#region HEADER
# Unit Test Template Version: 1.1.0
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
    -TestType Unit
#endregion HEADER

# Begin Testing
try
{
    #region Pester Tests
    InModuleScope $script:DSCResourceName {

        # Create the Mock Objects that will be used for running tests
        $MockNetAdapter = [PSCustomObject] @{
            Name                    = 'Ethernet'
        }

        $TestRoute = [PSObject]@{
            InterfaceAlias          = $MockNetAdapter.Name
            AddressFamily           = 'IPv4'
            DestinationPrefix       = '10.0.0.1/8'
            NextHop                 = '10.0.0.2'
            Ensure                  = 'Present'
            RouteMetric             = 200
            Publish                 = 'Age'
            PreferredLifetime       = 50000
        }

        $TestRouteKeys = [PSObject]@{
            InterfaceAlias          = $MockNetAdapter.Name
            AddressFamily           = $TestRoute.AddressFamily
            DestinationPrefix       = $TestRoute.DestinationPrefix
            NextHop                 = $TestRoute.NextHop
        }

        $MockRoute = [PSObject]@{
            InterfaceAlias          = $MockNetAdapter.Name
            AddressFamily           = $TestRoute.AddressFamily
            DestinationPrefix       = $TestRoute.DestinationPrefix
            NextHop                 = $TestRoute.NextHop
            Ensure                  = $TestRoute.Ensure
            RouteMetric             = $TestRoute.RouteMetric
            Publish                 = $TestRoute.Publish
            PreferredLifetime       = ([Timespan]::FromSeconds($TestRoute.PreferredLifetime))
        }

        Describe "MSFT_xRoute\Get-TargetResource" {

            Context 'Route does not exist' {

                Mock Get-NetRoute

                It 'should return absent Route' {
                    $Result = Get-TargetResource `
                        @TestRouteKeys
                    $Result.Ensure | Should Be 'Absent'
                }
                It 'should call the expected mocks' {
                    Assert-MockCalled -commandName Get-NetRoute -Exactly 1
                }
            }

            Context 'Route does exist' {

                Mock Get-NetRoute -MockWith { $MockRoute }

                It 'should return correct Route' {
                    $Result = Get-TargetResource `
                        @TestRouteKeys
                    $Result.Ensure            | Should Be 'Present'
                    $Result.InterfaceAlias    | Should Be $TestRoute.InterfaceAlias
                    $Result.AddressFamily     | Should Be $TestRoute.AddressFamily
                    $Result.DestinationPrefix | Should Be $TestRoute.DestinationPrefix
                    $Result.NextHop           | Should Be $TestRoute.NextHop
                    $Result.RouteMetric       | Should Be $TestRoute.RouteMetric
                    $Result.Publish           | Should Be $TestRoute.Publish
                    $Result.PreferredLifetime | Should Be $TestRoute.PreferredLifetime
                }
                It 'should call the expected mocks' {
                    Assert-MockCalled -commandName Get-NetRoute -Exactly 1
                }
            }
        }

        Describe "MSFT_xRoute\Set-TargetResource" {

            Context 'Route does not exist but should' {

                Mock Get-NetRoute
                Mock New-NetRoute
                Mock Set-NetRoute
                Mock Remove-NetRoute

                It 'should not throw error' {
                    {
                        $Splat = $TestRoute.Clone()
                        Set-TargetResource @Splat
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-NetRoute -Exactly 1
                    Assert-MockCalled -commandName New-NetRoute -Exactly 1
                    Assert-MockCalled -commandName Set-NetRoute -Exactly 0
                    Assert-MockCalled -commandName Remove-NetRoute -Exactly 0
                }
            }

            Context 'Route exists and should but has a different RouteMetric' {

                Mock Get-NetRoute -MockWith { $MockRoute }
                Mock New-NetRoute
                Mock Set-NetRoute
                Mock Remove-NetRoute

                It 'should not throw error' {
                    {
                        $Splat = $TestRoute.Clone()
                        $Splat.RouteMetric = $Splat.RouteMetric + 10
                        Set-TargetResource @Splat
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-NetRoute -Exactly 1
                    Assert-MockCalled -commandName New-NetRoute -Exactly 0
                    Assert-MockCalled -commandName Set-NetRoute -Exactly 1
                    Assert-MockCalled -commandName Remove-NetRoute -Exactly 0
                }
            }

            Context 'Route exists and should but has a different Publish' {

                Mock Get-NetRoute -MockWith { $MockRoute }
                Mock New-NetRoute
                Mock Set-NetRoute
                Mock Remove-NetRoute

                It 'should not throw error' {
                    {
                        $Splat = $TestRoute.Clone()
                        $Splat.Publish = 'No'
                        Set-TargetResource @Splat
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-NetRoute -Exactly 1
                    Assert-MockCalled -commandName New-NetRoute -Exactly 0
                    Assert-MockCalled -commandName Set-NetRoute -Exactly 1
                    Assert-MockCalled -commandName Remove-NetRoute -Exactly 0
                }
            }

            Context 'Route exists and should but has a different PreferredLifetime' {

                Mock Get-NetRoute -MockWith { $MockRoute }
                Mock New-NetRoute
                Mock Set-NetRoute
                Mock Remove-NetRoute

                It 'should not throw error' {
                    {
                        $Splat = $TestRoute.Clone()
                        $Splat.PreferredLifetime = $TestRoute.PreferredLifetime + 1000
                        Set-TargetResource @Splat
                    } | Should Not Throw
                }
                It 'should call expected mocks' {
                    Assert-MockCalled -commandName Get-NetRoute -Exactly 1
                    Assert-MockCalled -commandName New-NetRoute -Exactly 0
                    Assert-MockCalled -commandName Set-NetRoute -Exactly 1
                    Assert-MockCalled -commandName Remove-NetRoute -Exactly 0
                }
            }

            Context 'Route exists and but should not' {

                Mock Get-NetRoute -MockWith { $MockRoute }
                Mock New-NetRoute
                Mock Set-NetRoute
                Mock Remove-NetRoute `
                    -ParameterFilter {
                        ($InterfaceAlias -eq $TestRoute.InterfaceAlias) -and `
                        ($AddressFamily -eq $TestRoute.AddressFamily) -and `
                        ($DestinationPrefix -eq $TestRoute.DestinationPrefix) -and `
                        ($NextHop -eq $TestRoute.NextHop) -and `
                        ($RouteMetric -eq $TestRoute.RouteMetric)
                    }

                It 'should not throw error' {
                    {
                        $Splat = $TestRoute.Clone()
                        $Splat.Ensure = 'Absent'
                        Set-TargetResource @Splat
                    } | Should Not Throw
                }
                It 'should call expected mocks and parameters' {
                    Assert-MockCalled -commandName Get-NetRoute -Exactly 1
                    Assert-MockCalled -commandName New-NetRoute -Exactly 0
                    Assert-MockCalled -commandName Set-NetRoute -Exactly 0
                    Assert-MockCalled -commandName Remove-NetRoute `
                        -ParameterFilter {
                            ($InterfaceAlias -eq $TestRoute.InterfaceAlias) -and `
                            ($AddressFamily -eq $TestRoute.AddressFamily) -and `
                            ($DestinationPrefix -eq $TestRoute.DestinationPrefix) -and `
                            ($NextHop -eq $TestRoute.NextHop) -and `
                            ($RouteMetric -eq $TestRoute.RouteMetric)
                        } `
                        -Exactly 1
                }
            }

            Context 'Route does not exist and should not' {

                Mock Get-NetRoute
                Mock New-NetRoute
                Mock Set-NetRoute
                Mock Remove-NetRoute

                It 'should not throw error' {
                    {
                        $Splat = $TestRoute.Clone()
                        $Splat.Ensure = 'Absent'
                        Set-TargetResource @Splat
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-NetRoute -Exactly 1
                    Assert-MockCalled -commandName New-NetRoute -Exactly 0
                    Assert-MockCalled -commandName Set-NetRoute -Exactly 0
                    Assert-MockCalled -commandName Remove-NetRoute -Exactly 0
                }
            }
        }

        Describe "MSFT_xRoute\Test-TargetResource" {

            Context 'Route does not exist but should' {

                Mock Get-NetAdapter -MockWith { $MockNetAdapter }
                Mock Get-NetRoute

                It 'should return false' {
                    $Splat = $TestRoute.Clone()
                    Test-TargetResource @Splat | Should Be $False

                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-NetRoute -Exactly 1
                }
            }

            Context 'Route exists and should but has a different RouteMetric' {

                Mock Get-NetAdapter -MockWith { $MockNetAdapter }
                Mock Get-NetRoute -MockWith { $MockRoute }

                It 'should return false' {
                    {
                        $Splat = $TestRoute.Clone()
                        $Splat.RouteMetric = $Splat.RouteMetric + 5
                        Test-TargetResource @Splat | Should Be $False
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-NetRoute -Exactly 1
                }
            }

            Context 'Route exists and should but has a different Publish' {

                Mock Get-NetAdapter -MockWith { $MockNetAdapter }
                Mock Get-NetRoute -MockWith { $MockRoute }

                It 'should return false' {
                    {
                        $Splat = $TestRoute.Clone()
                        $Splat.Publish = 'Yes'
                        Test-TargetResource @Splat | Should Be $False
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-NetRoute -Exactly 1
                }
            }

            Context 'Route exists and should but has a different PreferredLifetime' {

                Mock Get-NetAdapter -MockWith { $MockNetAdapter }
                Mock Get-NetRoute -MockWith { $MockRoute }

                It 'should return false' {
                    {
                        $Splat = $TestRoute.Clone()
                        $Splat.PreferredLifetime = $Splat.PreferredLifetime + 5000
                        Test-TargetResource @Splat | Should Be $False
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-NetRoute -Exactly 1
                }
            }

            Context 'Route exists and should and all parameters match' {

                Mock Get-NetAdapter -MockWith { $MockNetAdapter }
                Mock Get-NetRoute -MockWith { $MockRoute }

                It 'should return true' {
                    {
                        $Splat = $TestRoute.Clone()
                        Test-TargetResource @Splat | Should Be $True
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-NetRoute -Exactly 1
                }
            }

            Context 'Route exists but should not' {

                Mock Get-NetAdapter -MockWith { $MockNetAdapter }
                Mock Get-NetRoute -MockWith { $MockRoute }

                It 'should return false' {
                    {
                        $Splat = $TestRoute.Clone()
                        $Splat.Ensure = 'Absent'
                    Test-TargetResource @Splat | Should Be $False
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-NetRoute -Exactly 1
                }
            }

            Context 'Route does not exist and should not' {

                Mock Get-NetAdapter -MockWith { $MockNetAdapter }
                Mock Get-NetRoute

                It 'should return true' {
                    {
                        $Splat = $TestRoute.Clone()
                        $Splat.Ensure = 'Absent'
                        Test-TargetResource @Splat | Should Be $True
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-NetRoute -Exactly 1
                }
            }
        }

        Describe "MSFT_xRoute\Test-ResourceProperty" {

            Context 'invoking with bad interface alias' {

                Mock Get-NetAdapter

                It 'should throw an InterfaceNotAvailable error' {
                    $errorId = 'InterfaceNotAvailable'
                    $errorCategory = [System.Management.Automation.ErrorCategory]::DeviceError
                    $errorMessage = $($LocalizedData.InterfaceNotAvailableError) -f $TestRoute.InterfaceAlias
                    $exception = New-Object -TypeName System.InvalidOperationException `
                        -ArgumentList $errorMessage
                    $errorRecord = New-Object -TypeName System.Management.Automation.ErrorRecord `
                        -ArgumentList $exception, $errorId, $errorCategory, $null

                    { Test-ResourceProperty @TestRoute } | Should Throw $ErrorRecord
                }
            }

            Context 'invoking with bad IPv4 DestinationPrefix address' {

                Mock Get-NetAdapter -MockWith { $MockNetAdapter }

                It 'should throw an AddressFormatError error' {
                    $Splat = $TestRoute.Clone()
                    $Splat.DestinationPrefix = '10.0.300.0/24'
                    $Splat.NextHop = '10.0.1.0'
                    $Splat.AddressFamily = 'IPv4'

                    $errorId = 'AddressFormatError'
                    $errorCategory = [System.Management.Automation.ErrorCategory]::DeviceError
                    $errorMessage = $($LocalizedData.AddressFormatError) -f '10.0.300.0'
                    $exception = New-Object -TypeName System.InvalidOperationException `
                        -ArgumentList $errorMessage
                    $errorRecord = New-Object -TypeName System.Management.Automation.ErrorRecord `
                        -ArgumentList $exception, $errorId, $errorCategory, $null

                    { Test-ResourceProperty @Splat } | Should Throw $ErrorRecord
                }
            }

            Context 'invoking with bad IPv6 DestinationPrefix address' {

                Mock Get-NetAdapter -MockWith { $MockNetAdapter }

                It 'should throw an AddressFormatError error' {
                    $Splat = $TestRoute.Clone()
                    $Splat.DestinationPrefix = 'fe8x::/64'
                    $Splat.NextHop = 'fe90::'
                    $Splat.AddressFamily = 'IPv6'

                    $errorId = 'AddressFormatError'
                    $errorCategory = [System.Management.Automation.ErrorCategory]::DeviceError
                    $errorMessage = $($LocalizedData.AddressFormatError) -f 'fe8x::'
                    $exception = New-Object -TypeName System.InvalidOperationException `
                        -ArgumentList $errorMessage
                    $errorRecord = New-Object -TypeName System.Management.Automation.ErrorRecord `
                        -ArgumentList $exception, $errorId, $errorCategory, $null

                    { Test-ResourceProperty @Splat } | Should Throw $ErrorRecord
                }
            }

            Context 'invoking with IPv4 DestinationPrefix mismatch' {

                Mock Get-NetAdapter -MockWith { $MockNetAdapter }

                It 'should throw an AddressIPv6MismatchError error' {
                    $Splat = $TestRoute.Clone()
                    $Splat.DestinationPrefix = 'fe80::/64'
                    $Splat.NextHop = '10.0.1.0'
                    $Splat.AddressFamily = 'IPv4'

                    $errorId = 'AddressIPv6MismatchError'
                    $errorCategory = [System.Management.Automation.ErrorCategory]::DeviceError
                    $errorMessage = $($LocalizedData.AddressIPv6MismatchError) -f 'fe80::','IPv4'
                    $exception = New-Object -TypeName System.InvalidOperationException `
                        -ArgumentList $errorMessage
                    $errorRecord = New-Object -TypeName System.Management.Automation.ErrorRecord `
                        -ArgumentList $exception, $errorId, $errorCategory, $null

                    { Test-ResourceProperty @Splat } | Should Throw $ErrorRecord
                }
            }

            Context 'invoking with IPv6 DestinationPrefix mismatch' {

                Mock Get-NetAdapter -MockWith { $MockNetAdapter }

                It 'should throw an AddressIPv4MismatchError error' {
                    $Splat = $TestRoute.Clone()
                    $Splat.DestinationPrefix = '10.0.0.0/24'
                    $Splat.NextHop = 'fe81::'
                    $Splat.AddressFamily = 'IPv6'

                    $errorId = 'AddressIPv4MismatchError'
                    $errorCategory = [System.Management.Automation.ErrorCategory]::DeviceError
                    $errorMessage = $($LocalizedData.AddressIPv4MismatchError) -f '10.0.0.0','IPv6'
                    $exception = New-Object -TypeName System.InvalidOperationException `
                        -ArgumentList $errorMessage
                    $errorRecord = New-Object -TypeName System.Management.Automation.ErrorRecord `
                        -ArgumentList $exception, $errorId, $errorCategory, $null

                    { Test-ResourceProperty @Splat } | Should Throw $ErrorRecord
                }
            }

            Context 'invoking with bad IPv4 NextHop address' {

                Mock Get-NetAdapter -MockWith { $MockNetAdapter }

                It 'should throw an AddressFormatError error' {
                    $Splat = $TestRoute.Clone()
                    $Splat.DestinationPrefix = '10.0.0.0/24'
                    $Splat.NextHop = '10.0.300.0'
                    $Splat.AddressFamily = 'IPv4'

                    $errorId = 'AddressFormatError'
                    $errorCategory = [System.Management.Automation.ErrorCategory]::DeviceError
                    $errorMessage = $($LocalizedData.AddressFormatError) -f '10.0.300.0'
                    $exception = New-Object -TypeName System.InvalidOperationException `
                        -ArgumentList $errorMessage
                    $errorRecord = New-Object -TypeName System.Management.Automation.ErrorRecord `
                        -ArgumentList $exception, $errorId, $errorCategory, $null

                    { Test-ResourceProperty @Splat } | Should Throw $ErrorRecord
                }
            }

            Context 'invoking with bad IPv6 NextHop address' {

                Mock Get-NetAdapter -MockWith { $MockNetAdapter }

                It 'should throw an AddressFormatError error' {
                    $Splat = $TestRoute.Clone()
                    $Splat.DestinationPrefix = 'fe80::/64'
                    $Splat.NextHop = 'fe9x::'
                    $Splat.AddressFamily = 'IPv6'

                    $errorId = 'AddressFormatError'
                    $errorCategory = [System.Management.Automation.ErrorCategory]::DeviceError
                    $errorMessage = $($LocalizedData.AddressFormatError) -f 'fe9x::'
                    $exception = New-Object -TypeName System.InvalidOperationException `
                        -ArgumentList $errorMessage
                    $errorRecord = New-Object -TypeName System.Management.Automation.ErrorRecord `
                        -ArgumentList $exception, $errorId, $errorCategory, $null

                    { Test-ResourceProperty @Splat } | Should Throw $ErrorRecord
                }
            }

            Context 'invoking with IPv4 NextHop mismatch' {

                Mock Get-NetAdapter -MockWith { $MockNetAdapter }

                It 'should throw an AddressIPv6MismatchError error' {
                    $Splat = $TestRoute.Clone()
                    $Splat.DestinationPrefix = '10.0.0.0/24'
                    $Splat.NextHop = 'fe90::'
                    $Splat.AddressFamily = 'IPv4'

                    $errorId = 'AddressIPv6MismatchError'
                    $errorCategory = [System.Management.Automation.ErrorCategory]::DeviceError
                    $errorMessage = $($LocalizedData.AddressIPv6MismatchError) -f 'fe90::','IPv4'
                    $exception = New-Object -TypeName System.InvalidOperationException `
                        -ArgumentList $errorMessage
                    $errorRecord = New-Object -TypeName System.Management.Automation.ErrorRecord `
                        -ArgumentList $exception, $errorId, $errorCategory, $null

                    { Test-ResourceProperty @Splat } | Should Throw $ErrorRecord
                }
            }

            Context 'invoking with IPv6 NextHop mismatch' {

                Mock Get-NetAdapter -MockWith { $MockNetAdapter }

                It 'should throw an AddressIPv4MismatchError error' {
                    $Splat = $TestRoute.Clone()
                    $Splat.DestinationPrefix = 'fe80::/64'
                    $Splat.NextHop = '10.0.1.0'
                    $Splat.AddressFamily = 'IPv6'

                    $errorId = 'AddressIPv4MismatchError'
                    $errorCategory = [System.Management.Automation.ErrorCategory]::DeviceError
                    $errorMessage = $($LocalizedData.AddressIPv4MismatchError) -f '10.0.1.0','IPv6'
                    $exception = New-Object -TypeName System.InvalidOperationException `
                        -ArgumentList $errorMessage
                    $errorRecord = New-Object -TypeName System.Management.Automation.ErrorRecord `
                        -ArgumentList $exception, $errorId, $errorCategory, $null

                    { Test-ResourceProperty @Splat } | Should Throw $ErrorRecord
                }
            }
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
