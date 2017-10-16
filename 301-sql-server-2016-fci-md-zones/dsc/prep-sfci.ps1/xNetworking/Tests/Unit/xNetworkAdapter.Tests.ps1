$script:ModuleName = 'xNetworkAdapter'

#region HEADER
# Unit Test Template Version: 1.1.0
[String] $script:moduleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
if ( (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests'))) -or `
     (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1'))) )
{
    & git @('clone','https://github.com/PowerShell/DscResource.Tests.git',(Join-Path -Path $script:moduleRoot -ChildPath '\DSCResource.Tests\'))
}

Import-Module (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1') -Force
Import-Module (Join-Path -Path $script:moduleRoot -ChildPath "$script:ModuleName.psm1") -Force
#endregion HEADER

# Begin Testing
try
{
    Set-StrictMode -Version latest
    $ErrorActionPreference = 'stop'
    
    #region Pester Tests

    $GetNetAdapter_PhysicalNetAdapterMock = {
        return [PSCustomObject] @{
            Name              = 'Ethernet'
            PhysicalMediaType = '802.3'
            Status            = 'Up'
        }
    }

    $GetNetAdapter_HypervVmNetAdapterMock = {
        return [PSCustomObject] @{
            Name              = 'Ethernet'
            PhysicalMediaType = 'Unspecified'
            Status            = 'Up'
        }
    }

    $GetNetAdapter_MultipleNetAdapterMock = {
        return @(
            [PSCustomObject] @{
                Name               = 'Ethernet1'
                PhysicalMediaType  = '802.3'
                Status             = 'Up'
            },
            [PSCustomObject] @{
                Name               = 'MyEthernet'
                PhysicalMediaType  = '802.3'
                Status             = 'Up'
            }
        )
    }

    $TestAdapterKeys = @{
        Name               = 'MyEthernet'
        PhysicalMediaType  = '802.3'
        Status             = 'Up'
    }

    $TestHypervVmAdapterKeys = @{
        Name                       = 'MyEthernet'
        Status                     = 'Up'
    }

    Describe "xNetworkAdapter\Get-xNetworkAdapterName" {

        Context 'Adapter does not exist' {

            Mock Get-NetAdapter -ModuleName $script:ModuleName
            
            It 'should return absent Route' {
                $Result = Get-xNetworkAdapterName @TestAdapterKeys
                $Result.MatchingAdapterCount | Should Be 0
                $Result.Name | Should Be $null
            }
            It 'should call the expected mocks' {
                Assert-MockCalled -ModuleName $script:ModuleName -commandName Get-NetAdapter -Exactly 1
            }
        }

        Context 'Adapter does exist' {

            Mock Get-NetAdapter -ModuleName $script:ModuleName -MockWith $GetNetAdapter_PhysicalNetAdapterMock

            It 'should return correct Route' {
                $Result = Get-xNetworkAdapterName @TestAdapterKeys
                $Result.MatchingAdapterCount | Should Be 1
                $Result.Name | Should Be 'Ethernet'
            }
            It 'should call the expected mocks' {
                Assert-MockCalled -ModuleName $script:ModuleName -commandName Get-NetAdapter -Exactly 1
            }
        }

        Context 'Hyperv VM Adapter does exist' {

            Mock Get-NetAdapter -ModuleName $script:ModuleName -MockWith $GetNetAdapter_HypervVmNetAdapterMock

            It 'should return correct Route' {
                $Result = Get-xNetworkAdapterName @TestHypervVmAdapterKeys
                $Result.MatchingAdapterCount | Should Be 1
                $Result.Name | Should Be 'Ethernet'
            }
            It 'should call the expected mocks' {
                Assert-MockCalled -ModuleName $script:ModuleName -commandName Get-NetAdapter -Exactly 1
            }
        }

        Context 'Multiple Adapters exist' {

            Mock Get-NetAdapter -ModuleName $script:ModuleName -MockWith $GetNetAdapter_MultipleNetAdapterMock

            It 'should return correct Route' {
                $Result = Get-xNetworkAdapterName @TestAdapterKeys
                $Result.MatchingAdapterCount | Should Be 1
                $Result.Name | Should Be 'MyEthernet'
            }
            It 'should call the expected mocks' {
                Assert-MockCalled -ModuleName $script:ModuleName -commandName Get-NetAdapter -Exactly 1
            }
        }
    }

    Describe "xNetworkAdapter\Set-xNetworkAdapterName" {

        Context 'Adapter does not exist' {

            Mock Get-NetAdapter -ModuleName $script:ModuleName 
            Mock Rename-NetAdapter -ModuleName $script:ModuleName 

            It 'should not throw error' {
                {
                    $Splat = $TestAdapterKeys.Clone()
                    Set-xNetworkAdapterName @Splat
                } | Should Throw 'A NetAdapter matching the properties was not found. Please correct the properties and try again.'
            }
            It 'should call expected Mocks' {
                Assert-MockCalled -ModuleName $script:ModuleName -commandName Get-NetAdapter -Exactly 1
                Assert-MockCalled -ModuleName $script:ModuleName -commandName Rename-NetAdapter -Exactly 0
            }
        }

        Context 'Adapter exists and should be renamed' {

            Mock Get-NetAdapter -ModuleName $script:ModuleName -MockWith $GetNetAdapter_PhysicalNetAdapterMock
            Mock Rename-NetAdapter -ModuleName $script:ModuleName 

            It 'should not throw error' {
                {
                    $Splat = $TestAdapterKeys.Clone()
                    Set-xNetworkAdapterName @Splat
                } | Should Not Throw
            }
            It 'should call expected Mocks' {
                Assert-MockCalled -ModuleName $script:ModuleName -commandName Get-NetAdapter -Exactly 1
                Assert-MockCalled -ModuleName $script:ModuleName -commandName Rename-NetAdapter -Exactly 1
            }
        }

        Context 'Hyperv VM Adapter exists and should be renamed' {

            Mock Get-NetAdapter -ModuleName $script:ModuleName -MockWith $GetNetAdapter_HypervVmNetAdapterMock
            Mock Rename-NetAdapter -ModuleName $script:ModuleName 

            It 'should not throw error' {
                {
                    $Splat = $TestHypervVmAdapterKeys.Clone()
                    Set-xNetworkAdapterName @Splat
                } | Should Not Throw
            }
            It 'should call expected Mocks' {
                Assert-MockCalled -ModuleName $script:ModuleName -commandName Get-NetAdapter -Exactly 1
                Assert-MockCalled -ModuleName $script:ModuleName -commandName Rename-NetAdapter -Exactly 1
            }
        }

        Context 'Multiple matching adapter exists and IgnoreMultipleMatchingAdapters is true and name matches' {

            Mock Get-NetAdapter -ModuleName $script:ModuleName -MockWith $GetNetAdapter_MultipleNetAdapterMock
            Mock Rename-NetAdapter -ModuleName $script:ModuleName 

            It 'should not throw error' {
                {
                    $Splat = $TestAdapterKeys.Clone()
                    Set-xNetworkAdapterName @Splat
                } | Should Not Throw
            }
            It 'should call expected Mocks' {
                Assert-MockCalled -ModuleName $script:ModuleName -commandName Get-NetAdapter -Exactly 1
                Assert-MockCalled -ModuleName $script:ModuleName -commandName Rename-NetAdapter -Exactly 0
            }
        }

        Context 'Multiple matching adapter exists and IgnoreMultipleMatchingAdapters is true and name mismatches' {

            Mock Get-NetAdapter -ModuleName $script:ModuleName -MockWith $GetNetAdapter_MultipleNetAdapterMock
            Mock Rename-NetAdapter -ModuleName $script:ModuleName 

            It 'should not throw error' {
                {
                    $Splat = $TestAdapterKeys.Clone()
                    $Splat.Name = 'MyEthernet2'
                    $Splat.IgnoreMultipleMatchingAdapters = $true
                    Set-xNetworkAdapterName @Splat
                } | Should Not Throw
            }
            It 'should call expected Mocks' {
                Assert-MockCalled -ModuleName $script:ModuleName -commandName Get-NetAdapter -Exactly 1
                Assert-MockCalled -ModuleName $script:ModuleName -commandName Rename-NetAdapter -Exactly 1
            }
        }

        Context 'Multiple matching adapter exists and IgnoreMultipleMatchingAdapters is false' {

            Mock Get-NetAdapter -ModuleName $script:ModuleName -MockWith $GetNetAdapter_MultipleNetAdapterMock
            Mock Rename-NetAdapter -ModuleName $script:ModuleName 

            It 'should not throw error' {
                {
                    $Splat = $TestAdapterKeys.Clone()
                    $Splat.Name = 'MyEthernet2'
                    $Splat.IgnoreMultipleMatchingAdapters = $false
                    Set-xNetworkAdapterName @Splat
                } | Should Throw 'Multiple matching NetAdapters where found for the properties. Please correct the properties or specify IgnoreMultipleMatchingAdapters to only use the first and try again.'
            }
            It 'should call expected Mocks' {
                Assert-MockCalled -ModuleName $script:ModuleName -commandName Get-NetAdapter -Exactly 1
                Assert-MockCalled -ModuleName $script:ModuleName -commandName Rename-NetAdapter -Exactly 0
            }
        }
    }

    Describe "xNetworkAdapter\Test-xNetworkAdapterName" {

        Context 'NetAdapter does not exist' {

            Mock Get-NetAdapter -ModuleName $script:ModuleName -MockWith $GetNetAdapter_PhysicalNetAdapterMock

            It 'should return false' {
                $Splat = $TestAdapterKeys.Clone()
                Test-xNetworkAdapterName @Splat | Should Be $False

            }
            It 'should call expected Mocks' {
                Assert-MockCalled -ModuleName $script:ModuleName -commandName Get-NetAdapter -Exactly 1
            }
        }

        Context 'NetAdapter exists and should but renamed' {

            Mock Get-NetAdapter -ModuleName $script:ModuleName -MockWith $GetNetAdapter_PhysicalNetAdapterMock

            It 'should return false' {
                {
                    $Splat = $TestAdapterKeys.Clone()
                    Test-xNetworkAdapterName @Splat | Should Be $False
                } | Should Not Throw
            }
            It 'should call expected Mocks' {
                Assert-MockCalled -ModuleName $script:ModuleName -commandName Get-NetAdapter -Exactly 1
            }
        }

    }

    Describe "xNetworkAdapter\Test-ResourceProperty" {

        Context 'TBD' {
        }
    }
    #endregion
}
finally
{
    #region FOOTER
    #endregion
}
