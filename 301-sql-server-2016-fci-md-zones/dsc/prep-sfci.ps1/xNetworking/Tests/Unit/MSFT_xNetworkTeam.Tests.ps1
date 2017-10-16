$script:DSCModuleName   = 'xNetworking'
$script:DSCResourceName = 'MSFT_xNetworkTeam'

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
        $MockNetTeam = [PSCustomObject] @{
            Name                = 'HostTeam'
            Members             = @('NIC1','NIC2')
        }

        $TestTeam = [PSObject]@{
            Name                    = $MockNetTeam.Name
            TeamMembers             = $MockNetTeam.Members
        }

        $MockTeam = [PSObject]@{
            Name                    = $TestTeam.Name
            Members                 = $TestTeam.TeamMembers
            loadBalancingAlgorithm  = 'Dynamic'
            teamingMode             = 'SwitchIndependent'
            Ensure                  = 'Present'
        }

        Describe "MSFT_xNetworkTeam\Get-TargetResource" {

            Context 'Team does not exist' {
                Mock Get-NetLbfoTeam
                It 'should return ensure as absent' {
                    $Result = Get-TargetResource `
                        @TestTeam
                    $Result.Ensure | Should Be 'Absent'
                }
                It 'should call the expected mocks' {
                    Assert-MockCalled -commandName Get-NetLbfoTeam -Exactly 1
                }
            }

            Context 'Network Team exists' {
                Mock Get-NetLbfoTeam -MockWith { $MockTeam }
                It 'should return team properties' {
                    $Result = Get-TargetResource @TestTeam
                    $Result.Ensure                 | Should Be 'Present'
                    $Result.Name                   | Should Be $TestTeam.Name
                    $Result.TeamMembers            | Should Be $TestTeam.TeamMembers
                    $Result.loadBalancingAlgorithm | Should Be 'Dynamic'
                    $Result.teamingMode            | Should Be 'SwitchIndependent'
                }
                It 'should call the expected mocks' {
                    Assert-MockCalled -commandName Get-NetLbfoTeam -Exactly 1
                }
            }
        }

        Describe "MSFT_xNetworkTeam\Set-TargetResource" {
            $newTeam = [PSObject]@{
                Name                    = $TestTeam.Name
                TeamMembers             = $TestTeam.TeamMembers
                loadBalancingAlgorithm  = 'Dynamic'
                teamingMode             = 'SwitchIndependent'
                Ensure                  = 'Present'
            }

            Context 'Team does not exist but should' {

                Mock Get-NetLbfoTeam
                Mock New-NetLbfoTeam
                Mock Set-NetLbfoTeam
                Mock Remove-NetLbfoTeamMember
                Mock Add-NetLbfoTeamMember

                It 'should not throw error' {
                    {
                        Set-TargetResource @newTeam
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-NetLbfoTeam -Exactly 1
                    Assert-MockCalled -commandName New-NetLbfoTeam -Exactly 1
                    Assert-MockCalled -commandName Set-NetLbfoTeam -Exactly 0
                    Assert-MockCalled -commandName Remove-NetLbfoTeamMember -Exactly 0
                    Assert-MockCalled -commandName Add-NetLbfoTeamMember -Exactly 0
                }
            }

            Context 'team exists but needs a different teaming mode' {

                Mock Get-NetLbfoTeam -MockWith { $MockTeam }
                Mock New-NetLbfoTeam
                Mock Set-NetLbfoTeam
                Mock Remove-NetLbfoTeam

                It 'should not throw error' {
                    {
                        $updateTeam = $newTeam.Clone()
                        $updateTeam.teamingMode = 'LACP'
                        Set-TargetResource @updateTeam
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-NetLbfoTeam -Exactly 1
                    Assert-MockCalled -commandName New-NetLbfoTeam -Exactly 0
                    Assert-MockCalled -commandName Set-NetLbfoTeam -Exactly 1
                    Assert-MockCalled -commandName Remove-NetLbfoTeam -Exactly 0
                }
            }

            Context 'team exists but needs a different load balacing algorithm' {
                Mock Get-NetLbfoTeam -MockWith { $MockTeam }
                Mock New-NetLbfoTeam
                Mock Set-NetLbfoTeam
                Mock Remove-NetLbfoTeam

                It 'should not throw error' {
                    {
                        $updateTeam = $newTeam.Clone()
                        $updateTeam.loadBalancingAlgorithm = 'HyperVPort'
                        Set-TargetResource @updateTeam
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-NetLbfoTeam -Exactly 1
                    Assert-MockCalled -commandName New-NetLbfoTeam -Exactly 0
                    Assert-MockCalled -commandName Set-NetLbfoTeam -Exactly 1
                    Assert-MockCalled -commandName Remove-NetLbfoTeam -Exactly 0
                }
            }

            Context 'team exists but has to remove a member adapter' {
                Mock Get-NetLbfoTeam -MockWith { $MockTeam }
                Mock New-NetLbfoTeam
                Mock Set-NetLbfoTeam
                Mock Remove-NetLbfoTeam
                Mock Remove-NetLbfoTeamMember

                It 'should not throw error' {
                    {
                        $updateTeam = $newTeam.Clone()
                        $updateTeam.TeamMembers = $newTeam.TeamMembers[0]
                        Set-TargetResource @updateTeam
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-NetLbfoTeam -Exactly 1
                    Assert-MockCalled -commandName New-NetLbfoTeam -Exactly 0
                    Assert-MockCalled -commandName Set-NetLbfoTeam -Exactly 0
                    Assert-MockCalled -commandName Remove-NetLbfoTeam -Exactly 0
                    Assert-MockCalled -commandName Remove-NetLbfoTeamMember -Exactly 1
                }
            }

            Context 'team exists but has to add a member adapter' {
                Mock Get-NetLbfoTeam -MockWith { $MockTeam }
                Mock New-NetLbfoTeam
                Mock Set-NetLbfoTeam
                Mock Remove-NetLbfoTeam
                Mock Remove-NetLbfoTeamMember
                Mock Add-NetLbfoTeamMember

                It 'should not throw error' {
                    {
                        $updateTeam = $newTeam.Clone()
                        $updateTeam.TeamMembers += 'NIC3'
                        Set-TargetResource @updateTeam
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-NetLbfoTeam -Exactly 1
                    Assert-MockCalled -commandName New-NetLbfoTeam -Exactly 0
                    Assert-MockCalled -commandName Set-NetLbfoTeam -Exactly 0
                    Assert-MockCalled -commandName Remove-NetLbfoTeam -Exactly 0
                    Assert-MockCalled -commandName Remove-NetLbfoTeamMember -Exactly 0
                    Assert-MockCalled -commandName Add-NetLbfoTeamMember -Exactly 1
                }
            }

            Context 'team exists but should not exist' {
                Mock Get-NetLbfoTeam -MockWith { $MockTeam }
                Mock New-NetLbfoTeam
                Mock Set-NetLbfoTeam
                Mock Remove-NetLbfoTeam
                Mock Remove-NetLbfoTeamMember
                Mock Add-NetLbfoTeamMember

                It 'should not throw error' {
                    {
                        $updateTeam = $newTeam.Clone()
                        $updateTeam.Ensure = 'absent'
                        Set-TargetResource @updateTeam
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-NetLbfoTeam -Exactly 1
                    Assert-MockCalled -commandName New-NetLbfoTeam -Exactly 0
                    Assert-MockCalled -commandName Set-NetLbfoTeam -Exactly 0
                    Assert-MockCalled -commandName Remove-NetLbfoTeam -Exactly 1
                    Assert-MockCalled -commandName Remove-NetLbfoTeamMember -Exactly 0
                    Assert-MockCalled -commandName Add-NetLbfoTeamMember -Exactly 0
                }
            }
        }

        Describe "MSFT_xNetworkTeam\Test-TargetResource" {
            $newTeam = [PSObject]@{
                Name                    = $TestTeam.Name
                TeamMembers             = $TestTeam.TeamMembers
                loadBalancingAlgorithm  = 'Dynamic'
                teamingMode             = 'SwitchIndependent'
                Ensure                  = 'Present'
            }

            Context 'Team does not exist but should' {
                Mock Get-NetLbfoTeam

                It 'should return false' {
                        Test-TargetResource @newTeam | Should be $false
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-NetLbfoTeam -Exactly 1
                }
            }

            Context 'team exists but needs a different teaming mode' {
                Mock Get-NetLbfoTeam -MockWith { $MockTeam }

                It 'should return false' {
                    $updateTeam = $newTeam.Clone()
                    $updateTeam.teamingMode = 'LACP'
                    Test-TargetResource @updateTeam | Should Be $false
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-NetLbfoTeam -Exactly 1
                }
            }

            Context 'team exists but needs a different load balacing algorithm' {
                Mock Get-NetLbfoTeam -MockWith { $MockTeam }

                It 'should return false' {
                    $updateTeam = $newTeam.Clone()
                    $updateTeam.loadBalancingAlgorithm = 'HyperVPort'
                    Test-TargetResource @updateTeam | Should Be $false
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-NetLbfoTeam -Exactly 1
                }
            }

            Context 'team exists but has to remove a member adapter' {
                Mock Get-NetLbfoTeam -MockWith { $MockTeam }

                It 'should return false' {
                    $updateTeam = $newTeam.Clone()
                    $updateTeam.TeamMembers = $newTeam.TeamMembers[0]
                    Test-TargetResource @updateTeam | Should Be $false
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-NetLbfoTeam -Exactly 1
                }
            }

            Context 'team exists but has to add a member adapter' {
                Mock Get-NetLbfoTeam -MockWith { $MockTeam }

                It 'should return false' {
                    $updateTeam = $newTeam.Clone()
                    $updateTeam.TeamMembers += 'NIC3'
                    Test-TargetResource @updateTeam | Should Be $false
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-NetLbfoTeam -Exactly 1
                }
            }

            Context 'team exists but should not exist' {
                Mock Get-NetLbfoTeam -MockWith { $MockTeam }

                It 'should return $false' {
                    $updateTeam = $newTeam.Clone()
                    $updateTeam.Ensure = 'absent'
                    Test-TargetResource @updateTeam | Should Be $false
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-NetLbfoTeam -Exactly 1
                }
            }

            Context 'team exists and no action needed' {
                Mock Get-NetLbfoTeam -MockWith { $MockTeam }

                It 'should return true' {
                    $updateTeam = $newTeam.Clone()
                    Test-TargetResource @updateTeam | Should Be $true
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-NetLbfoTeam -Exactly 1
                }
            }

            Context 'team does not and no action needed' {
                Mock Get-NetLbfoTeam

                It 'should return true' {
                    $updateTeam = $newTeam.Clone()
                    $updateTeam.Ensure = 'Absent'
                    Test-TargetResource @updateTeam | Should Be $true
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-NetLbfoTeam -Exactly 1
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
