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
    Describe 'xRegistry Integration Tests' {
        BeforeAll {
            # Import Registry test helper
            $registryTestHelperFilePath = Join-Path -Path $script:testsFolderFilePath -ChildPath 'MSFT_xRegistryResource.TestHelper.psm1'
            Import-Module -Name $registryTestHelperFilePath -Force

            # Import Registry resource module for Get-TargetResource, Test-TargetResource, Set-TargetResource
            $moduleRootFilePath = Split-Path -Path $script:testsFolderFilePath -Parent
            $dscResourcesFolderFilePath = Join-Path -Path $moduleRootFilePath -ChildPath 'DscResources'
            $registryResourceFolderFilePath = Join-Path -Path $dscResourcesFolderFilePath -ChildPath 'MSFT_xRegistryResource'
            $registryResourceModuleFilePath = Join-Path -Path $registryResourceFolderFilePath -ChildPath 'MSFT_xRegistryResource.psm1'
            Import-Module -Name $registryResourceModuleFilePath -Force

            $baseRegistryKeyPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment\TestKey'
            $script:registryKeyPath = $baseRegistryKeyPath

            $script:doNotDeleteRegistryKey = $false
            $script:registryDriveOriginallyMounted = $true

            $loopTimeoutMinutes = 1

            $startLoopTime = Get-Date
            while ((Test-RegistryKeyExists -KeyPath $script:registryKeyPath) -and $loopMinutes -lt $loopTimeoutMinutes)
            {
                $randomNumber = Get-Random
                $script:registryKeyPath = $baseRegistryKeyPath + $randomNumber
                $loopMinutes = ((Get-Date) - $startLoopTime).Minutes
            }

            if (Test-RegistryKeyExists -KeyPath $script:registryKeyPath)
            {
                $script:doNotDeleteRegistryKey = $true
                throw "Timed out while attempting to set up a non-destructive registry key for testing. Last testing key attempted: $script:registryKeyPath"
                return
            }
        }

        BeforeEach {
            # Remove the test registry key if it already exists
            if (Test-RegistryKeyExists -KeyPath $script:registryKeyPath)
            {
                Remove-RegistryKey -KeyPath $script:registryKeyPath
            }
        }

        AfterAll {
            # Remove the test registry key if it already exists
            if ((Test-RegistryKeyExists -KeyPath $script:registryKeyPath) -and -not $script:doNotDeleteRegistryKey)
            {
                Remove-RegistryKey -KeyPath $script:registryKeyPath
            }
        }

        Context 'Old tests' {
            # Get-TargetResource
            It 'Should return Present when retrieving a blank value from an existing registry key' {
                $registryKeyPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment'
                $getTargetResourceResult = Get-TargetResource -Key $registryKeyPath -ValueName ''
                $getTargetResourceResult.Ensure | Should Be 'Present'
            }

            It 'Should return Absent when retrieving a blank value from a registry key that does not exist' {
                $registryKeyPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environmental'
                $getTargetResourceResult = Get-TargetResource -Key $registryKeyPath -ValueName ''
                $getTargetResourceResult.Ensure | Should Be 'Absent'
            }

            It 'Should return Present when retrieving an existing value from an existing registry key' {
                $registryKeyPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment'       
                $registryValueName = 'Path'
                $getTargetResourceResult = Get-TargetResource -Key $registryKeyPath -ValueName $registryValueName
                $getTargetResourceResult.Ensure | Should Be 'Present'
            }

            It 'Should return Absent when retrieving a nonexistant value from an existing registry key' {
                $registryKeyPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment'        
                $registryValueName = 'PsychoPath'
                $getTargetResourceResult = Get-TargetResource -Key $registryKeyPath -ValueName $registryValueName
                $getTargetResourceResult.Ensure | Should Be 'Absent'
            }

            $commonRegistryKeys = @( 'HKEY_CURRENT_USER', 'HKEY_CLASSES_ROOT', 'HKEY_USERS', 'HKEY_CURRENT_CONFIG' )
            foreach ($commonRegistryKey in $commonRegistryKeys)
            {
                It "Should return Present when retrieving a blank value from $commonRegistryKey" {
                    $getTargetResourceResult = Get-TargetResource -Key $commonRegistryKey -ValueName ''
                    $getTargetResourceResult.Ensure | Should Be 'Present'
                }
            }

            # Set-TargetResource
            It 'Should create a new registry key' {
                Set-TargetResource -Key $script:registryKeyPath -ValueName ''

                # Verify that the registry key has been created
                $registryKeyExists = Test-RegistryKeyExists -KeyPath $script:registryKeyPath
                $registryKeyExists | Should Be $true
            }

            It 'Should create a new registry key tree' {
                $registryKeyTreePath = Join-Path -Path (Join-Path -Path (Join-Path -Path $script:registryKeyPath -ChildPath 'A') -ChildPath 'B') -ChildPath 'C'

                Set-TargetResource -Key $registryKeyTreePath -ValueName ''

                # Verify that the registry key has been created
                $registryKeyExists = Test-RegistryKeyExists -KeyPath $registryKeyTreePath
                $registryKeyExists | Should Be $true
            }

            It 'Should remove a registry key' {
                # Create the test registry key
                New-TestRegistryKey -KeyPath $script:registryKeyPath

                # Verify that the registry key exists before removal
                $registryKeyExists = Test-RegistryKeyExists -KeyPath $script:registryKeyPath
                $registryKeyExists | Should Be $true

                # Now remove the TestKey            
                Set-TargetResource -Key $script:registryKeyPath -ValueName '' -Ensure 'Absent'

                # Verify that the registry key has been removed
                $registryKeyExists = Test-RegistryKeyExists -KeyPath $script:registryKeyPath
                $registryKeyExists | Should Be $false
            }

            It 'Should remove a registry key tree' {
                $registryKeyTreePath = Join-Path -Path (Join-Path -Path (Join-Path -Path $script:registryKeyPath -ChildPath 'A') -ChildPath 'B') -ChildPath 'C'

                # Create the test registry key
                New-TestRegistryKey -KeyPath $registryKeyTreePath

                # Verify that the registry key tree exists before removal
                $registryKeyExists = Test-RegistryKeyExists -KeyPath $registryKeyTreePath
                $registryKeyExists | Should Be $true

                # Remove the test registry key tree            
                Set-TargetResource -Key $registryKeyTreePath -ValueName '' -Ensure 'Absent'

                # Verify that the registry key tree has been removed
                $registryKeyExists = Test-RegistryKeyExists -KeyPath $registryKeyTreePath
                $registryKeyExists | Should Be $false
            }

            It 'Should create a new string registry key value' {
                $valueName = 'TestValue'
                $valueData = 'TestData'
                $valueType = 'String'
                       
                # Create the new registry key value            
                Set-TargetResource -Key $script:registryKeyPath -ValueName $valueName -ValueData $valueData -ValueType $valueType

                # Verify that the registry key value has been created with the correct data and type
                $registryValueExists = Test-RegistryValueExists -KeyPath $script:registryKeyPath -ValueName $valueName -ValueData $valueData -ValueType $valueType
                $registryValueExists | Should Be $true
            }

            It 'Should create a new binary registry key value' {
                $valueName = 'TestValue'
                $valueData = 'aabbcc'
                $valueType = 'Binary'

                # Create the new registry key value            
                Set-TargetResource -Key $script:registryKeyPath -ValueName $valueName -ValueData $valueData -ValueType $valueType -Hex $true

                # Verify that the registry key value has been created with the correct data and type
                $registryValueExists = Test-RegistryValueExists -KeyPath $script:registryKeyPath -ValueName $valueName -ValueData $valueData -ValueType $valueType
                $registryValueExists | Should Be $true
            }

            It 'Should set the default value of a registry key' {
                $valueName = ''
                $valueData = 'DefaultValue'

                # Create the new registry key value               
                Set-TargetResource -Key $script:registryKeyPath -ValueName $valueName -ValueData $valueData

                # Verify that the registry key value has been created with the correct data and type
                $registryValueExists = Test-RegistryValueExists -KeyPath $script:registryKeyPath -ValueName '(default)' -ValueData $valueData -ValueType 'String'
                $registryValueExists | Should Be $true
            }

            It 'Should remove a registry key value' {
                $valueName = 'TestValue'
                $valueData = 'TestData'
                $valueType = 'String'

                # Create the test registry value
                New-RegistryValue -KeyPath $script:registryKeyPath -ValueName $valueName -ValueData $valueData -ValueType $valueType
   
                # Verify that the registry key value exists before removal
                $registryValueExists = Test-RegistryValueExists -KeyPath $script:registryKeyPath -ValueName $valueName
                $registryValueExists | Should Be $true

                # Remove the registry value
                Set-TargetResource -Key $script:registryKeyPath -ValueName $valueName -Ensure 'Absent'

                # Verify that the registry key value has been removed
                $registryValueExists = Test-RegistryValueExists -KeyPath $script:registryKeyPath -ValueName $valueName
                $registryValueExists | Should Be $false
            }

            It 'Should remove the default value for a registry key' {
                $valueName = ''
                $valueData = 'DefaultValue'
                $valueType = 'String'

                # Create the test registry value
                New-RegistryValue -KeyPath $script:registryKeyPath -ValueName '(default)' -ValueData $valueData -ValueType $valueType
   
                # Verify that the registry key value exists before removal
                $registryValueExists = Test-RegistryValueExists -KeyPath $script:registryKeyPath -ValueName '(default)'
                $registryValueExists | Should Be $true

                # Remove the registry value
                Set-TargetResource -Key $script:registryKeyPath -ValueName $valueName -Ensure 'Absent'

                # Verify that the registry key value has been removed
                $registryValueExists = Test-RegistryValueExists -KeyPath $script:registryKeyPath -ValueName '(default)'
                $registryValueExists | Should Be $false
            }

            It 'Should create a new key and value with path containing forward slashes' {
                $registryKeyPathWithForwardSlashes = $script:registryKeyPath + '/Test/Key'
                $valueName = 'Testing'
                $valueData = 'TestValue'

                # Create the new registry key value               
                Set-TargetResource -Key $registryKeyPathWithForwardSlashes -ValueName $valueName -ValueData $valueData

                # Verify that the registry key value has been created with the correct data and type
                $registryValueExists = Test-RegistryValueExists -KeyPath $registryKeyPathWithForwardSlashes -ValueName $valueName  -ValueData $valueData
                $registryValueExists | Should Be $true
            }

            # Test-TargetResource
            It 'Should return true for an existing registry key' {
                $registryKeyPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment'
                $testTargetResourceResult = Test-TargetResource -Key $registryKeyPath -ValueName ''
                $testTargetResourceResult | Should Be $true
            }

            It 'Should return false for a registry key that does not exist' {
                $registryKeyPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environmentally'
                $testTargetResourceResult = Test-TargetResource -Key $registryKeyPath -ValueName ''
                $testTargetResourceResult | Should Be $false
            }

            It 'Should return true for an existing registry value' {
                $registryKeyPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment'
                $valueName = 'path'
                $testTargetResourceResult = Test-TargetResource -Key $registryKeyPath -ValueName $valueName
                $testTargetResourceResult | Should Be $true
            }

            It 'Should return false for a registry value that does not exist' {
                $registryKeyPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment' 
                $valueName = 'NonExisting'
                $testTargetResourceResult = Test-TargetResource -Key $registryKeyPath -ValueName $valueName
                $testTargetResourceResult | Should Be $false
            }

            It 'Should return true when Ensure is Absent and registry key does not exist' {
                $registryKeyPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environmentally'
                $testTargetResourceResult = Test-TargetResource -Key $registryKeyPath -ValueName '' -Ensure 'Absent'
                $testTargetResourceResult | Should Be $true     
            }

            It 'Should return false when Ensure is Absent and registry key exists' {
                $registryKeyPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment'
                $testTargetResourceResult = Test-TargetResource -Key $registryKeyPath -ValueName '' -Ensure 'Absent'
                $testTargetResourceResult | Should Be $false      
            }

            It 'Should return false when Ensure is Absent and registry value exists with invalid data' {
                $registryKeyPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment'
                $valueName = 'path'
                $valueData = 'FakePath'

                $testTargetResourceResult = Test-TargetResource -Key $registryKeyPath -ValueName $valueName -ValueData $valueData -Ensure 'Absent'
                $testTargetResourceResult | Should Be $false      
            }

            It 'Should return true for a multi-string registry value' {
                $valueName = 'TestValue'
                $valueData = @('a', 'b', 'c')
                $valueType = 'MultiString'

                # Create the test registry value
                New-RegistryValue -KeyPath $script:registryKeyPath -ValueName $valueName -ValueData $valueData -ValueType $valueType

                $testTargetResourceResult = Test-TargetResource -Key $registryKeyPath -ValueName $valueName -ValueData $valueData
                $testTargetResourceResult | Should Be $true
            }

            It 'Should return true for a binary registry value' {
                $valueName = 'TestValue'
                $valueData = 'abcd123'
                $valueType = 'Binary'

                # Create the test registry value
                New-RegistryValue -KeyPath $script:registryKeyPath -ValueName $valueName -ValueData $valueData -ValueType $valueType

                $testTargetResourceResult = Test-TargetResource -Key $script:registryKeyPath -ValueName $valueName -ValueData $valueData
                $testTargetResourceResult | Should Be $true
            }

            It 'Should return true for an empty binary registry value' {
                $valueName = 'TestValue'
                $valueData = ''
                $valueType = 'Binary'

                # Create the test registry value
                New-RegistryValue -KeyPath $script:registryKeyPath -ValueName $valueName -ValueData $valueData -ValueType $valueType

                # Verify that the registry key value has been created with the correct data and type
                $registryValueExists = Test-RegistryValueExists -KeyPath $script:registryKeyPath -ValueName $valueName  -ValueData $valueData -ValueType $valueType
                $registryValueExists | Should Be $true

                $testTargetResourceResult = Test-TargetResource -Key $script:registryKeyPath -ValueName $valueName -ValueData $valueData
                $testTargetResourceResult | Should Be $true
            }

            It 'Should return true for binary registry value with zeroes' {
                $valueName = 'TestValue'
                $valueData = 'abcd0123'
                $valueType = 'Binary'

                # Create the test registry value
                New-RegistryValue -KeyPath $script:registryKeyPath -ValueName $valueName -ValueData $valueData -ValueType $valueType

                $testTargetResourceResult = Test-TargetResource -Key $script:registryKeyPath -ValueName $valueName -ValueData $valueData
                $testTargetResourceResult | Should Be $true
            }
        }
    }
}
finally
{
    Exit-DscResourceTestEnvironment -TestEnvironment $script:testEnvironment
}
