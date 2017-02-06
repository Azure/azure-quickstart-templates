$script:DSCModuleName      = 'xStorage'
$script:DSCResourceName    = 'MSFT_xWaitForDisk'

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
        $mockedDisk0 = [pscustomobject] @{
            Number = 0
            FriendlyName = 'Test Disk'
        }

        $disk0Parameters = @{
            DiskNumber = 00
            RetryIntervalSec = 5
            RetryCount = 20
        }
        #endregion

        #region Function Get-TargetResource
        Describe "MSFT_xWaitForDisk\Get-TargetResource" {
            $resource = Get-TargetResource @disk0Parameters -Verbose
            It "DiskNumber Should Be $($disk0Parameters.DiskNumber)" {
                $resource.DiskNumber | Should Be $disk0Parameters.DiskNumber
            }

            It "RetryIntervalSec Should Be $($disk0Parameters.RetryIntervalSec)" {
                $resource.RetryIntervalSec | Should Be $disk0Parameters.RetryIntervalSec
            }

            It "RetryIntervalSec Should Be $($disk0Parameters.RetryCount)" {
                $resource.RetryCount | Should Be $disk0Parameters.RetryCount
            }

            It 'the correct mocks were called' {
                Assert-VerifiableMocks
            }
        }
        #endregion

        #region Function Set-TargetResource
        Describe 'MSFT_xWaitForDisk\Set-TargetResource' {
            Mock Start-Sleep

            Context 'disk 0 is ready' {
                # verifiable (Should Be called) mocks
                Mock Get-Disk -MockWith { return $mockedDisk0 } -Verifiable

                It 'should not throw' {
                    { Set-targetResource @disk0Parameters -Verbose } | Should Not throw
                }

                It 'the correct mocks were called' {
                    Assert-VerifiableMocks
                    Assert-MockCalled -CommandName Start-Sleep -Times 0
                    Assert-MockCalled -CommandName Get-Disk -Times 1
                }
            }
            Context 'disk 0 does not become ready' {
                # verifiable (Should Be called) mocks
                Mock Get-Disk -MockWith { } -Verifiable

                $errorRecord = Get-InvalidOperationRecord `
                    -Message $($LocalizedData.DiskNotFoundAfterError `
                        -f $disk0Parameters.DiskNumber,$disk0Parameters.RetryCount)

                It 'should throw DiskNotFoundAfterError' {
                    { Set-targetResource @disk0Parameters -Verbose } | Should Throw $errorRecord
                }

                It 'the correct mocks were called' {
                    Assert-VerifiableMocks
                    Assert-MockCalled -CommandName Start-Sleep -Times $disk0Parameters.RetryCount
                    Assert-MockCalled -CommandName Get-Disk -Times 1
                }
            }
        }
        #endregion

        #region Function Test-TargetResource
        Describe 'MSFT_xWaitForDisk\Test-TargetResource' {
            Context 'disk 0 is ready' {
                # verifiable (Should Be called) mocks
                Mock Get-Disk -MockWith { return $mockedDisk0 } -Verifiable

                $script:result = $null

                It 'calling test should not throw' {
                    {
                        $script:result = Test-TargetResource @disk0Parameters -Verbose
                    } | Should Not Throw
                }

                It "result Should Be true" {
                    $script:result | Should Be $true
                }

                It "the correct mocks were called" {
                    Assert-VerifiableMocks
                    Assert-MockCalled -CommandName Get-Disk -Times 1
                }
            }
            Context 'disk 0 is not ready' {
                # verifiable (Should Be called) mocks
                Mock Get-Disk -MockWith { } -Verifiable

                $script:result = $null

                It 'calling test should not throw' {
                    {
                        $script:result = Test-TargetResource @disk0Parameters -Verbose
                    } | Should Not Throw
                }

                It 'result Should Be false' {
                    $script:result | Should Be $false
                }

                It 'the correct mocks were called' {
                    Assert-VerifiableMocks
                    Assert-MockCalled -CommandName Get-Disk -Times 1
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
