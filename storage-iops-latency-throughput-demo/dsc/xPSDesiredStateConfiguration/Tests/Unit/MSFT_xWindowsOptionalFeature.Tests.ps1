Import-Module -Name (Join-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -ChildPath 'CommonTestHelper.psm1')

$script:testEnvironment = Enter-DscResourceTestEnvironment `
    -DscResourceModuleName 'xPSDesiredStateConfiguration' `
    -DscResourceName 'MSFT_xWindowsOptionalFeature' `
    -TestType 'Unit'

try
{
    InModuleScope 'MSFT_xWindowsOptionalFeature' {
        Describe 'xWindowsOptionalFeature Unit Tests' {
            BeforeAll {
                Import-Module -Name 'Dism'

                $script:testFeatureName = 'TestFeature'

                $script:fakeEnabledFeature = [PSCustomObject] @{ 
                    Name = $testFeatureName
                    State = 'Enabled'
                }

                $script:fakeDisabledFeature = [PSCustomObject] @{
                    Name = $testFeatureName
                    State = 'Disabled'
                }
            }

            <#
                This context block needs to stay at the top because of a bug in Pester on Nano server.
                
                Assert-ResourcePrerequisitesValid is mocked in most of the other contexts blocks.
                This causes errors to throw from the script blocks in this context since this function does
                not take any parameters, but Pester tries to pipe something into it.

                This bug does not occur on full server machines.
            #>
            Context 'Assert-ResourcePrerequisitesValid' {
                $fakeWin32OSObjects = @{
                    '7' = [PSCustomObject] @{
                        ProductType = 1
                        BuildNumber = 7601
                    }
                    'Server2008R2' = [PSCustomObject] @{
                        ProductType = 2
                        BuildNumber = 7601
                    }
                    'Server2012' = [PSCustomObject] @{
                        ProductType = 2
                        BuildNumber = 9200
                    }
                    '8.1' = [PSCustomObject] @{
                        ProductType = 1
                        BuildNumber = 9600
                    }
                    'Server2012R2' = [PSCustomObject] @{
                        ProductType = 2
                        BuildNumber = 9600
                    }
                }
                
                It 'Should throw when the DISM module is not available' {
                    Mock Import-Module -ParameterFilter { $Name -eq 'Dism' } -MockWith { Write-Error 'Cannot find module' }
                    { Assert-ResourcePrerequisitesValid } | Should Throw $script:localizedData.DismNotAvailable
                }

                Mock Import-Module -ParameterFilter { $Name -eq 'Dism' } -MockWith { }

                It 'Should throw when operating system is Server 2008 R2' {
                    Mock Get-CimInstance -ParameterFilter { $ClassName -eq 'Win32_OperatingSystem' } -MockWith { return $fakeWin32OSObjects['Server2008R2'] }
                    { Assert-ResourcePrerequisitesValid } | Should Throw $script:localizedData.NotSupportedSku
                }

                It 'Should throw when operating system is Server 2012' {
                    Mock Get-CimInstance -ParameterFilter { $ClassName -eq 'Win32_OperatingSystem' } -MockWith { return $fakeWin32OSObjects['Server2012'] }
                    { Assert-ResourcePrerequisitesValid } | Should Throw $script:localizedData.NotSupportedSku
                }

                It 'Should not throw when operating system is Windows 7' {
                    Mock Get-CimInstance -ParameterFilter { $ClassName -eq 'Win32_OperatingSystem' } -MockWith { return $fakeWin32OSObjects['7'] }
                    { Assert-ResourcePrerequisitesValid } | Should Not Throw
                }

                It 'Should not throw when operating system is Windows 8.1' {
                    Mock Get-CimInstance -ParameterFilter { $ClassName -eq 'Win32_OperatingSystem' } -MockWith { return $fakeWin32OSObjects['8.1'] }
                    { Assert-ResourcePrerequisitesValid } | Should Not Throw
                }

                It 'Should not throw when operating system is Server 2012 R2' {
                    Mock Get-CimInstance -ParameterFilter { $ClassName -eq 'Win32_OperatingSystem' } -MockWith { return $fakeWin32OSObjects['Server2012R2'] }
                    { Assert-ResourcePrerequisitesValid } | Should Not Throw
                }
            }

            Context 'Get-TargetResource - Feature Enabled' {
                Mock Assert-ResourcePrerequisitesValid -MockWith { }
                Mock Dism\Get-WindowsOptionalFeature { $FeatureName -eq $script:testFeatureName } -MockWith { return $script:fakeEnabledFeature }

                It 'Should return a Hashtable' {
                    $getTargetResourceResult = Get-TargetResource -Name $script:testFeatureName
                    $getTargetResourceResult -is [System.Collections.Hashtable] | Should Be $true
                }

                It 'Should call Assert-ResourcePrerequisitesValid with the feature name' {
                    $getTargetResourceResult = Get-TargetResource -Name $script:testFeatureName
                    Assert-MockCalled Dism\Get-WindowsOptionalFeature -ParameterFilter { $FeatureName -eq $script:testFeatureName } -Scope It
                }

                It 'Should return Ensure as Present' {
                    $getTargetResourceResult = Get-TargetResource -Name $script:testFeatureName
                    $getTargetResourceResult.Ensure | Should Be 'Present'
                }
            }

            
            Context 'Get-TargetResource - Feature Disabled' {
                Mock Assert-ResourcePrerequisitesValid -MockWith { }
                Mock Dism\Get-WindowsOptionalFeature { $FeatureName -eq $script:testFeatureName } -MockWith { return $script:fakeDisabledFeature }

                It 'Should return Ensure as Absent' {
                    $getTargetResourceResult = Get-TargetResource -Name $script:testFeatureName
                    $getTargetResourceResult.Ensure | Should Be 'Absent'
                }
            }

            Context 'Test-TargetResource - Feature Enabled' {
                Mock Assert-ResourcePrerequisitesValid -MockWith { }
                Mock Dism\Get-WindowsOptionalFeature { $FeatureName -eq $script:testFeatureName } -MockWith { return $script:fakeEnabledFeature }

                It 'Should return true when Ensure set to Present' {
                    Test-TargetResource -Name $testFeatureName -Ensure 'Present' | Should Be $true
                }

                It 'Should return false when Ensure set to Absent' {
                    Test-TargetResource -Name $testFeatureName -Ensure 'Absent' | Should Be $false
                }

            }

            Context 'Test-TargetResource - Feature Disabled' {
                Mock Assert-ResourcePrerequisitesValid -MockWith { }
                Mock Dism\Get-WindowsOptionalFeature { $FeatureName -eq $script:testFeatureName } -MockWith { return $script:fakeDisabledFeature }

                It 'Should return false when Ensure set to Present' {
                    Test-TargetResource -Name $testFeatureName -Ensure 'Present' | Should Be $false
                }

                It 'Should return true when Ensure set to Absent' {
                    Test-TargetResource -Name $testFeatureName -Ensure 'Absent' | Should Be $true
                }
            }

            Context 'Test-TargetResource - Feature Missing' {
                Mock Assert-ResourcePrerequisitesValid -MockWith { }
                Mock Dism\Get-WindowsOptionalFeature { $FeatureName -eq $script:testFeatureName } -MockWith { }

                It 'Should return false when Ensure set to Present' {
                    Test-TargetResource -Name $testFeatureName -Ensure 'Present' | Should Be $false
                }

                It 'Should return true when Ensure set to Absent' {
                    Test-TargetResource -Name $testFeatureName -Ensure 'Absent' | Should Be $true
                }
            }

            Context 'Set-TargetResource' {
                Mock Assert-ResourcePrerequisitesValid -MockWith { }

                It 'Should call Enable-WindowsOptionalFeature with NoRestart set to true by default when Ensure set to Present' {
                    Mock Dism\Enable-WindowsOptionalFeature -ParameterFilter { $NoRestart -eq $true } -MockWith { }
                    
                    Set-TargetResource -Name $script:testFeatureName
                    
                    Assert-MockCalled Dism\Enable-WindowsOptionalFeature -ParameterFilter { $NoRestart -eq $true } -Scope It
                }

                It 'Should call Disable-WindowsOptionalFeature with NoRestart set to true by default when Ensure set to Absent' {
                    Mock Dism\Disable-WindowsOptionalFeature -ParameterFilter { $NoRestart -eq $true } -MockWith { }

                    Set-TargetResource -Name $script:testFeatureName -Ensure 'Absent'

                    Assert-MockCalled Dism\Disable-WindowsOptionalFeature -ParameterFilter  { $NoRestart -eq $true } -Scope It
                }

                It 'Should call Enable-WindowsOptionalFeature with Online by default as true when Ensure set to Present' {
                    Mock Dism\Enable-WindowsOptionalFeature -ParameterFilter { $Online -eq $true } -MockWith { }

                    Set-TargetResource -Name $script:testFeatureName

                    Assert-MockCalled Dism\Enable-WindowsOptionalFeature -ParameterFilter { $Online -eq $true } -Scope It
                }

                It 'Should call Disable-WindowsOptionalFeature with Online set to true by default when Ensure set to Absent' {
                    Mock Dism\Disable-WindowsOptionalFeature -ParameterFilter { $Online -eq $true } -MockWith { }

                    Set-TargetResource -Name $script:testFeatureName -Ensure 'Absent'

                    Assert-MockCalled Dism\Disable-WindowsOptionalFeature -ParameterFilter { $Online -eq $true } -Scope It
                }

                It 'Should call Enable-WindowsOptionalFeature with LogLevel set to WarningsInfo by default when Ensure set to Present' {
                    Mock Dism\Enable-WindowsOptionalFeature -ParameterFilter { $LogLevel -eq 'WarningsInfo' } -MockWith { }

                    Set-TargetResource -Name $script:testFeatureName

                    Assert-MockCalled Dism\Enable-WindowsOptionalFeature -ParameterFilter { $LogLevel -eq 'WarningsInfo' } -Scope It
                }

                It 'Should call Enable-WindowsOptionalFeature with LogLevel set to Errors when Ensure set to Present and LogLevel set to ErrorsOnly' {
                    Mock Dism\Enable-WindowsOptionalFeature -ParameterFilter { $LogLevel -eq 'Errors' } -MockWith { }

                    Set-TargetResource -Name $script:testFeatureName -LogLevel 'ErrorsOnly'

                    Assert-MockCalled Dism\Enable-WindowsOptionalFeature -ParameterFilter { $LogLevel -eq 'Errors' } -Scope It
                }

                It 'Should call Enable-WindowsOptionalFeature with LogLevel set to Warnings when Ensure set to Present and LogLevel set to ErrorsAndWarnings' {
                    Mock Dism\Enable-WindowsOptionalFeature -ParameterFilter { $LogLevel -eq 'Warnings' } -MockWith { }

                    Set-TargetResource -Name $script:testFeatureName -LogLevel 'ErrorsAndWarning'

                    Assert-MockCalled Dism\Enable-WindowsOptionalFeature -ParameterFilter { $LogLevel -eq 'Warnings' } -Scope It
                }

                It 'Should call Disable-WindowsOptionalFeature with LogLevel set to WarningsInfo by default when Ensure set to Absent' {
                    Mock Dism\Disable-WindowsOptionalFeature -ParameterFilter { $LogLevel -eq 'WarningsInfo' } -MockWith { }

                    Set-TargetResource -Name $script:testFeatureName -Ensure 'Absent'

                    Assert-MockCalled Dism\Disable-WindowsOptionalFeature -ParameterFilter { $LogLevel -eq 'WarningsInfo' } -Scope It
                }

                It 'Should call Enable-WindowsOptionalFeature without LimitAccess by default when Ensure set to Present' {
                    Mock Dism\Enable-WindowsOptionalFeature -ParameterFilter { $LimitAccess -eq $null } -MockWith { }

                    Set-TargetResource -Name $script:testFeatureName

                    Assert-MockCalled Dism\Enable-WindowsOptionalFeature -ParameterFilter  { $LimitAccess -eq $null } -Scope It
                }

                It 'Should call Enable-WindowsOptionalFeature with LimitAccess set to true when NoWindowsUpdateCheck is specified' {
                    Mock Dism\Enable-WindowsOptionalFeature -ParameterFilter { $LimitAccess -eq $true } -MockWith { }

                    Set-TargetResource -Name $script:testFeatureName -NoWindowsUpdateCheck $true

                    Assert-MockCalled Dism\Enable-WindowsOptionalFeature -ParameterFilter  { $LimitAccess -eq $true } -Scope It
                }

                It 'Should call Disable-WindowsOptionalFeature with Remove set to true when Ensure set to Absent and RemoveFilesOnDisable specified' {
                    Mock Dism\Disable-WindowsOptionalFeature -ParameterFilter { $Remove -eq $true } -MockWith { }

                    Set-TargetResource -Name $script:testFeatureName -Ensure 'Absent' -RemoveFilesOnDisable $true

                    Assert-MockCalled Dism\Disable-WindowsOptionalFeature -ParameterFilter { $Remove -eq $true } -Scope It
                }

            }

            Context 'Convert-FeatureStateToEnsure' {
                It 'Should return Present when state is Enabled' {
                    Convert-FeatureStateToEnsure -State 'Enabled' | Should Be 'Present'
                }

                It 'Should return Absent when state is Disabled' {
                    Convert-FeatureStateToEnsure -State 'Disabled' | Should Be 'Absent'
                }

                It 'Should return the same state when state is not Enabled or Disabled' {
                    $originalWarningPreference = $WarningPreference
                    $WarningPreference = 'SilentlyContinue'

                    try
                    {
                        Convert-FeatureStateToEnsure -State 'UnknownState' | Should Be 'UnknownState'
                    }
                    finally
                    {
                        $WarningPreference = $originalWarningPreference
                    }
                }
            }

            Context 'Convert-CustomPropertyArrayToStringArray' {
                [PSCustomObject[]] $psCustomObjects = @(
                    [PSCustomObject] @{
                        Name = 'Object 1'
                        Value = 'Value 1'
                        Path = 'Path 1'
                    },
                    [PSCustomObject] @{
                        Name = 'Object 2'
                        Value = 'Value 2'
                        Path = 'Path 2'
                    },
                    [PSCustomObject] @{
                        Name = 'Object 3'
                        Value = 'Value 3'
                        Path = 'Path 3'
                    },
                    $null
                )

                It 'Should return 3 strings from 3 PSCustomObjects and a null object' {
                    $propertiesAsStrings = Convert-CustomPropertyArrayToStringArray -CustomProperties $psCustomObjects
                    $propertiesAsStrings.Length | Should Be 3
                }

                It 'Should return the correct string for each object' {
                    $propertiesAsStrings = Convert-CustomPropertyArrayToStringArray -CustomProperties $psCustomObjects
                    
                    foreach ($objectNumber in @(1, 2, 3))
                    {
                        $propertiesAsStrings.Contains("Name = Object $objectNumber, Value = Value $objectNumber, Path = Path $objectNumber") | Should Be $true
                    }
                }
            }
        }
    }
}
finally
{
    Exit-DscResourceTestEnvironment -TestEnvironment $script:testEnvironment
}
