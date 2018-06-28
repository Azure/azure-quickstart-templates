
$script:DSCModuleName = 'xWebAdministration'
$script:DSCResourceName = 'MSFT_xIISHandler'

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

        #region Function Get-TargetResource
        Describe 'MSFT_xIISHandler\Get-TargetResource' {
            Context 'Ensure = Absent and Handler is not Present' {
                Mock Assert-Module
                Mock Get-Handler

                It 'Should return the right hashtable' {
                    $result = Get-TargetResource -Name 'StaticFile' -Ensure 'Absent'
                    $result.Ensure | Should Be 'Absent'
                    $result.Name   | Should Be 'StaticFile'
                }
            }
            Context 'Ensure = Present and Handler is Present' {
                Mock Assert-Module
                Mock Get-Handler {'Present'}

                It 'Should return the right hashtable' {
                    $result = Get-TargetResource -Name 'StaticFile' -Ensure 'Present'
                    $result.Ensure | Should Be 'Present'
                    $result.Name   | Should Be 'StaticFile'
                }
            }
        }
        #endregion


        #region Function Test-TargetResource
        Describe 'MSFT_xIISHandler\Test-TargetResource' {
            $Name = 'StaticFile'

            Context 'Handler is NULL and Ensure = Present' {
                Mock Assert-Module
                Mock Get-Handler

                $result = Test-TargetResource -Name $Name -Ensure 'Present' -Verbose *>&1
                It 'Should return False' {
                    $result[0] | Should Be $false
                }

                It 'Should not return a verbose message' {
                    $result[1] | Should Be $null
                }
            }

            Context 'Handler is Present and Ensure = Present' {
                Mock Assert-Module
                Mock Get-Handler {'Present'}

                $result = Test-TargetResource -Name $Name -Ensure 'Present' -Verbose *>&1

                It 'Should return the correct verbose message' {
                    $result[0] | Should Be ($LocalizedData.HandlerExists -f $Name)
                }

                It 'Should return False' {
                    $result[1] | Should Be $true
                }
            }

            Context 'Handler is Present and Ensure = Absent' {
                Mock Assert-Module
                Mock Get-Handler {'Present'}

                $result = Test-TargetResource -Name $Name -Ensure 'Absent' -Verbose *>&1
                It 'Should return False' {
                    $result[0] | Should Be $false
                }

                It 'Should not return a verbose message' {
                    $result[1] | Should Be $null
                }
            }

            Context 'Handler is Present and Ensure = Present' {
                Mock Assert-Module
                Mock Get-Handler

                $result = Test-TargetResource -Name $Name -Ensure 'Absent' -Verbose *>&1

                It 'Should return the correct verbose message' {
                    $result[0] | Should Be ($LocalizedData.HandlerNotPresent -f $Name)
                }

                It 'Should return False' {
                    $result[1] | Should Be $true
                }
            }
        }
        #endregion


        #region Function Set-TargetResource
        Describe 'MSFT_xIISHandler\Set-TargetResource' {
            Context 'Ensure = Present and Handler is NOT present' {
                $mockName = 'StaticFile'
                Mock Assert-Module
                Mock Get-Handler
                Mock Add-Handler {} -ParameterFilter {$Name -eq $mockName}

                $message = Set-TargetResource -Name $mockName -Ensure 'Present' -Verbose 4>&1

                It 'Should add the handler' {
                    Assert-MockCalled Add-Handler -ParameterFilter {$Name -eq $mockName}
                }

                It 'Should call the right Verbose Message' {
                    $message | Should Be ($LocalizedData.AddingHandler -f $mockName)
                }
            }

            Context 'Ensure = Absent and Handler IS present' {
                $mockName = 'StaticFile'
                Mock Assert-Module
                Mock Get-Handler {'Present'}
                Mock Remove-WebConfigurationProperty

                $message = Set-TargetResource -Name $mockName -Ensure 'Absent' -Verbose 4>&1

                It 'Should add the handler' {
                    Assert-MockCalled Remove-WebConfigurationProperty
                }

                It 'Should call the right Verbose Message' {
                    $message | Should Be ($LocalizedData.RemovingHandler -f $mockName)
                }
            }
        }
        #endregion

        Describe 'MSFT_xIISHandler\Add-Handler' {
            Context 'Should find all the handlers' {
                foreach ($key in $script:handlers.keys)
                {
                    Mock Add-WebConfigurationProperty {} -ParameterFilter {$Value -and $Value -eq $script:handlers[$key]}

                    Add-Handler -Name $key
                    It "Should find $key in `$script:handler" {
                        Assert-MockCalled Add-WebConfigurationProperty -Exactly 1 -ParameterFilter {$Value -and $Value -eq $script:handlers[$key]}
                    }
                }
            }

            Context 'It should throw when it cannot find the handler' {
                It 'Should throw an error' {
                    $keyName = 'Non-ExistantKey'
                    {Add-Handler -Name $keyName} | Should throw ($LocalizedData.HandlerNotSupported -f $KeyName)
                }
            }
        }

        Describe 'MSFT_xIISHandler\Get-Handler' {
            It 'Should call the mocks' {
                $name = 'StaticFile'
                $mockFilter = "system.webServer/handlers/Add[@Name='" + $name + "']"
                Mock Get-WebConfigurationProperty {} -ParameterFilter {$Filter -and $Filter -eq $mockFilter}
                Get-Handler -Name $Name
                Assert-MockCalled Get-WebConfigurationProperty
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
