$script:DSCModuleName      = 'xStorage'
$script:DSCResourceName    = 'MSFT_xWaitForVolume'

Import-Module -Name (Join-Path -Path (Join-Path -Path (Split-Path $PSScriptRoot -Parent) -ChildPath 'TestHelpers') -ChildPath 'CommonTestHelper.psm1')

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

    # The InModuleScope command allows you to perform white-box unit testing on the internal
    # (non-exported) code of a Script Module.
    InModuleScope $script:DSCResourceName {
        #region Pester Test Initialization
        $mockedDriveC = [pscustomobject] @{
            DriveLetter      = 'C'
        }
        $driveCParameters = @{
            DriveLetter      = 'C'
            RetryIntervalSec = 5
            RetryCount       = 20
        }
        #endregion

        #region Function Get-TargetResource
        Describe "MSFT_xWaitForVolume\Get-TargetResource" {
            $resource = Get-TargetResource @driveCParameters -Verbose
            It "DriveLetter Should Be $($driveCParameters.DriveLetter)" {
                $resource.DriveLetter | Should Be $driveCParameters.DriveLetter
            }

            It "RetryIntervalSec Should Be $($driveCParameters.RetryIntervalSec)" {
                $resource.RetryIntervalSec | Should Be $driveCParameters.RetryIntervalSec
            }

            It "RetryIntervalSec Should Be $($driveCParameters.RetryCount)" {
                $resource.RetryCount | Should Be $driveCParameters.RetryCount
            }

            It 'the correct mocks were called' {
                Assert-VerifiableMocks
            }
        }
        #endregion

        #region Function Set-TargetResource
        Describe 'MSFT_xWaitForVolume\Set-TargetResource' {
            Mock Start-Sleep
            Mock Get-PSDrive

            Context 'drive C is ready' {
                # verifiable (Should Be called) mocks
                Mock Get-Volume -MockWith { return $mockedDriveC } -Verifiable

                It 'should not throw' {
                    { Set-targetResource @driveCParameters -Verbose } | Should Not throw
                }

                It 'the correct mocks were called' {
                    Assert-VerifiableMocks
                    Assert-MockCalled -CommandName Start-Sleep -Times 0
                    Assert-MockCalled -CommandName Get-PSDrive -Times 0
                    Assert-MockCalled -CommandName Get-Volume -Times 1
                }
            }
            Context 'drive C does not become ready' {
                # verifiable (Should Be called) mocks
                Mock Get-Volume -MockWith { } -Verifiable

                $errorRecord = Get-InvalidOperationRecord `
                    -Message $($LocalizedData.VolumeNotFoundAfterError `
                        -f $driveCParameters.DriveLetter,$driveCParameters.RetryCount)

                It 'should throw VolumeNotFoundAfterError' {
                    { Set-targetResource @driveCParameters -Verbose } | Should Throw $errorRecord
                }

                It 'the correct mocks were called' {
                    Assert-VerifiableMocks
                    Assert-MockCalled -CommandName Start-Sleep -Times $driveCParameters.RetryCount
                    Assert-MockCalled -CommandName Get-PSDrive -Times $driveCParameters.RetryCount
                    Assert-MockCalled -CommandName Get-Volume -Times $driveCParameters.RetryCount
                }
            }
        }
        #endregion

        #region Function Test-TargetResource
        Describe 'MSFT_xWaitForVolume\Test-TargetResource' {
            Mock Get-PSDrive

            Context 'drive C is ready' {
                # verifiable (Should Be called) mocks
                Mock Get-Volume -MockWith { return $mockedDriveC } -Verifiable

                $script:result = $null

                It 'calling test should not throw' {
                    {
                        $script:result = Test-TargetResource @driveCParameters -Verbose
                    } | Should Not Throw
                }

                It "result Should Be true" {
                    $script:result | Should Be $true
                }

                It "the correct mocks were called" {
                    Assert-VerifiableMocks
                    Assert-MockCalled -CommandName Get-PSDrive -Times 1
                    Assert-MockCalled -CommandName Get-Volume -Times 1
                }
            }
            Context 'drive C is not ready' {
                # verifiable (Should Be called) mocks
                Mock Get-Volume -MockWith { } -Verifiable

                $script:result = $null

                It 'calling test should not throw' {
                    {
                        $script:result = Test-TargetResource @driveCParameters -Verbose
                    } | Should Not Throw
                }

                It 'result Should Be false' {
                    $script:result | Should Be $false
                }

                It 'the correct mocks were called' {
                    Assert-VerifiableMocks
                    Assert-MockCalled -CommandName Get-PSDrive -Times 1
                    Assert-MockCalled -CommandName Get-Volume -Times 1
                }
            }
        }
        #endregion
    }
}
finally
{
    #region FOOTER
    Restore-TestEnvironment -TestEnvironment $TestEnvironment
    #endregion

}
