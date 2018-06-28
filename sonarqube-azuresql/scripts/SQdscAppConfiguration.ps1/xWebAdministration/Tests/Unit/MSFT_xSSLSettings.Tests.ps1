
$script:DSCModuleName = 'xWebAdministration'
$script:DSCResourceName = 'MSFT_xSSLSettings'

#region HEADER
$script:moduleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
 if ( (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests'))) -or `
      (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1'))) )
{
    & git @('clone','https://github.com/PowerShell/DscResource.Tests.git',(Join-Path -Path $script:moduleRoot -ChildPath '\DSCResource.Tests\'))
}

Import-Module (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1') -Force

Import-Module (Join-Path -Path $script:moduleRoot -ChildPath 'Tests\MockWebAdministrationWindowsFeature.psm1')

$TestEnvironment = Initialize-TestEnvironment `
    -DSCModuleName $script:DSCModuleName `
    -DSCResourceName $script:DSCResourceName `
    -TestType Unit
#endregion

# Begin Testing

try
{
    #region Pester Tests

    InModuleScope $DSCResourceName {

        Describe "$script:DSCResourceName\Test-TargetResource" {
            Context 'Ensure is Present and SSLSettings is Present' {
                Mock Get-TargetResource -Verifiable {return @{
                    Name = 'Test'
                    Bindings = @('Ssl')
                    Ensure = 'Present'
                }}

                $result = Test-TargetResource -Name 'Test' -Ensure 'Present' -Bindings 'Ssl'

                Assert-VerifiableMocks

                It 'should return true' {
                    $result | should be $true
                }
            }

            Context 'Ensure is Absent and SslSettings is Absent' {
                Mock Get-TargetResource {return @{
                    Name = 'Test'
                    Bindings = @('Ssl')
                    Ensure = 'Absent'
                }}

                $result = Test-TargetResource -Name 'Test' -Ensure 'Absent' -Bindings 'Ssl'

                Assert-VerifiableMocks

                It 'should return true' {
                    $result | should be $true
                }
            }

            Context 'Ensure is Present and SslSettings is Absent' {
                Mock Get-TargetResource {return @{
                    Name = 'Test'
                    Bindings = @('Ssl')
                    Ensure = 'Absent'
                }}

                $result = Test-TargetResource -Name 'Test' -Ensure 'Present' -Bindings 'Ssl'

                Assert-VerifiableMocks

                It 'should return true' {
                    $result | should be $false
                }
            }
        }

        Describe "$script:DSCResourceName\Get-TargetResource" {
            Context 'Command finds SSL Settings' {
                Mock Assert-Module -Verifiable {}
                Mock Get-WebConfigurationProperty -Verifiable { return 'Ssl' }

                $result = Get-TargetResource -Name 'Name' -Bindings 'Ssl'
                $expected = @{
                    Name = 'Name'
                    Bindings = 'Ssl'
                    Ensure = 'Present'
                }

                Assert-VerifiableMocks

                It 'should return the correct bindings' {
                    $result.Bindings | should be $expected.Bindings
                }

                It 'should return the correct ensure' {
                    $result.Ensure | Should Be $expected.Ensure
                }
            }

            Context 'Command does not find Ssl Settings' {
                Mock Assert-Module -Verifiable {}
                Mock Get-WebConfigurationProperty -Verifiable { return $false }

                $result = Get-TargetResource -Name 'Name' -Bindings 'Ssl'
                $expected = @{
                    Name = 'Name'
                    Bindings = 'Ssl'
                    Ensure = 'Absent'
                }

                Assert-VerifiableMocks

                It 'should return the correct bindings' {
                    $result.Bindings | should be $expected.Bindings
                }

                It 'should return the correct ensure' {
                    $result.Ensure | Should Be $expected.Ensure
                }
            }
        }

        Describe "$script:DSCResourceName\Set-TargetResource" {
            Context 'SSL Bindings set to none' {
                Mock Assert-Module -Verifiable { }
                Mock Set-WebConfigurationProperty -Verifiable {}

                $result = (Set-TargetResource -Name 'Name' -Bindings '' -Ensure 'Present' -Verbose) 4>&1

                # Check that the LocalizedData message from the Set-TargetResource is correct
                $resultMessage = $LocalizedData.SettingSSLConfig -f 'Name', ''

                Assert-VerifiableMocks

                It 'should return the correct string' {
                    $result | Should Be $resultMessage
                }
            }

            Context 'Ssl Bindings set to Ssl' {
                Mock Assert-Module -Verifiable { }
                Mock Set-WebConfigurationProperty -Verifiable {}

                $result = (Set-TargetResource -Name 'Name' -Bindings 'Ssl' -Ensure 'Present' -Verbose) 4>&1

                # Check that the LocalizedData message from the Set-TargetResource is correct
                $resultMessage = $LocalizedData.SettingSSLConfig -f 'Name', 'Ssl'

                Assert-VerifiableMocks

                It 'should return the correct string' {
                    $result | Should Be $resultMessage
                }
            }

            Context 'Ssl Bindings set to Ssl,SslNegotiateCert,SslRequireCert' {
                Mock Assert-Module -Verifiable {}
                Mock Set-WebConfigurationProperty -Verifiable {}

                $result = (Set-TargetResource -Name 'Name' -Bindings @('Ssl','SslNegotiateCert','SslRequireCert') -Ensure 'Present' -Verbose) 4>&1

                # Check that the LocalizedData message from the Set-TargetResource is correct
                $resultMessage = $LocalizedData.SettingSSLConfig -f 'Name', 'Ssl,SslNegotiateCert,SslRequireCert'

                Assert-VerifiableMocks

                It 'should return the correct string' {
                    $result | Should Be $resultMessage
                }
            }
        }
    }
}
finally
{
    #region FOOTER
    Restore-TestEnvironment -TestEnvironment $TestEnvironment
    #endregion
}
