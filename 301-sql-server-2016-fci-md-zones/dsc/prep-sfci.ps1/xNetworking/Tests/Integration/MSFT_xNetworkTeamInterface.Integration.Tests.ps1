#Remove this following line before using this integration test script
return

$Global:DSCModuleName      = 'xNetworking'
$Global:DSCResourceName    = 'MSFT_xNetworkTeamInterface'
$Global:teamMembers        = (Get-NetAdapter -Physical).Name

#region HEADER
# Integration Test Template Version: 1.1.0
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
    -TestType Integration 
#endregion

# Using try/finally to always cleanup even if something awful happens.
try
{
    #region Integration Tests
    $ConfigFile = Join-Path -Path $PSScriptRoot -ChildPath "$($Global:DSCResourceName).config.ps1"
    . $ConfigFile -Verbose -ErrorAction Stop

    Describe "$($Global:DSCResourceName)_Integration" {
        #region DEFAULT TESTS
        It 'Should compile without throwing' {
            {
                Invoke-Expression -Command "$($Global:DSCResourceName)_Config -OutputPath `$TestEnvironment.WorkingFolder"
                Start-DscConfiguration -Path $TestEnvironment.WorkingFolder -ComputerName localhost -Wait -Verbose -Force
            } | Should not throw
        }

        It 'should be able to call Get-DscConfiguration without throwing' {
            Start-Sleep -Seconds 30
            { Get-DscConfiguration -Verbose -ErrorAction Stop } | Should Not throw
        }
        #endregion

        It 'Should have set the resource and all the parameters should match' {
            $result = Get-DscConfiguration    | Where-Object {$_.ConfigurationName -eq "$($Global:DSCResourceName)_Config"}
            $result[0].Ensure                 | Should Be $TestTeam.Ensure
            $result[0].Name                   | Should Be $TestTeam.Name
            $result[0].TeamMembers            | Should Be $Global:teamMembers
            $result[0].loadBalancingAlgorithm | Should Be $TestTeam.loadBalancingAlgorithm
            $result[0].teamingMode            | Should Be $TestTeam.teamingMode
            $result[1].Ensure                 | Should Be $TestInterface.Ensure
            $result[1].Name                   | Should Be $TestInterface.Name
            $result[1].TeamName               | Should be $TestInterface.TeamName
            $result[1].VlanID                 | Should be $TestInterface.VlanID
        }
        
        Remove-NetLbfoTeamNic `
            -Team $TestInterface.TeamName `
            -VlanID $TestInterface.VlanID `
            -Confirm:$false

        Remove-NetLbfoTeam `
            -Name $TestTeam.Name `
            -Confirm:$false
    }
    #endregion
}
finally
{
    #region FOOTER
    Restore-TestEnvironment -TestEnvironment $TestEnvironment
    #endregion
}
