$script:DSCModuleName      = 'xNetworking'
$script:DSCResourceName    = 'MSFT_xNetAdapterBinding'

#region HEADER
# Unit Test Template Version: 1.1.0
[String] $script:moduleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
if ( (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests'))) -or `
     (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1'))) )
{
    #& git @('clone','https://github.com/PowerShell/DscResource.Tests.git',(Join-Path -Path $script:moduleRoot -ChildPath '\DSCResource.Tests\'))
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
    InModuleScope $script:DSCResourceName {

        $TestBindingEnabled = @{
            InterfaceAlias = 'Ethernet'
            ComponentId = 'ms_tcpip63'
            State = 'Enabled'
        }
        $TestBindingDisabled = @{
            InterfaceAlias = 'Ethernet'
            ComponentId = 'ms_tcpip63'
            State = 'Disabled'
        }
        $TestBindingMixed = @{
            InterfaceAlias = '*'
            ComponentId = 'ms_tcpip63'
            State = 'Enabled'
        }
        $MockAdapter = @{
            InterfaceAlias = 'Ethernet'
        }
        $MockBindingEnabled = @{
            InterfaceAlias = 'Ethernet'
            ComponentId = 'ms_tcpip63'
            Enabled = $True
        }
        $MockBindingDisabled = @{
            InterfaceAlias = 'Ethernet'
            ComponentId = 'ms_tcpip63'
            Enabled = $False
        }

        $MockBindingMixed = @{
            InterfaceAlias = 'Ethernet'
            ComponentId = 'ms_tcpip63'
            Enabled = $False
        },
        @{
            InterfaceAlias = 'Ethernet2'
            ComponentId = 'ms_tcpip63'
            Enabled = $True
        }

        Describe "MSFT_xNetAdapterBinding\Get-TargetResource" {
            Context 'Adapter exists and binding Enabled' {
                Mock Get-Binding -MockWith { $MockBindingEnabled }

                It 'should return existing binding' {
                    $Result = Get-TargetResource @TestBindingEnabled
                    $Result.InterfaceAlias | Should Be $TestBindingEnabled.InterfaceAlias
                    $Result.ComponentId | Should Be $TestBindingEnabled.ComponentId
                    $Result.State | Should Be 'Enabled'
                    $Result.CurrentState | Should Be 'Enabled'
                }
                It 'Should call all the mocks' {
                    Assert-MockCalled -commandName Get-Binding -Exactly 1
                }
            }

            Context 'Adapter exists and binding Disabled' {
                Mock Get-Binding -MockWith { $MockBindingDisabled }

                It 'should return existing binding' {
                    $Result = Get-TargetResource @TestBindingDisabled
                    $Result.InterfaceAlias | Should Be $TestBindingDisabled.InterfaceAlias
                    $Result.ComponentId | Should Be $TestBindingDisabled.ComponentId
                    $Result.State | Should Be 'Disabled'
                    $Result.CurrentState | Should Be 'Disabled'
                }
                It 'Should call all the mocks' {
                    Assert-MockCalled -commandName Get-Binding -Exactly 1
                }
            }

            Context 'More than one Adapter exists and binding is Disabled on one and Enabled on another' {
                Mock Get-Binding -MockWith { $MockBindingMixed }

                It 'should return existing binding' {
                    $Result = Get-TargetResource @TestBindingMixed
                    $Result.InterfaceAlias | Should Be $TestBindingMixed.InterfaceAlias
                    $Result.ComponentId | Should Be $TestBindingMixed.ComponentId
                    $Result.State | Should Be 'Enabled'
                    $Result.CurrentState | Should Be 'Mixed'
                }
                It 'Should call all the mocks' {
                    Assert-MockCalled -commandName Get-Binding -Exactly 1
                }
            }

        }

        Describe "MSFT_xNetAdapterBinding\Set-TargetResource" {
            Context 'Adapter exists and set binding to Enabled' {
                Mock Get-Binding -MockWith { $MockBindingDisabled }
                Mock Enable-NetAdapterBinding
                Mock Disable-NetAdapterBinding
                It 'Should not throw an exception' {
                    { Set-TargetResource @TestBindingEnabled } | Should Not Throw
                }
                It 'Should call all the mocks' {
                    Assert-MockCalled -commandName Get-Binding -Exactly 1
                    Assert-MockCalled -commandName Enable-NetAdapterBinding -Exactly 1
                    Assert-MockCalled -commandName Disable-NetAdapterBinding -Exactly 0
                }
            }

            Context 'Adapter exists and set binding to Disabled' {
                Mock Get-Binding -MockWith { $MockBindingEnabled }
                Mock Enable-NetAdapterBinding
                Mock Disable-NetAdapterBinding
                It 'Should not throw an exception' {
                    { Set-TargetResource @TestBindingDisabled } | Should Not Throw
                }
                It 'Should call all the mocks' {
                    Assert-MockCalled -commandName Get-Binding -Exactly 1
                    Assert-MockCalled -commandName Enable-NetAdapterBinding -Exactly 0
                    Assert-MockCalled -commandName Disable-NetAdapterBinding -Exactly 1
                }
            }
        }

        Describe "MSFT_xNetAdapterBinding\Test-TargetResource" {
            Context 'Adapter exists, current binding set to Enabled but want it Disabled' {
                Mock Get-Binding -MockWith { $MockBindingEnabled }
                It 'Should return false' {
                    Test-TargetResource @TestBindingDisabled | Should Be $False
                }
                It 'Should call all the mocks' {
                    Assert-MockCalled -commandName Get-Binding -Exactly 1
                }
            }

            Context 'Adapter exists, current binding set to Disabled but want it Enabled' {
                Mock Get-Binding -MockWith { $MockBindingDisabled }
                It 'Should return false' {
                    Test-TargetResource @TestBindingEnabled | Should Be $False
                }
                It 'Should call all the mocks' {
                    Assert-MockCalled -commandName Get-Binding -Exactly 1
                }
            }

            Context 'Adapter exists, current binding set to Enabled and want it Enabled' {
                Mock Get-Binding -MockWith { $MockBindingEnabled }
                It 'Should return true' {
                    Test-TargetResource @TestBindingEnabled | Should Be $True
                }
                It 'Should call all the mocks' {
                    Assert-MockCalled -commandName Get-Binding -Exactly 1
                }
            }

            Context 'Adapter exists, current binding set to Disabled and want it Disabled' {
                Mock Get-Binding -MockWith { $MockBindingDisabled }
                It 'Should return true' {
                    Test-TargetResource @TestBindingDisabled | Should Be $True
                }
                It 'Should call all the mocks' {
                    Assert-MockCalled -commandName Get-Binding -Exactly 1
                }
            }
        }

        Describe "MSFT_xNetAdapterBinding\Get-Binding" {
            Context 'Adapter does not exist' {
                Mock Get-NetAdapter
                It 'Should throw an InterfaceNotAvailable error' {
                    $errorId = 'InterfaceNotAvailable'
                    $errorCategory = [System.Management.Automation.ErrorCategory]::DeviceError
                    $errorMessage = $($LocalizedData.InterfaceNotAvailableError `
                        -f $TestBindingEnabled.InterfaceAlias)
                    $exception = New-Object -TypeName System.InvalidOperationException `
                        -ArgumentList $errorMessage
                    $errorRecord = New-Object -TypeName System.Management.Automation.ErrorRecord `
                        -ArgumentList $exception, $errorId, $errorCategory, $null

                    { Get-Binding @TestBindingEnabled } | Should Throw $errorRecord
                }
                It 'Should call all the mocks' {
                    Assert-MockCalled -commandName Get-NetAdapter -Exactly 1
                }
            }

            Context 'Adapter exists and binding enabled' {
                Mock Get-NetAdapter -MockWith { $MockAdapter }
                Mock Get-NetAdapterBinding -MockWith { $MockBindingEnabled }
                It 'Should return the adapter binding' {
                    $Result = Get-Binding @TestBindingEnabled
                    $Result.InterfaceAlias | Should Be $MockBindingEnabled.InterfaceAlias
                    $Result.ComponentId    | Should Be $MockBindingEnabled.ComponentId
                    $Result.Enabled        | Should Be $MockBindingEnabled.Enabled
                }
                It 'Should call all the mocks' {
                    Assert-MockCalled -commandName Get-NetAdapter -Exactly 1
                    Assert-MockCalled -commandName Get-NetAdapterBinding -Exactly 1
                }
            }

            Context 'Adapter exists and binding disabled' {
                Mock Get-NetAdapter -MockWith { $MockAdapter }
                Mock Get-NetAdapterBinding -MockWith { $MockBindingDisabled }
                It 'Should return the adapter binding' {
                    $Result = Get-Binding @TestBindingDisabled
                    $Result.InterfaceAlias | Should Be $MockBindingDisabled.InterfaceAlias
                    $Result.ComponentId    | Should Be $MockBindingDisabled.ComponentId
                    $Result.Enabled        | Should Be $MockBindingDisabled.Enabled
                }
                It 'Should call all the mocks' {
                    Assert-MockCalled -commandName Get-NetAdapter -Exactly 1
                    Assert-MockCalled -commandName Get-NetAdapterBinding -Exactly 1
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
