$script:DSCModuleName      = 'xNetworking'
$script:DSCResourceName    = 'MSFT_xNetConnectionProfile'

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

        Describe "MSFT_xNetConnectionProfile\Get-TargetResource" {
            Mock Get-NetConnectionProfile {
                return @{
                    InterfaceAlias   = 'InterfaceAlias'
                    NetworkCategory  = 'Wired'
                    IPv4Connectivity = 'IPv4'
                    IPv6Connectivity = 'IPv6'
                }
            }
            $expected = Get-NetConnectionProfile | select -first 1
            $result = Get-TargetResource -InterfaceAlias $expected.InterfaceAlias

            It 'Should return the correct values' {
                $expected.InterfaceAlias   | Should Be $result.InterfaceAlias
                $expected.NetworkCategory  | Should Be $result.NetworkCategory
                $expected.IPv4Connectivity | Should Be $result.IPv4Connectivity
                $expected.IPv6Connectivity | Should Be $result.IPv6Connectivity
            }
        }

        Describe "MSFT_xNetConnectionProfile\Test-TargetResource" {
            $Splat = @{
                InterfaceAlias   = 'Test'
                NetworkCategory  = 'Private'
                IPv4Connectivity = 'Internet'
                IPv6Connectivity = 'Disconnected'
            }

            Context 'IPv4Connectivity is incorrect' {
                $incorrect = $Splat.Clone()
                $incorrect.IPv4Connectivity = 'Disconnected'
                Mock Get-TargetResource {
                    return $incorrect
                }

                It 'should return false' {
                    Test-TargetResource @Splat | should be $false
                }
            }

            Context 'IPv6Connectivity is incorrect' {
                $incorrect = $Splat.Clone()
                $incorrect.IPv6Connectivity = 'Internet'
                Mock Get-TargetResource {
                    return $incorrect
                }

                It 'should return false' {
                    Test-TargetResource @Splat | should be $false
                }
            }

            Context 'NetworkCategory is incorrect' {
                $incorrect = $Splat.Clone()
                $incorrect.NetworkCategory = 'Public'
                Mock Get-TargetResource {
                    return $incorrect
                }

                It 'should return false' {
                    Test-TargetResource @Splat | should be $false
                }
            }
        }

        Describe "MSFT_xNetConnectionProfile\Set-TargetResource" {
            It 'Should do call all the mocks' {
                $Splat = @{
                    InterfaceAlias   = 'Test'
                    NetworkCategory  = 'Private'
                    IPv4Connectivity = 'Internet'
                    IPv6Connectivity = 'Disconnected'
                }

                Mock Set-NetConnectionProfile {}

                Set-TargetResource @Splat

                Assert-MockCalled Set-NetConnectionProfile
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
