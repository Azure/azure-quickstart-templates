$script:DSCModuleName      = 'xNetworking'
$script:DSCResourceName    = 'MSFT_xDhcpClient'

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

        $TestNetIPInterfaceEnabled = [PSObject]@{
            State                   = 'Enabled'
            InterfaceAlias          = $MockNetAdapter.Name
            AddressFamily           = 'IPv4'
        }

        $TestNetIPInterfaceDisabled = [PSObject]@{
            State                   = 'Disabled'
            InterfaceAlias          = $MockNetAdapter.Name
            AddressFamily           = 'IPv4'
        }

        $MockNetIPInterfaceEnabled = [PSObject]@{
            Dhcp                    = $TestNetIPInterfaceEnabled.State
            InterfaceAlias          = $TestNetIPInterfaceEnabled.Name
            AddressFamily           = $TestNetIPInterfaceEnabled.AddressFamily
        }

        $MockNetIPInterfaceDisabled = [PSObject]@{
            Dhcp                    = $TestNetIPInterfaceDisabled.State
            InterfaceAlias          = $TestNetIPInterfaceDisabled.Name
            AddressFamily           = $TestNetIPInterfaceDisabled.AddressFamily
        }

        Describe "MSFT_xDhcpClient\Get-TargetResource" {

            Mock Get-NetAdapter -MockWith { $MockNetAdapter }
            Mock Get-NetIPInterface -MockWith { $MockNetIPInterfaceEnabled }

            Context 'invoking with when DHCP is enabled' {
                It 'should return DHCP state of enabled' {
                    $Result = Get-TargetResource @TestNetIPInterfaceEnabled
                    $Result.State          | Should Be $TestNetIPInterfaceEnabled.State
                    $Result.InterfaceAlias | Should Be $TestNetIPInterfaceEnabled.InterfaceAlias
                    $Result.AddressFamily  | Should Be $TestNetIPInterfaceEnabled.AddressFamily
                }
                It 'should call all the mocks' {
                    Assert-MockCalled -commandName Get-NetAdapter -Exactly 1
                    Assert-MockCalled -commandName Get-NetIPInterface -Exactly 1
                }
            }

            Mock Get-NetIPInterface -MockWith { $MockNetIPInterfaceDisabled }

            Context 'invoking with when DHCP is disabled' {
                It 'should return DHCP state of disabled' {
                    $Result = Get-TargetResource @TestNetIPInterfaceDisabled
                    $Result.State          | Should Be $TestNetIPInterfaceDisabled.State
                    $Result.InterfaceAlias | Should Be $TestNetIPInterfaceDisabled.InterfaceAlias
                    $Result.AddressFamily  | Should Be $TestNetIPInterfaceDisabled.AddressFamily
                }
                It 'should call all the mocks' {
                    Assert-MockCalled -commandName Get-NetAdapter -Exactly 1
                    Assert-MockCalled -commandName Get-NetIPInterface -Exactly 1
                }
            }
        }

        Describe "MSFT_xDhcpClient\Set-TargetResource" {

            Mock Get-NetAdapter -MockWith { $MockNetAdapter }
            Mock Get-NetIPInterface -MockWith { $MockNetIPInterfaceDisabled }
            Mock Set-NetIPInterface -ParameterFilter { $dhcp -eq 'Enabled' }
            Mock Set-NetIPInterface -ParameterFilter { $dhcp -eq 'Disabled' }

            Context 'invoking with state enabled but DHCP is currently disabled' {
                It 'should not throw an exception' {
                    { Set-TargetResource @TestNetIPInterfaceEnabled } | Should Not Throw
                }
                It 'should call appropriate mocks' {
                    Assert-MockCalled -commandName Get-NetAdapter -Exactly 1
                    Assert-MockCalled -commandName Get-NetIPInterface -Exactly 1
                    Assert-MockCalled -commandName Set-NetIPInterface -ParameterFilter { $dhcp -eq 'Enabled' } -Exactly 1
                    Assert-MockCalled -commandName Set-NetIPInterface -ParameterFilter { $dhcp -eq 'Disabled' } -Exactly 0
                }
            }

            Context 'invoking with state disabled and DHCP is currently disabled' {
                It 'should not throw an exception' {
                    { Set-TargetResource @TestNetIPInterfaceDisabled } | Should Not Throw
                }
                It 'should call appropriate mocks' {
                    Assert-MockCalled -commandName Get-NetAdapter -Exactly 1
                    Assert-MockCalled -commandName Get-NetIPInterface -Exactly 1
                    Assert-MockCalled -commandName Set-NetIPInterface -ParameterFilter { $dhcp -eq 'Enabled' } -Exactly 0
                    Assert-MockCalled -commandName Set-NetIPInterface -ParameterFilter { $dhcp -eq 'Disabled' } -Exactly 1
                }
            }

            Mock Get-NetIPInterface -MockWith { $MockNetIPInterfaceEnabled }

            Context 'invoking with state enabled and DHCP is currently enabled' {
                It 'should not throw an exception' {
                    { Set-TargetResource @TestNetIPInterfaceEnabled } | Should Not Throw
                }
                It 'should call appropriate mocks' {
                    Assert-MockCalled -commandName Get-NetAdapter -Exactly 1
                    Assert-MockCalled -commandName Get-NetIPInterface -Exactly 1
                    Assert-MockCalled -commandName Set-NetIPInterface -ParameterFilter { $dhcp -eq 'Enabled' } -Exactly 1
                    Assert-MockCalled -commandName Set-NetIPInterface -ParameterFilter { $dhcp -eq 'Disabled' } -Exactly 0
                }
            }

            Context 'invoking with state disabled but DHCP is currently enabled' {
                It 'should not throw an exception' {
                    { Set-TargetResource @TestNetIPInterfaceDisabled } | Should Not Throw
                }
                It 'should call appropriate mocks' {
                    Assert-MockCalled -commandName Get-NetAdapter -Exactly 1
                    Assert-MockCalled -commandName Get-NetIPInterface -Exactly 1
                    Assert-MockCalled -commandName Set-NetIPInterface -ParameterFilter { $dhcp -eq 'Enabled' } -Exactly 0
                    Assert-MockCalled -commandName Set-NetIPInterface -ParameterFilter { $dhcp -eq 'Disabled' } -Exactly 1
                }
            }
        }

        Describe "MSFT_xDhcpClient\Test-TargetResource" {

            Mock Get-NetAdapter -MockWith { $MockNetAdapter }
            Mock Get-NetIPInterface -MockWith { $MockNetIPInterfaceDisabled }

            Context 'invoking with state enabled but DHCP is currently disabled' {
                It 'should return false' {
                    Test-TargetResource @TestNetIPInterfaceEnabled | Should Be $False
                }
                It 'should call all mocks' {
                    Assert-MockCalled -commandName Get-NetAdapter -Exactly 1
                    Assert-MockCalled -commandName Get-NetIPInterface -Exactly 1
                }
            }

            Context 'invoking with state disabled and DHCP is currently disabled' {
                It 'should return true' {
                    Test-TargetResource @TestNetIPInterfaceDisabled | Should Be $True
                }
                It 'should call all mocks' {
                    Assert-MockCalled -commandName Get-NetAdapter -Exactly 1
                    Assert-MockCalled -commandName Get-NetIPInterface -Exactly 1
                }
            }

            Mock Get-NetIPInterface -MockWith { $MockNetIPInterfaceEnabled }

            Context 'invoking with state enabled and DHCP is currently enabled' {
                It 'should return true' {
                    Test-TargetResource @TestNetIPInterfaceEnabled | Should Be $True
                }
                It 'should call all mocks' {
                    Assert-MockCalled -commandName Get-NetAdapter -Exactly 1
                    Assert-MockCalled -commandName Get-NetIPInterface -Exactly 1
                }
            }

            Context 'invoking with state disabled but DHCP is currently enabled' {
                It 'should return false' {
                    Test-TargetResource @TestNetIPInterfaceDisabled | Should Be $False
                }
                It 'should call all mocks' {
                    Assert-MockCalled -commandName Get-NetAdapter -Exactly 1
                    Assert-MockCalled -commandName Get-NetIPInterface -Exactly 1
                }
            }
        }

        Describe "MSFT_xDhcpClient\Test-ResourceProperty" {

            Mock Get-NetAdapter

            Context 'invoking with bad interface alias' {

                It 'should throw an InterfaceNotAvailable error' {
                    $errorId = 'InterfaceNotAvailable'
                    $errorCategory = [System.Management.Automation.ErrorCategory]::DeviceError
                    $errorMessage = $($LocalizedData.InterfaceNotAvailableError) -f $TestNetIPInterfaceEnabled.InterfaceAlias
                    $exception = New-Object -TypeName System.InvalidOperationException `
                        -ArgumentList $errorMessage
                    $errorRecord = New-Object -TypeName System.Management.Automation.ErrorRecord `
                        -ArgumentList $exception, $errorId, $errorCategory, $null

                    { Test-ResourceProperty @TestNetIPInterfaceEnabled } | Should Throw $ErrorRecord
                }
            }
        }
    } #end InModuleScope $DSCResourceName
    #endregion
}
finally
{
    #region FOOTER
    Restore-TestEnvironment -TestEnvironment $TestEnvironment
    #endregion
}
