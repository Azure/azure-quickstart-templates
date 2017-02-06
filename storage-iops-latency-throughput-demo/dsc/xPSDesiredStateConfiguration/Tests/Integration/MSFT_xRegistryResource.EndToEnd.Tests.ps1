<#
    WARNING: DO NOT RUN THESE TESTS ON A VALUABLE MACHINE!
    Running on a disposable VM or AppVeyor is strongly recommended.
    If these tests go awry, your machine's registry could be corrupted which will brick your machine!
    If this happens to you, it is fixable, but the fix is difficult and time-consuming.
#>

$errorActionPreference = 'Stop'
Set-StrictMode -Version 'Latest'

# Import CommonTestHelper for Enter-DscResourceTestEnvironment, Exit-DscResourceTestEnvironment
$script:testsFolderFilePath = Split-Path $PSScriptRoot -Parent
$script:commonTestHelperFilePath = Join-Path -Path $testsFolderFilePath -ChildPath 'CommonTestHelper.psm1'
Import-Module -Name $commonTestHelperFilePath

$script:testEnvironment = Enter-DscResourceTestEnvironment `
    -DscResourceModuleName 'xPSDesiredStateConfiguration' `
    -DscResourceName 'MSFT_xRegistryResource' `
    -TestType 'Integration'

try
{
    Describe 'xRegistry End to End Tests' {
        BeforeAll {
            # Import Registry resource module for Get-TargetResource, Test-TargetResource, Set-TargetResource
            $moduleRootFilePath = Split-Path -Path $script:testsFolderFilePath -Parent
            $dscResourcesFolderFilePath = Join-Path -Path $moduleRootFilePath -ChildPath 'DscResources'
            $registryResourceFolderFilePath = Join-Path -Path $dscResourcesFolderFilePath -ChildPath 'MSFT_xRegistryResource'
            $registryResourceModuleFilePath = Join-Path -Path $registryResourceFolderFilePath -ChildPath 'MSFT_xRegistryResource.psm1'
            Import-Module -Name $registryResourceModuleFilePath -Force

            $script:registryKeyValueTypes = @( 'String', 'Binary', 'DWord', 'QWord', 'MultiString', 'ExpandString' )
            $script:testRegistryKeyPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment\TestKey2'

            # Force is specified as true for both of these configurations
            $script:confgurationFilePathKeyAndNameOnly = Join-Path -Path $PSScriptRoot -ChildPath 'MSFT_xRegistryResource_KeyAndNameOnly.config.ps1'
            $script:confgurationFilePathWithDataAndType = Join-Path -Path $PSScriptRoot -ChildPath 'MSFT_xRegistryResource_WithDataAndType.config.ps1'
        }

        Context 'Create a new registry key' {
            $configurationName = 'CreateRegistryKey'

            $registryParameters = @{
                Key = $script:testRegistryKeyPath
                Ensure = 'Present'
                ValueName = ''
            }

            It 'Should compile and run configuration' {
                { 
                    . $script:confgurationFilePathKeyAndNameOnly -ConfigurationName $configurationName
                    & $configurationName -OutputPath $TestDrive @registryParameters
                    Start-DscConfiguration -Path $TestDrive -ErrorAction 'Stop' -Wait -Force
                } | Should Not Throw
            }

            $registryKey = Get-Item -Path $registryParameters.Key -ErrorAction 'SilentlyContinue'

            It 'Should have created the registry key' {
                $registryKey | Should Not Be $null
            }

            It 'Should return true from Test-TargetResource with the same parameters' {
                MSFT_xRegistryResource\Test-TargetResource @registryParameters | Should Be $true
            }
        }

        Context 'Create a registry key value with no data or type' {
            $configurationName = 'CreateRegistryKeyValueNoDataOrType'

            $registryParameters = @{
                Key = $script:testRegistryKeyPath
                Ensure = 'Present'
                ValueName = 'TestValue'
            }

            It 'Should compile and run configuration' {
                { 
                    . $script:confgurationFilePathKeyAndNameOnly -ConfigurationName $configurationName
                    & $configurationName -OutputPath $TestDrive @registryParameters
                    Start-DscConfiguration -Path $TestDrive -ErrorAction 'Stop' -Wait -Force
                } | Should Not Throw
            }

            $registryKeyValue = Get-ItemProperty -Path $registryParameters.Key -Name $registryParameters.ValueName -ErrorAction 'SilentlyContinue'

            It 'Should have created the registry key value' {
                $registryKeyValue | Should Not Be $null
            }

            It 'Should not have set the registry key value' {
                $registryKeyValue.($registryParameters.ValueName) | Should Be ''
            }

            It 'Should return true from Test-TargetResource with the same parameters' {
                MSFT_xRegistryResource\Test-TargetResource @registryParameters | Should Be $true
            }
        }

        Context 'Set registry key value with data and String type' {
            $configurationName = 'SetRegistryKeyValueString'

            $registryParameters = @{
                Key = $script:testRegistryKeyPath
                Ensure = 'Present'
                ValueName = 'TestValue'
                ValueType = 'String'
                ValueData = 'TestString1'
            }

            It 'Should compile and run configuration' {
                { 
                    . $script:confgurationFilePathWithDataAndType -ConfigurationName $configurationName
                    & $configurationName -OutputPath $TestDrive @registryParameters
                    Start-DscConfiguration -Path $TestDrive -ErrorAction 'Stop' -Wait -Force
                } | Should Not Throw
            }

            $registryKeyValue = Get-ItemProperty -Path $registryParameters.Key -Name $registryParameters.ValueName -ErrorAction 'SilentlyContinue'

            It 'Should have created the registry key value' {
                $registryKeyValue | Should Not Be $null
            }

            It 'Should have set the registry key value to the specified String value' {
                $registryKeyValue.($registryParameters.ValueName) | Should Be $registryParameters.ValueData
            }

            It 'Should return true from Test-TargetResource with the same parameters' {
                MSFT_xRegistryResource\Test-TargetResource @registryParameters | Should Be $true
            }
        }

        foreach ($registryKeyValueType in $script:registryKeyValueTypes)
        {
            $registryKeyValueData = switch ($registryKeyValueType)
            {
                'String' { 'TestString2'; break }
                'Binary' { '0xCAC1111'; break }
                'DWord' { [Int32]::MaxValue.ToString(); break }
                'QWord' { [Int64]::MaxValue.ToString(); break }
                'MultiString' { @('MultiString1', 'MultiString2'); break }
                'ExpandString' { '%WINDIR%'; break }
            }

            $expectedRegistryKeyValue = switch ($registryKeyValueType)
            {
                'String' { 'TestString2'; break }
                'Binary' { [Byte[]]@( 12, 172, 17, 17 ); break }
                'DWord' { [Int32]::MaxValue; break }
                'QWord' { [Int64]::MaxValue; break }
                'MultiString' { [String[]]@('MultiString1', 'MultiString2'); break }
                'ExpandString' { 'C:\windows'; break }
            }

            Context "Overwrite a registry key value with a $registryKeyValueType value" {
                $configurationName = "OverwriteRegistryKeyValue$registryKeyValueType"

                $registryParameters = @{
                    Key = $script:testRegistryKeyPath
                    Ensure = 'Present'
                    ValueName = 'TestValue'
                    ValueType = $registryKeyValueType
                    ValueData = $registryKeyValueData
                }

                It 'Should compile and run configuration' {
                    { 
                        . $script:confgurationFilePathWithDataAndType -ConfigurationName $configurationName
                        & $configurationName -OutputPath $TestDrive @registryParameters
                        Start-DscConfiguration -Path $TestDrive -ErrorAction 'Stop' -Wait -Force
                    } | Should Not Throw
                }

                $registryKeyValue = Get-ItemProperty -Path $registryParameters.Key -Name $registryParameters.ValueName -ErrorAction 'SilentlyContinue'

                It 'Should be able to retrieve the registry key value' {
                    $registryKeyValue | Should Not Be $null
                }

                It 'Should have set the registry key value to the specified value' {
                    Compare-Object -ReferenceObject $expectedRegistryKeyValue -DifferenceObject $registryKeyValue.($registryParameters.ValueName) | Should Be $null
                }

                It 'Should return true from Test-TargetResource with the same parameters' {
                    MSFT_xRegistryResource\Test-TargetResource @registryParameters | Should Be $true
                }
            }
        }

        Context 'Set the registry key default value to a Binary value of 0' {
            $configurationName = 'SetDefaultRegistryKeyValueBinary0'

            $registryParameters = @{
                Key = $script:testRegistryKeyPath
                Ensure = 'Present'
                ValueName = ''
                ValueType = 'Binary'
                ValueData = '0x00'
            }

            $expectedRegistryKeyValue = [Byte[]]@(0)

            It 'Should compile and run configuration' {
                { 
                    . $script:confgurationFilePathWithDataAndType -ConfigurationName $configurationName
                    & $configurationName -OutputPath $TestDrive @registryParameters
                    Start-DscConfiguration -Path $TestDrive -ErrorAction 'Stop' -Wait -Force
                } | Should Not Throw
            }

            $registryKeyValue = Get-ItemProperty -Path $registryParameters.Key -Name $registryParameters.ValueName -ErrorAction 'SilentlyContinue'

            It 'Should be able to retrieve the registry key value' {
                $registryKeyValue | Should Not Be $null
            }

            It 'Should have set the registry key value to the specified Binary value' {
                Compare-Object -ReferenceObject $expectedRegistryKeyValue -DifferenceObject $registryKeyValue.'(default)' | Should Be $null
            }

            It 'Should return true from Test-TargetResource with the same parameters' {
                MSFT_xRegistryResource\Test-TargetResource @registryParameters | Should Be $true
            }
        }

        Context 'Remove a registry key value' {
            $configurationName = 'RemoveRegistryKeyValue'

            $registryParameters = @{
                Key = $script:testRegistryKeyPath
                Ensure = 'Absent'
                ValueName = 'TestValue'
            }

            It 'Should compile and run configuration' {
                { 
                    . $script:confgurationFilePathKeyAndNameOnly -ConfigurationName $configurationName
                    & $configurationName -OutputPath $TestDrive @registryParameters
                    Start-DscConfiguration -Path $TestDrive -ErrorAction 'Stop' -Wait -Force
                } | Should Not Throw
            }

            $registryKeyValue = Get-ItemProperty -Path $registryParameters.Key -Name $registryParameters.ValueName -ErrorAction 'SilentlyContinue'

            It 'Should have removed the registry key value' {
                $registryKeyValue | Should Be $null
            }

            It 'Should return true from Test-TargetResource with the same parameters' {
                MSFT_xRegistryResource\Test-TargetResource @registryParameters | Should Be $true
            }
        }

        Context 'Remove a default registry key value' {
            $configurationName = 'RemoveDefaultRegistryKeyValue'

            $registryParameters = @{
                Key = $script:testRegistryKeyPath
                Ensure = 'Absent'
                ValueName = ''
                ValueType = 'Binary'
                ValueData = '0'
            }

            It 'Should compile and run configuration' {
                { 
                    . $script:confgurationFilePathWithDataAndType -ConfigurationName $configurationName
                    & $configurationName -OutputPath $TestDrive @registryParameters
                    Start-DscConfiguration -Path $TestDrive -ErrorAction 'Stop' -Wait -Force
                } | Should Not Throw
            }

            $registryKeyValue = Get-ItemProperty -Path $registryParameters.Key -Name $registryParameters.ValueName -ErrorAction 'SilentlyContinue'

            It 'Should have removed the registry key value' {
                $registryKeyValue | Should Be $null
            }

            It 'Should return true from Test-TargetResource with the same parameters' {
                MSFT_xRegistryResource\Test-TargetResource @registryParameters | Should Be $true
            }
        }

        Context 'Remove a registry key' {
            $configurationName = 'RemoveRegistryKey'

            $registryParameters = @{
                Key = $script:testRegistryKeyPath
                Ensure = 'Absent'
                ValueName = ''
            }

            It 'Should compile and run configuration' {
                { 
                    . $script:confgurationFilePathKeyAndNameOnly -ConfigurationName $configurationName
                    & $configurationName -OutputPath $TestDrive @registryParameters
                    Start-DscConfiguration -Path $TestDrive -ErrorAction 'Stop' -Wait -Force
                } | Should Not Throw
            }

            $registryKey = Get-Item -Path $registryParameters.Key -ErrorAction 'SilentlyContinue'

            It 'Should have removed the registry key value' {
                $registryKey | Should Be $null
            }

            It 'Should return true from Test-TargetResource with the same parameters' {
                MSFT_xRegistryResource\Test-TargetResource @registryParameters | Should Be $true
            }
        }
    }
}
finally
{
    Exit-DscResourceTestEnvironment -TestEnvironment $script:testEnvironment
}
        
