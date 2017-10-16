$script:DSCModuleName      = 'xNetworking'
$script:DSCResourceName    = 'MSFT_xIPAddress'

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

        Describe "MSFT_xIPAddress\Get-TargetResource" {

            #region Mocks
            Mock Get-NetIPAddress -MockWith {
                [PSCustomObject]@{
                    IPAddress = '192.168.0.1'
                    InterfaceAlias = 'Ethernet'
                    InterfaceIndex = 1
                    PrefixLength = [byte]24
                    AddressFamily = 'IPv4'
                }
            }
            #endregion

            Context 'invoking' {
                It 'should return existing IP details' {
                    $Splat = @{
                        IPAddress = '192.168.0.1'
                        InterfaceAlias = 'Ethernet'
                        AddressFamily = 'IPv4'
                    }
                    $Result = Get-TargetResource @Splat
                    $Result.IPAddress | Should Be $Splat.IPAddress
                    $Result.PrefixLength | Should Be 24
                }
            }

            Context 'Prefix Length' {
                It 'should fail if passed a negative number' {
                    $Splat = @{
                        IPAddress = '192.168.0.1'
                        InterfaceAlias = 'Ethernet'
                        PrefixLength = -16
                    }

                    { Get-TargetResource @Splat } `
                        | Should Throw 'Value was either too large or too small for a UInt32.'
                }
            }
        }

        Describe "MSFT_xIPAddress\Set-TargetResource" {

            #region Mocks
            Mock Get-NetIPAddress -MockWith {
                [PSCustomObject]@{
                    IPAddress = '192.168.0.1'
                    InterfaceAlias = 'Ethernet'
                    InterfaceIndex = 1
                    PrefixLength = [byte]16
                    AddressFamily = 'IPv4'
                }
            }

            Mock New-NetIPAddress

            Mock Get-NetRoute {
                [PSCustomObject]@{
                    InterfaceAlias = 'Ethernet'
                    InterfaceIndex = 1
                    AddressFamily = 'IPv4'
                    NextHop = '192.168.0.254'
                    DestinationPrefix = '0.0.0.0/0'
                }
            }

            Mock Remove-NetIPAddress

            Mock Remove-NetRoute
            #endregion

            Context 'invoking with valid IP Address' {

                It 'should rerturn $null' {
                    $Splat = @{
                        IPAddress = '10.0.0.2'
                        InterfaceAlias = 'Ethernet'
                        AddressFamily = 'IPv4'
                    }
                    { $Result = Set-TargetResource @Splat } | Should Not Throw
                    $Result | Should BeNullOrEmpty
                }

                It 'should call all the mocks' {
                    Assert-MockCalled -commandName Get-NetIPAddress -Exactly 1
                    Assert-MockCalled -commandName Get-NetRoute -Exactly 1
                    Assert-MockCalled -commandName Remove-NetRoute -Exactly 1
                    Assert-MockCalled -commandName Remove-NetIPAddress -Exactly 1
                    Assert-MockCalled -commandName New-NetIPAddress -Exactly 1
                }
            }
        }

        Describe "MSFT_xIPAddress\Test-TargetResource" {


            #region Mocks
            Mock Get-NetAdapter -MockWith { [PSObject]@{ Name = 'Ethernet' } }

            Mock Get-NetIPAddress -MockWith {

                [PSCustomObject]@{
                    IPAddress = '192.168.0.15'
                    InterfaceAlias = 'Ethernet'
                    InterfaceIndex = 1
                    PrefixLength = [byte]16
                    AddressFamily = 'IPv4'
                }
            }
            #endregion

            Context 'invoking with invalid IPv4 Address' {

                It 'should throw an AddressFormatError error' {
                    $Splat = @{
                        IPAddress = 'BadAddress'
                        InterfaceAlias = 'Ethernet'
                        AddressFamily = 'IPv4'
                    }
                    $errorId = 'AddressFormatError'
                    $errorCategory = [System.Management.Automation.ErrorCategory]::InvalidArgument
                    $errorMessage = $($LocalizedData.AddressFormatError) -f $Splat.IPAddress
                    $exception = New-Object -TypeName System.InvalidOperationException `
                        -ArgumentList $errorMessage
                    $errorRecord = New-Object -TypeName System.Management.Automation.ErrorRecord `
                        -ArgumentList $exception, $errorId, $errorCategory, $null

                    { $Result = Test-TargetResource @Splat } | Should Throw $errorRecord
                }
            }

            Context 'invoking with different IPv4 Address' {

                It 'should be $false' {
                    $Splat = @{
                        IPAddress = '192.168.0.1'
                        InterfaceAlias = 'Ethernet'
                        AddressFamily = 'IPv4'
                    }
                    $Result = Test-TargetResource @Splat
                    $Result | Should Be $false
                }
                It 'should call appropriate mocks' {
                    Assert-MockCalled -commandName Get-NetIPAddress -Exactly 1
                }
            }

            Context 'invoking with the same IPv4 Address' {

                It 'should be $true' {
                    $Splat = @{
                        IPAddress = '192.168.0.15'
                        InterfaceAlias = 'Ethernet'
                        AddressFamily = 'IPv4'
                    }
                    $Result = Test-TargetResource @Splat
                    $Result | Should Be $true
                }
                It 'should call appropriate mocks' {
                    Assert-MockCalled -commandName Get-NetIPAddress -Exactly 1
                }
            }

            Mock Get-NetIPAddress -MockWith {

                [PSCustomObject]@{
                    IPAddress = 'fe80::15'
                    InterfaceAlias = 'Ethernet'
                    InterfaceIndex = 1
                    PrefixLength = [byte]64
                    AddressFamily = 'IPv6'
                }
            }
            Context 'invoking with invalid IPv6 Address' {

                It 'should throw an AddressFormatError error' {
                    $Splat = @{
                        IPAddress = 'BadAddress'
                        InterfaceAlias = 'Ethernet'
                        PrefixLength = 64
                        AddressFamily = 'IPv6'
                    }
                    $errorId = 'AddressFormatError'
                    $errorCategory = [System.Management.Automation.ErrorCategory]::InvalidArgument
                    $errorMessage = $($LocalizedData.AddressFormatError) -f $Splat.IPAddress
                    $exception = New-Object -TypeName System.InvalidOperationException `
                        -ArgumentList $errorMessage
                    $errorRecord = New-Object -TypeName System.Management.Automation.ErrorRecord `
                        -ArgumentList $exception, $errorId, $errorCategory, $null

                    { $Result = Test-TargetResource @Splat } | Should Throw $errorRecord
                }
            }

            Context 'invoking with different IPv6 Address' {

                It 'should be $false' {
                    $Splat = @{
                        IPAddress = 'fe80::1'
                        InterfaceAlias = 'Ethernet'
                        PrefixLength = 64
                        AddressFamily = 'IPv6'
                    }
                    $Result = Test-TargetResource @Splat
                    $Result | Should Be $false
                }
                It 'should call appropriate mocks' {
                    Assert-MockCalled -commandName Get-NetIPAddress -Exactly 1
                }
            }

            Context 'invoking with the same IPv6 Address' {

                It 'should be $true' {
                    $Splat = @{
                        IPAddress = 'fe80::15'
                        InterfaceAlias = 'Ethernet'
                        PrefixLength = 64
                        AddressFamily = 'IPv6'
                    }
                    $Result = Test-TargetResource @Splat
                    $Result | Should Be $true
                }
                It 'should call appropriate mocks' {
                    Assert-MockCalled -commandName Get-NetIPAddress -Exactly 1
                }
            }
        }

        Describe "MSFT_xIPAddress\Test-ResourceProperty" {

            Mock Get-NetAdapter -MockWith { [PSObject]@{ Name = 'Ethernet' } }

            Context 'invoking with bad interface alias' {

                It 'should throw an InterfaceNotAvailable error' {
                    $Splat = @{
                        IPAddress = '192.168.0.1'
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

                    { Test-ResourceProperty @Splat } | Should Throw $errorRecord
                }
            }

            Context 'invoking with invalid IP Address' {

                It 'should throw an AddressFormatError error' {
                    $Splat = @{
                        IPAddress = 'NotReal'
                        InterfaceAlias = 'Ethernet'
                        AddressFamily = 'IPv4'
                    }
                    $errorId = 'AddressFormatError'
                    $errorCategory = [System.Management.Automation.ErrorCategory]::InvalidArgument
                    $errorMessage = $($LocalizedData.AddressFormatError) -f $Splat.IPAddress
                    $exception = New-Object -TypeName System.InvalidOperationException `
                        -ArgumentList $errorMessage
                    $errorRecord = New-Object -TypeName System.Management.Automation.ErrorRecord `
                        -ArgumentList $exception, $errorId, $errorCategory, $null

                    { Test-ResourceProperty @Splat } | Should Throw $errorRecord
                }
            }

            Context 'invoking with IP Address and family mismatch' {

                It 'should throw an AddressMismatchError error' {
                    $Splat = @{
                        IPAddress = '192.168.0.1'
                        InterfaceAlias = 'Ethernet'
                        AddressFamily = 'IPv6'
                    }
                    $errorId = 'AddressMismatchError'
                    $errorCategory = [System.Management.Automation.ErrorCategory]::InvalidArgument
                    $errorMessage = $($LocalizedData.AddressIPv4MismatchError) -f $Splat.IPAddress,$Splat.AddressFamily
                    $exception = New-Object -TypeName System.InvalidOperationException `
                        -ArgumentList $errorMessage
                    $errorRecord = New-Object -TypeName System.Management.Automation.ErrorRecord `
                        -ArgumentList $exception, $errorId, $errorCategory, $null

                    { Test-ResourceProperty @Splat } | Should Throw $errorRecord
                }
            }

            Context 'invoking with valid IPv4 Address' {

                It 'should not throw an error' {
                    $Splat = @{
                        IPAddress = '192.168.0.1'
                        InterfaceAlias = 'Ethernet'
                        AddressFamily = 'IPv4'
                    }
                    { Test-ResourceProperty @Splat } | Should Not Throw
                }
            }

            Context 'invoking with valid IPv6 Address' {

                It 'should not throw an error' {
                    $Splat = @{
                        IPAddress = 'fe80:ab04:30F5:002b::1'
                        InterfaceAlias = 'Ethernet'
                        PrefixLength = 64
                        AddressFamily = 'IPv6'
                    }
                    { Test-ResourceProperty @Splat } | Should Not Throw
                }
            }

            Context 'invoking with invalid IPv4 prefix length' {

                It 'should throw a PrefixLengthError when greater than 32' {
                    $Splat = @{
                        IPAddress = '192.168.0.1'
                        InterfaceAlias = 'Ethernet'
                        PrefixLength = 33
                        AddressFamily = 'IPv4'
                    }
                    $errorId = 'PrefixLengthError'
                    $errorCategory = [System.Management.Automation.ErrorCategory]::InvalidArgument
                    $errorMessage = $($LocalizedData.PrefixLengthError) -f $Splat.PrefixLength,$Splat.AddressFamily
                    $exception = New-Object -TypeName System.InvalidOperationException `
                        -ArgumentList $errorMessage
                    $errorRecord = New-Object -TypeName System.Management.Automation.ErrorRecord `
                        -ArgumentList $exception, $errorId, $errorCategory, $null

                    { Test-ResourceProperty @Splat } | Should Throw $errorRecord
                }
                It 'should throw an Argument error when less than 0' {
                    $Splat = @{
                        IPAddress = '192.168.0.1'
                        InterfaceAlias = 'Ethernet'
                        PrefixLength = -1
                        AddressFamily = 'IPv4'
                    }
                    { Test-ResourceProperty @Splat } `
                        | Should Throw 'Value was either too large or too small for a UInt32.'
                }
            }

            Context 'invoking with invalid IPv6 prefix length' {

                It 'should throw a PrefixLengthError error when greater than 128' {
                    $Splat = @{
                        IPAddress = 'fe80::1'
                        InterfaceAlias = 'Ethernet'
                        PrefixLength = 129
                        AddressFamily = 'IPv6'
                    }

                    $errorId = 'PrefixLengthError'
                    $errorCategory = [System.Management.Automation.ErrorCategory]::InvalidArgument
                    $errorMessage = $($LocalizedData.PrefixLengthError) -f $Splat.PrefixLength,$Splat.AddressFamily
                    $exception = New-Object -TypeName System.InvalidOperationException `
                        -ArgumentList $errorMessage
                    $errorRecord = New-Object -TypeName System.Management.Automation.ErrorRecord `
                        -ArgumentList $exception, $errorId, $errorCategory, $null

                    { Test-ResourceProperty @Splat } | Should Throw $errorRecord
                }
                It 'should throw an Argument error when less than 0' {
                    $Splat = @{
                        IPAddress = 'fe80::1'
                        InterfaceAlias = 'Ethernet'
                        PrefixLength = -1
                        AddressFamily = 'IPv6'
                    }

                    { Test-ResourceProperty @Splat } `
                        | Should Throw 'Value was either too large or too small for a UInt32.'
                }
            }

            Context 'invoking with valid string IPv6 prefix length' {

                It 'should not throw an error' {
                    $Splat = @{
                        IPAddress = 'fe80::1'
                        InterfaceAlias = 'Ethernet'
                        PrefixLength = '64'
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
