$script:DSCModuleName   = 'xNetworking'
$script:DSCResourceName = 'MSFT_xDnsClientGlobalSetting'

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
        $DnsClientGlobalSettings = [PSObject]@{
            SuffixSearchList             = 'contoso.com'
            DevolutionLevel              = 1
            UseDevolution                = $True
        }
        $DnsClientGlobalSettingsSplat = [PSObject]@{
            IsSingleInstance             = 'Yes'
            SuffixSearchList             = $DnsClientGlobalSettings.SuffixSearchList
            DevolutionLevel              = $DnsClientGlobalSettings.DevolutionLevel
            UseDevolution                = $DnsClientGlobalSettings.UseDevolution
        }

        Describe "MSFT_xDnsClientGlobalSetting\Get-TargetResource" {

            Context 'DNS Client Global Settings Exists' {

                Mock Get-DnsClientGlobalSetting -MockWith { $DnsClientGlobalSettings }

                It 'should return correct DNS Client Global Settings values' {
                    $Result = Get-TargetResource -IsSingleInstance 'Yes'
                    $Result.SuffixSearchList          | Should Be $DnsClientGlobalSettings.SuffixSearchList
                    $Result.DevolutionLevel           | Should Be $DnsClientGlobalSettings.DevolutionLevel
                    $Result.UseDevolution             | Should Be $DnsClientGlobalSettings.UseDevolution
                }
                It 'should call the expected mocks' {
                    Assert-MockCalled -CommandName Get-DnsClientGlobalSetting -Exactly 1
                }
            }
        }

        Describe "MSFT_xDnsClientGlobalSetting\Set-TargetResource" {

            Mock Get-DnsClientGlobalSetting -MockWith { $DnsClientGlobalSettings }
            Mock Set-DnsClientGlobalSetting

            Context 'DNS Client Global Settings all parameters are the same' {
                It 'should not throw error' {
                    {
                        $Splat = $DnsClientGlobalSettingsSplat.Clone()
                        Set-TargetResource @Splat
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-DnsClientGlobalSetting -Exactly 1
                    Assert-MockCalled -commandName Set-DnsClientGlobalSetting -Exactly 0
                }
            }

            Context 'DNS Client Global Settings SuffixSearchList is different' {
                It 'should not throw error' {
                    {
                        $Splat = $DnsClientGlobalSettingsSplat.Clone()
                        $Splat.SuffixSearchList = 'fabrikam.com'
                        Set-TargetResource @Splat
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-DnsClientGlobalSetting -Exactly 1
                    Assert-MockCalled -commandName Set-DnsClientGlobalSetting -Exactly 1
                }
            }

            Context 'DNS Client Global Settings DevolutionLevel is different' {
                It 'should not throw error' {
                    {
                        $Splat = $DnsClientGlobalSettingsSplat.Clone()
                        $Splat.DevolutionLevel = $Splat.DevolutionLevel + 1
                        Set-TargetResource @Splat
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-DnsClientGlobalSetting -Exactly 1
                    Assert-MockCalled -commandName Set-DnsClientGlobalSetting -Exactly 1
                }
            }

            Context 'DNS Client Global Settings UseDevolution is different' {
                It 'should not throw error' {
                    {
                        $Splat = $DnsClientGlobalSettingsSplat.Clone()
                        $Splat.UseDevolution = -not $Splat.UseDevolution
                        Set-TargetResource @Splat
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-DnsClientGlobalSetting -Exactly 1
                    Assert-MockCalled -commandName Set-DnsClientGlobalSetting -Exactly 1
                }
            }
        }

        Describe "MSFT_xDnsClientGlobalSetting\Test-TargetResource" {

            Mock Get-DnsClientGlobalSetting -MockWith { $DnsClientGlobalSettings }

            Context 'DNS Client Global Settings all parameters are the same' {
                It 'should return true' {
                    $Splat = $DnsClientGlobalSettingsSplat.Clone()
                    Test-TargetResource @Splat | Should Be $True
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-DnsClientGlobalSetting -Exactly 1
                }
            }

            Context 'DNS Client Global Settings SuffixSearchList is different' {
                It 'should return false' {
                    $Splat = $DnsClientGlobalSettingsSplat.Clone()
                    $Splat.SuffixSearchList = 'fabrikam.com'
                    Test-TargetResource @Splat | Should Be $False
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-DnsClientGlobalSetting -Exactly 1
                }
            }

            Context 'DNS Client Global Settings DevolutionLevel is different' {
                It 'should return false' {
                    $Splat = $DnsClientGlobalSettingsSplat.Clone()
                    $Splat.DevolutionLevel = $Splat.DevolutionLevel + 1
                    Test-TargetResource @Splat | Should Be $False
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-DnsClientGlobalSetting -Exactly 1
                }
            }

            Context 'DNS Client Global Settings UseDevolution is different' {
                It 'should return false' {
                    $Splat = $DnsClientGlobalSettingsSplat.Clone()
                    $Splat.UseDevolution = -not $Splat.UseDevolution
                    Test-TargetResource @Splat | Should Be $False
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-DnsClientGlobalSetting -Exactly 1
                }
            }
        }

        Describe "MSFT_xDnsClientGlobalSetting\New-TerminatingError" {

            Context 'Create a TestError Exception' {

                It 'should throw an TestError exception' {
                    $errorId = 'TestError'
                    $errorCategory = [System.Management.Automation.ErrorCategory]::InvalidArgument
                    $errorMessage = 'Test Error Message'
                    $exception = New-Object `
                        -TypeName System.InvalidOperationException `
                        -ArgumentList $errorMessage
                    $errorRecord = New-Object `
                        -TypeName System.Management.Automation.ErrorRecord `
                        -ArgumentList $exception, $errorId, $errorCategory, $null

                    { New-TerminatingError `
                        -ErrorId $errorId `
                        -ErrorMessage $errorMessage `
                        -ErrorCategory $errorCategory } | Should Throw $errorRecord
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
