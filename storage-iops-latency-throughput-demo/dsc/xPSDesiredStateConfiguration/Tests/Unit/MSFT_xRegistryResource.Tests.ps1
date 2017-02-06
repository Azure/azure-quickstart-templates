$errorActionPreference = 'Stop'
Set-StrictMode -Version 'Latest'

# Import CommonTestHelper for Enter-DscResourceTestEnvironment, Exit-DscResourceTestEnvironment
$script:testsFolderFilePath = Split-Path $PSScriptRoot -Parent
$script:commonTestHelperFilePath = Join-Path -Path $testsFolderFilePath -ChildPath 'CommonTestHelper.psm1'
Import-Module -Name $commonTestHelperFilePath

$script:testEnvironment = Enter-DscResourceTestEnvironment `
    -DscResourceModuleName 'xPSDesiredStateConfiguration' `
    -DscResourceName 'MSFT_xRegistryResource' `
    -TestType 'Unit'

try
{
    InModuleScope 'MSFT_xRegistryResource' {
        $script:registryKeyValueTypes = @( 'String', 'Binary', 'DWord', 'QWord', 'MultiString', 'ExpandString' )

        $script:validRegistryDriveRoots = @( 'HKEY_CLASSES_ROOT', 'HKEY_CURRENT_USER', 'HKEY_LOCAL_MACHINE', 'HKEY_USERS', 'HKEY_CURRENT_CONFIG' )
        $script:validRegistryDriveNames = @( 'HKCR', 'HKCU', 'HKLM', 'HKUS', 'HKCC' )
        
        # This registry key is used ONLY for its type (Microsoft.Win32.RegistryKey). It is not actually accessed in any way during these tests.
        $script:testRegistryKey = [Microsoft.Win32.Registry]::CurrentConfig

        $script:defaultValueType = 'String'
        $script:defaultValueData = @()

        Describe 'xRegistry\Get-TargetResource' {
            Mock -CommandName 'Get-RegistryKey' -MockWith { }
            Mock -CommandName 'Get-RegistryKeyValueDisplayName' -MockWith { return $RegistryKeyValueName }
            Mock -CommandName 'Get-RegistryKeyValue' -MockWith { }
            Mock -CommandName 'Get-RegistryKeyValueType' -MockWith { }
            Mock -CommandName 'ConvertTo-ReadableString' -MockWith { return $RegistryKeyValue }

            Context 'Registry key at specified path does not exist' {
                $getTargetResourceParameters = @{
                    Key = 'TestRegistryKey'
                    ValueName = ''
                }
                
                It 'Should not throw' {
                    { $null = Get-TargetResource @getTargetResourceParameters } | Should Not Throw
                }

                It 'Should retrieve the registry key' {
                    $getRegistryKeyParameterFilter = {
                        $registryKeyPathParameterCorrect = $RegistryKeyPath -eq $getTargetResourceParameters.Key
                        return $registryKeyPathParameterCorrect
                    }

                    Assert-MockCalled -CommandName 'Get-RegistryKey' -ParameterFilter $getRegistryKeyParameterFilter -Times 1 -Scope 'Context'
                }

                It 'Should not attempt to retrieve the registry key value display name' {
                    Assert-MockCalled -CommandName 'Get-RegistryKeyValueDisplayName' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to retrieve the registry key value' {
                    Assert-MockCalled -CommandName 'Get-RegistryKeyValue' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to retrieve the registry key value type' {
                    Assert-MockCalled -CommandName 'Get-RegistryKeyValueType' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to convert the registry key value to a readable string' {
                    Assert-MockCalled -CommandName 'ConvertTo-ReadableString' -Times 0 -Scope 'Context'
                }

                $getTargetResourceResult = Get-TargetResource @getTargetResourceParameters

                It 'Should return a hashtable' {
                    $getTargetResourceResult -is [Hashtable] | Should Be $true
                }

                It 'Should return 5 hashtable properties' {
                    $getTargetResourceResult.Keys.Count | Should Be 5
                }

                It 'Should return the Key property as the given registry key path' {
                    $getTargetResourceResult.Key | Should Be $getTargetResourceParameters.Key
                }

                It 'Should return the Ensure property as Absent' {
                    $getTargetResourceResult.Ensure | Should Be 'Absent'
                }

                It 'Should return the ValueName property as null' {
                    $getTargetResourceResult.ValueName | Should Be $null
                }

                It 'Should return the ValueType property as null' {
                    $getTargetResourceResult.ValueType | Should Be $null
                }

                It 'Should return the ValueData property as null' {
                    $getTargetResourceResult.ValueData | Should Be $null
                }
            }
            
            Mock -CommandName 'Get-RegistryKey' -MockWith { return $script:testRegistryKey }

            Context 'Specified registry key exists, registry key value name specified as an empty string, and registry key value data and type not specified' {
                $getTargetResourceParameters = @{
                    Key = 'TestRegistryKey'
                    ValueName = ''
                }
                
                It 'Should not throw' {
                    { $null = Get-TargetResource @getTargetResourceParameters } | Should Not Throw
                }

                It 'Should retrieve the registry key' {
                    $getRegistryKeyParameterFilter = {
                        $registryKeyPathParameterCorrect = $RegistryKeyPath -eq $getTargetResourceParameters.Key
                        return $registryKeyPathParameterCorrect
                    }

                    Assert-MockCalled -CommandName 'Get-RegistryKey' -ParameterFilter $getRegistryKeyParameterFilter -Times 1 -Scope 'Context'
                }

                It 'Should not attempt to retrieve the registry key value display name' {
                    Assert-MockCalled -CommandName 'Get-RegistryKeyValueDisplayName' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to retrieve the registry key value' {
                    Assert-MockCalled -CommandName 'Get-RegistryKeyValue' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to retrieve the registry key value type' {
                    Assert-MockCalled -CommandName 'Get-RegistryKeyValueType' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to convert the registry key value to a readable string' {
                    Assert-MockCalled -CommandName 'ConvertTo-ReadableString' -Times 0 -Scope 'Context'
                }

                $getTargetResourceResult = Get-TargetResource @getTargetResourceParameters

                It 'Should return a hashtable' {
                    $getTargetResourceResult -is [Hashtable] | Should Be $true
                }

                It 'Should return 5 hashtable properties' {
                    $getTargetResourceResult.Keys.Count | Should Be 5
                }

                It 'Should return the Key property as the given registry key path' {
                    $getTargetResourceResult.Key | Should Be $getTargetResourceParameters.Key
                }

                It 'Should return the Ensure property as Present' {
                    $getTargetResourceResult.Ensure | Should Be 'Present'
                }

                It 'Should return the ValueName property as null' {
                    $getTargetResourceResult.ValueName | Should Be $null
                }

                It 'Should return the ValueType property as null' {
                    $getTargetResourceResult.ValueType | Should Be $null
                }

                It 'Should return the ValueData property as null' {
                    $getTargetResourceResult.ValueData | Should Be $null
                }
            }

            Context 'Specified registry key exists and specified registry key value does not exist' {
                $getTargetResourceParameters = @{
                    Key = 'TestRegistryKey'
                    ValueName = 'TestValueName'
                }
                
                It 'Should not throw' {
                    { $null = Get-TargetResource @getTargetResourceParameters } | Should Not Throw
                }

                It 'Should retrieve the registry key' {
                    $getRegistryKeyParameterFilter = {
                        $registryKeyPathParameterCorrect = $RegistryKeyPath -eq $getTargetResourceParameters.Key
                        return $registryKeyPathParameterCorrect
                    }

                    Assert-MockCalled -CommandName 'Get-RegistryKey' -ParameterFilter $getRegistryKeyParameterFilter -Times 1 -Scope 'Context'
                }

                It 'Should retrieve the registry key value display name' {
                    $getRegistryKeyValueDisplayNameParameterFilter = {
                        $registryKeyValueNameParameterCorrect = $RegistryKeyValueName -eq $getTargetResourceParameters.ValueName
                        return $registryKeyValueNameParameterCorrect
                    }

                    Assert-MockCalled -CommandName 'Get-RegistryKeyValueDisplayName' -ParameterFilter $getRegistryKeyValueDisplayNameParameterFilter -Times 1 -Scope 'Context'
                }

                It 'Should retrieve the registry key value' {
                    $getRegistryKeyValueParameterFilter = {
                        $registryKeyParameterCorrect = $null -eq (Compare-Object -ReferenceObject $script:testRegistryKey -DifferenceObject $RegistryKey)
                        $registryKeyValueNameParameterCorrect = $RegistryKeyValueName -eq $getTargetResourceParameters.ValueName

                        return $registryKeyParameterCorrect -and $registryKeyValueNameParameterCorrect
                    }

                    Assert-MockCalled -CommandName 'Get-RegistryKeyValue' -ParameterFilter $getRegistryKeyValueParameterFilter -Times 1 -Scope 'Context'
                }

                It 'Should not attempt to retrieve the registry key value type' {
                    Assert-MockCalled -CommandName 'Get-RegistryKeyValueType' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to convert the registry key value to a readable string' {
                    Assert-MockCalled -CommandName 'ConvertTo-ReadableString' -Times 0 -Scope 'Context'
                }

                $getTargetResourceResult = Get-TargetResource @getTargetResourceParameters

                It 'Should return a hashtable' {
                    $getTargetResourceResult -is [Hashtable] | Should Be $true
                }

                It 'Should return 5 hashtable properties' {
                    $getTargetResourceResult.Keys.Count | Should Be 5
                }

                It 'Should return the Key property as the given registry key path' {
                    $getTargetResourceResult.Key | Should Be $getTargetResourceParameters.Key
                }

                It 'Should return the Ensure property as Absent' {
                    $getTargetResourceResult.Ensure | Should Be 'Absent'
                }

                It 'Should return the ValueName property as the specified value name' {
                    $getTargetResourceResult.ValueName | Should Be $getTargetResourceParameters.ValueName
                }

                It 'Should return the ValueType property as null' {
                    $getTargetResourceResult.ValueType | Should Be $null
                }

                It 'Should return the ValueData property as null' {
                    $getTargetResourceResult.ValueData | Should Be $null
                }
            }

            $testRegistryKeyValue = 'TestRegistryKeyValue'
            $testRegistryValueType = 'String'
            Mock -CommandName 'Get-RegistryKeyValue' -MockWith { return $testRegistryKeyValue }
            Mock -CommandName 'Get-RegistryKeyValueType' -MockWith { return $testRegistryValueType }

            Context 'Specified registry key exists and specified registry key value exists as a string' {
                $getTargetResourceParameters = @{
                    Key = 'TestRegistryKey'
                    ValueName = 'TestValueName'
                }
                
                It 'Should not throw' {
                    { $null = Get-TargetResource @getTargetResourceParameters } | Should Not Throw
                }

                It 'Should retrieve the registry key' {
                    $getRegistryKeyParameterFilter = {
                        $registryKeyPathParameterCorrect = $RegistryKeyPath -eq $getTargetResourceParameters.Key
                        return $registryKeyPathParameterCorrect
                    }

                    Assert-MockCalled -CommandName 'Get-RegistryKey' -ParameterFilter $getRegistryKeyParameterFilter -Times 1 -Scope 'Context'
                }

                It 'Should retrieve the registry key value display name' {
                    $getRegistryKeyValueDisplayNameParameterFilter = {
                        $registryKeyValueNameParameterCorrect = $RegistryKeyValueName -eq $getTargetResourceParameters.ValueName
                        return $registryKeyValueNameParameterCorrect
                    }

                    Assert-MockCalled -CommandName 'Get-RegistryKeyValueDisplayName' -ParameterFilter $getRegistryKeyValueDisplayNameParameterFilter -Times 1 -Scope 'Context'
                }

                It 'Should retrieve the registry key value' {
                    $getRegistryKeyValueParameterFilter = {
                        $registryKeyParameterCorrect = $null -eq (Compare-Object -ReferenceObject $script:testRegistryKey -DifferenceObject $RegistryKey)
                        $registryKeyValueNameParameterCorrect = $RegistryKeyValueName -eq $getTargetResourceParameters.ValueName

                        return $registryKeyParameterCorrect -and $registryKeyValueNameParameterCorrect
                    }

                    Assert-MockCalled -CommandName 'Get-RegistryKeyValue' -ParameterFilter $getRegistryKeyValueParameterFilter -Times 1 -Scope 'Context'
                }

                It 'Should retrieve the registry key value type' {
                    $getRegistryKeyValueTypeParameterFilter = {
                        $registryKeyParameterCorrect = $null -eq (Compare-Object -ReferenceObject $script:testRegistryKey -DifferenceObject $RegistryKey)
                        $registryKeyValueNameParameterCorrect = $RegistryKeyValueName -eq $getTargetResourceParameters.ValueName

                        return $registryKeyParameterCorrect -and $registryKeyValueNameParameterCorrect
                    }

                    Assert-MockCalled -CommandName 'Get-RegistryKeyValueType' -ParameterFilter $getRegistryKeyValueTypeParameterFilter -Times 1 -Scope 'Context'
                }

                It 'Should convert the registry key value to a readable string' {
                    $convertToReadableStringParameterFilter = {
                        $registryKeyValueParameterCorrect = $testRegistryKeyValue -eq $RegistryKeyValue
                        $registryKeyValueTypeParameterCorrect = $RegistryKeyValueType -eq $testRegistryValueType
                        return $registryKeyValueParameterCorrect -and $registryKeyValueTypeParameterCorrect
                    }

                    Assert-MockCalled -CommandName 'ConvertTo-ReadableString' -ParameterFilter $convertToReadableStringParameterFilter -Times 1 -Scope 'Context'
                }

                $getTargetResourceResult = Get-TargetResource @getTargetResourceParameters

                It 'Should return a hashtable' {
                    $getTargetResourceResult -is [Hashtable] | Should Be $true
                }

                It 'Should return 5 hashtable properties' {
                    $getTargetResourceResult.Keys.Count | Should Be 5
                }

                It 'Should return the Key property as the given registry key path' {
                    $getTargetResourceResult.Key | Should Be $getTargetResourceParameters.Key
                }

                It 'Should return the Ensure property as Present' {
                    $getTargetResourceResult.Ensure | Should Be 'Present'
                }

                It 'Should return the ValueName property as specified value display name' {
                    $getTargetResourceResult.ValueName | Should Be $getTargetResourceParameters.ValueName
                }

                It 'Should return the ValueType property as the retrieved value type' {
                    $getTargetResourceResult.ValueType | Should Be $testRegistryValueType
                }

                It 'Should return the ValueData property as the retrieved value' {
                    $getTargetResourceResult.ValueData | Should Be $testRegistryKeyValue
                }
            }

            Context 'Specified registry key exists and registry key default value exists as a string' {
                $getTargetResourceParameters = @{
                    Key = 'TestRegistryKey'
                    ValueName = ''
                    ValueType = 'String'
                    ValueData = 'TestValueData'
                }
                
                It 'Should not throw' {
                    { $null = Get-TargetResource @getTargetResourceParameters } | Should Not Throw
                }

                It 'Should retrieve the registry key' {
                    $getRegistryKeyParameterFilter = {
                        $registryKeyPathParameterCorrect = $RegistryKeyPath -eq $getTargetResourceParameters.Key
                        return $registryKeyPathParameterCorrect
                    }

                    Assert-MockCalled -CommandName 'Get-RegistryKey' -ParameterFilter $getRegistryKeyParameterFilter -Times 1 -Scope 'Context'
                }

                It 'Should retrieve the registry key value display name' {
                    $getRegistryKeyValueDisplayNameParameterFilter = {
                        $registryKeyValueNameParameterCorrect = $RegistryKeyValueName -eq $getTargetResourceParameters.ValueName
                        return $registryKeyValueNameParameterCorrect
                    }

                    Assert-MockCalled -CommandName 'Get-RegistryKeyValueDisplayName' -ParameterFilter $getRegistryKeyValueDisplayNameParameterFilter -Times 1 -Scope 'Context'
                }

                It 'Should retrieve the registry key value' {
                    $getRegistryKeyValueParameterFilter = {
                        $registryKeyParameterCorrect = $null -eq (Compare-Object -ReferenceObject $script:testRegistryKey -DifferenceObject $RegistryKey)
                        $registryKeyValueNameParameterCorrect = $RegistryKeyValueName -eq $getTargetResourceParameters.ValueName

                        return $registryKeyParameterCorrect -and $registryKeyValueNameParameterCorrect
                    }

                    Assert-MockCalled -CommandName 'Get-RegistryKeyValue' -ParameterFilter $getRegistryKeyValueParameterFilter -Times 1 -Scope 'Context'
                }

                It 'Should retrieve the registry key value type' {
                    $getRegistryKeyValueTypeParameterFilter = {
                        $registryKeyParameterCorrect = $null -eq (Compare-Object -ReferenceObject $script:testRegistryKey -DifferenceObject $RegistryKey)
                        $registryKeyValueNameParameterCorrect = $RegistryKeyValueName -eq $getTargetResourceParameters.ValueName

                        return $registryKeyParameterCorrect -and $registryKeyValueNameParameterCorrect
                    }

                    Assert-MockCalled -CommandName 'Get-RegistryKeyValueType' -ParameterFilter $getRegistryKeyValueTypeParameterFilter -Times 1 -Scope 'Context'
                }

                It 'Should convert the registry key value to a readable string' {
                    $convertToReadableStringParameterFilter = {
                        $registryKeyValueParameterCorrect = $testRegistryKeyValue -eq $RegistryKeyValue
                        $registryKeyValueTypeParameterCorrect = $RegistryKeyValueType -eq $testRegistryValueType
                        return $registryKeyValueParameterCorrect -and $registryKeyValueTypeParameterCorrect
                    }

                    Assert-MockCalled -CommandName 'ConvertTo-ReadableString' -ParameterFilter $convertToReadableStringParameterFilter -Times 1 -Scope 'Context'
                }

                $getTargetResourceResult = Get-TargetResource @getTargetResourceParameters

                It 'Should return a hashtable' {
                    $getTargetResourceResult -is [Hashtable] | Should Be $true
                }

                It 'Should return 5 hashtable properties' {
                    $getTargetResourceResult.Keys.Count | Should Be 5
                }

                It 'Should return the Key property as the given registry key path' {
                    $getTargetResourceResult.Key | Should Be $getTargetResourceParameters.Key
                }

                It 'Should return the Ensure property as Present' {
                    $getTargetResourceResult.Ensure | Should Be 'Present'
                }

                It 'Should return the ValueName property as specified value display name' {
                    $getTargetResourceResult.ValueName | Should Be $getTargetResourceParameters.ValueName
                }

                It 'Should return the ValueType property as the retrieved value type' {
                    $getTargetResourceResult.ValueType | Should Be $testRegistryValueType
                }

                It 'Should return the ValueData property as the retrieved value' {
                    $getTargetResourceResult.ValueData | Should Be $testRegistryKeyValue
                }
            }
        }

        Describe 'xRegistry\Set-TargetResource' {
            Mock -CommandName 'Get-RegistryKey' -MockWith { }
            Mock -CommandName 'New-RegistryKey' -MockWith { return $script:testRegistryKey }
            Mock -CommandName 'Get-RegistryKeyValueDisplayName' -MockWith { return $RegistryKeyValueName }
            Mock -CommandName 'Get-RegistryKeyValue' -MockWith { }
            Mock -CommandName 'ConvertTo-Binary' -MockWith { return $RegistryKeyValue }
            Mock -CommandName 'ConvertTo-Dword' -MockWith { return $RegistryKeyValue }
            Mock -CommandName 'ConvertTo-MultiString' -MockWith { return $RegistryKeyValue }
            Mock -CommandName 'ConvertTo-Qword' -MockWith { return $RegistryKeyValue }
            Mock -CommandName 'ConvertTo-String' -MockWith { return $RegistryKeyValue }
            Mock -CommandName 'Get-RegistryKeyName' -MockWith { return $setTargetResourceParameters.Key }
            Mock -CommandName 'Set-RegistryKeyValue' -MockWith { }
            Mock -CommandName 'Test-RegistryKeyValuesMatch' -MockWith { return $true }
            Mock -CommandName 'Remove-ItemProperty' -MockWith { }
            Mock -CommandName 'Remove-DefaultRegistryKeyValue' -MockWith { }
            Mock -CommandName 'Get-RegistryKeySubKeyCount' -MockWith { return 0 }
            Mock -CommandName 'Remove-Item' -MockWith { }
            

            Context 'Registry key does not exist and Ensure specified as Absent' {
                $setTargetResourceParameters = @{
                    Key = 'TestRegistryKey'
                    ValueName = ''
                    Ensure = 'Absent'
                }

                It 'Should not throw' {
                    { Set-TargetResource @setTargetResourceParameters } | Should Not Throw
                }

                It 'Should retrieve the registry key' {
                    $getRegistryKeyParameterFilter = {
                        $registryKeyPathParameterCorrect = $RegistryKeyPath -eq $setTargetResourceParameters.Key
                        return $registryKeyPathParameterCorrect
                    }

                    Assert-MockCalled -CommandName 'Get-RegistryKey' -ParameterFilter $getRegistryKeyParameterFilter -Times 1 -Scope 'Context'
                }

                It 'Should not attempt to create a new registry key' {
                    Assert-MockCalled -CommandName 'New-RegistryKey' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to retrieve the registry key value display name' {
                    Assert-MockCalled -CommandName 'Get-RegistryKeyValueDisplayName' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to retrieve the registry key value' {
                    Assert-MockCalled -CommandName 'Get-RegistryKeyValue' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to convert the specified registry key value to a string' {
                    Assert-MockCalled -CommandName 'ConvertTo-String' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to convert the specified registry key value to binary data' {
                    Assert-MockCalled -CommandName 'ConvertTo-Binary' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to convert the specified registry key value to a dword' {
                    Assert-MockCalled -CommandName 'ConvertTo-Dword' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to convert the specified registry key value to a qword' {
                    Assert-MockCalled -CommandName 'ConvertTo-Qword' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to convert the specified registry key value to a multi-string' {
                    Assert-MockCalled -CommandName 'ConvertTo-MultiString' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to test if the specified registry key value matches the retrieved registry key value' {
                    Assert-MockCalled -CommandName 'Test-RegistryKeyValuesMatch' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to retrieve the registry key name' {
                    Assert-MockCalled -CommandName 'Get-RegistryKeyName' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to set the registry key value' {
                    Assert-MockCalled -CommandName 'Set-RegistryKeyValue' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to remove the registry key value' {
                    Assert-MockCalled -CommandName 'Remove-ItemProperty' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to remove the default registry key value' {
                    Assert-MockCalled -CommandName 'Remove-DefaultRegistryKeyValue' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to retrieve the registry key subkey count' {
                    Assert-MockCalled -CommandName 'Get-RegistryKeySubKeyCount' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to remove the registry key' {
                    Assert-MockCalled -CommandName 'Remove-Item' -Times 0 -Scope 'Context'
                }

                It 'Should not return' {
                    Set-TargetResource @setTargetResourceParameters | Should Be $null
                }
            }

            Context 'Registry key does not exist, Ensure specified as Present, registry value name specified as empty string, and registry value type and data not specified' {
                $setTargetResourceParameters = @{
                    Key = 'TestRegistryKey'
                    ValueName = ''
                    Ensure = 'Present'
                }

                It 'Should not throw' {
                    { Set-TargetResource @setTargetResourceParameters } | Should Not Throw
                }

                It 'Should retrieve the registry key' {
                    $getRegistryKeyParameterFilter = {
                        $registryKeyPathParameterCorrect = $RegistryKeyPath -eq $setTargetResourceParameters.Key
                        return $registryKeyPathParameterCorrect
                    }

                    Assert-MockCalled -CommandName 'Get-RegistryKey' -ParameterFilter $getRegistryKeyParameterFilter -Times 1 -Scope 'Context'
                }

                It 'Should create a new registry key' {
                    $newRegistryKeyParameterFilter = {
                        $registryKeyPathParameterCorrect = $RegistryKeyPath -eq $setTargetResourceParameters.Key
                        return $registryKeyPathParameterCorrect
                    }

                    Assert-MockCalled -CommandName 'New-RegistryKey' -ParameterFilter $newRegistryKeyParameterFilter -Times 1 -Scope 'Context'
                }

                It 'Should not attempt to retrieve the registry key value display name' {
                    Assert-MockCalled -CommandName 'Get-RegistryKeyValueDisplayName' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to retrieve the registry key value' {
                    Assert-MockCalled -CommandName 'Get-RegistryKeyValue' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to convert the specified registry key value to a string' {
                    Assert-MockCalled -CommandName 'ConvertTo-String' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to convert the specified registry key value to binary data' {
                    Assert-MockCalled -CommandName 'ConvertTo-Binary' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to convert the specified registry key value to a dword' {
                    Assert-MockCalled -CommandName 'ConvertTo-Dword' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to convert the specified registry key value to a qword' {
                    Assert-MockCalled -CommandName 'ConvertTo-Qword' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to convert the specified registry key value to a multi-string' {
                    Assert-MockCalled -CommandName 'ConvertTo-MultiString' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to test if the specified registry key value matches the retrieved registry key value' {
                    Assert-MockCalled -CommandName 'Test-RegistryKeyValuesMatch' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to retrieve the registry key name' {
                    Assert-MockCalled -CommandName 'Get-RegistryKeyName' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to set the registry key value' {
                    Assert-MockCalled -CommandName 'Set-RegistryKeyValue' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to remove the registry key value' {
                    Assert-MockCalled -CommandName 'Remove-ItemProperty' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to remove the default registry key value' {
                    Assert-MockCalled -CommandName 'Remove-DefaultRegistryKeyValue' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to retrieve the registry key subkey count' {
                    Assert-MockCalled -CommandName 'Get-RegistryKeySubKeyCount' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to remove the registry key' {
                    Assert-MockCalled -CommandName 'Remove-Item' -Times 0 -Scope 'Context'
                }

                It 'Should not return' {
                    Set-TargetResource @setTargetResourceParameters | Should Be $null
                }
            }

            Mock -CommandName 'Get-RegistryKey' -MockWith { return $script:testRegistryKey }

            Context 'Registry key exists with no subkeys, Ensure specified as Absent, registry value name specified as empty string, and registry value type and data not specified' {
                $setTargetResourceParameters = @{
                    Key = 'TestRegistryKey'
                    ValueName = ''
                    Ensure = 'Absent'
                }

                It 'Should not throw' {
                    { Set-TargetResource @setTargetResourceParameters } | Should Not Throw
                }

                It 'Should retrieve the registry key' {
                    $getRegistryKeyParameterFilter = {
                        $registryKeyPathParameterCorrect = $RegistryKeyPath -eq $setTargetResourceParameters.Key
                        return $registryKeyPathParameterCorrect
                    }

                    Assert-MockCalled -CommandName 'Get-RegistryKey' -ParameterFilter $getRegistryKeyParameterFilter -Times 1 -Scope 'Context'
                }

                It 'Should not attempt to create a new registry key' {
                    Assert-MockCalled -CommandName 'New-RegistryKey' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to retrieve the registry key value display name' {
                    Assert-MockCalled -CommandName 'Get-RegistryKeyValueDisplayName' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to retrieve the registry key value' {
                    Assert-MockCalled -CommandName 'Get-RegistryKeyValue' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to convert the specified registry key value to a string' {
                    Assert-MockCalled -CommandName 'ConvertTo-String' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to convert the specified registry key value to binary data' {
                    Assert-MockCalled -CommandName 'ConvertTo-Binary' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to convert the specified registry key value to a dword' {
                    Assert-MockCalled -CommandName 'ConvertTo-Dword' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to convert the specified registry key value to a qword' {
                    Assert-MockCalled -CommandName 'ConvertTo-Qword' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to convert the specified registry key value to a multi-string' {
                    Assert-MockCalled -CommandName 'ConvertTo-MultiString' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to test if the specified registry key value matches the retrieved registry key value' {
                    Assert-MockCalled -CommandName 'Test-RegistryKeyValuesMatch' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to retrieve the registry key name' {
                    Assert-MockCalled -CommandName 'Get-RegistryKeyName' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to set the registry key value' {
                    Assert-MockCalled -CommandName 'Set-RegistryKeyValue' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to remove the registry key value' {
                    Assert-MockCalled -CommandName 'Remove-ItemProperty' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to remove the default registry key value' {
                    Assert-MockCalled -CommandName 'Remove-DefaultRegistryKeyValue' -Times 0 -Scope 'Context'
                }

                It 'Should retrieve the registry key subkey count' {
                    $getRegistryKeySubCountParameterFilter = {
                        $registryKeyParameterCorrect = $null -eq (Compare-Object -ReferenceObject $script:testRegistryKey -DifferenceObject $RegistryKey)
                        return $registryKeyParameterCorrect
                    }

                    Assert-MockCalled -CommandName 'Get-RegistryKeySubKeyCount' -ParameterFilter $getRegistryKeySubCountParameterFilter -Times 1 -Scope 'Context'
                }

                It 'Should remove the registry key' {
                    $removeItemParameterFilter = {
                        $pathParameterCorrect = $Path -eq $setTargetResourceParameters.Key
                        $recurseParameterCorrect = $Recurse -eq $true
                        $forceParameterCorrect = $Force -eq $true

                        return $pathParameterCorrect -and $recurseParameterCorrect -and $forceParameterCorrect
                    }

                    Assert-MockCalled -CommandName 'Remove-Item' -ParameterFilter $removeItemParameterFilter -Times 1 -Scope 'Context'
                }

                It 'Should not return' {
                    Set-TargetResource @setTargetResourceParameters | Should Be $null
                }
            }

            Mock -CommandName 'Get-RegistryKeySubKeyCount' -MockWith { return 2 }

            Context 'Registry key exists with subkeys, Ensure specified as Absent, registry value name specified as empty string, registry value type and data not specified, and Force not specified' {
                $setTargetResourceParameters = @{
                    Key = 'TestRegistryKey'
                    ValueName = ''
                    Ensure = 'Absent'
                }

                It 'Should throw error for removal of registry key with subkeys without specifying Force as True' {
                    $errorMessage = $script:localizedData.CannotRemoveExistingRegistryKeyWithSubKeysWithoutForce -f $setTargetResourceParameters.Key

                    { Set-TargetResource @setTargetResourceParameters } | Should Throw $errorMessage
                }
            }

            Context 'Registry key exists with subkeys, Ensure specified as Absent, registry value name specified as empty string, registry value type and data not specified, and Force specified as True' {
                $setTargetResourceParameters = @{
                    Key = 'TestRegistryKey'
                    ValueName = ''
                    Ensure = 'Absent'
                    Force = $true
                }

                It 'Should not throw' {
                    { Set-TargetResource @setTargetResourceParameters } | Should Not Throw
                }

                It 'Should retrieve the registry key' {
                    $getRegistryKeyParameterFilter = {
                        $registryKeyPathParameterCorrect = $RegistryKeyPath -eq $setTargetResourceParameters.Key
                        return $registryKeyPathParameterCorrect
                    }

                    Assert-MockCalled -CommandName 'Get-RegistryKey' -ParameterFilter $getRegistryKeyParameterFilter -Times 1 -Scope 'Context'
                }

                It 'Should not attempt to create a new registry key' {
                    Assert-MockCalled -CommandName 'New-RegistryKey' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to retrieve the registry key value display name' {
                    Assert-MockCalled -CommandName 'Get-RegistryKeyValueDisplayName' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to retrieve the registry key value' {
                    Assert-MockCalled -CommandName 'Get-RegistryKeyValue' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to convert the specified registry key value to a string' {
                    Assert-MockCalled -CommandName 'ConvertTo-String' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to convert the specified registry key value to binary data' {
                    Assert-MockCalled -CommandName 'ConvertTo-Binary' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to convert the specified registry key value to a dword' {
                    Assert-MockCalled -CommandName 'ConvertTo-Dword' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to convert the specified registry key value to a qword' {
                    Assert-MockCalled -CommandName 'ConvertTo-Qword' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to convert the specified registry key value to a multi-string' {
                    Assert-MockCalled -CommandName 'ConvertTo-MultiString' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to test if the specified registry key value matches the retrieved registry key value' {
                    Assert-MockCalled -CommandName 'Test-RegistryKeyValuesMatch' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to retrieve the registry key name' {
                    Assert-MockCalled -CommandName 'Get-RegistryKeyName' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to set the registry key value' {
                    Assert-MockCalled -CommandName 'Set-RegistryKeyValue' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to remove the registry key value' {
                    Assert-MockCalled -CommandName 'Remove-ItemProperty' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to remove the default registry key value' {
                    Assert-MockCalled -CommandName 'Remove-DefaultRegistryKeyValue' -Times 0 -Scope 'Context'
                }

                It 'Should retrieve the registry key subkey count' {
                    $getRegistryKeySubCountParameterFilter = {
                        $registryKeyParameterCorrect = $null -eq (Compare-Object -ReferenceObject $script:testRegistryKey -DifferenceObject $RegistryKey)
                        return $registryKeyParameterCorrect
                    }

                    Assert-MockCalled -CommandName 'Get-RegistryKeySubKeyCount' -ParameterFilter $getRegistryKeySubCountParameterFilter -Times 1 -Scope 'Context'
                }

                It 'Should remove the registry key' {
                    $removeItemParameterFilter = {
                        $pathParameterCorrect = $Path -eq $setTargetResourceParameters.Key
                        $recurseParameterCorrect = $Recurse -eq $true
                        $forceParameterCorrect = $Force -eq $true

                        return $pathParameterCorrect -and $recurseParameterCorrect -and $forceParameterCorrect
                    }

                    Assert-MockCalled -CommandName 'Remove-Item' -ParameterFilter $removeItemParameterFilter -Times 1 -Scope 'Context'
                }

                It 'Should not return' {
                    Set-TargetResource @setTargetResourceParameters | Should Be $null
                }
            }

            Context 'Registry key exists, Ensure specified as Absent, specified registry value does not exist, and registry value type and data not specified' {
                $setTargetResourceParameters = @{
                    Key = 'TestRegistryKey'
                    ValueName = 'TestRegistryKeyValueName'
                    Ensure = 'Absent'
                }

                It 'Should not throw' {
                    { Set-TargetResource @setTargetResourceParameters } | Should Not Throw
                }

                It 'Should retrieve the registry key' {
                    $getRegistryKeyParameterFilter = {
                        $registryKeyPathParameterCorrect = $RegistryKeyPath -eq $setTargetResourceParameters.Key
                        return $registryKeyPathParameterCorrect
                    }

                    Assert-MockCalled -CommandName 'Get-RegistryKey' -ParameterFilter $getRegistryKeyParameterFilter -Times 1 -Scope 'Context'
                }

                It 'Should not attempt to create a new registry key' {
                    Assert-MockCalled -CommandName 'New-RegistryKey' -Times 0 -Scope 'Context'
                }

                It 'Should retrieve the registry key value display name' {
                    $getRegistryKeyValueDisplayNameParameterFilter = {
                        $registryKeyValueNameParameterCorrect = $RegistryKeyValueName -eq $setTargetResourceParameters.ValueName
                        return $registryKeyValueNameParameterCorrect
                    }

                    Assert-MockCalled -CommandName 'Get-RegistryKeyValueDisplayName' -ParameterFilter $getRegistryKeyValueDisplayNameParameterFilter -Times 1 -Scope 'Context'
                }

                It 'Should retrieve the registry key value' {
                    $getRegistryKeyValueParameterFilter = {
                        $registryKeyParameterCorrect = $null -eq (Compare-Object -ReferenceObject $script:testRegistryKey -DifferenceObject $RegistryKey)
                        return $registryKeyParameterCorrect
                    }

                    Assert-MockCalled -CommandName 'Get-RegistryKeyValue' -ParameterFilter $getRegistryKeyValueParameterFilter -Times 1 -Scope 'Context'
                }

                It 'Should not attempt to convert the specified registry key value to a string' {
                    Assert-MockCalled -CommandName 'ConvertTo-String' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to convert the specified registry key value to binary data' {
                    Assert-MockCalled -CommandName 'ConvertTo-Binary' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to convert the specified registry key value to a dword' {
                    Assert-MockCalled -CommandName 'ConvertTo-Dword' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to convert the specified registry key value to a qword' {
                    Assert-MockCalled -CommandName 'ConvertTo-Qword' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to convert the specified registry key value to a multi-string' {
                    Assert-MockCalled -CommandName 'ConvertTo-MultiString' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to test if the specified registry key value matches the retrieved registry key value' {
                    Assert-MockCalled -CommandName 'Test-RegistryKeyValuesMatch' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to retrieve the registry key name' {
                    Assert-MockCalled -CommandName 'Get-RegistryKeyName' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to set the registry key value' {
                    Assert-MockCalled -CommandName 'Set-RegistryKeyValue' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to remove the registry key value' {
                    Assert-MockCalled -CommandName 'Remove-ItemProperty' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to remove the default registry key value' {
                    Assert-MockCalled -CommandName 'Remove-DefaultRegistryKeyValue' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to retrieve the registry key subkey count' {
                    Assert-MockCalled -CommandName 'Get-RegistryKeySubKeyCount' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to remove the registry key' {
                    Assert-MockCalled -CommandName 'Remove-Item' -Times 0 -Scope 'Context'
                }

                It 'Should not return' {
                    Set-TargetResource @setTargetResourceParameters | Should Be $null
                }
            }

            Context 'Registry key exists, Ensure specified as Present, registry value name specified as empty string, and registry value type and data not specified' {
                $setTargetResourceParameters = @{
                    Key = 'TestRegistryKey'
                    ValueName = ''
                    Ensure = 'Present'
                }

                It 'Should not throw' {
                    { Set-TargetResource @setTargetResourceParameters } | Should Not Throw
                }

                It 'Should retrieve the registry key' {
                    $getRegistryKeyParameterFilter = {
                        $registryKeyPathParameterCorrect = $RegistryKeyPath -eq $setTargetResourceParameters.Key
                        return $registryKeyPathParameterCorrect
                    }

                    Assert-MockCalled -CommandName 'Get-RegistryKey' -ParameterFilter $getRegistryKeyParameterFilter -Times 1 -Scope 'Context'
                }

                It 'Should not attempt to create a new registry key' {
                    Assert-MockCalled -CommandName 'New-RegistryKey' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to retrieve the registry key value display name' {
                    Assert-MockCalled -CommandName 'Get-RegistryKeyValueDisplayName' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to retrieve the registry key value' {
                    Assert-MockCalled -CommandName 'Get-RegistryKeyValue' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to convert the specified registry key value to a string' {
                    Assert-MockCalled -CommandName 'ConvertTo-String' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to convert the specified registry key value to binary data' {
                    Assert-MockCalled -CommandName 'ConvertTo-Binary' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to convert the specified registry key value to a dword' {
                    Assert-MockCalled -CommandName 'ConvertTo-Dword' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to convert the specified registry key value to a qword' {
                    Assert-MockCalled -CommandName 'ConvertTo-Qword' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to convert the specified registry key value to a multi-string' {
                    Assert-MockCalled -CommandName 'ConvertTo-MultiString' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to test if the specified registry key value matches the retrieved registry key value' {
                    Assert-MockCalled -CommandName 'Test-RegistryKeyValuesMatch' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to retrieve the registry key name' {
                    Assert-MockCalled -CommandName 'Get-RegistryKeyName' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to set the registry key value' {
                    Assert-MockCalled -CommandName 'Set-RegistryKeyValue' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to remove the registry key value' {
                    Assert-MockCalled -CommandName 'Remove-ItemProperty' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to remove the default registry key value' {
                    Assert-MockCalled -CommandName 'Remove-DefaultRegistryKeyValue' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to retrieve the registry key subkey count' {
                    Assert-MockCalled -CommandName 'Get-RegistryKeySubKeyCount' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to remove the registry key' {
                    Assert-MockCalled -CommandName 'Remove-Item' -Times 0 -Scope 'Context'
                }

                It 'Should not return' {
                    Set-TargetResource @setTargetResourceParameters | Should Be $null
                }
            }
            
            Context 'Registry key exists, Ensure specified as Present, specified registry value does not exist, and registry value type and data not specified' {
                $setTargetResourceParameters = @{
                    Key = 'TestRegistryKey'
                    ValueName = 'TestRegistryKeyValueName'
                    Ensure = 'Present'
                }

                It 'Should not throw' {
                    { Set-TargetResource @setTargetResourceParameters } | Should Not Throw
                }

                It 'Should retrieve the registry key' {
                    $getRegistryKeyParameterFilter = {
                        $registryKeyPathParameterCorrect = $RegistryKeyPath -eq $setTargetResourceParameters.Key
                        return $registryKeyPathParameterCorrect
                    }

                    Assert-MockCalled -CommandName 'Get-RegistryKey' -ParameterFilter $getRegistryKeyParameterFilter -Times 1 -Scope 'Context'
                }

                It 'Should not attempt to create a new registry key' {
                    Assert-MockCalled -CommandName 'New-RegistryKey' -Times 0 -Scope 'Context'
                }

                It 'Should retrieve the registry key value display name' {
                    $getRegistryKeyValueDisplayNameParameterFilter = {
                        $registryKeyValueNameParameterCorrect = $RegistryKeyValueName -eq $setTargetResourceParameters.ValueName
                        return $registryKeyValueNameParameterCorrect
                    }

                    Assert-MockCalled -CommandName 'Get-RegistryKeyValueDisplayName' -ParameterFilter $getRegistryKeyValueDisplayNameParameterFilter -Times 1 -Scope 'Context'
                }

                It 'Should retrieve the registry key value' {
                    $getRegistryKeyValueParameterFilter = {
                        $registryKeyParameterCorrect = $null -eq (Compare-Object -ReferenceObject $script:testRegistryKey -DifferenceObject $RegistryKey)
                        return $registryKeyParameterCorrect
                    }

                    Assert-MockCalled -CommandName 'Get-RegistryKeyValue' -ParameterFilter $getRegistryKeyValueParameterFilter -Times 1 -Scope 'Context'
                }

                It 'Should convert the specified registry key value to a string' {
                    $convertToStringParameterFilter = {
                        $registryKeyValueParameterCorrect = $null -eq (Compare-Object -ReferenceObject $script:defaultValueData -DifferenceObject $RegistryKeyValue) 
                        return $registryKeyValueParameterCorrect
                    }

                    Assert-MockCalled -CommandName 'ConvertTo-String' -ParameterFilter $convertToStringParameterFilter -Times 1 -Scope 'Context'
                }

                It 'Should not attempt to convert the specified registry key value to binary data' {
                    Assert-MockCalled -CommandName 'ConvertTo-Binary' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to convert the specified registry key value to a dword' {
                    Assert-MockCalled -CommandName 'ConvertTo-Dword' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to convert the specified registry key value to a qword' {
                    Assert-MockCalled -CommandName 'ConvertTo-Qword' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to convert the specified registry key value to a multi-string' {
                    Assert-MockCalled -CommandName 'ConvertTo-MultiString' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to test if the specified registry key value matches the retrieved registry key value' {
                    Assert-MockCalled -CommandName 'Test-RegistryKeyValuesMatch' -Times 0 -Scope 'Context'
                }

                It 'Should retrieve the registry key name' {
                    $getRegistryKeyNameParameterFilter = {
                        $registryKeyParameterCorrect = $null -eq (Compare-Object -ReferenceObject $script:testRegistryKey -DifferenceObject $RegistryKey)
                        return $registryKeyParameterCorrect
                    }

                    Assert-MockCalled -CommandName 'Get-RegistryKeyName' -ParameterFilter $getRegistryKeyNameParameterFilter -Times 1 -Scope 'Context'
                }

                It 'Should set the registry key value' {
                    $setRegistryKeyValueParameterFilter = {
                        $registryKeyNameParameterCorrect = $RegistryKeyName -eq $setTargetResourceParameters.Key
                        $registryKeyValueNameParameterCorrect = $RegistryKeyValueName -eq $setTargetResourceParameters.ValueName
                        $registryKeyValueParameterCorrect = $null -eq $RegistryKeyValue
                        $valueTypeParameterCorrect = $ValueType -eq $script:defaultValueType

                        return $registryKeyNameParameterCorrect -and $registryKeyValueNameParameterCorrect -and $registryKeyValueParameterCorrect -and $valueTypeParameterCorrect
                    }

                    Assert-MockCalled -CommandName 'Set-RegistryKeyValue' -ParameterFilter $setRegistryKeyValueParameterFilter -Times 1 -Scope 'Context'
                }

                It 'Should not attempt to remove the registry key value' {
                    Assert-MockCalled -CommandName 'Remove-ItemProperty' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to remove the default registry key value' {
                    Assert-MockCalled -CommandName 'Remove-DefaultRegistryKeyValue' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to retrieve the registry key subkey count' {
                    Assert-MockCalled -CommandName 'Get-RegistryKeySubKeyCount' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to remove the registry key' {
                    Assert-MockCalled -CommandName 'Remove-Item' -Times 0 -Scope 'Context'
                }

                It 'Should not return' {
                    Set-TargetResource @setTargetResourceParameters | Should Be $null
                }
            }

            Context 'Registry key exists, Ensure specified as Present, default registry value does not exist, registry value type specified as binary, and value data specified' {
                $setTargetResourceParameters = @{
                    Key = 'TestRegistryKey'
                    ValueName = ''
                    ValueType = 'Binary'
                    ValueData = @( [Byte]::MinValue.ToString(), [Byte]::MaxValue.ToString() )
                    Ensure = 'Present'
                }

                It 'Should not throw' {
                    { Set-TargetResource @setTargetResourceParameters } | Should Not Throw
                }

                It 'Should retrieve the registry key' {
                    $getRegistryKeyParameterFilter = {
                        $registryKeyPathParameterCorrect = $RegistryKeyPath -eq $setTargetResourceParameters.Key
                        return $registryKeyPathParameterCorrect
                    }

                    Assert-MockCalled -CommandName 'Get-RegistryKey' -ParameterFilter $getRegistryKeyParameterFilter -Times 1 -Scope 'Context'
                }

                It 'Should not attempt to create a new registry key' {
                    Assert-MockCalled -CommandName 'New-RegistryKey' -Times 0 -Scope 'Context'
                }

                It 'Should retrieve the registry key value display name' {
                    $getRegistryKeyValueDisplayNameParameterFilter = {
                        $registryKeyValueNameParameterCorrect = $RegistryKeyValueName -eq $setTargetResourceParameters.ValueName
                        return $registryKeyValueNameParameterCorrect
                    }

                    Assert-MockCalled -CommandName 'Get-RegistryKeyValueDisplayName' -ParameterFilter $getRegistryKeyValueDisplayNameParameterFilter -Times 1 -Scope 'Context'
                }

                It 'Should retrieve the registry key value' {
                    $getRegistryKeyValueParameterFilter = {
                        $registryKeyParameterCorrect = $null -eq (Compare-Object -ReferenceObject $script:testRegistryKey -DifferenceObject $RegistryKey)
                        return $registryKeyParameterCorrect
                    }

                    Assert-MockCalled -CommandName 'Get-RegistryKeyValue' -ParameterFilter $getRegistryKeyValueParameterFilter -Times 1 -Scope 'Context'
                }

                It 'Should not attempt to convert the specified registry key value to a string' {
                    Assert-MockCalled -CommandName 'ConvertTo-String' -Times 0 -Scope 'Context'
                }

                It 'Should convert the specified registry key value to binary data' {
                    $convertToBinaryParameterFilter = {
                        $registryKeyValueParameterCorrect = $null -eq (Compare-Object -ReferenceObject $setTargetResourceParameters.ValueData -DifferenceObject $RegistryKeyValue) 
                        return $registryKeyValueParameterCorrect
                    }

                    Assert-MockCalled -CommandName 'ConvertTo-Binary' -ParameterFilter $convertToBinaryParameterFilter -Times 1 -Scope 'Context'
                }

                It 'Should not attempt to convert the specified registry key value to a dword' {
                    Assert-MockCalled -CommandName 'ConvertTo-Dword' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to convert the specified registry key value to a qword' {
                    Assert-MockCalled -CommandName 'ConvertTo-Qword' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to convert the specified registry key value to a multi-string' {
                    Assert-MockCalled -CommandName 'ConvertTo-MultiString' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to test if the specified registry key value matches the retrieved registry key value' {
                    Assert-MockCalled -CommandName 'Test-RegistryKeyValuesMatch' -Times 0 -Scope 'Context'
                }

                It 'Should retrieve the registry key name' {
                    $getRegistryKeyNameParameterFilter = {
                        $registryKeyParameterCorrect = $null -eq (Compare-Object -ReferenceObject $script:testRegistryKey -DifferenceObject $RegistryKey)
                        return $registryKeyParameterCorrect
                    }

                    Assert-MockCalled -CommandName 'Get-RegistryKeyName' -ParameterFilter $getRegistryKeyNameParameterFilter -Times 1 -Scope 'Context'
                }

                It 'Should set the registry key value' {
                    $setRegistryKeyValueParameterFilter = {
                        $registryKeyNameParameterCorrect = $RegistryKeyName -eq $setTargetResourceParameters.Key
                        $registryKeyValueNameParameterCorrect = $RegistryKeyValueName -eq $setTargetResourceParameters.ValueName
                        $registryKeyValueParameterCorrect = $null -eq (Compare-Object -ReferenceObject $setTargetResourceParameters.ValueData -DifferenceObject $RegistryKeyValue)
                        $valueTypeParameterCorrect = $ValueType -eq $setTargetResourceParameters.ValueType

                        return $registryKeyNameParameterCorrect -and $registryKeyValueNameParameterCorrect -and $registryKeyValueParameterCorrect -and $valueTypeParameterCorrect
                    }

                    Assert-MockCalled -CommandName 'Set-RegistryKeyValue' -ParameterFilter $setRegistryKeyValueParameterFilter -Times 1 -Scope 'Context'
                }

                It 'Should not attempt to remove the registry key value' {
                    Assert-MockCalled -CommandName 'Remove-ItemProperty' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to remove the default registry key value' {
                    Assert-MockCalled -CommandName 'Remove-DefaultRegistryKeyValue' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to retrieve the registry key subkey count' {
                    Assert-MockCalled -CommandName 'Get-RegistryKeySubKeyCount' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to remove the registry key' {
                    Assert-MockCalled -CommandName 'Remove-Item' -Times 0 -Scope 'Context'
                }

                It 'Should not return' {
                    Set-TargetResource @setTargetResourceParameters | Should Be $null
                }
            }

            Mock -CommandName 'Get-RegistryKeyValue' -MockWith { return $setTargetResourceParameters.ValueData }

            Context 'Registry key exists, Ensure specified as Present, specified registry value exists and matches specified multi-string value data' {
                $setTargetResourceParameters = @{
                    Key = 'TestRegistryKey'
                    ValueName = 'TestRegistryeyValueName'
                    ValueType = 'MultiString'
                    ValueData = @( 'TestValueData1', 'TestValueData2' )
                    Ensure = 'Present'
                }

                It 'Should not throw' {
                    { Set-TargetResource @setTargetResourceParameters } | Should Not Throw
                }

                It 'Should retrieve the registry key' {
                    $getRegistryKeyParameterFilter = {
                        $registryKeyPathParameterCorrect = $RegistryKeyPath -eq $setTargetResourceParameters.Key
                        return $registryKeyPathParameterCorrect
                    }

                    Assert-MockCalled -CommandName 'Get-RegistryKey' -ParameterFilter $getRegistryKeyParameterFilter -Times 1 -Scope 'Context'
                }

                It 'Should not attempt to create a new registry key' {
                    Assert-MockCalled -CommandName 'New-RegistryKey' -Times 0 -Scope 'Context'
                }

                It 'Should retrieve the registry key value display name' {
                    $getRegistryKeyValueDisplayNameParameterFilter = {
                        $registryKeyValueNameParameterCorrect = $RegistryKeyValueName -eq $setTargetResourceParameters.ValueName
                        return $registryKeyValueNameParameterCorrect
                    }

                    Assert-MockCalled -CommandName 'Get-RegistryKeyValueDisplayName' -ParameterFilter $getRegistryKeyValueDisplayNameParameterFilter -Times 1 -Scope 'Context'
                }

                It 'Should retrieve the registry key value' {
                    $getRegistryKeyValueParameterFilter = {
                        $registryKeyParameterCorrect = $null -eq (Compare-Object -ReferenceObject $script:testRegistryKey -DifferenceObject $RegistryKey)
                        return $registryKeyParameterCorrect
                    }

                    Assert-MockCalled -CommandName 'Get-RegistryKeyValue' -ParameterFilter $getRegistryKeyValueParameterFilter -Times 1 -Scope 'Context'
                }

                It 'Should not attempt to convert the specified registry key value to a string' {
                    Assert-MockCalled -CommandName 'ConvertTo-String' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to convert the specified registry key value to binary data' {
                    Assert-MockCalled -CommandName 'ConvertTo-Binary' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to convert the specified registry key value to a dword' {
                    Assert-MockCalled -CommandName 'ConvertTo-Dword' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to convert the specified registry key value to a qword' {
                    Assert-MockCalled -CommandName 'ConvertTo-Qword' -Times 0 -Scope 'Context'
                }

                It 'Should convert the specified registry key value to a multi-string' {
                    $convertToMultiStringParameterFilter = {
                        $registryKeyValueParameterCorrect = $null -eq (Compare-Object -ReferenceObject $setTargetResourceParameters.ValueData -DifferenceObject $RegistryKeyValue) 
                        return $registryKeyValueParameterCorrect
                    }

                    Assert-MockCalled -CommandName 'ConvertTo-MultiString' -ParameterFilter $convertToMultiStringParameterFilter -Times 1 -Scope 'Context'
                }

                It 'Should test if the specified registry key value matches the retrieved registry key value' {
                    $testRegistryKeyValuesMatchParameterFilter = {
                        $expectedRegistryKeyValueParameterCorrect = $null -eq (Compare-Object -ReferenceObject $setTargetResourceParameters.ValueData -DifferenceObject $ExpectedRegistryKeyValue)
                        $actualRegistryKeyValueParameterCorrect = $null -eq (Compare-Object -ReferenceObject $setTargetResourceParameters.ValueData -DifferenceObject $ActualRegistryKeyValue)
                        $registryKeyValueTypeParameterCorrect = $RegistryKeyValueType -eq $setTargetResourceParameters.ValueType

                        return $expectedRegistryKeyValueParameterCorrect -and $actualRegistryKeyValueParameterCorrect -and $registryKeyValueTypeParameterCorrect
                    }

                    Assert-MockCalled -CommandName 'Test-RegistryKeyValuesMatch' -ParameterFilter $testRegistryKeyValuesMatchParameterFilter -Times 1 -Scope 'Context'
                }

                It 'Should retrieve the registry key name' {
                    $getRegistryKeyNameParameterFilter = {
                        $registryKeyParameterCorrect = $null -eq (Compare-Object -ReferenceObject $script:testRegistryKey -DifferenceObject $RegistryKey)
                        return $registryKeyParameterCorrect
                    }

                    Assert-MockCalled -CommandName 'Get-RegistryKeyName' -ParameterFilter $getRegistryKeyNameParameterFilter -Times 1 -Scope 'Context'
                }

                It 'Should not attempt to set the registry key value' {
                    Assert-MockCalled -CommandName 'Set-RegistryKeyValue' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to remove the registry key value' {
                    Assert-MockCalled -CommandName 'Remove-ItemProperty' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to remove the default registry key value' {
                    Assert-MockCalled -CommandName 'Remove-DefaultRegistryKeyValue' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to retrieve the registry key subkey count' {
                    Assert-MockCalled -CommandName 'Get-RegistryKeySubKeyCount' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to remove the registry key' {
                    Assert-MockCalled -CommandName 'Remove-Item' -Times 0 -Scope 'Context'
                }

                It 'Should not return' {
                    Set-TargetResource @setTargetResourceParameters | Should Be $null
                }
            }

            Mock -CommandName 'Test-RegistryKeyValuesMatch' -MockWith { return $false }

            Context 'Registry key exists, Ensure specified as Present, specified registry value exists and does not match specified expand string value data, and Force not specified' {
                $setTargetResourceParameters = @{
                    Key = 'TestRegistryKey'
                    ValueName = 'TestRegistryeyValueName'
                    ValueType = 'ExpandString'
                    ValueData = 'TestValueData1'
                    Ensure = 'Present'
                }

                It 'Should throw error for trying to overwrite existing registry key value without specifying Force as True' {
                    $errorMessage = $script:localizedData.CannotOverwriteExistingRegistryKeyValueWithoutForce -f $setTargetResourceParameters.Key, $setTargetResourceParameters.ValueName

                    { Set-TargetResource @setTargetResourceParameters } | Should Throw $errorMessage
                }
            }

            Context 'Registry key exists, Ensure specified as Present, specified registry value exists and does not match specified dword value data, and Hex and Force specified as True' {
                $setTargetResourceParameters = @{
                    Key = 'TestRegistryKey'
                    ValueName = 'TestRegistryeyValueName'
                    ValueType = 'DWord'
                    ValueData = 'x9A'
                    Ensure = 'Present'
                    Hex = $true
                    Force = $true
                }

                It 'Should not throw' {
                    { Set-TargetResource @setTargetResourceParameters } | Should Not Throw
                }

                It 'Should retrieve the registry key' {
                    $getRegistryKeyParameterFilter = {
                        $registryKeyPathParameterCorrect = $RegistryKeyPath -eq $setTargetResourceParameters.Key
                        return $registryKeyPathParameterCorrect
                    }

                    Assert-MockCalled -CommandName 'Get-RegistryKey' -ParameterFilter $getRegistryKeyParameterFilter -Times 1 -Scope 'Context'
                }

                It 'Should not attempt to create a new registry key' {
                    Assert-MockCalled -CommandName 'New-RegistryKey' -Times 0 -Scope 'Context'
                }

                It 'Should retrieve the registry key value display name' {
                    $getRegistryKeyValueDisplayNameParameterFilter = {
                        $registryKeyValueNameParameterCorrect = $RegistryKeyValueName -eq $setTargetResourceParameters.ValueName
                        return $registryKeyValueNameParameterCorrect
                    }

                    Assert-MockCalled -CommandName 'Get-RegistryKeyValueDisplayName' -ParameterFilter $getRegistryKeyValueDisplayNameParameterFilter -Times 1 -Scope 'Context'
                }

                It 'Should retrieve the registry key value' {
                    $getRegistryKeyValueParameterFilter = {
                        $registryKeyParameterCorrect = $null -eq (Compare-Object -ReferenceObject $script:testRegistryKey -DifferenceObject $RegistryKey)
                        return $registryKeyParameterCorrect
                    }

                    Assert-MockCalled -CommandName 'Get-RegistryKeyValue' -ParameterFilter $getRegistryKeyValueParameterFilter -Times 1 -Scope 'Context'
                }

                It 'Should not attempt to convert the specified registry key value to a string' {
                    Assert-MockCalled -CommandName 'ConvertTo-String' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to convert the specified registry key value to binary data' {
                    Assert-MockCalled -CommandName 'ConvertTo-Binary' -Times 0 -Scope 'Context'
                }

                It 'Should convert the specified registry key value to a dword' {
                    $convertToDwordParameterFilter = {
                        $registryKeyValueParameterCorrect = $null -eq (Compare-Object -ReferenceObject $setTargetResourceParameters.ValueData -DifferenceObject $RegistryKeyValue) 
                        $hexParameterCorrect = $Hex -eq $setTargetResourceParameters.Hex
                        
                        return $registryKeyValueParameterCorrect -and $hexParameterCorrect
                    }

                    Assert-MockCalled -CommandName 'ConvertTo-Dword' -ParameterFilter $convertToDwordParameterFilter -Times 1 -Scope 'Context'
                }

                It 'Should not attempt to convert the specified registry key value to a qword' {
                    Assert-MockCalled -CommandName 'ConvertTo-Qword' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to convert the specified registry key value to a multi-string' {
                    Assert-MockCalled -CommandName 'ConvertTo-MultiString' -Times 0 -Scope 'Context'
                }

                It 'Should test if the specified registry key value matches the retrieved registry key value' {
                    $testRegistryKeyValuesMatchParameterFilter = {
                        $expectedRegistryKeyValueParameterCorrect = $null -eq (Compare-Object -ReferenceObject $setTargetResourceParameters.ValueData -DifferenceObject $ExpectedRegistryKeyValue)
                        $actualRegistryKeyValueParameterCorrect = $null -eq (Compare-Object -ReferenceObject $setTargetResourceParameters.ValueData -DifferenceObject $ActualRegistryKeyValue)
                        $registryKeyValueTypeParameterCorrect = $RegistryKeyValueType -eq $setTargetResourceParameters.ValueType

                        return $expectedRegistryKeyValueParameterCorrect -and $actualRegistryKeyValueParameterCorrect -and $registryKeyValueTypeParameterCorrect
                    }

                    Assert-MockCalled -CommandName 'Test-RegistryKeyValuesMatch' -ParameterFilter $testRegistryKeyValuesMatchParameterFilter -Times 1 -Scope 'Context'
                }

                It 'Should retrieve the registry key name' {
                    $getRegistryKeyNameParameterFilter = {
                        $registryKeyParameterCorrect = $null -eq (Compare-Object -ReferenceObject $script:testRegistryKey -DifferenceObject $RegistryKey)
                        return $registryKeyParameterCorrect
                    }

                    Assert-MockCalled -CommandName 'Get-RegistryKeyName' -ParameterFilter $getRegistryKeyNameParameterFilter -Times 1 -Scope 'Context'
                }

                It 'Should set the registry key value' {
                    $setRegistryKeyValueParameterFilter = {
                        $registryKeyNameParameterCorrect = $RegistryKeyName -eq $setTargetResourceParameters.Key
                        $registryKeyValueNameParameterCorrect = $RegistryKeyValueName -eq $setTargetResourceParameters.ValueName
                        $registryKeyValueParameterCorrect = $null -eq (Compare-Object -ReferenceObject $setTargetResourceParameters.ValueData -DifferenceObject $RegistryKeyValue)
                        $valueTypeParameterCorrect = $ValueType -eq $setTargetResourceParameters.ValueType

                        return $registryKeyNameParameterCorrect -and $registryKeyValueNameParameterCorrect -and $registryKeyValueParameterCorrect -and $valueTypeParameterCorrect
                    }

                    Assert-MockCalled -CommandName 'Set-RegistryKeyValue' -ParameterFilter $setRegistryKeyValueParameterFilter -Times 1 -Scope 'Context'
                }

                It 'Should not attempt to remove the registry key value' {
                    Assert-MockCalled -CommandName 'Remove-ItemProperty' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to remove the default registry key value' {
                    Assert-MockCalled -CommandName 'Remove-DefaultRegistryKeyValue' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to retrieve the registry key subkey count' {
                    Assert-MockCalled -CommandName 'Get-RegistryKeySubKeyCount' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to remove the registry key' {
                    Assert-MockCalled -CommandName 'Remove-Item' -Times 0 -Scope 'Context'
                }

                It 'Should not return' {
                    Set-TargetResource @setTargetResourceParameters | Should Be $null
                }
            }

            Context 'Registry key exists, Ensure specified as Present, specified registry value exists and does not match specified qword value data, and Hex and Force specified as True' {
                $setTargetResourceParameters = @{
                    Key = 'TestRegistryKey'
                    ValueName = 'TestRegistryeyValueName'
                    ValueType = 'QWord'
                    ValueData = 'x9A'
                    Ensure = 'Present'
                    Hex = $true
                    Force = $true
                }

                It 'Should not throw' {
                    { Set-TargetResource @setTargetResourceParameters } | Should Not Throw
                }

                It 'Should retrieve the registry key' {
                    $getRegistryKeyParameterFilter = {
                        $registryKeyPathParameterCorrect = $RegistryKeyPath -eq $setTargetResourceParameters.Key
                        return $registryKeyPathParameterCorrect
                    }

                    Assert-MockCalled -CommandName 'Get-RegistryKey' -ParameterFilter $getRegistryKeyParameterFilter -Times 1 -Scope 'Context'
                }

                It 'Should not attempt to create a new registry key' {
                    Assert-MockCalled -CommandName 'New-RegistryKey' -Times 0 -Scope 'Context'
                }

                It 'Should retrieve the registry key value display name' {
                    $getRegistryKeyValueDisplayNameParameterFilter = {
                        $registryKeyValueNameParameterCorrect = $RegistryKeyValueName -eq $setTargetResourceParameters.ValueName
                        return $registryKeyValueNameParameterCorrect
                    }

                    Assert-MockCalled -CommandName 'Get-RegistryKeyValueDisplayName' -ParameterFilter $getRegistryKeyValueDisplayNameParameterFilter -Times 1 -Scope 'Context'
                }

                It 'Should retrieve the registry key value' {
                    $getRegistryKeyValueParameterFilter = {
                        $registryKeyParameterCorrect = $null -eq (Compare-Object -ReferenceObject $script:testRegistryKey -DifferenceObject $RegistryKey)
                        return $registryKeyParameterCorrect
                    }

                    Assert-MockCalled -CommandName 'Get-RegistryKeyValue' -ParameterFilter $getRegistryKeyValueParameterFilter -Times 1 -Scope 'Context'
                }

                It 'Should not attempt to convert the specified registry key value to a string' {
                    Assert-MockCalled -CommandName 'ConvertTo-String' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to convert the specified registry key value to binary data' {
                    Assert-MockCalled -CommandName 'ConvertTo-Binary' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to convert the specified registry key value to a dword' {
                    Assert-MockCalled -CommandName 'ConvertTo-Dword' -Times 0 -Scope 'Context'
                }

                It 'Should convert the specified registry key value to a qword' {
                    $convertToQwordParameterFilter = {
                        $registryKeyValueParameterCorrect = $null -eq (Compare-Object -ReferenceObject $setTargetResourceParameters.ValueData -DifferenceObject $RegistryKeyValue) 
                        $hexParameterCorrect = $Hex -eq $setTargetResourceParameters.Hex
                        
                        return $registryKeyValueParameterCorrect -and $hexParameterCorrect
                    }

                    Assert-MockCalled -CommandName 'ConvertTo-Qword' -ParameterFilter $convertToQwordParameterFilter -Times 1 -Scope 'Context'
                }

                It 'Should not attempt to convert the specified registry key value to a multi-string' {
                    Assert-MockCalled -CommandName 'ConvertTo-MultiString' -Times 0 -Scope 'Context'
                }

                It 'Should test if the specified registry key value matches the retrieved registry key value' {
                    $testRegistryKeyValuesMatchParameterFilter = {
                        $expectedRegistryKeyValueParameterCorrect = $null -eq (Compare-Object -ReferenceObject $setTargetResourceParameters.ValueData -DifferenceObject $ExpectedRegistryKeyValue)
                        $actualRegistryKeyValueParameterCorrect = $null -eq (Compare-Object -ReferenceObject $setTargetResourceParameters.ValueData -DifferenceObject $ActualRegistryKeyValue)
                        $registryKeyValueTypeParameterCorrect = $RegistryKeyValueType -eq $setTargetResourceParameters.ValueType

                        return $expectedRegistryKeyValueParameterCorrect -and $actualRegistryKeyValueParameterCorrect -and $registryKeyValueTypeParameterCorrect
                    }

                    Assert-MockCalled -CommandName 'Test-RegistryKeyValuesMatch' -ParameterFilter $testRegistryKeyValuesMatchParameterFilter -Times 1 -Scope 'Context'
                }

                It 'Should retrieve the registry key name' {
                    $getRegistryKeyNameParameterFilter = {
                        $registryKeyParameterCorrect = $null -eq (Compare-Object -ReferenceObject $script:testRegistryKey -DifferenceObject $RegistryKey)
                        return $registryKeyParameterCorrect
                    }

                    Assert-MockCalled -CommandName 'Get-RegistryKeyName' -ParameterFilter $getRegistryKeyNameParameterFilter -Times 1 -Scope 'Context'
                }

                It 'Should set the registry key value' {
                    $setRegistryKeyValueParameterFilter = {
                        $registryKeyNameParameterCorrect = $RegistryKeyName -eq $setTargetResourceParameters.Key
                        $registryKeyValueNameParameterCorrect = $RegistryKeyValueName -eq $setTargetResourceParameters.ValueName
                        $registryKeyValueParameterCorrect = $null -eq (Compare-Object -ReferenceObject $setTargetResourceParameters.ValueData -DifferenceObject $RegistryKeyValue)
                        $valueTypeParameterCorrect = $ValueType -eq $setTargetResourceParameters.ValueType

                        return $registryKeyNameParameterCorrect -and $registryKeyValueNameParameterCorrect -and $registryKeyValueParameterCorrect -and $valueTypeParameterCorrect
                    }

                    Assert-MockCalled -CommandName 'Set-RegistryKeyValue' -ParameterFilter $setRegistryKeyValueParameterFilter -Times 1 -Scope 'Context'
                }

                It 'Should not attempt to remove the registry key value' {
                    Assert-MockCalled -CommandName 'Remove-ItemProperty' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to remove the default registry key value' {
                    Assert-MockCalled -CommandName 'Remove-DefaultRegistryKeyValue' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to retrieve the registry key subkey count' {
                    Assert-MockCalled -CommandName 'Get-RegistryKeySubKeyCount' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to remove the registry key' {
                    Assert-MockCalled -CommandName 'Remove-Item' -Times 0 -Scope 'Context'
                }

                It 'Should not return' {
                    Set-TargetResource @setTargetResourceParameters | Should Be $null
                }
            }

            Mock -CommandName 'Get-RegistryKeyValue' -MockWith { return 'NotNull' }

            Context 'Registry key exists, Ensure specified as Absent specified registry value exists' {
                $setTargetResourceParameters = @{
                    Key = 'TestRegistryKey'
                    ValueName = 'TestRegistryKeyValueName'
                    Ensure = 'Absent'
                    Force = $true
                }

                It 'Should not throw' {
                    { Set-TargetResource @setTargetResourceParameters } | Should Not Throw
                }

                It 'Should retrieve the registry key' {
                    $getRegistryKeyParameterFilter = {
                        $registryKeyPathParameterCorrect = $RegistryKeyPath -eq $setTargetResourceParameters.Key
                        return $registryKeyPathParameterCorrect
                    }

                    Assert-MockCalled -CommandName 'Get-RegistryKey' -ParameterFilter $getRegistryKeyParameterFilter -Times 1 -Scope 'Context'
                }

                It 'Should not attempt to create a new registry key' {
                    Assert-MockCalled -CommandName 'New-RegistryKey' -Times 0 -Scope 'Context'
                }

                It 'Should retrieve the registry key value display name' {
                    $getRegistryKeyValueDisplayNameParameterFilter = {
                        $registryKeyValueNameParameterCorrect = $RegistryKeyValueName -eq $setTargetResourceParameters.ValueName
                        return $registryKeyValueNameParameterCorrect
                    }

                    Assert-MockCalled -CommandName 'Get-RegistryKeyValueDisplayName' -ParameterFilter $getRegistryKeyValueDisplayNameParameterFilter -Times 1 -Scope 'Context'
                }

                It 'Should retrieve the registry key value' {
                    $getRegistryKeyValueParameterFilter = {
                        $registryKeyParameterCorrect = $null -eq (Compare-Object -ReferenceObject $script:testRegistryKey -DifferenceObject $RegistryKey)
                        return $registryKeyParameterCorrect
                    }

                    Assert-MockCalled -CommandName 'Get-RegistryKeyValue' -ParameterFilter $getRegistryKeyValueParameterFilter -Times 1 -Scope 'Context'
                }

                It 'Should not attempt to convert the specified registry key value to a string' {
                    Assert-MockCalled -CommandName 'ConvertTo-String' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to convert the specified registry key value to binary data' {
                    Assert-MockCalled -CommandName 'ConvertTo-Binary' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to convert the specified registry key value to a dword' {
                    Assert-MockCalled -CommandName 'ConvertTo-Dword' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to convert the specified registry key value to a qword' {
                    Assert-MockCalled -CommandName 'ConvertTo-Qword' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to convert the specified registry key value to a multi-string' {
                    Assert-MockCalled -CommandName 'ConvertTo-MultiString' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to test if the specified registry key value matches the retrieved registry key value' {
                    Assert-MockCalled -CommandName 'Test-RegistryKeyValuesMatch' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to retrieve the registry key name' {
                    Assert-MockCalled -CommandName 'Get-RegistryKeyName' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to set the registry key value' {
                    Assert-MockCalled -CommandName 'Set-RegistryKeyValue' -Times 0 -Scope 'Context'
                }

                It 'Should remove the registry key value' {
                    $removeItemPropertyParameterFilter = {
                        $pathParameterCorrect = $Path -eq $setTargetResourceParameters.Key
                        $nameParameterCorrect = $Name -eq $setTargetResourceParameters.ValueName
                        $forceParameterCorrect = $Force -eq $true

                        return $pathParameterCorrect -and $nameParameterCorrect -and $forceParameterCorrect
                    }

                    Assert-MockCalled -CommandName 'Remove-ItemProperty' -ParameterFilter $removeItemPropertyParameterFilter -Times 1 -Scope 'Context'
                }

                It 'Should not attempt to remove the default registry key value' {
                    Assert-MockCalled -CommandName 'Remove-DefaultRegistryKeyValue' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to retrieve the registry key subkey count' {
                    Assert-MockCalled -CommandName 'Get-RegistryKeySubKeyCount' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to remove the registry key' {
                    Assert-MockCalled -CommandName 'Remove-Item' -Times 0 -Scope 'Context'
                }

                It 'Should not return' {
                    Set-TargetResource @setTargetResourceParameters | Should Be $null
                }
            }

            Context 'Registry key exists, Ensure specified as Absent, default registry value exists, and Force specified as True' {
                $setTargetResourceParameters = @{
                    Key = 'TestRegistryKey'
                    ValueName = ''
                    ValueType = 'String'
                    ValueData = 'TestValueData'
                    Ensure = 'Absent'
                    Force = $true
                }

                It 'Should not throw' {
                    { Set-TargetResource @setTargetResourceParameters } | Should Not Throw
                }

                It 'Should retrieve the registry key' {
                    $getRegistryKeyParameterFilter = {
                        $registryKeyPathParameterCorrect = $RegistryKeyPath -eq $setTargetResourceParameters.Key
                        return $registryKeyPathParameterCorrect
                    }

                    Assert-MockCalled -CommandName 'Get-RegistryKey' -ParameterFilter $getRegistryKeyParameterFilter -Times 1 -Scope 'Context'
                }

                It 'Should not attempt to create a new registry key' {
                    Assert-MockCalled -CommandName 'New-RegistryKey' -Times 0 -Scope 'Context'
                }

                It 'Should retrieve the registry key value display name' {
                    $getRegistryKeyValueDisplayNameParameterFilter = {
                        $registryKeyValueNameParameterCorrect = $RegistryKeyValueName -eq $setTargetResourceParameters.ValueName
                        return $registryKeyValueNameParameterCorrect
                    }

                    Assert-MockCalled -CommandName 'Get-RegistryKeyValueDisplayName' -ParameterFilter $getRegistryKeyValueDisplayNameParameterFilter -Times 1 -Scope 'Context'
                }

                It 'Should retrieve the registry key value' {
                    $getRegistryKeyValueParameterFilter = {
                        $registryKeyParameterCorrect = $null -eq (Compare-Object -ReferenceObject $script:testRegistryKey -DifferenceObject $RegistryKey)
                        return $registryKeyParameterCorrect
                    }

                    Assert-MockCalled -CommandName 'Get-RegistryKeyValue' -ParameterFilter $getRegistryKeyValueParameterFilter -Times 1 -Scope 'Context'
                }

                It 'Should not attempt to convert the specified registry key value to a string' {
                    Assert-MockCalled -CommandName 'ConvertTo-String' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to convert the specified registry key value to binary data' {
                    Assert-MockCalled -CommandName 'ConvertTo-Binary' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to convert the specified registry key value to a dword' {
                    Assert-MockCalled -CommandName 'ConvertTo-Dword' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to convert the specified registry key value to a qword' {
                    Assert-MockCalled -CommandName 'ConvertTo-Qword' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to convert the specified registry key value to a multi-string' {
                    Assert-MockCalled -CommandName 'ConvertTo-MultiString' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to test if the specified registry key value matches the retrieved registry key value' {
                    Assert-MockCalled -CommandName 'Test-RegistryKeyValuesMatch' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to retrieve the registry key name' {
                    Assert-MockCalled -CommandName 'Get-RegistryKeyName' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to set the registry key value' {
                    Assert-MockCalled -CommandName 'Set-RegistryKeyValue' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to remove the registry key value' {
                    Assert-MockCalled -CommandName 'Remove-ItemProperty' -Times 0 -Scope 'Context'
                }

                It 'Should remove the default registry key value' {
                    $removeReistryKeyDefaultValueParameterFilter = {
                        $registryKeyParameterCorrect = $null -eq (Compare-Object -ReferenceObject $script:testRegistryKey -DifferenceObject $RegistryKey)
                        return $registryKeyParameterCorrect
                    }

                    Assert-MockCalled -CommandName 'Remove-DefaultRegistryKeyValue' -ParameterFilter $removeReistryKeyDefaultValueParameterFilter -Times 1 -Scope 'Context'
                }

                It 'Should not attempt to retrieve the registry key subkey count' {
                    Assert-MockCalled -CommandName 'Get-RegistryKeySubKeyCount' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to remove the registry key' {
                    Assert-MockCalled -CommandName 'Remove-Item' -Times 0 -Scope 'Context'
                }

                It 'Should not return' {
                    Set-TargetResource @setTargetResourceParameters | Should Be $null
                }
            }
        }
        
        Describe 'xRegistry\Test-TargetResource' {
            Mock -CommandName 'Get-RegistryKeyValueDisplayName' -MockWith { return $RegistryKeyValueName }
            Mock -CommandName 'Test-RegistryKeyValuesMatch' -MockWith { return $true }
            Mock -CommandName 'Get-RegistryKey' -MockWith { return $script:testRegistryKey }

            $testRegistryKeyValue = 'Something'

            Mock -CommandName 'Get-RegistryKeyValue' -MockWith { return $testRegistryKeyValue }

            Mock -CommandName 'Get-TargetResource' -MockWith {
                return @{
                    Ensure = 'Absent'
                }
            }

            Context 'Registry key does not exist and Ensure set to Absent' {
                $testTargetResourceParameters = @{
                    Key = 'TestRegistryKey'
                    ValueName = ''
                    Ensure = 'Absent'
                }

                It 'Should not throw' {
                    { $null = Test-TargetResource @testTargetResourceParameters } | Should Not Throw
                }

                It 'Should retrieve the registry resource with the specified reigstry key and value name' {
                    $getTargetResourceParameterFilter = {
                        $keyParameterCorrect = $Key -eq $testTargetResourceParameters.Key
                        $valueNameParameterCorrect = $ValueName -eq $testTargetResourceParameters.ValueName

                        return $keyParameterCorrect -and $valueNameParameterCorrect
                    }

                    Assert-MockCalled -CommandName 'Get-TargetResource' -ParameterFilter $getTargetResourceParameterFilter -Times 1 -Scope 'Context'
                }

                It 'Should not attempt to retrieve the registry key value display name' {
                    Assert-MockCalled -CommandName 'Get-RegistryKeyValueDisplayName' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to test if the specified registry key value matches the retrieved registry key value' {
                    Assert-MockCalled -CommandName 'Test-RegistryKeyValuesMatch' -Times 0 -Scope 'Context'
                }

                $testTargetResourceResult = Test-TargetResource @testTargetResourceParameters

                It 'Should return a boolean' {
                    $testTargetResourceResult -is [Boolean] | Should Be $true
                }

                It 'Should return True' {
                    $testTargetResourceResult | Should Be $true
                }
            }

            Context 'Registry key does not exist and Ensure set to Present' {
                $testTargetResourceParameters = @{
                    Key = 'TestRegistryKey'
                    ValueName = ''
                    Ensure = 'Present'
                }

                It 'Should not throw' {
                    { $null = Test-TargetResource @testTargetResourceParameters } | Should Not Throw
                }

                It 'Should retrieve the registry resource with the specified reigstry key and value name' {
                    $getTargetResourceParameterFilter = {
                        $keyParameterCorrect = $Key -eq $testTargetResourceParameters.Key
                        $valueNameParameterCorrect = $ValueName -eq $testTargetResourceParameters.ValueName

                        return $keyParameterCorrect -and $valueNameParameterCorrect
                    }

                    Assert-MockCalled -CommandName 'Get-TargetResource' -ParameterFilter $getTargetResourceParameterFilter -Times 1 -Scope 'Context'
                }

                It 'Should not attempt to retrieve the registry key value display name' {
                    Assert-MockCalled -CommandName 'Get-RegistryKeyValueDisplayName' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to test if the specified registry key value matches the retrieved registry key value' {
                    Assert-MockCalled -CommandName 'Test-RegistryKeyValuesMatch' -Times 0 -Scope 'Context'
                }

                $testTargetResourceResult = Test-TargetResource @testTargetResourceParameters

                It 'Should return a boolean' {
                    $testTargetResourceResult -is [Boolean] | Should Be $true
                }

                It 'Should return False' {
                    $testTargetResourceResult | Should Be $false
                }
            }

            Mock -CommandName 'Get-TargetResource' -MockWith {
                if ([String]::IsNullOrEmpty($ValueName))
                {
                    return @{
                        Ensure = 'Present'
                    }
                }
                else
                {
                    return @{
                        Ensure = 'Absent'
                    }
                }
            }

            Context 'Registry key value does not exist and Ensure set to Absent' {
                $testTargetResourceParameters = @{
                    Key = 'TestRegistryKey'
                    ValueName = 'TestRegistryKeyValueName'
                    Ensure = 'Absent'
                }

                It 'Should not throw' {
                    { $null = Test-TargetResource @testTargetResourceParameters } | Should Not Throw
                }

                It 'Should retrieve the registry key value display name' {
                    $getRegistryKeyValueDisplayNameParameterFilter = {
                        $registryKeyValueNameParameterCorrect = $RegistryKeyValueName -eq $testTargetResourceParameters.ValueName
                        return $registryKeyValueNameParameterCorrect
                    }

                    Assert-MockCalled -CommandName 'Get-RegistryKeyValueDisplayName' -ParameterFilter $getRegistryKeyValueDisplayNameParameterFilter -Times 1 -Scope 'Context'
                }

                It 'Should retrieve the registry resource with the specified reigstry key and value name' {
                    $getTargetResourceParameterFilter = {
                        $keyParameterCorrect = $Key -eq $testTargetResourceParameters.Key
                        $valueNameParameterCorrect = $ValueName -eq $testTargetResourceParameters.ValueName

                        return $keyParameterCorrect -and $valueNameParameterCorrect
                    }

                    Assert-MockCalled -CommandName 'Get-TargetResource' -ParameterFilter $getTargetResourceParameterFilter -Times 1 -Scope 'Context'
                }

                It 'Should not attempt to test if the specified registry key value matches the retrieved registry key value' {
                    Assert-MockCalled -CommandName 'Test-RegistryKeyValuesMatch' -Times 0 -Scope 'Context'
                }

                $testTargetResourceResult = Test-TargetResource @testTargetResourceParameters

                It 'Should return a boolean' {
                    $testTargetResourceResult -is [Boolean] | Should Be $true
                }

                It 'Should return True' {
                    $testTargetResourceResult | Should Be $true
                }
            }

            Context 'Registry key value does not exist and Ensure set to Present' {
                $testTargetResourceParameters = @{
                    Key = 'TestRegistryKey'
                    ValueName = 'TestRegistryKeyValueName'
                    Ensure = 'Present'
                }

                It 'Should not throw' {
                    { $null = Test-TargetResource @testTargetResourceParameters } | Should Not Throw
                }

                It 'Should retrieve the registry resource with the specified reigstry key and value name' {
                    $getTargetResourceParameterFilter = {
                        $keyParameterCorrect = $Key -eq $testTargetResourceParameters.Key
                        $valueNameParameterCorrect = $ValueName -eq $testTargetResourceParameters.ValueName

                        return $keyParameterCorrect -and $valueNameParameterCorrect
                    }

                    Assert-MockCalled -CommandName 'Get-TargetResource' -ParameterFilter $getTargetResourceParameterFilter -Times 1 -Scope 'Context'
                }

                It 'Should retrieve the registry key value display name' {
                    $getRegistryKeyValueDisplayNameParameterFilter = {
                        $registryKeyValueNameParameterCorrect = $RegistryKeyValueName -eq $testTargetResourceParameters.ValueName
                        return $registryKeyValueNameParameterCorrect
                    }

                    Assert-MockCalled -CommandName 'Get-RegistryKeyValueDisplayName' -ParameterFilter $getRegistryKeyValueDisplayNameParameterFilter -Times 1 -Scope 'Context'
                }

                It 'Should not attempt to test if the specified registry key value matches the retrieved registry key value' {
                    Assert-MockCalled -CommandName 'Test-RegistryKeyValuesMatch' -Times 0 -Scope 'Context'
                }

                $testTargetResourceResult = Test-TargetResource @testTargetResourceParameters

                It 'Should return a boolean' {
                    $testTargetResourceResult -is [Boolean] | Should Be $true
                }

                It 'Should return False' {
                    $testTargetResourceResult | Should Be $false
                }
            }

            Mock -CommandName 'Get-TargetResource' -MockWith {
                return @{
                    Ensure = 'Present'
                }
            }

            Context 'Registry key exists, Ensure set to Absent, and registry key value name, type, and data not specified' {
                $testTargetResourceParameters = @{
                    Key = 'TestRegistryKey'
                    ValueName = ''
                    Ensure = 'Absent'
                }

                It 'Should not throw' {
                    { $null = Test-TargetResource @testTargetResourceParameters } | Should Not Throw
                }

                It 'Should retrieve the registry resource with the specified reigstry key and value name' {
                    $getTargetResourceParameterFilter = {
                        $keyParameterCorrect = $Key -eq $testTargetResourceParameters.Key
                        $valueNameParameterCorrect = $ValueName -eq $testTargetResourceParameters.ValueName

                        return $keyParameterCorrect -and $valueNameParameterCorrect
                    }

                    Assert-MockCalled -CommandName 'Get-TargetResource' -ParameterFilter $getTargetResourceParameterFilter -Times 1 -Scope 'Context'
                }

                It 'Should not attempt to retrieve the registry key value display name' {
                    Assert-MockCalled -CommandName 'Get-RegistryKeyValueDisplayName' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to test if the specified registry key value matches the retrieved registry key value' {
                    Assert-MockCalled -CommandName 'Test-RegistryKeyValuesMatch' -Times 0 -Scope 'Context'
                }

                $testTargetResourceResult = Test-TargetResource @testTargetResourceParameters

                It 'Should return a boolean' {
                    $testTargetResourceResult -is [Boolean] | Should Be $true
                }

                It 'Should return False' {
                    $testTargetResourceResult | Should Be $false
                }
            }

            Context 'Registry key exists, Ensure set to Present, and registry key value name, type, and data not specified' {
                $testTargetResourceParameters = @{
                    Key = 'TestRegistryKey'
                    ValueName = ''
                    Ensure = 'Present'
                }

                It 'Should not throw' {
                    { $null = Test-TargetResource @testTargetResourceParameters } | Should Not Throw
                }

                It 'Should retrieve the registry resource with the specified reigstry key and value name' {
                    $getTargetResourceParameterFilter = {
                        $keyParameterCorrect = $Key -eq $testTargetResourceParameters.Key
                        $valueNameParameterCorrect = $ValueName -eq $testTargetResourceParameters.ValueName

                        return $keyParameterCorrect -and $valueNameParameterCorrect
                    }

                    Assert-MockCalled -CommandName 'Get-TargetResource' -ParameterFilter $getTargetResourceParameterFilter -Times 1 -Scope 'Context'
                }

                It 'Should not attempt to retrieve the registry key value display name' {
                    Assert-MockCalled -CommandName 'Get-RegistryKeyValueDisplayName' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to test if the specified registry key value matches the retrieved registry key value' {
                    Assert-MockCalled -CommandName 'Test-RegistryKeyValuesMatch' -Times 0 -Scope 'Context'
                }

                $testTargetResourceResult = Test-TargetResource @testTargetResourceParameters

                It 'Should return a boolean' {
                    $testTargetResourceResult -is [Boolean] | Should Be $true
                }

                It 'Should return True' {
                    $testTargetResourceResult | Should Be $true
                }
            }

            Context 'Registry key value exists, Enusre set to Absent, and registry key value name specified' {
                $testTargetResourceParameters = @{
                    Key = 'TestRegistryKey'
                    ValueName = 'TestRegistryKeyValueName'
                    Ensure = 'Absent'
                }

                It 'Should not throw' {
                    { $null = Test-TargetResource @testTargetResourceParameters } | Should Not Throw
                }

                It 'Should retrieve the registry resource with the specified reigstry key and value name' {
                    $getTargetResourceParameterFilter = {
                        $keyParameterCorrect = $Key -eq $testTargetResourceParameters.Key
                        $valueNameParameterCorrect = $ValueName -eq $testTargetResourceParameters.ValueName

                        return $keyParameterCorrect -and $valueNameParameterCorrect
                    }

                    Assert-MockCalled -CommandName 'Get-TargetResource' -ParameterFilter $getTargetResourceParameterFilter -Times 1 -Scope 'Context'
                }

                It 'Should retrieve the registry key value display name' {
                    $getRegistryKeyValueDisplayNameParameterFilter = {
                        $registryKeyValueNameParameterCorrect = $RegistryKeyValueName -eq $testTargetResourceParameters.ValueName
                        return $registryKeyValueNameParameterCorrect
                    }

                    Assert-MockCalled -CommandName 'Get-RegistryKeyValueDisplayName' -ParameterFilter $getRegistryKeyValueDisplayNameParameterFilter -Times 1 -Scope 'Context'
                }

                It 'Should not attempt to test if the specified registry key value matches the retrieved registry key value' {
                    Assert-MockCalled -CommandName 'Test-RegistryKeyValuesMatch' -Times 0 -Scope 'Context'
                }

                $testTargetResourceResult = Test-TargetResource @testTargetResourceParameters

                It 'Should return a boolean' {
                    $testTargetResourceResult -is [Boolean] | Should Be $true
                }

                It 'Should return False' {
                    $testTargetResourceResult | Should Be $false
                }
            }

            Context 'Registry key value exists, Enusre set to Absent, and registry key value type specified' {
                $testTargetResourceParameters = @{
                    Key = 'TestRegistryKey'
                    ValueName = ''
                    ValueType = 'String'
                    Ensure = 'Absent'
                }

                It 'Should not throw' {
                    { $null = Test-TargetResource @testTargetResourceParameters } | Should Not Throw
                }

                It 'Should retrieve the registry resource with the specified reigstry key and value name' {
                    $getTargetResourceParameterFilter = {
                        $keyParameterCorrect = $Key -eq $testTargetResourceParameters.Key
                        $valueNameParameterCorrect = $ValueName -eq $testTargetResourceParameters.ValueName

                        return $keyParameterCorrect -and $valueNameParameterCorrect
                    }

                    Assert-MockCalled -CommandName 'Get-TargetResource' -ParameterFilter $getTargetResourceParameterFilter -Times 1 -Scope 'Context'
                }

                It 'Should retrieve the registry key value display name' {
                    $getRegistryKeyValueDisplayNameParameterFilter = {
                        $registryKeyValueNameParameterCorrect = $RegistryKeyValueName -eq $testTargetResourceParameters.ValueName
                        return $registryKeyValueNameParameterCorrect
                    }

                    Assert-MockCalled -CommandName 'Get-RegistryKeyValueDisplayName' -ParameterFilter $getRegistryKeyValueDisplayNameParameterFilter -Times 1 -Scope 'Context'
                }

                It 'Should not attempt to test if the specified registry key value matches the retrieved registry key value' {
                    Assert-MockCalled -CommandName 'Test-RegistryKeyValuesMatch' -Times 0 -Scope 'Context'
                }

                $testTargetResourceResult = Test-TargetResource @testTargetResourceParameters

                It 'Should return a boolean' {
                    $testTargetResourceResult -is [Boolean] | Should Be $true
                }

                It 'Should return False' {
                    $testTargetResourceResult | Should Be $false
                }
            }

            Context 'Registry key value exists, Enusre set to Absent, and registry key value data specified' {
                $testTargetResourceParameters = @{
                    Key = 'TestRegistryKey'
                    ValueName = ''
                    ValueData = 'TestValueData'
                    Ensure = 'Absent'
                }

                It 'Should not throw' {
                    { $null = Test-TargetResource @testTargetResourceParameters } | Should Not Throw
                }

                It 'Should retrieve the registry resource with the specified reigstry key and value name' {
                    $getTargetResourceParameterFilter = {
                        $keyParameterCorrect = $Key -eq $testTargetResourceParameters.Key
                        $valueNameParameterCorrect = $ValueName -eq $testTargetResourceParameters.ValueName

                        return $keyParameterCorrect -and $valueNameParameterCorrect
                    }

                    Assert-MockCalled -CommandName 'Get-TargetResource' -ParameterFilter $getTargetResourceParameterFilter -Times 1 -Scope 'Context'
                }

                It 'Should retrieve the registry key value display name' {
                    $getRegistryKeyValueDisplayNameParameterFilter = {
                        $registryKeyValueNameParameterCorrect = $RegistryKeyValueName -eq $testTargetResourceParameters.ValueName
                        return $registryKeyValueNameParameterCorrect
                    }

                    Assert-MockCalled -CommandName 'Get-RegistryKeyValueDisplayName' -ParameterFilter $getRegistryKeyValueDisplayNameParameterFilter -Times 1 -Scope 'Context'
                }

                It 'Should not attempt to test if the specified registry key value matches the retrieved registry key value' {
                    Assert-MockCalled -CommandName 'Test-RegistryKeyValuesMatch' -Times 0 -Scope 'Context'
                }

                $testTargetResourceResult = Test-TargetResource @testTargetResourceParameters

                It 'Should return a boolean' {
                    $testTargetResourceResult -is [Boolean] | Should Be $true
                }

                It 'Should return False' {
                    $testTargetResourceResult | Should Be $false
                }
            }

            Context 'Registry key value exists, Enusre set to Present, and registry key value name specified' {
                $testTargetResourceParameters = @{
                    Key = 'TestRegistryKey'
                    ValueName = 'TestRegistryKeyValueName'
                    Ensure = 'Present'
                }

                It 'Should not throw' {
                    { $null = Test-TargetResource @testTargetResourceParameters } | Should Not Throw
                }

                It 'Should retrieve the registry resource with the specified reigstry key and value name' {
                    $getTargetResourceParameterFilter = {
                        $keyParameterCorrect = $Key -eq $testTargetResourceParameters.Key
                        $valueNameParameterCorrect = $ValueName -eq $testTargetResourceParameters.ValueName

                        return $keyParameterCorrect -and $valueNameParameterCorrect
                    }

                    Assert-MockCalled -CommandName 'Get-TargetResource' -ParameterFilter $getTargetResourceParameterFilter -Times 1 -Scope 'Context'
                }

                It 'Should retrieve the registry key value display name' {
                    $getRegistryKeyValueDisplayNameParameterFilter = {
                        $registryKeyValueNameParameterCorrect = $RegistryKeyValueName -eq $testTargetResourceParameters.ValueName
                        return $registryKeyValueNameParameterCorrect
                    }

                    Assert-MockCalled -CommandName 'Get-RegistryKeyValueDisplayName' -ParameterFilter $getRegistryKeyValueDisplayNameParameterFilter -Times 1 -Scope 'Context'
                }

                It 'Should not attempt to test if the specified registry key value matches the retrieved registry key value' {
                    Assert-MockCalled -CommandName 'Test-RegistryKeyValuesMatch' -Times 0 -Scope 'Context'
                }

                $testTargetResourceResult = Test-TargetResource @testTargetResourceParameters

                It 'Should return a boolean' {
                    $testTargetResourceResult -is [Boolean] | Should Be $true
                }

                It 'Should return True' {
                    $testTargetResourceResult | Should Be $true
                }
            }

            Mock -CommandName 'Get-TargetResource' -MockWith {
                return @{
                    Ensure = 'Present'
                    ValueType = $testTargetResourceParameters.ValueType
                }
            }

            Context 'Registry key value exists, Enusre set to Present, and matching registry key value type specified' {
                $testTargetResourceParameters = @{
                    Key = 'TestRegistryKey'
                    ValueName = ''
                    ValueType = 'String'
                    Ensure = 'Present'
                }

                It 'Should not throw' {
                    { $null = Test-TargetResource @testTargetResourceParameters } | Should Not Throw
                }

                It 'Should retrieve the registry resource with the specified reigstry key, value name, and value type' {
                    $getTargetResourceParameterFilter = {
                        $keyParameterCorrect = $Key -eq $testTargetResourceParameters.Key
                        $valueNameParameterCorrect = $ValueName -eq $testTargetResourceParameters.ValueName
                        $valueTypeParameterCorrect = $ValueType -eq $testTargetResourceParameters.ValueType

                        return $keyParameterCorrect -and $valueNameParameterCorrect -and $valueTypeParameterCorrect
                    }

                    Assert-MockCalled -CommandName 'Get-TargetResource' -ParameterFilter $getTargetResourceParameterFilter -Times 1 -Scope 'Context'
                }

                It 'Should retrieve the registry key value display name' {
                    $getRegistryKeyValueDisplayNameParameterFilter = {
                        $registryKeyValueNameParameterCorrect = $RegistryKeyValueName -eq $testTargetResourceParameters.ValueName
                        return $registryKeyValueNameParameterCorrect
                    }

                    Assert-MockCalled -CommandName 'Get-RegistryKeyValueDisplayName' -ParameterFilter $getRegistryKeyValueDisplayNameParameterFilter -Times 1 -Scope 'Context'
                }

                It 'Should not attempt to test if the specified registry key value matches the retrieved registry key value' {
                    Assert-MockCalled -CommandName 'Test-RegistryKeyValuesMatch' -Times 0 -Scope 'Context'
                }

                $testTargetResourceResult = Test-TargetResource @testTargetResourceParameters

                It 'Should return a boolean' {
                    $testTargetResourceResult -is [Boolean] | Should Be $true
                }

                It 'Should return True' {
                    $testTargetResourceResult | Should Be $true
                }
            }

            Mock -CommandName 'Get-TargetResource' -MockWith {
                return @{
                    Ensure ='Present'
                    ValueData = $testTargetResourceParameters.ValueData
                    ValueType = $null
                }
            }

            Context 'Registry key value exists, Enusre set to Present, and matching registry key value data specified' {
                $testTargetResourceParameters = @{
                    Key = 'TestRegistryKey'
                    ValueName = ''
                    ValueData = 'TestValueData'
                    Ensure = 'Present'
                }

                It 'Should not throw' {
                    { $null = Test-TargetResource @testTargetResourceParameters } | Should Not Throw
                }

                It 'Should retrieve the registry resource with the specified reigstry key, value name, and value data' {
                    $getTargetResourceParameterFilter = {
                        $keyParameterCorrect = $Key -eq $testTargetResourceParameters.Key
                        $valueNameParameterCorrect = $ValueName -eq $testTargetResourceParameters.ValueName
                        $valueDataParameterCorrect = $null -eq (Compare-Object -ReferenceObject $testTargetResourceParameters.ValueData -DifferenceObject $ValueData)

                        return $keyParameterCorrect -and $valueNameParameterCorrect -and $valueDataParameterCorrect
                    }

                    Assert-MockCalled -CommandName 'Get-TargetResource' -ParameterFilter $getTargetResourceParameterFilter -Times 1 -Scope 'Context'
                }

                It 'Should retrieve the registry key value display name' {
                    $getRegistryKeyValueDisplayNameParameterFilter = {
                        $registryKeyValueNameParameterCorrect = $RegistryKeyValueName -eq $testTargetResourceParameters.ValueName
                        return $registryKeyValueNameParameterCorrect
                    }

                    Assert-MockCalled -CommandName 'Get-RegistryKeyValueDisplayName' -ParameterFilter $getRegistryKeyValueDisplayNameParameterFilter -Times 1 -Scope 'Context'
                }

                It 'Should test if the specified registry key value matches the retrieved registry key value' {
                    $testRegistryKeyValuesMatchParameterFilter = {
                        $expectedRegistryKeyValueParameterCorrect = $null -eq (Compare-Object -ReferenceObject $testTargetResourceParameters.ValueData -DifferenceObject $ExpectedRegistryKeyValue)
                        $actualRegistryKeyValueParameterCorrect = $null -eq (Compare-Object -ReferenceObject $testRegistryKeyValue -DifferenceObject $ActualRegistryKeyValue)
                        $registryKeyValueTypeParameterCorrect = $RegistryKeyValueType -eq $script:defaultValueType

                        return $expectedRegistryKeyValueParameterCorrect -and $actualRegistryKeyValueParameterCorrect -and $registryKeyValueTypeParameterCorrect
                    }

                    Assert-MockCalled -CommandName 'Test-RegistryKeyValuesMatch' -ParameterFilter $testRegistryKeyValuesMatchParameterFilter -Times 1 -Scope 'Context'
                }

                $testTargetResourceResult = Test-TargetResource @testTargetResourceParameters

                It 'Should return a boolean' {
                    $testTargetResourceResult -is [Boolean] | Should Be $true
                }

                It 'Should return True' {
                    $testTargetResourceResult | Should Be $true
                }
            }

            Mock -CommandName 'Get-TargetResource' -MockWith {
                return @{
                    Ensure ='Present'
                    ValueType = 'MismatchingValueType'
                }
            }

            Context 'Registry key value exists, Enusre set to Present, and mismatching registry key value type specified' {
                $testTargetResourceParameters = @{
                    Key = 'TestRegistryKey'
                    ValueName = ''
                    ValueType = 'String'
                    Ensure = 'Present'
                }

                It 'Should not throw' {
                    { $null = Test-TargetResource @testTargetResourceParameters } | Should Not Throw
                }

                It 'Should retrieve the registry resource with the specified reigstry key, value name, and value type' {
                    $getTargetResourceParameterFilter = {
                        $keyParameterCorrect = $Key -eq $testTargetResourceParameters.Key
                        $valueNameParameterCorrect = $ValueName -eq $testTargetResourceParameters.ValueName
                        $valueTypeParameterCorrect = $ValueType -eq $testTargetResourceParameters.ValueType

                        return $keyParameterCorrect -and $valueNameParameterCorrect -and $valueTypeParameterCorrect
                    }

                    Assert-MockCalled -CommandName 'Get-TargetResource' -ParameterFilter $getTargetResourceParameterFilter -Times 1 -Scope 'Context'
                }

                It 'Should retrieve the registry key value display name' {
                    $getRegistryKeyValueDisplayNameParameterFilter = {
                        $registryKeyValueNameParameterCorrect = $RegistryKeyValueName -eq $testTargetResourceParameters.ValueName
                        return $registryKeyValueNameParameterCorrect
                    }

                    Assert-MockCalled -CommandName 'Get-RegistryKeyValueDisplayName' -ParameterFilter $getRegistryKeyValueDisplayNameParameterFilter -Times 1 -Scope 'Context'
                }

                It 'Should not attempt to test if the specified registry key value matches the retrieved registry key value' {
                    Assert-MockCalled -CommandName 'Test-RegistryKeyValuesMatch' -Times 0 -Scope 'Context'
                }

                $testTargetResourceResult = Test-TargetResource @testTargetResourceParameters

                It 'Should return a boolean' {
                    $testTargetResourceResult -is [Boolean] | Should Be $true
                }

                It 'Should return False' {
                    $testTargetResourceResult | Should Be $false
                }
            }

            $mismatchingValueData = 'MismatchingValueData'

            Mock -CommandName 'Get-TargetResource' -MockWith {
                return @{
                    Ensure ='Present'
                    ValueData = $mismatchingValueData
                    ValueType = $null
                }
            }

            Mock -CommandName 'Test-RegistryKeyValuesMatch' -MockWith { return $false }

            Context 'Registry key value exists, Enusre set to Present, and mismatching registry key value data specified' {
                $testTargetResourceParameters = @{
                    Key = 'TestRegistryKey'
                    ValueName = ''
                    ValueData = 'TestValueData'
                    Ensure = 'Present'
                }

                It 'Should not throw' {
                    { $null = Test-TargetResource @testTargetResourceParameters } | Should Not Throw
                }

                It 'Should retrieve the registry resource with the specified reigstry key, value name, and value data' {
                    $getTargetResourceParameterFilter = {
                        $keyParameterCorrect = $Key -eq $testTargetResourceParameters.Key
                        $valueNameParameterCorrect = $ValueName -eq $testTargetResourceParameters.ValueName
                        $valueDataParameterCorrect = $null -eq (Compare-Object -ReferenceObject $testTargetResourceParameters.ValueData -DifferenceObject $ValueData)

                        return $keyParameterCorrect -and $valueNameParameterCorrect -and $valueDataParameterCorrect
                    }

                    Assert-MockCalled -CommandName 'Get-TargetResource' -ParameterFilter $getTargetResourceParameterFilter -Times 1 -Scope 'Context'
                }

                It 'Should retrieve the registry key value display name' {
                    $getRegistryKeyValueDisplayNameParameterFilter = {
                        $registryKeyValueNameParameterCorrect = $RegistryKeyValueName -eq $testTargetResourceParameters.ValueName
                        return $registryKeyValueNameParameterCorrect
                    }

                    Assert-MockCalled -CommandName 'Get-RegistryKeyValueDisplayName' -ParameterFilter $getRegistryKeyValueDisplayNameParameterFilter -Times 1 -Scope 'Context'
                }

                It 'Should test if the specified registry key value matches the retrieved registry key value' {
                    $testRegistryKeyValuesMatchParameterFilter = {
                        $expectedRegistryKeyValueParameterCorrect = $null -eq (Compare-Object -ReferenceObject $testTargetResourceParameters.ValueData -DifferenceObject $ExpectedRegistryKeyValue)
                        $actualRegistryKeyValueParameterCorrect = $null -eq (Compare-Object -ReferenceObject $testRegistryKeyValue -DifferenceObject $ActualRegistryKeyValue)
                        $registryKeyValueTypeParameterCorrect = $RegistryKeyValueType -eq $script:defaultValueType

                        return $expectedRegistryKeyValueParameterCorrect -and $actualRegistryKeyValueParameterCorrect -and $registryKeyValueTypeParameterCorrect
                    }

                    Assert-MockCalled -CommandName 'Test-RegistryKeyValuesMatch' -ParameterFilter $testRegistryKeyValuesMatchParameterFilter -Times 1 -Scope 'Context'
                }

                $testTargetResourceResult = Test-TargetResource @testTargetResourceParameters

                It 'Should return a boolean' {
                    $testTargetResourceResult -is [Boolean] | Should Be $true
                }

                It 'Should return False' {
                    $testTargetResourceResult | Should Be $false
                }
            }
        }

        Describe 'xRegistry\Get-PathRoot' {
            Context 'Path without parent specified' {
                $getPathRootParameters = @{
                    Path = 'PathWithoutParent'
                }

                It 'Should not throw' {
                    { $null = Get-PathRoot @getPathRootParameters } | Should Not Throw
                }

                $getPathRootResult = Get-PathRoot @getPathRootParameters

                It 'Should return given path' {
                    $getPathRootResult | Should Be $getPathRootParameters.Path
                }
            }

            Context 'Path with one parent specified' {
                $pathRoot = 'PathRoot'

                $getPathRootParameters = @{
                    Path = Join-Path -Path $pathRoot -ChildPath 'PathLeaf'
                }

                It 'Should not throw' {
                    { $null = Get-PathRoot @getPathRootParameters } | Should Not Throw
                }

                $getPathRootResult = Get-PathRoot @getPathRootParameters

                It 'Should return the root of the given path' {
                    $getPathRootResult | Should Be $pathRoot
                }
            }

            Context 'Path with two parents specified' {
                $pathRoot = 'PathRoot'
                $pathMiddleParent = 'PathMiddleParent'
                $parentPath = Join-Path -Path $pathRoot -ChildPath $pathMiddleParent

                $getPathRootParameters = @{
                    Path = Join-Path -Path $parentPath -ChildPath 'PathLeaf'
                }

                It 'Should not throw' {
                    { $null = Get-PathRoot @getPathRootParameters } | Should Not Throw
                }

                $getPathRootResult = Get-PathRoot @getPathRootParameters

                It 'Should return the root of the given path' {
                    $getPathRootResult | Should Be $pathRoot
                }
            }
        }

        Describe 'xRegistry\ConvertTo-RegistryDriveName' {
            foreach ($validRegistryDriveRoot in $script:validRegistryDriveRoots)
            {
                Context "Valid registry drive root $validRegistryDriveRoot specified" {
                    $convertToRegistryDriveNameParameters = @{
                        RegistryDriveRoot = $validRegistryDriveRoot
                    }

                    It 'Should not throw' {
                        { $null = ConvertTo-RegistryDriveName @convertToRegistryDriveNameParameters } | Should Not Throw
                    }

                    $expcetedRegistryDriveName = switch ($validRegistryDriveRoot)
                    {
                        'HKEY_CLASSES_ROOT' { 'HKCR' }
                        'HKEY_CURRENT_USER' { 'HKCU' }
                        'HKEY_LOCAL_MACHINE' { 'HKLM' }
                        'HKEY_USERS' { 'HKUS' }
                        'HKEY_CURRENT_CONFIG' { 'HKCC' }
                    }

                    $convertToRegistryDriveNameResult = ConvertTo-RegistryDriveName @convertToRegistryDriveNameParameters

                    It "Should return correct registry drive name $expcetedRegistryDriveName" {
                        $convertToRegistryDriveNameResult | Should Be $expcetedRegistryDriveName
                    }
                }
            }

            Context 'Invalid registry drive root specified' {
                $convertToRegistryDriveNameParameters = @{
                    RegistryDriveRoot = 'HKEY_COAL_MINE'
                }

                It 'Should not throw' {
                    { $null = ConvertTo-RegistryDriveName @convertToRegistryDriveNameParameters } | Should Not Throw
                }

                $convertToRegistryDriveNameResult = ConvertTo-RegistryDriveName @convertToRegistryDriveNameParameters

                It 'Should return null' {
                    $convertToRegistryDriveNameResult | Should Be $null
                }
            }
        }

        Describe 'xRegistry\Get-RegistryDriveName' {
            Mock -CommandName 'Get-PathRoot' -MockWith { return Split-Path -Path $RegistryKeyPath -Parent }
            Mock -CommandName 'ConvertTo-RegistryDriveName' { }

            Context 'Specified registry path contains an invalid registry drive root' {
                $invalidRegistryDriveRoot = 'HKEY_COAL_MINE'

                $getRegistryDriveNameParameters = @{
                    RegistryKeyPath = Join-Path -Path $invalidRegistryDriveRoot -ChildPath 'TestRegistryPath'
                }

                It 'Should throw an error for invalid registry drive' {
                    $errorMessage = $script:localizedData.InvalidRegistryDrive -f $invalidRegistryDriveRoot

                    { $null = Get-RegistryDriveName @getRegistryDriveNameParameters } | Should Throw $errorMessage
                }
            }

            Mock -CommandName 'ConvertTo-RegistryDriveName' { return $script:validRegistryDriveNames[0] }

            Context 'Specified registry key path contains a valid registry drive root' {
                $validRegistryDriveRoot = $script:validRegistryDriveRoots[0]

                $getRegistryDriveNameParameters = @{
                    RegistryKeyPath = Join-Path -Path $validRegistryDriveRoot -ChildPath 'TestRegistryPath'
                }

                It 'Should not throw' {
                    { $null = Get-RegistryDriveName @getRegistryDriveNameParameters } | Should Not Throw
                }

                It 'Should retrieve the path root' {
                    $getPathRootParameterFilter = {
                        $pathParameterCorrect = $Path -eq $getRegistryDriveNameParameters.RegistryKeyPath
                        return $pathParameterCorrect
                    }

                    Assert-MockCalled -CommandName 'Get-PathRoot' -ParameterFilter $getPathRootParameterFilter -Times 1 -Scope 'Context'
                }

                It 'Should convert the registry drive root to a registry drive name' {
                    $convertToRegistryDriveNameParameterFilter = {
                        $registryDriveRootParameterCorrect = $RegistryDriveRoot -eq $validRegistryDriveRoot
                        return $registryDriveRootParameterCorrect
                    }

                    Assert-MockCalled -CommandName 'ConvertTo-RegistryDriveName' -ParameterFilter $convertToRegistryDriveNameParameterFilter -Times 1 -Scope 'Context'
                }

                $getDriveNameResult = Get-RegistryDriveName @getRegistryDriveNameParameters

                It 'Should return the retrieved registry drive name' {
                    $getDriveNameResult | Should Be $script:validRegistryDriveNames[0]
                }
            }

            Context 'Specified registry path contains an invalid registry drive name' {
                $invalidRegistryDriveName = 'HKCM'

                # Join-Path will search for the drive and throw an error if the drive does not exist
                $getRegistryDriveNameParameters = @{
                    RegistryKeyPath = "$($invalidRegistryDriveName):\TestRegistryPath"
                }

                It 'Should throw an error for invalid registry drive' {
                    $errorMessage = $script:localizedData.InvalidRegistryDrive -f $invalidRegistryDriveName

                    { $null = Get-RegistryDriveName @getRegistryDriveNameParameters } | Should Throw $errorMessage
                }
            }

            foreach ($validRegistryDriveName in $script:validRegistryDriveNames)
            {
                Context "Specified registry key path contains the valid registry drive name $validRegistryDriveName" {
                    # Join-Path will search for the drive and throw an error if the drive does not exist
                    $getRegistryDriveNameParameters = @{
                        RegistryKeyPath = "$($validRegistryDriveName):\TestRegistryPath"
                    }

                    It 'Should not throw' {
                        { $null = Get-RegistryDriveName @getRegistryDriveNameParameters } | Should Not Throw
                    }

                    It 'Should retrieve the path root' {
                        $getPathRootParameterFilter = {
                            $pathParameterCorrect = $Path -eq $getRegistryDriveNameParameters.RegistryKeyPath
                            return $pathParameterCorrect
                        }

                        Assert-MockCalled -CommandName 'Get-PathRoot' -ParameterFilter $getPathRootParameterFilter -Times 1 -Scope 'Context'
                    }

                    It 'Should not attempt to convert a registry drive root to a registry drive name' {
                        Assert-MockCalled -CommandName 'ConvertTo-RegistryDriveName' -Times 0 -Scope 'Context'
                    }

                    $getDriveNameResult = Get-RegistryDriveName @getRegistryDriveNameParameters

                    It 'Should return the retrieved registry drive name' {
                        $getDriveNameResult | Should Be $validRegistryDriveName
                    }
                }
            }
        }

        Describe 'xRegistry\Mount-RegistryDrive' {
            Mock -CommandName 'Get-PSDrive' -MockWith { }
            Mock -CommandName 'New-PSDrive' -MockWith { }

            Context 'Registry drive with specified name does not exist and new drive creation fails' {
                $mountRegistryDriveParameters = @{
                    RegistryDriveName = 'TestRegistryDriveName'
                }
                
                It 'Should throw error for unmountable registry drive' {
                    $errorMessage = $script:localizedData.RegistryDriveCouldNotBeMounted -f $mountRegistryDriveParameters.RegistryDriveName

                    { Mount-RegistryDrive @mountRegistryDriveParameters } | Should Throw $errorMessage
                }
            }

            Mock -CommandName 'New-PSDrive' -MockWith { return @{ Name = 'NewRegistryDrive'; Provider = $null } }

            Context 'Registry drive with specified name does not exist and new drive does not have a provider' {
                $mountRegistryDriveParameters = @{
                    RegistryDriveName = 'TestRegistryDriveName'
                }
                
                It 'Should throw error for unmountable registry drive' {
                    $errorMessage = $script:localizedData.RegistryDriveCouldNotBeMounted -f $mountRegistryDriveParameters.RegistryDriveName

                    { Mount-RegistryDrive @mountRegistryDriveParameters } | Should Throw $errorMessage
                }
            }

            Mock -CommandName 'New-PSDrive' -MockWith { return @{ Provider = @{ Name = 'NotRegistry' } } }

            Context 'Registry drive with specified name does not exist and provider of the new drives is not the registry' {
                $mountRegistryDriveParameters = @{
                    RegistryDriveName = 'TestRegistryDriveName'
                }
                
                It 'Should throw error for unmountable registry drive' {
                    $errorMessage = $script:localizedData.RegistryDriveCouldNotBeMounted -f $mountRegistryDriveParameters.RegistryDriveName

                    { Mount-RegistryDrive @mountRegistryDriveParameters } | Should Throw $errorMessage
                }
            }

            Mock -CommandName 'New-PSDrive' -MockWith { return @{ Provider = @{ Name = 'Registry' } } }

            Context 'Registry drive with specified name does not exist and new drive creation succeeds' {
                $mountRegistryDriveParameters = @{
                    RegistryDriveName = 'HKCR'
                }
                
                $expectedRegistryDriveRoot = 'HKEY_CLASSES_ROOT'

                It 'Should not throw' {
                    { Mount-RegistryDrive @mountRegistryDriveParameters } | Should Not Throw
                }

                It 'Should retrieve the registry drive with specified name' {
                    $getPSDriveParamterFilter = {
                        $nameParameterCorrect = $Name -eq $mountRegistryDriveParameters.RegistryDriveName
                        return $nameParameterCorrect
                    }

                    Assert-MockCalled -CommandName 'Get-PSDrive' -ParameterFilter $getPSDriveParamterFilter -Times 1 -Scope 'Context'
                }

                It 'Should create the registry drive with specified name' {
                    $newPSDriveParamterFilter = {
                        $nameParameterCorrect = $Name -eq $mountRegistryDriveParameters.RegistryDriveName
                        $rootParameterCorrect = $Root -eq $expectedRegistryDriveRoot
                        $psProviderParameterCorrect = $PSProvider -eq 'Registry'
                        $scopeParameterCorrect = $Scope -eq 'Script'
                        
                        return $nameParameterCorrect -and $rootParameterCorrect -and $psProviderParameterCorrect -and $scopeParameterCorrect
                    }

                    Assert-MockCalled -CommandName 'New-PSDrive' -ParameterFilter $newPSDriveParamterFilter -Times 1 -Scope 'Context'
                }

                It 'Should not return anything' {
                    Mount-RegistryDrive @mountRegistryDriveParameters | Should Be $null
                }
            }

            Mock -CommandName 'Get-PSDrive' -MockWith { return @{ Name = 'NewRegistryDrive'; Provider = $null } }

            Context 'Registry drive with specified name exists and does not have a provider' {
                $mountRegistryDriveParameters = @{
                    RegistryDriveName = 'TestRegistryDriveName'
                }
                
                It 'Should throw error for unmountable registry drive' {
                    $errorMessage = $script:localizedData.RegistryDriveCouldNotBeMounted -f $mountRegistryDriveParameters.RegistryDriveName

                    { Mount-RegistryDrive @mountRegistryDriveParameters } | Should Throw $errorMessage
                }
            }

            Mock -CommandName 'Get-PSDrive' -MockWith { return @{ Provider = @{ Name = 'NotRegistry' } } }

            Context 'Registry drive with specified name exists and its provider is not the registry' {
                $mountRegistryDriveParameters = @{
                    RegistryDriveName = 'TestRegistryDriveName'
                }
                
                It 'Should throw error for unmountable registry drive' {
                    $errorMessage = $script:localizedData.RegistryDriveCouldNotBeMounted -f $mountRegistryDriveParameters.RegistryDriveName

                    { Mount-RegistryDrive @mountRegistryDriveParameters } | Should Throw $errorMessage
                }
            }

            Mock -CommandName 'Get-PSDrive' -MockWith { return @{ Provider = @{ Name = 'Registry' } } }

            Context 'Registry drive with specified name exists' {
                $mountRegistryDriveParameters = @{
                    RegistryDriveName = 'HKCR'
                }
                
                $expectedRegistryDriveRoot = 'HKEY_CLASSES_ROOT'

                It 'Should not throw' {
                    { Mount-RegistryDrive @mountRegistryDriveParameters } | Should Not Throw
                }

                It 'Should retrieve the registry drive with specified name' {
                    $getPSDriveParamterFilter = {
                        $nameParameterCorrect = $Name -eq $mountRegistryDriveParameters.RegistryDriveName
                        return $nameParameterCorrect
                    }

                    Assert-MockCalled -CommandName 'Get-PSDrive' -ParameterFilter $getPSDriveParamterFilter -Times 1 -Scope 'Context'
                }

                It 'Should not attempt to create a registry drive with specified name' {
                    Assert-MockCalled -CommandName 'New-PSDrive' -Times 0 -Scope 'Context'
                }

                It 'Should not return anything' {
                    Mount-RegistryDrive @mountRegistryDriveParameters | Should Be $null
                }
            }
        }

        Describe 'xRegistry\Get-RegistryKey' {
            $expectedRegistryDriveName = 'RegistryDriveName'
            Mock -CommandName 'Get-RegistryDriveName' -MockWith { return $expectedRegistryDriveName }

            Mock -CommandName 'Mount-RegistryDrive' -MockWith { }
            Mock -CommandName 'Get-Item' -MockWith { return $script:testRegistryKey }

            $expectedGetRegistryKeyResult = $null
            Mock -CommandName 'Open-RegistrySubKey' -MockWith { return $expectedGetRegistryKeyResult }

            Context 'Registry key at specified path does not exist' {
                $getRegistryKeyParameters = @{
                    RegistryKeyPath = 'TestRegistryKeyPath'
                }

                It 'Should not throw' {
                    { $null = Get-RegistryKey @getRegistryKeyParameters } | Should Not Throw
                }

                It 'Should retrieve the registry drive name of the specified registry key path' {
                    $getRegistryDriveNameParameterFilter = {
                        $registryKeyPathParameterCorrect = $RegistryKeyPath -eq $getRegistryKeyParameters.RegistryKeyPath
                        return $registryKeyPathParameterCorrect
                    }

                    Assert-MockCalled -CommandName 'Get-RegistryDriveName' -ParameterFilter $getRegistryDriveNameParameterFilter -Times 1 -Scope 'Context'
                }

                It 'Should mount the registry drive with the retrieved name' {
                    $mountRegistryDriveParameterFilter = {
                        $registryDriveNameParameterCorrect = $RegistryDriveName -eq $expectedRegistryDriveName
                        return $registryDriveNameParameterCorrect
                    }

                    Assert-MockCalled -CommandName 'Mount-RegistryDrive' -ParameterFilter $mountRegistryDriveParameterFilter -Times 1 -Scope 'Context'
                }

                It 'Should retrieve the registry drive key' {
                    $getItemParameterFilter = {
                        $literalPathParameterCorrect = $LiteralPath -eq ($expectedRegistryDriveName  + ':')
                        return $literalPathParameterCorrect
                    }

                    Assert-MockCalled -CommandName 'Get-Item' -ParameterFilter $getItemParameterFilter -Times 1 -Scope 'Context'
                }

                It 'Should open the specified registry key' {
                    $openRegistrySubKeyParameterFilter = {
                        $parentKeyParameterCorrect = $null -eq (Compare-Object -ReferenceObject $script:testRegistryKey -DifferenceObject $ParentKey)
                        $subKeyParameterCorrect = $SubKey -eq ''
                        $writeAccessAllowedParameterCorrect = $WriteAccessAllowed -eq $false

                        return $parentKeyParameterCorrect -and $subKeyParameterCorrect -and $writeAccessAllowedParameterCorrect
                    }

                    Assert-MockCalled -CommandName 'Open-RegistrySubKey' -ParameterFilter $openRegistrySubKeyParameterFilter -Times 1 -Scope 'Context'
                }

                $getRegistryKeyResult = Get-RegistryKey @getRegistryKeyParameters

                It 'Should return the retrieved registry key' {
                    $getRegistryKeyResult | Should Be $expectedGetRegistryKeyResult
                }
            }

            $expectedGetRegistryKeyResult = 'TestRegistryKey'

            Context 'Registry key at specified path exists and WriteAccessAllowed not specified' {
                $getRegistryKeyParameters = @{
                    RegistryKeyPath = 'TestRegistryKeyPath\TestSubKey'
                }

                It 'Should not throw' {
                    { $null = Get-RegistryKey @getRegistryKeyParameters } | Should Not Throw
                }

                It 'Should retrieve the registry drive name of the specified registry key path' {
                    $getRegistryDriveNameParameterFilter = {
                        $registryKeyPathParameterCorrect = $RegistryKeyPath -eq $getRegistryKeyParameters.RegistryKeyPath
                        return $registryKeyPathParameterCorrect
                    }

                    Assert-MockCalled -CommandName 'Get-RegistryDriveName' -ParameterFilter $getRegistryDriveNameParameterFilter -Times 1 -Scope 'Context'
                }

                It 'Should mount the registry drive with the retrieved name' {
                    $mountRegistryDriveParameterFilter = {
                        $registryDriveNameParameterCorrect = $RegistryDriveName -eq $expectedRegistryDriveName
                        return $registryDriveNameParameterCorrect
                    }

                    Assert-MockCalled -CommandName 'Mount-RegistryDrive' -ParameterFilter $mountRegistryDriveParameterFilter -Times 1 -Scope 'Context'
                }

                It 'Should retrieve the registry drive key' {
                    $getItemParameterFilter = {
                        $literalPathParameterCorrect = $LiteralPath -eq ($expectedRegistryDriveName  + ':')
                        return $literalPathParameterCorrect
                    }

                    Assert-MockCalled -CommandName 'Get-Item' -ParameterFilter $getItemParameterFilter -Times 1 -Scope 'Context'
                }

                It 'Should open the specified registry key' {
                    $openRegistrySubKeyParameterFilter = {
                        $parentKeyParameterCorrect = $null -eq (Compare-Object -ReferenceObject $script:testRegistryKey -DifferenceObject $ParentKey)
                        $subKeyParameterCorrect = $SubKey -eq 'TestSubKey'
                        $writeAccessAllowedParameterCorrect = $WriteAccessAllowed -eq $false

                        return $parentKeyParameterCorrect -and $subKeyParameterCorrect -and $writeAccessAllowedParameterCorrect
                    }

                    Assert-MockCalled -CommandName 'Open-RegistrySubKey' -ParameterFilter $openRegistrySubKeyParameterFilter -Times 1 -Scope 'Context'
                }

                $getRegistryKeyResult = Get-RegistryKey @getRegistryKeyParameters

                It 'Should return the retrieved registry key' {
                    $getRegistryKeyResult | Should Be $expectedGetRegistryKeyResult
                }
            }

            Context 'Registry key at specified path exists and WriteAccessAllowed specified' {
                $getRegistryKeyParameters = @{
                    RegistryKeyPath = 'TestRegistryKeyPath\TestSubKey'
                    WriteAccessAllowed = $true
                }

                It 'Should not throw' {
                    { $null = Get-RegistryKey @getRegistryKeyParameters } | Should Not Throw
                }

                It 'Should retrieve the registry drive name of the specified registry key path' {
                    $getRegistryDriveNameParameterFilter = {
                        $registryKeyPathParameterCorrect = $RegistryKeyPath -eq $getRegistryKeyParameters.RegistryKeyPath
                        return $registryKeyPathParameterCorrect
                    }

                    Assert-MockCalled -CommandName 'Get-RegistryDriveName' -ParameterFilter $getRegistryDriveNameParameterFilter -Times 1 -Scope 'Context'
                }

                It 'Should mount the registry drive with the retrieved name' {
                    $mountRegistryDriveParameterFilter = {
                        $registryDriveNameParameterCorrect = $RegistryDriveName -eq $expectedRegistryDriveName
                        return $registryDriveNameParameterCorrect
                    }

                    Assert-MockCalled -CommandName 'Mount-RegistryDrive' -ParameterFilter $mountRegistryDriveParameterFilter -Times 1 -Scope 'Context'
                }

                It 'Should retrieve the registry drive key' {
                    $getItemParameterFilter = {
                        $literalPathParameterCorrect = $LiteralPath -eq ($expectedRegistryDriveName  + ':')
                        return $literalPathParameterCorrect
                    }

                    Assert-MockCalled -CommandName 'Get-Item' -ParameterFilter $getItemParameterFilter -Times 1 -Scope 'Context'
                }

                It 'Should open the specified registry key' {
                    $openRegistrySubKeyParameterFilter = {
                        $parentKeyParameterCorrect = $null -eq (Compare-Object -ReferenceObject $script:testRegistryKey -DifferenceObject $ParentKey)
                        $subKeyParameterCorrect = $SubKey -eq 'TestSubKey'
                        $writeAccessAllowedParameterCorrect = $WriteAccessAllowed -eq $getRegistryKeyParameters.WriteAccessAllowed

                        return $parentKeyParameterCorrect -and $subKeyParameterCorrect -and $writeAccessAllowedParameterCorrect
                    }

                    Assert-MockCalled -CommandName 'Open-RegistrySubKey' -ParameterFilter $openRegistrySubKeyParameterFilter -Times 1 -Scope 'Context'
                }

                $getRegistryKeyResult = Get-RegistryKey @getRegistryKeyParameters

                It 'Should return the retrieved registry key' {
                    $getRegistryKeyResult | Should Be $expectedGetRegistryKeyResult
                }
            }
        }

        Describe 'xRegistry\Get-RegistryKeyValueDisplayName' {
            Context 'Specified registry key value name is null' {
                $getRegistryKeyValueDisplayNameParameters = @{
                    RegistryKeyValue = $null
                }

                It 'Should not throw' {
                    { $null = Get-RegistryKeyValueDisplayName @getRegistryKeyValueDisplayNameParameters } | Should Not Throw
                }

                $getRegistryKeyValueDisplayNameResult = Get-RegistryKeyValueDisplayName @getRegistryKeyValueDisplayNameParameters

                It 'Should return default registry key value name' {
                    $getRegistryKeyValueDisplayNameResult | Should Be $localizedData.DefaultValueDisplayName
                }
            }

            Context 'Specified registry key value name is an empty string' {
                $getRegistryKeyValueDisplayNameParameters = @{
                    RegistryKeyValue = [String]::Empty
                }

                It 'Should not throw' {
                    { $null = Get-RegistryKeyValueDisplayName @getRegistryKeyValueDisplayNameParameters } | Should Not Throw
                }

                $getRegistryKeyValueDisplayNameResult = Get-RegistryKeyValueDisplayName @getRegistryKeyValueDisplayNameParameters

                It 'Should return default registry key value name' {
                    $getRegistryKeyValueDisplayNameResult | Should Be $localizedData.DefaultValueDisplayName
                }
            }

            Context 'Specified registry key value name is a populated string' {
                $getRegistryKeyValueDisplayNameParameters = @{
                    RegistryKeyValue = 'TestRegistryKeyValueName'
                }

                It 'Should not throw' {
                    { $null = Get-RegistryKeyValueDisplayName @getRegistryKeyValueDisplayNameParameters } | Should Not Throw
                }

                $getRegistryKeyValueDisplayNameResult = Get-RegistryKeyValueDisplayName @getRegistryKeyValueDisplayNameParameters

                It 'Should return given registry key value name' {
                    $getRegistryKeyValueDisplayNameResult | Should Be $getRegistryKeyValueDisplayNameParameters.RegistryKeyValue
                }
            }
        }

        Describe 'xRegistry\Convert-ByteArrayToHexString' {
            Context 'Specified byte array is empty' {
                $convertByteArrayToHexStringParameters = @{
                    ByteArray = @()
                }

                It 'Should not throw' {
                    { $null = Convert-ByteArrayToHexString @convertByteArrayToHexStringParameters } | Should Not Throw
                }

                $convertByteArrayToHexStringResult = Convert-ByteArrayToHexString @convertByteArrayToHexStringParameters

                It 'Should return an empty string' {
                    $convertByteArrayToHexStringResult | Should Be ([String]::Empty)
                }
            }

            Context 'Specified byte array has one element' {
                $convertByteArrayToHexStringParameters = @{
                    ByteArray = @( [Byte]'1' )
                }

                It 'Should not throw' {
                    { $null = Convert-ByteArrayToHexString @convertByteArrayToHexStringParameters } | Should Not Throw
                }

                $convertByteArrayToHexStringResult = Convert-ByteArrayToHexString @convertByteArrayToHexStringParameters

                It 'Should return the byte array as a single hex string' {
                    $convertByteArrayToHexStringResult | Should Be '01'
                }
            }

            Context 'Specified byte array has multiple elements' {
                $convertByteArrayToHexStringParameters = @{
                    ByteArray = @( 0, [Byte]::MaxValue )
                }

                It 'Should not throw' {
                    { $null = Convert-ByteArrayToHexString @convertByteArrayToHexStringParameters } | Should Not Throw
                }

                $convertByteArrayToHexStringResult = Convert-ByteArrayToHexString @convertByteArrayToHexStringParameters

                It 'Should return the byte array as a single hex string' {
                    $convertByteArrayToHexStringResult | Should Be '00ff'
                }
            }
        }

        Describe 'xRegistry\ConvertTo-ReadableString' {
            Mock -CommandName 'Convert-ByteArrayToHexString' -MockWith { return $ByteArray }

            foreach ($registryKeyValueType in $script:registryKeyValueTypes)
            {
                Context "Registry key value specified as null and registry key type specified as $registryKeyValueType" {
                    $convertToReadableStringParameters = @{
                        RegistryKeyValue = $null
                        RegistryKeyValueType = $registryKeyValueType
                    }

                    It 'Should not throw' {
                        { $null = ConvertTo-ReadableString @convertToReadableStringParameters } | Should Not Throw
                    }

                    It 'Should not attempt to convert registry key value to a hex string' {
                        Assert-MockCalled -CommandName 'Convert-ByteArrayToHexString' -Times 0 -Scope 'Context'
                    }

                    $convertToReadableStringResult = ConvertTo-ReadableString @convertToReadableStringParameters

                    It 'Should return an empty string' {
                        $convertToReadableStringResult | Should Be ([String]::Empty)
                    }
                }
            
                Context "Registry key value specified as an empty array and registry key type specified as $registryKeyValueType" {
                    $convertToReadableStringParameters = @{
                        RegistryKeyValue = @()
                        RegistryKeyValueType = $registryKeyValueType
                    }

                    It 'Should not throw' {
                        { $null = ConvertTo-ReadableString @convertToReadableStringParameters } | Should Not Throw
                    }

                    if ($registryKeyValueType -eq 'Binary')
                    {
                        It 'Should convert registry key value to a hex string' {
                            $convertByteArrayToHexStringParameterFilter = {
                                $byteArrayParameterCorrect = $null -eq (Compare-Object -ReferenceObject $convertToReadableStringParameters.RegistryKeyValue -DifferenceObject $ByteArray)
                                return $byteArrayParameterCorrect
                            }

                            Assert-MockCalled -CommandName 'Convert-ByteArrayToHexString' -ParameterFilter $convertByteArrayToHexStringParameterFilter -Times 1 -Scope 'Context'
                        }
                    }
                    else
                    {
                        It 'Should not attempt to convert registry key value to a hex string' {
                            Assert-MockCalled -CommandName 'Convert-ByteArrayToHexString' -Times 0 -Scope 'Context'
                        }
                    }

                    $convertToReadableStringResult = ConvertTo-ReadableString @convertToReadableStringParameters

                    It 'Should return an empty string' {
                        $convertToReadableStringResult | Should Be ([String]::Empty)
                    }
                }

                Context "Registry key value specified as an array with a single element and registry key type specified as $registryKeyValueType" {
                    $convertToReadableStringParameters = @{
                        RegistryKeyValue = @( 'String1' )
                        RegistryKeyValueType = $registryKeyValueType
                    }

                    It 'Should not throw' {
                        { $null = ConvertTo-ReadableString @convertToReadableStringParameters } | Should Not Throw
                    }

                    if ($registryKeyValueType -eq 'Binary')
                    {
                        It 'Should convert registry key value to a hex string' {
                            $convertByteArrayToHexStringParameterFilter = {
                                $byteArrayParameterCorrect = $null -eq (Compare-Object -ReferenceObject $convertToReadableStringParameters.RegistryKeyValue -DifferenceObject $ByteArray)
                                return $byteArrayParameterCorrect
                            }

                            Assert-MockCalled -CommandName 'Convert-ByteArrayToHexString' -ParameterFilter $convertByteArrayToHexStringParameterFilter -Times 1 -Scope 'Context'
                        }
                    }
                    else
                    {
                        It 'Should not attempt to convert registry key value to a hex string' {
                            Assert-MockCalled -CommandName 'Convert-ByteArrayToHexString' -Times 0 -Scope 'Context'
                        }
                    }

                    $convertToReadableStringResult = ConvertTo-ReadableString @convertToReadableStringParameters

                    It 'Should return the specified string' {
                        $convertToReadableStringResult | Should Be $convertToReadableStringParameters.RegistryKeyValue[0]
                    }
                }

                Context "Registry key value specified as an array with multiple elements and registry key type specified as $registryKeyValueType" {
                    $convertToReadableStringParameters = @{
                        RegistryKeyValue = @( 'String1', 'String2' )
                        RegistryKeyValueType = $registryKeyValueType
                    }

                    It 'Should not throw' {
                        { $null = ConvertTo-ReadableString @convertToReadableStringParameters } | Should Not Throw
                    }

                    if ($registryKeyValueType -eq 'Binary')
                    {
                        It 'Should convert registry key value to a hex string' {
                            $convertByteArrayToHexStringParameterFilter = {
                                $byteArrayParameterCorrect = $null -eq (Compare-Object -ReferenceObject $convertToReadableStringParameters.RegistryKeyValue -DifferenceObject $ByteArray)
                                return $byteArrayParameterCorrect
                            }

                            Assert-MockCalled -CommandName 'Convert-ByteArrayToHexString' -ParameterFilter $convertByteArrayToHexStringParameterFilter -Times 1 -Scope 'Context'
                        }
                    }
                    else
                    {
                        It 'Should not attempt to convert registry key value to a hex string' {
                            Assert-MockCalled -CommandName 'Convert-ByteArrayToHexString' -Times 0 -Scope 'Context'
                        }
                    }

                    $expectedReadProperty = '(String1, String2)'
                    $convertToReadableStringResult = ConvertTo-ReadableString @convertToReadableStringParameters

                    It 'Should return the specified strings inside one string' {
                        $convertToReadableStringResult | Should Be $expectedReadProperty
                    }
                }
            }
        }

        Describe 'xRegistry\New-RegistryKey' {
            $registryRootKeyPath = 'RegistryRoot'
            $newRegistryKeyPath = 'TestRegistryKeyPath'

            Mock -CommandName 'Get-RegistryKey' -MockWith { return $script:testRegistryKey }
            Mock -CommandName 'New-RegistrySubKey' -MockWith { return $script:testRegistryKey }

            Context 'Parent registry key exists' {
                $newRegistryKeyParameters = @{
                    RegistryKeyPath = Join-Path -Path $registryRootKeyPath -ChildPath $newRegistryKeyPath
                }

                It 'Should not throw' {
                    { $null = New-RegistryKey @newRegistryKeyParameters } | Should Not Throw
                }

                It 'Should retrieve the parent registry key' {
                    $getRegistryKeyParameterFilter = {
                        $registryKeyPathParameterCorrect = $RegistryKeyPath -eq $registryRootKeyPath
                        return $registryKeyPathParameterCorrect
                    }

                    Assert-MockCalled -CommandName 'Get-RegistryKey' -ParameterFilter $getRegistryKeyParameterFilter -Times 1 -Scope 'Context'
                }

                It 'Should not create the parent registry key' {
                    Assert-MockCalled -CommandName 'Get-RegistryKey' -Exactly 1 -Scope 'Context'
                }

                It 'Should create the registry key as a subkey of the parent registry key' {
                    $newRegistrySubKeyParameterFilter = {
                        $parentRegistryKeyParameterCorrect = $null -eq (Compare-Object -ReferenceObject $script:testRegistryKey -DifferenceObject $ParentRegistryKey)
                        $subKeyNameParameterCorrect = $SubKeyName -eq $newRegistryKeyPath

                        return $parentRegistryKeyParameterCorrect -and $subKeyNameParameterCorrect
                    }

                    Assert-MockCalled -CommandName 'New-RegistrySubKey' -ParameterFilter $newRegistrySubKeyParameterFilter -Times 1 -Scope 'Context'
                }

                $newRegistryKeyResult = New-RegistryKey @newRegistryKeyParameters

                It 'Should return the created subkey' {
                    $newRegistryKeyResult | Should Be $script:testRegistryKey
                }
            }

            $newParentRegistryKeyPath = 'NewParentRegistryKey'
            $testParentRegistryKeyPath = Join-Path -Path $registryRootKeyPath -ChildPath $newParentRegistryKeyPath

            Mock -CommandName 'Get-RegistryKey' -MockWith {
                if ($RegistryKeyPath -eq $testParentRegistryKeyPath)
                {
                    return $null
                }
                else
                {
                    return $script:testRegistryKey
                }
            }

            Context 'Parent registry key does not exist' {
                $newRegistryKeyParameters = @{
                    RegistryKeyPath = Join-Path -Path $testParentRegistryKeyPath -ChildPath $newRegistryKeyPath
                }

                It 'Should not throw' {
                    { $null = New-RegistryKey @newRegistryKeyParameters } | Should Not Throw
                }

                It 'Should retrieve the parent registry key' {
                    $getRegistryKeyParameterFilter = {
                        $registryKeyPathParameterCorrect = $RegistryKeyPath -eq $testParentRegistryKeyPath
                        return $registryKeyPathParameterCorrect
                    }

                    Assert-MockCalled -CommandName 'Get-RegistryKey' -ParameterFilter $getRegistryKeyParameterFilter -Times 1 -Scope 'Context'
                }

                It 'Should create the parent registry key' {
                    $getRegistryKeyParameterFilter = {
                        $registryKeyPathParameterCorrect = $RegistryKeyPath -eq $registryRootKeyPath
                        return $registryKeyPathParameterCorrect
                    }

                    Assert-MockCalled -CommandName 'Get-RegistryKey' -ParameterFilter $getRegistryKeyParameterFilter -Times 1 -Scope 'Context'

                    $newRegistrySubKeyParameterFilter = {
                        $parentRegistryKeyParameterCorrect = $null -eq (Compare-Object -ReferenceObject $script:testRegistryKey -DifferenceObject $ParentRegistryKey)
                        $subKeyNameParameterCorrect = $SubKeyName -eq $newParentRegistryKeyPath

                        return $parentRegistryKeyParameterCorrect -and $subKeyNameParameterCorrect
                    }

                    Assert-MockCalled -CommandName 'New-RegistrySubKey' -ParameterFilter $newRegistrySubKeyParameterFilter -Times 1 -Scope 'Context'

                }

                It 'Should create the registry key as a subkey of the parent registry key' {
                    $newRegistrySubKeyParameterFilter = {
                        $parentRegistryKeyParameterCorrect = $null -eq (Compare-Object -ReferenceObject $script:testRegistryKey -DifferenceObject $ParentRegistryKey)
                        $subKeyNameParameterCorrect = $SubKeyName -eq $newRegistryKeyPath

                        return $parentRegistryKeyParameterCorrect -and $subKeyNameParameterCorrect
                    }

                    Assert-MockCalled -CommandName 'New-RegistrySubKey' -ParameterFilter $newRegistrySubKeyParameterFilter -Times 1 -Scope 'Context'
                }

                $newRegistryKeyResult = New-RegistryKey @newRegistryKeyParameters

                It 'Should return the created subkey' {
                    $newRegistryKeyResult | Should Be $script:testRegistryKey
                }
            }
        }

        Describe 'xRegistry\Test-RegistryKeyValuesMatch' {
            foreach ($registryKeyValueType in $script:registryKeyValueTypes)
            {
                $expectedRegistryKeyValue = switch ($registryKeyValueType)
                {
                    'String' { 'String1' }
                    'Binary' { [Byte[]]@( 12, 172, 17, 17 ) }
                    'DWord' { 169 }
                    'QWord' { 92 }
                    'MultiString' { @( 'String1', 'String2' ) }
                    'ExpandString' { '$expandMe' }
                }

                $mismatchingActualRegistryKeyValue = switch ($registryKeyValueType)
                {
                    'String' { 'String2' }
                    'Binary' { [Byte[]]@( 11, 172, 17, 1 ) }
                    'DWord' { 12 }
                    'QWord' { 64 }
                    'MultiString' { @( 'String3', 'String2' ) }
                    'ExpandString' { '$dontExpandMe' }
                }

                Context "Registry key value type specified as $registryKeyValueType and registry key values match" {
                    $testRegistryKeyValuesMatchParameters = @{
                        ExpectedRegistryKeyValue = $expectedRegistryKeyValue
                        ActualRegistryKeyValue = $expectedRegistryKeyValue
                        RegistryKeyValueType = $registryKeyValueType
                    }

                    It 'Should not throw' {
                        { $null = Test-RegistryKeyValuesMatch @testRegistryKeyValuesMatchParameters } | Should Not Throw
                    }

                    $testRegistryKeyValuesMatchResult = Test-RegistryKeyValuesMatch @testRegistryKeyValuesMatchParameters

                    It 'Should return true' {
                        $testRegistryKeyValuesMatchResult | Should Be $true
                    }
                }

                Context "Registry key value type specified as $registryKeyValueType and registry key values do not match" {
                    $testRegistryKeyValuesMatchParameters = @{
                        ExpectedRegistryKeyValue = $expectedRegistryKeyValue
                        ActualRegistryKeyValue = $mismatchingActualRegistryKeyValue
                        RegistryKeyValueType = $registryKeyValueType
                    }

                    It 'Should not throw' {
                        { $null = Test-RegistryKeyValuesMatch @testRegistryKeyValuesMatchParameters } | Should Not Throw
                    }

                    $testRegistryKeyValuesMatchResult = Test-RegistryKeyValuesMatch @testRegistryKeyValuesMatchParameters

                    It 'Should return false' {
                        $testRegistryKeyValuesMatchResult | Should Be $false
                    }
                }
            }
        }

        Describe 'xRegistry\ConvertTo-Binary' {
            Context 'Specified registry key value is null' {
                $convertToBinaryParameters = @{
                    RegistryKeyValue = $null
                }

                It 'Should not throw' {
                    { $null = ConvertTo-Binary @convertToBinaryParameters } | Should Not Throw
                }

                $convertToBinaryResult = ConvertTo-Binary @convertToBinaryParameters

                It 'Should return null' {
                    $convertToBinaryResult | Should Be $null
                }
            }

            Context 'Specified registry key value is an empty array' {
                $convertToBinaryParameters = @{
                    RegistryKeyValue = @()
                }

                It 'Should not throw' {
                    { $null = ConvertTo-Binary @convertToBinaryParameters } | Should Not Throw
                }

                $convertToBinaryResult = ConvertTo-Binary @convertToBinaryParameters

                It 'Should return null' {
                    $convertToBinaryResult | Should Be $null
                }
            }

            Context 'Specified registry key value is an array containing a single null element' {
                $convertToBinaryParameters = @{
                    RegistryKeyValue = @( $null )
                }

                It 'Should not throw' {
                    { $null = ConvertTo-Binary @convertToBinaryParameters } | Should Not Throw
                }

                $convertToBinaryResult = ConvertTo-Binary @convertToBinaryParameters

                It 'Should return null' {
                    $convertToBinaryResult | Should Be $null
                }
            }

            Context 'Specified registry key value is an array containing a valid single string of an odd length' {
                $validBinaryString = '0xCAC1111'
                $expectedByteArray = [Byte[]]@( 12, 172, 17, 17 )

                $convertToBinaryParameters = @{
                    RegistryKeyValue = @( $validBinaryString )
                }

                It 'Should not throw' {
                    { $null = ConvertTo-Binary @convertToBinaryParameters } | Should Not Throw
                }

                $convertToBinaryResult = ConvertTo-Binary @convertToBinaryParameters

                It 'Should return the specified single string' {
                    Compare-Object -ReferenceObject $expectedByteArray -DifferenceObject $convertToBinaryResult | Should Be $null
                }
            }

            Context 'Specified registry key value is an array containing a valid single string of an even length' {
                $validBinaryString = '0x0CAC1111'
                $expectedByteArray = [Byte[]]@( 12, 172, 17, 17 )

                $convertToBinaryParameters = @{
                    RegistryKeyValue = @( $validBinaryString )
                }

                It 'Should not throw' {
                    { $null = ConvertTo-Binary @convertToBinaryParameters } | Should Not Throw
                }

                $convertToBinaryResult = ConvertTo-Binary @convertToBinaryParameters

                It 'Should return the specified single string' {
                    Compare-Object -ReferenceObject $expectedByteArray -DifferenceObject $convertToBinaryResult | Should Be $null
                }
            }

            Context 'Specified registry key value is an array containing a valid single string of an even length not starting with 0x' {
                $validBinaryString = '0CAC1111'
                $expectedByteArray = [Byte[]]@( 12, 172, 17, 17 )

                $convertToBinaryParameters = @{
                    RegistryKeyValue = @( $validBinaryString )
                }

                It 'Should not throw' {
                    { $null = ConvertTo-Binary @convertToBinaryParameters } | Should Not Throw
                }

                $convertToBinaryResult = ConvertTo-Binary @convertToBinaryParameters

                It 'Should return the specified single string' {
                    Compare-Object -ReferenceObject $expectedByteArray -DifferenceObject $convertToBinaryResult | Should Be $null
                }
            }

            Context 'Specified registry key value is an array containing a valid single string of 0x00' {
                $validBinaryString = '0x00'
                $expectedByteArray = [Byte[]]@( 0 )

                $convertToBinaryParameters = @{
                    RegistryKeyValue = @( $validBinaryString )
                }

                It 'Should not throw' {
                    { $null = ConvertTo-Binary @convertToBinaryParameters } | Should Not Throw
                }

                $convertToBinaryResult = ConvertTo-Binary @convertToBinaryParameters

                It 'Should return the specified single string' {
                    Compare-Object -ReferenceObject $expectedByteArray -DifferenceObject $convertToBinaryResult | Should Be $null
                }
            }

            Context 'Specified registry key value is an array containing a invalid single string' {
                $invalidBinaryString = 'InvalidBinaryValue'

                $convertToBinaryParameters = @{
                    RegistryKeyValue = @( $invalidBinaryString )
                }

                It 'Should not throw' {
                    $errorMessage = $script:localizedData.BinaryDataNotInHexFormat -f $invalidBinaryString

                    { $null = ConvertTo-Binary @convertToBinaryParameters } | Should Throw $errorMessage
                }
            }

            Context 'Specified registry key value is an array with more than one string' {
                $convertToBinaryParameters = @{
                    RegistryKeyValue = @( 'String1', 'String2' )
                }

                It 'Should throw an error for unexpected array' {
                    $errorMessage = $script:localizedData.ArrayNotAllowedForExpectedType -f 'Binary'

                    { $null = ConvertTo-Binary @convertToBinaryParameters } | Should Throw $errorMessage
                }
            }
        }

        Describe 'xRegistry\ConvertTo-DWord' {
            Context 'Specified registry key value is null' {
                $convertToDWordParameters = @{
                    RegistryKeyValue = $null
                }

                It 'Should not throw' {
                    { $null = ConvertTo-DWord @convertToDWordParameters } | Should Not Throw
                }

                $convertToDWordResult =  ConvertTo-DWord @convertToDWordParameters

                It 'Should return 0 as an Int32' {
                    $convertToDWordResult | Should Be ([System.Int32] 0)
                }
            }

            Context 'Specified registry key value is an empty array' {
                $convertToDWordParameters = @{
                    RegistryKeyValue = @()
                }

                It 'Should not throw' {
                    { $null = ConvertTo-DWord @convertToDWordParameters } | Should Not Throw
                }

                $convertToDWordResult = ConvertTo-DWord @convertToDWordParameters

                It 'Should return 0 as an Int32' {
                    $convertToDWordResult | Should Be ([System.Int32] 0)
                }
            }

            Context 'Specified registry key value is an array containing a single null element' {
                $convertToDWordParameters = @{
                    RegistryKeyValue = @( $null )
                }

                It 'Should not throw' {
                    { $null = ConvertTo-DWord @convertToDWordParameters } | Should Not Throw
                }

                $convertToDWordResult = ConvertTo-DWord @convertToDWordParameters

                It 'Should return 0 as an Int32' {
                    $convertToDWordResult | Should Be ([System.Int32] 0)
                }
            }

            $testDWord1 = [System.Int32]::MaxValue

            Context 'Specified registry key value is an array containing a valid single string and Hex not specified' {
                $convertToDWordParameters = @{
                    RegistryKeyValue = @( $testDWord1.ToString() )
                }

                It 'Should not throw' {
                    { $null = ConvertTo-DWord @convertToDWordParameters } | Should Not Throw
                }

                $convertToDWordResult = ConvertTo-DWord @convertToDWordParameters

                It 'Should return the specified double word' {
                    $convertToDWordResult | Should Be $testDWord1
                }
            }

            Context 'Specified registry key value is an array containing an invalid single string and Hex specified as True' {
                $invalidHexDWord = 'InvalidInt32'
                $convertToDWordParameters = @{
                    RegistryKeyValue = @( $invalidHexDWord )
                    Hex = $true
                }

                It 'Should throw an error for the invalid dword string' {
                    $errorMessage = $script:localizedData.DWordDataNotInHexFormat -f $invalidHexDWord

                    { $null = ConvertTo-DWord @convertToDWordParameters } | Should Throw $errorMessage
                }
            }

            Context 'Specified registry key value is an array containing a valid single string and Hex specified as True' {
                $validHexDWord = '0xA9'
                $expectedInt32Value = 169

                $convertToDWordParameters = @{
                    RegistryKeyValue = @( $validHexDWord.ToString() )
                    Hex = $true
                }

                It 'Should not throw' {
                    { $null = ConvertTo-DWord @convertToDWordParameters } | Should Not Throw
                }

                $convertToDWordResult = ConvertTo-DWord @convertToDWordParameters

                It 'Should return the specified double word converted from a Hex value' {
                    $convertToDWordResult | Should Be $expectedInt32Value
                }
            }

            Context 'Specified registry key value is an array containing a valid single string of 0x00 and Hex specified as True' {
                $validHexDWord = '0x00'
                $expectedInt32Value = 0

                $convertToDWordParameters = @{
                    RegistryKeyValue = @( $validHexDWord.ToString() )
                    Hex = $true
                }

                It 'Should not throw' {
                    { $null = ConvertTo-DWord @convertToDWordParameters } | Should Not Throw
                }

                $convertToDWordResult = ConvertTo-DWord @convertToDWordParameters

                It 'Should return the specified double word converted from a Hex value' {
                    $convertToDWordResult | Should Be $expectedInt32Value
                }
            }

            Context 'Specified registry key value is an array with more than one string' {
                $testDWord2 = [System.Int32]::MinValue

                $convertToDWordParameters = @{
                    RegistryKeyValue = @( $testDWord1.ToString(), $testDWord2.ToString() )
                }

                It 'Should throw an error for unexpected array' {
                    $errorMessage = $script:localizedData.ArrayNotAllowedForExpectedType -f 'Dword'

                    { $null = ConvertTo-DWord @convertToDWordParameters } | Should Throw $errorMessage
                }
            }
        }

        Describe 'xRegistry\ConvertTo-MultiString' {
            Context 'Specified registry key value is null' {
                $convertToMultiStringParameters = @{
                    RegistryKeyValue = $null
                }

                It 'Should not throw' {
                    { $null = ConvertTo-MultiString @convertToMultiStringParameters } | Should Not Throw
                }

                $convertToMultiStringResult = ConvertTo-MultiString @convertToMultiStringParameters

                It 'Should return null' {
                    $convertToMultiStringResult | Should Be $null
                }
            }

            Context 'Specified registry key value is an empty array' {
                $convertToMultiStringParameters = @{
                    RegistryKeyValue = @()
                }

                It 'Should not throw' {
                    { $null = ConvertTo-MultiString @convertToMultiStringParameters } | Should Not Throw
                }

                $convertToMultiStringResult =  ConvertTo-MultiString @convertToMultiStringParameters

                It 'Should return null' {
                    $convertToMultiStringResult | Should Be $null
                }
            }

            Context 'Specified registry key value is an array containing a single null element' {
                $convertToMultiStringParameters = @{
                    RegistryKeyValue = @( $null )
                }

                It 'Should not throw' {
                    { $null = ConvertTo-MultiString @convertToMultiStringParameters } | Should Not Throw
                }

                $convertToMultiStringResult =  ConvertTo-MultiString @convertToMultiStringParameters

                It 'Should return an array containing null' {
                    Compare-Object -ReferenceObject ([String[]]@($null)) -DifferenceObject $convertToMultiStringResult | Should Be $null
                }
            }

            Context 'Specified registry key value is an array containing a single string' {
                $convertToMultiStringParameters = @{
                    RegistryKeyValue = @( 'String1' )
                }

                It 'Should not throw' {
                    { $null = ConvertTo-MultiString @convertToMultiStringParameters } | Should Not Throw
                }

                $convertToMultiStringResult =  ConvertTo-MultiString @convertToMultiStringParameters

                It 'Should return an array containing the specified single string' {
                    Compare-Object -ReferenceObject $convertToMultiStringParameters.RegistryKeyValue -DifferenceObject $convertToMultiStringResult | Should Be $null
                }
            }

            Context 'Specified registry key value is an array with more than one string' {
                $convertToMultiStringParameters = @{
                    RegistryKeyValue = @( 'String1', 'String2' )
                }

                It 'Should not throw' {
                    { $null = ConvertTo-MultiString @convertToMultiStringParameters } | Should Not Throw
                }

                $convertToMultiStringResult =  ConvertTo-MultiString @convertToMultiStringParameters

                It 'Should return an array containing the specified single string' {
                    Compare-Object -ReferenceObject $convertToMultiStringParameters.RegistryKeyValue -DifferenceObject $convertToMultiStringResult | Should Be $null
                }
            }
        }

        Describe 'xRegistry\ConvertTo-QWord' {
            Context 'Specified registry key value is null' {
                $convertToQWordParameters = @{
                    RegistryKeyValue = $null
                }

                It 'Should not throw' {
                    { $null = ConvertTo-QWord @convertToQWordParameters } | Should Not Throw
                }

                $convertToQWordResult = ConvertTo-QWord @convertToQWordParameters

                It 'Should return 0 as an Int64' {
                    $convertToQWordResult | Should Be ([System.Int64] 0)
                }
            }

            Context 'Specified registry key value is an empty array' {
                $convertToQWordParameters = @{
                    RegistryKeyValue = @()
                }

                It 'Should not throw' {
                    { $null = ConvertTo-QWord @convertToQWordParameters } | Should Not Throw
                }

                $convertToQWordResult = ConvertTo-QWord @convertToQWordParameters

                It 'Should return 0 as an Int64' {
                    $convertToQWordResult | Should Be ([System.Int64] 0)
                }
            }

            Context 'Specified registry key value is an array containing a single null element' {
                $convertToQWordParameters = @{
                    RegistryKeyValue = @( $null )
                }

                It 'Should not throw' {
                    { $null = ConvertTo-QWord @convertToQWordParameters } | Should Not Throw
                }

                $convertToQWordResult = ConvertTo-QWord @convertToQWordParameters

                It 'Should return 0 as an Int64' {
                    $convertToQWordResult | Should Be ([System.Int64] 0)
                }
            }

            $testDWord1 = [System.Int64]::MaxValue

            Context 'Specified registry key value is an array containing a valid single string and Hex not specified' {
                $convertToQWordParameters = @{
                    RegistryKeyValue = @( $testDWord1.ToString() )
                }

                It 'Should not throw' {
                    { $null = ConvertTo-QWord @convertToQWordParameters } | Should Not Throw
                }

                $convertToQWordResult = ConvertTo-QWord @convertToQWordParameters

                It 'Should return the specified quad word' {
                    $convertToQWordResult | Should Be $testDWord1
                }
            }

            Context 'Specified registry key value is an array containing an invalid single string and Hex specified as True' {
                $invalidHexDWord = 'InvalidInt32'
                $convertToQWordParameters = @{
                    RegistryKeyValue = @( $invalidHexDWord )
                    Hex = $true
                }

                It 'Should throw an error for the invalid qword string' {
                    $errorMessage = $script:localizedData.QWordDataNotInHexFormat -f $invalidHexDWord

                    { $null = ConvertTo-QWord @convertToQWordParameters } | Should Throw $errorMessage
                }
            }

            Context 'Specified registry key value is an array containing a valid single string and Hex specified as True' {
                $validHexDWord = '0xA9'
                $expectedInt64Value = 169

                $convertToQWordParameters = @{
                    RegistryKeyValue = @( $validHexDWord.ToString() )
                    Hex = $true
                }

                It 'Should not throw' {
                    { $null = ConvertTo-QWord @convertToQWordParameters } | Should Not Throw
                }

                $convertToQWordResult = ConvertTo-QWord @convertToQWordParameters

                It 'Should return the specified quad word converted from a Hex value' {
                    $convertToQWordResult | Should Be $expectedInt64Value
                }
            }

            Context 'Specified registry key value is an array containing a valid single string of 0x00 and Hex specified as True' {
                $validHexDWord = '0x00'
                $expectedInt64Value = 0

                $convertToQWordParameters = @{
                    RegistryKeyValue = @( $validHexDWord.ToString() )
                    Hex = $true
                }

                It 'Should not throw' {
                    { $null = ConvertTo-QWord @convertToQWordParameters } | Should Not Throw
                }

                $convertToQWordResult = ConvertTo-QWord @convertToQWordParameters

                It 'Should return the specified quad word converted from a Hex value' {
                    $convertToQWordResult | Should Be $expectedInt64Value
                }
            }

            Context 'Specified registry key value is an array with more than one string' {
                $testDWord2 = [System.Int64]::MinValue

                $convertToQWordParameters = @{
                    RegistryKeyValue = @( $testDWord1.ToString(), $testDWord2.ToString() )
                }

                It 'Should throw an error for unexpected array' {
                    $errorMessage = $script:localizedData.ArrayNotAllowedForExpectedType -f 'Qword'

                    { $null = ConvertTo-QWord @convertToQWordParameters } | Should Throw $errorMessage
                }
            }
        }

        Describe 'xRegistry\ConvertTo-String' {
            Context 'Specified registry key value is null' {
                $convertToStringParameters = @{
                    RegistryKeyValue = $null
                }

                It 'Should not throw' {
                    { $null = ConvertTo-String @convertToStringParameters } | Should Not Throw
                }

                $convertToStringResult = ConvertTo-String @convertToStringParameters

                It 'Should return an empty string' {
                    $convertToStringResult | Should Be ([String]::Empty)
                }
            }

            Context 'Specified registry key value is an empty array' {
                $convertToStringParameters = @{
                    RegistryKeyValue = @()
                }

                It 'Should not throw' {
                    { $null = ConvertTo-String @convertToStringParameters } | Should Not Throw
                }

                $convertToStringResult = ConvertTo-String @convertToStringParameters

                It 'Should return an empty string' {
                    $convertToStringResult | Should Be ([String]::Empty)
                }
            }

            Context 'Specified registry key value is an array containing a single null element' {
                $convertToStringParameters = @{
                    RegistryKeyValue = @( $null )
                }

                It 'Should not throw' {
                    { $null = ConvertTo-String @convertToStringParameters } | Should Not Throw
                }

                $convertToStringResult = ConvertTo-String @convertToStringParameters

                It 'Should return an empty string' {
                    $convertToStringResult | Should Be ([String]::Empty)
                }
            }

            Context 'Specified registry key value is an array containing a single string' {
                $convertToStringParameters = @{
                    RegistryKeyValue = @( 'String1' )
                }

                It 'Should not throw' {
                    { $null = ConvertTo-String @convertToStringParameters } | Should Not Throw
                }

                $convertToStringResult = ConvertTo-String @convertToStringParameters

                It 'Should return the specified single string' {
                    $convertToStringResult | Should Be $convertToStringParameters.RegistryKeyValue[0]
                }
            }

            Context 'Specified registry key value is an array with more than one string' {
                $convertToStringParameters = @{
                    RegistryKeyValue = @( 'String1', 'String2' )
                }

                It 'Should throw an error for unexpected array' {
                    $errorMessage = $script:localizedData.ArrayNotAllowedForExpectedType -f 'String or ExpandString'

                    { $null = ConvertTo-String @convertToStringParameters } | Should Throw $errorMessage
                }
            }
        }
    }
}
finally
{
    Exit-DscResourceTestEnvironment -TestEnvironment $script:testEnvironment
}
