$Global:DSCModuleName   = 'xNetworking'
$Global:DSCResourceName = 'MSFT_xNetworkTeamInterface'

#region HEADER
# Unit Test Template Version: 1.1.0
[String] $moduleRoot = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $Script:MyInvocation.MyCommand.Path))
if ( (-not (Test-Path -Path (Join-Path -Path $moduleRoot -ChildPath 'DSCResource.Tests'))) -or `
     (-not (Test-Path -Path (Join-Path -Path $moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1'))) )
{
    & git @('clone','https://github.com/PowerShell/DscResource.Tests.git',(Join-Path -Path $moduleRoot -ChildPath '\DSCResource.Tests\'))
}

Import-Module (Join-Path -Path $moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1') -Force
$TestEnvironment = Initialize-TestEnvironment `
    -DSCModuleName $Global:DSCModuleName `
    -DSCResourceName $Global:DSCResourceName `
    -TestType Unit
#endregion HEADER

# Begin Testing
try
{
    #region Pester Tests
    InModuleScope $Global:DSCResourceName {
        # Create the Mock Objects that will be used for running tests
        $MockNetTeamNic = [PSCustomObject] @{
            Name                = 'HostTeamNic'
            Team                = 'HostTeam'
        }
        
        $TestTeamNic = [PSObject] @{
            Name                = $MockNetTeamNic.Name
            TeamName            = $MockNetTeamNic.Team
        }
        
        $MockTeamNic = [PSObject] @{
            Name                = $TestTeamNic.Name
            Team                = $TestTeamNic.TeamName
            VlanID              = 100
        }

        Describe "$($Global:DSCResourceName)\Get-TargetResource" {

            Context 'Team Interface does not exist' {
                Mock Get-NetLbfoTeamNic
                It 'should return ensure as absent' {
                    $Result = Get-TargetResource @TestTeamNic
                    $Result.Ensure | Should Be 'Absent'
                }
                It 'should call the expected mocks' {
                    Assert-MockCalled -commandName Get-NetLbfoTeamNic -Exactly 1
                }
            }

            Context 'Network Team Interface exists' {
                Mock Get-NetLbfoTeamNic -MockWith { $MockTeamNic }
                It 'should return team properties' {
                    $Result = Get-TargetResource @TestTeamNic
                    $Result.Ensure                 | Should Be 'Present'
                    $Result.Name                   | Should Be $TestTeamNic.Name
                    $Result.TeamName               | Should Be $TestTeamNic.TeamName
                    $Result.VlanID                 | Should be 100
                }
                It 'should call the expected mocks' {
                    Assert-MockCalled -commandName Get-NetLbfoTeamNic -Exactly 1
                }
            }
        }

        Describe "$($Global:DSCResourceName)\Set-TargetResource" {
            $newTeamNic = [PSObject] @{
                Name            = $TestTeamNic.Name
                TeamName        = $TestTeamNic.TeamName
                VlanID          = 100
            }

            Context 'Team Interface does not exist but should' {

                Mock Get-NetLbfoTeamNic
                Mock Add-NetLbfoTeamNic
                Mock Set-NetLbfoTeamNic

                It 'should not throw error' {
                    {
                        Set-TargetResource @newTeamNic
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-NetLbfoTeamNic -Exactly 1
                    Assert-MockCalled -commandName Add-NetLbfoTeamNic -Exactly 1
                    Assert-MockCalled -commandName Set-NetLbfoTeamNic -Exactly 0
                }
            }

            Context 'Team Interface exists but needs a different VlanID' {

                Mock Get-NetLbfoTeamNic -MockWith { $MockTeamNic }
                Mock Add-NetLbfoTeamNic
                Mock Set-NetLbfoTeamNic

                It 'should not throw error' {
                    {
                        $updateTeamNic = $newTeamNic.Clone()
                        $updateTeamNic.VlanID = 105
                        Set-TargetResource @updateTeamNic
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-NetLbfoTeamNic -Exactly 1
                    Assert-MockCalled -commandName Add-NetLbfoTeamNic -Exactly 0
                    Assert-MockCalled -commandName Set-NetLbfoTeamNic -Exactly 1
                }
            }

            Context 'Team Interface exists but should not exist' {
                Mock Get-NetLbfoTeamNic -MockWith { $MockTeamNic }
                Mock Add-NetLbfoTeamNic
                Mock Set-NetLbfoTeamNic
                Mock Remove-NetLbfoTeamNic

                It 'should not throw error' {
                    {
                        $updateTeamNic = $newTeamNic.Clone()
                        $updateTeamNic.Ensure = 'absent'
                        Set-TargetResource @updateTeamNic
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-NetLbfoTeamNic -Exactly 1
                    Assert-MockCalled -commandName Add-NetLbfoTeamNic -Exactly 0
                    Assert-MockCalled -commandName Set-NetLbfoTeamNic -Exactly 0
                    Assert-MockCalled -commandName Remove-NetLbfoTeamNic -Exactly 1
                }
            }
        }

        Describe "$($Global:DSCResourceName)\Test-TargetResource" {
            $newTeamNic = [PSObject] @{
                Name            = $TestTeamNic.Name
                TeamName        = $TestTeamNic.TeamName
                VlanID          = 100
            }

            Context 'Team Interface does not exist but should' {
                Mock Get-NetLbfoTeamNic

                It 'should return false' {
                        Test-TargetResource @newTeamNic | Should be $false
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-NetLbfoTeamNic -Exactly 1
                }
            }

            Context 'Team Interface exists but needs a different VlanID' {
                Mock Get-NetLbfoTeamNic -MockWith { $MockTeam }

                It 'should return false' {
                    $updateTeamNic = $newTeamNic.Clone()
                    $updateTeamNic.VlanID = 105
                    Test-TargetResource @updateTeamNic | Should Be $false
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-NetLbfoTeamNic -Exactly 1
                }
            }
            
            Context 'Team Interface exists but should not exist' {
                Mock Get-NetLbfoTeamNic -MockWith { $MockTeamNic }

                It 'should return $false' {
                    $updateTeamNic = $newTeamNic.Clone()
                    $updateTeamNic.Ensure = 'absent'
                    Test-TargetResource @updateTeamNic | Should Be $false
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-NetLbfoTeamNic -Exactly 1
                }
            }

            Context 'Team Interface exists and no action needed' {
                Mock Get-NetLbfoTeamNic -MockWith { $MockTeamNic }

                It 'should return true' {
                    $updateTeamNic = $newTeamNic.Clone()
                    Test-TargetResource @updateTeamNic | Should Be $true
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-NetLbfoTeamNic -Exactly 1
                }
            }

            Context 'Team Interface does not exist and no action needed' {
                Mock Get-NetLbfoTeamNic

                It 'should return true' {
                    $updateTeamNic = $newTeamNic.Clone()
                    $updateTeamNic.Ensure = 'Absent'
                    Test-TargetResource @updateTeamNic | Should Be $true
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-NetLbfoTeamNic -Exactly 1
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
