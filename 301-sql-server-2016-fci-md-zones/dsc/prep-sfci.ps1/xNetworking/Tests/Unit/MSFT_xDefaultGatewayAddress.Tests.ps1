$script:DSCModuleName      = 'xNetworking'
$script:DSCResourceName    = 'MSFT_xDefaultGatewayAddress'

#region HEADER
[String] $moduleRoot = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $Script:MyInvocation.MyCommand.Path))
if ( (-not (Test-Path -Path (Join-Path -Path $moduleRoot -ChildPath 'DSCResource.Tests'))) -or `
     (-not (Test-Path -Path (Join-Path -Path $moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1'))) )
{
    & git @('clone','https://github.com/PowerShell/DscResource.Tests.git',(Join-Path -Path $moduleRoot -ChildPath '\DSCResource.Tests\'))
}
else
{
    & git @('-C',(Join-Path -Path $moduleRoot -ChildPath '\DSCResource.Tests\'),'pull')
}
Import-Module (Join-Path -Path $moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1') -Force
$TestEnvironment = Initialize-TestEnvironment `
    -DSCModuleName $script:DSCModuleName `
    -DSCResourceName $script:DSCResourceName `
    -TestType Unit
#endregion

# Begin Testing
try
{
    #region Pester Tests
    InModuleScope $script:DSCResourceName {

        Describe "MSFT_xDefaultGatewayAddress\Get-TargetResource" {

            #region Mocks
            Mock Get-NetRoute -MockWith {
                [PSCustomObject]@{
                    NextHop = '192.168.0.1'
                    DestinationPrefix = '0.0.0.0/0'
                    InterfaceAlias = 'Ethernet'
                    InterfaceIndex = 1
                    AddressFamily = 'IPv4'
                }
            }
            #endregion

            Context 'checking return with default gateway' {
                It 'should return current default gateway' {

                    $Splat = @{
                        InterfaceAlias = 'Ethernet'
                        AddressFamily = 'IPv4'
                    }
                    $Result = Get-TargetResource @Splat
                    $Result.Address | Should Be '192.168.0.1'
                }
            }

            #region Mocks
            Mock Get-NetRoute -MockWith {}
            #endregion

            Context 'checking return with no default gateway' {
                It 'should return no default gateway' {

                    $Splat = @{
                        InterfaceAlias = 'Ethernet'
                        AddressFamily = 'IPv4'
                    }
                    $Result = Get-TargetResource @Splat
                    $Result.Address | Should BeNullOrEmpty
                }
            }
        }

        Describe "MSFT_xDefaultGatewayAddress\Set-TargetResource" {

            #region Mocks
            Mock Get-NetRoute -MockWith {
                [PSCustomObject]@{
                    NextHop = '192.168.0.1'
                    DestinationPrefix = '0.0.0.0/0'
                    InterfaceAlias = 'Ethernet'
                    InterfaceIndex = 1
                    AddressFamily = 'IPv4'
                }
            }

            Mock Remove-NetRoute

            Mock New-NetRoute
            #endregion

            Context 'invoking with no Default Gateway Address' {
                It 'should return $null' {
                    $Splat = @{
                        InterfaceAlias = 'Ethernet'
                        AddressFamily = 'IPv4'
                    }
                    { $Result = Set-TargetResource @Splat } | Should Not Throw
                    $Result | Should BeNullOrEmpty
                }

                It 'should call all the mocks' {
                    Assert-MockCalled -commandName Get-NetRoute -Exactly 1
                    Assert-MockCalled -commandName Remove-NetRoute -Exactly 1
                    Assert-MockCalled -commandName New-NetRoute -Exactly 0
                }
            }

            Context 'invoking with valid Default Gateway Address' {
                It 'should return $null' {
                    $Splat = @{
                        Address = '192.168.0.1'
                        InterfaceAlias = 'Ethernet'
                        AddressFamily = 'IPv4'
                    }
                    { $Result = Set-TargetResource @Splat } | Should Not Throw
                    $Result | Should BeNullOrEmpty
                }

                It 'should call all the mocks' {
                    Assert-MockCalled -commandName Get-NetRoute -Exactly 1
                    Assert-MockCalled -commandName Remove-NetRoute -Exactly 1
                    Assert-MockCalled -commandName New-NetRoute -Exactly 1
                }
            }
        }

        Describe "MSFT_xDefaultGatewayAddress\Test-TargetResource" {

            #region Mocks
            Mock Get-NetAdapter -MockWith { [PSObject]@{ Name = 'Ethernet' } }

            Mock Get-NetRoute -MockWith {
                [PSCustomObject]@{
                    NextHop = '192.168.0.1'
                    DestinationPrefix = '0.0.0.0/0'
                    InterfaceAlias = 'Ethernet'
                    InterfaceIndex = 1
                    AddressFamily = 'IPv4'
                }
            }
            #endregion

            Context 'checking return with default gateway that matches currently set one' {
                It 'should return true' {

                    $Splat = @{
                        Address = '192.168.0.1'
                        InterfaceAlias = 'Ethernet'
                        AddressFamily = 'IPv4'
                    }
                    Test-TargetResource @Splat | Should Be $True
                }
            }

            Context 'checking return with no gateway but one is currently set' {
                It 'should return false' {

                    $Splat = @{
                        InterfaceAlias = 'Ethernet'
                        AddressFamily = 'IPv4'
                    }
                    Test-TargetResource @Splat | Should Be $False
                }
            }

            #region Mocks
            Mock Get-NetRoute -MockWith {}
            #endregion

            Context 'checking return with default gateway but none are currently set' {
                It 'should return false' {

                    $Splat = @{
                        Address = '192.168.0.1'
                        InterfaceAlias = 'Ethernet'
                        AddressFamily = 'IPv4'
                    }
                    Test-TargetResource @Splat | Should Be $False
                }
            }

            Context 'checking return with no gateway and none are currently set' {
                It 'should return true' {

                    $Splat = @{
                        InterfaceAlias = 'Ethernet'
                        AddressFamily = 'IPv4'
                    }
                    Test-TargetResource @Splat | Should Be $True
                }
            }
        }

        Describe "MSFT_xDefaultGatewayAddress\Test-ResourceProperty" {

            Mock Get-NetAdapter -MockWith { [PSObject]@{ Name = 'Ethernet' } }

            Context 'invoking with bad interface alias' {

                It 'should throw an InterfaceNotAvailable error' {
                    $Splat = @{
                        Address = '192.168.0.1'
                        InterfaceAlias = 'NotReal'
                        AddressFamily = 'IPv4'
                    }
                    $errorId = 'InterfaceNotAvailable'
                    $errorCategory = [System.Management.Automation.ErrorCategory]::DeviceError
                    $errorMessage = $($LocalizedData.InterfaceNotAvailableError) -f $Splat.InterfaceAlias
                    $exception = New-Object -TypeName System.InvalidOperationException `
                        -ArgumentList $errorMessage
                    $errorRecord = New-Object -TypeName System.Management.Automation.ErrorRecord `
                        -ArgumentList $exception, $errorId, $errorCategory, $null

                    { Test-ResourceProperty @Splat } | Should Throw $ErrorRecord
                }
            }

            Context 'invoking with invalid IP Address' {

                It 'should throw an AddressFormatError error' {
                    $Splat = @{
                        Address = 'NotReal'
                        InterfaceAlias = 'Ethernet'
                        AddressFamily = 'IPv4'
                    }
                    $errorId = 'AddressFormatError'
                    $errorCategory = [System.Management.Automation.ErrorCategory]::InvalidArgument
                    $errorMessage = $($LocalizedData.AddressFormatError) -f $Splat.Address
                    $exception = New-Object -TypeName System.InvalidOperationException `
                        -ArgumentList $errorMessage
                    $errorRecord = New-Object -TypeName System.Management.Automation.ErrorRecord `
                        -ArgumentList $exception, $errorId, $errorCategory, $null

                    { Test-ResourceProperty @Splat } | Should Throw $ErrorRecord
                }
            }

            Context 'invoking with IPv4 Address and family mismatch' {

                It 'should throw an AddressMismatchError error' {
                    $Splat = @{
                        Address = '192.168.0.1'
                        InterfaceAlias = 'Ethernet'
                        AddressFamily = 'IPv6'
                    }
                    $errorId = 'AddressMismatchError'
                    $errorCategory = [System.Management.Automation.ErrorCategory]::InvalidArgument
                    $errorMessage = $($LocalizedData.AddressIPv4MismatchError) -f $Splat.Address,$Splat.AddressFamily
                    $exception = New-Object -TypeName System.InvalidOperationException `
                        -ArgumentList $errorMessage
                    $errorRecord = New-Object -TypeName System.Management.Automation.ErrorRecord `
                        -ArgumentList $exception, $errorId, $errorCategory, $null

                    { Test-ResourceProperty @Splat } | Should Throw $ErrorRecord
                }
            }

            Context 'invoking with IPv6 Address and family mismatch' {

                It 'should throw an AddressMismatchError error' {
                    $Splat = @{
                        Address = 'fe80::'
                        InterfaceAlias = 'Ethernet'
                        AddressFamily = 'IPv4'
                    }
                    $errorId = 'AddressMismatchError'
                    $errorCategory = [System.Management.Automation.ErrorCategory]::InvalidArgument
                    $errorMessage = $($LocalizedData.AddressIPv6MismatchError) -f $Splat.Address,$Splat.AddressFamily
                    $exception = New-Object -TypeName System.InvalidOperationException `
                        -ArgumentList $errorMessage
                    $errorRecord = New-Object -TypeName System.Management.Automation.ErrorRecord `
                        -ArgumentList $exception, $errorId, $errorCategory, $null

                    { Test-ResourceProperty @Splat } | Should Throw $ErrorRecord
                }
            }

            Context 'invoking with valid IPv4 Address' {

                It 'should not throw an error' {
                    $Splat = @{
                        Address = '192.168.0.1'
                        InterfaceAlias = 'Ethernet'
                        AddressFamily = 'IPv4'
                    }
                    { Test-ResourceProperty @Splat } | Should Not Throw
                }
            }

            Context 'invoking with valid IPv6 Address' {

                It 'should not throw an error' {
                    $Splat = @{
                        Address = 'fe80:ab04:30F5:002b::1'
                        InterfaceAlias = 'Ethernet'
                        AddressFamily = 'IPv6'
                    }
                    { Test-ResourceProperty @Splat } | Should Not Throw
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
