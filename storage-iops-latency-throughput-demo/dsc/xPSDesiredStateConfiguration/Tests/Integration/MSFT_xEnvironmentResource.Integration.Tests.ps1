# These tests must be run with elevated access

$errorActionPreference = 'Stop'
Set-StrictMode -Version 'Latest'

# Import CommonTestHelper for Enter-DscResourceTestEnvironment, Exit-DscResourceTestEnvironment
$script:testsFolderFilePath = Split-Path $PSScriptRoot -Parent
$script:commonTestHelperFilePath = Join-Path -Path $testsFolderFilePath -ChildPath 'CommonTestHelper.psm1'
Import-Module -Name $commonTestHelperFilePath

$script:testEnvironment = Enter-DscResourceTestEnvironment `
    -DscResourceModuleName 'xPSDesiredStateConfiguration' `
    -DscResourceName 'MSFT_xEnvironmentResource' `
    -TestType 'Integration'

try
{
    Describe 'xEnvironment Integration Tests' {
        BeforeAll {
            # Import environment resource module for Get-TargetResource, Test-TargetResource, Set-TargetResource
            $moduleRootFilePath = Split-Path -Path (Split-Path $PSScriptRoot -Parent) -Parent
            $dscResourcesFolderFilePath = Join-Path -Path $moduleRootFilePath -ChildPath 'DscResources'
            $environmentResourceFolderFilePath = Join-Path -Path $dscResourcesFolderFilePath -ChildPath 'MSFT_xEnvironmentResource'
            $environmentResourceModuleFilePath = Join-Path -Path $environmentResourceFolderFilePath -ChildPath 'MSFT_xEnvironmentResource.psm1'
            Import-Module -Name $environmentResourceModuleFilePath -Force
        }

        It 'Should return the correct value for an environment variable that exists' {
            $envVar = 'Username'               
            $retrievedVar = Get-TargetResource -Name $envVar

            # Verify the environmnet variable $envVar is successfully retrieved
            $retrievedVar.Ensure | Should Be 'Present'

            $regItem = Get-Item -Path 'HKLM:\\System\\CurrentControlSet\\Control\\Session Manager\\Environment'
            $matchVar = $regItem.GetValue($envVar)
            $retrievedVarValue = $retrievedVar.Value

            # Verify the $retrievedVar environmnet variable value matches the value retrieved using [Environment] API
            $retrievedVarValue | Should Be $matchVar
        }

        It 'Should return Absent for an environment variable that does not exists' {
            $envVar = 'BlahVar'

            Set-TargetResource -Name $envVar -Ensure Absent
  
            $retrievedVar = Get-TargetResource -Name $envVar

            # Verify the environmnet variable $envVar is not found
            $retrievedVar.Ensure | Should Be 'Absent'       
        }

        It 'Should throw an error when creating a new environment variable with no Value specified' {
            # Ensure the variable does not already exist
            $envVar = 'TestEnvVar'
            Set-TargetResource -Name $envVar -Ensure Absent

            { Set-TargetResource -Name $envVar } | Should Throw
    
            # Now retrieve the created variable
            $retrievedVar = Get-TargetResource -Name $envVar

            # Verify the environmnet variable $envVar is successfully created
            $retrievedVar.Ensure | Should Be 'Absent'       

            # Verify the create environmnet variable's value is set to default value [String]::Empty
            $retrievedVar.Value | Should Be $null
    
            # Remove the created test variable
            Set-TargetResource -Name $envVar -Ensure Absent
        }

        It 'Should create a new environment variable with the Value specified' {
            $envVar = 'TestEnvVar'
            $val = 'TestEnvVal'

            # Ensure the value does not already exist
            Set-TargetResource -Name $envVar -Ensure Absent

            Set-TargetResource -Name $envVar -Value $val
    
            # Now retrieve the created variable
            $retrievedVar = Get-TargetResource -Name $envVar

            # Verify the environmnet variable $envVar is successfully created
            $retrievedVar.Ensure | Should Be 'Present'       

            # Verify the create environmnet variable's value is set
            $retrievedVar.Value | Should Be $val
    
            # Remove the created test variable
            Set-TargetResource -Name $envVar -Ensure Absent
        }

        It 'Should update existing environment variable with new Value' {
            $envVar = 'TestEnvVar'
            $val = 'TestEnvVal'

            # Create the environment variable
            Set-TargetResource -Name $envVar -Value $val
            
            # Update the environment variable
            $newVal = 'TestEnvNewVal'
            Set-TargetResource -Name $envVar -Value $newVal
    
            # Now retrieve the created variable
            $retrievedVar = Get-TargetResource -Name $envVar

            # Verify the environmnet variable $envVar is successfully updated
            $retrievedVar.Value | Should Be $newVal
    
            # Remove the created test variable
            Set-TargetResource -Name $envVar -Ensure Absent
        }

        It 'Should Remove an existing environment variable (Ensure = Absent)' {
            $envVar = 'TestEnvVar'
            $val = 'TestEnvVal'

            # Create the environment variable
            Set-TargetResource -Name $envVar -Value $val
               
            Set-TargetResource -Name $envVar -Ensure Absent
    
            # Now try to retrieve the created variable
            $retrievedVar = Get-TargetResource -Name $envVar

            # Verify the environmnet variable no more exists
            $retrievedVar.Ensure | Should Be 'Absent'
        }

        It 'Should update a path environment variable' {
            $envVar = 'TestEnvVar'
            $val = 'A;B;C'
            Set-TargetResource -Name $envVar -Value $val -Path $true
    
            $addPathVal = 'D'   
            Set-TargetResource -Name $envVar -Value $addPathVal -Path $true
    
            $expectedFinalVal = $val + ';' + $addPathVal
            # Now try to retrieve the created variable
            $retrievedVar = Get-TargetResource -Name $envVar

            # Verify the environmnet variable no more exists
            $retrievedVar.Value | Should Be $expectedFinalVal
            
            # Remove the created test variable
            Set-TargetResource -Name $envVar -Ensure Absent
        }

        It 'Should remove a sub-path from a path environment variable' {
            $envVar = 'TestEnvVar'
            $val = 'A;B;C'
            Set-TargetResource -Name $envVar -Value $val -Path $true
           
            $removePathVal = 'C'   
            Set-TargetResource -Name $envVar -Value $removePathVal -Path $true -Ensure Absent
    
            $expectedFinalVal = 'A;B'
            # Now try to retrieve the created variable
            $retrievedVar = Get-TargetResource -Name $envVar

            # Verify the environmnet variable no more exists
            $retrievedVar.Value | Should Be $expectedFinalVal
            
            # Remove the created test variable
            Set-TargetResource -Name $envVar -Ensure Absent
        }

        It 'Should remove a path environment variable by removing all its sub-paths' {
            $envVar = 'TestEnvVar'
            $val = 'A;B;C'
            Set-TargetResource -Name $envVar -Value $val -Path $true
            
            $removePathVal = 'C;B;A'   
            Set-TargetResource -Name $envVar -Value $removePathVal -Path $true -Ensure Absent
                
            # Now try to retrieve the created variable
            $retrievedVar = Get-TargetResource -Name $envVar

            # Verify the environmnet variable no more exists
            $retrievedVar.Ensure | Should Be 'Absent'
            
            # Remove the created test variable
            Set-TargetResource -Name $envVar -Ensure Absent
        }

        It 'Should return true when an environment variable is present and should be' {
            $envVar = 'BlahVar'
            $val = 'A;B;C'
                                  
            Set-TargetResource -Name $envVar -Value $val
                                                                     
            # Test the created environmnet variable
            Test-TargetResource -Name $envVar | Should Be $true
            
            # Remove the created test variable
            Set-TargetResource -Name $envVar -Ensure Absent
        }

        It 'Should return true when an environment environment with a specific value exists and should' {
            $envVar = 'BlahVar'   
            $val = 'BlahVal'                    
            Set-TargetResource -Name $envVar -Value $val
                                                                      
            # Verify the environmnet variable exists
            Test-TargetResource -Name $envVar -Value $val | Should Be $true
            
            # Remove the created test variable
            Set-TargetResource -Name $envVar -Ensure Absent
        }

        It 'Should return true when an environment variable is absent and should be' {
            $envVar = 'BlahVar'               
            Set-TargetResource -Name $envVar -Ensure Absent
                                                                      
            # Verify the environmnet variable exists
            Test-TargetResource -Name $envVar -Ensure Absent | Should Be $true
            
            # Remove the created test variable
            Set-TargetResource -Name $envVar -Ensure Absent
        }

        It 'Should return true when a path exists in a path environment variable and should' {
            $envVar = 'PathVar'                     
            $val = 'A;B;C'  
            Set-TargetResource -Name $envVar -Value $val -Path $true
                                          
            $subpath = 'B'
                                      
            # Test a sub-path exists in environment variable
            Test-TargetResource -Name $envVar -Value $subpath -Path $true | Should Be $true
    
            # Remove the created test variable
            Set-TargetResource -Name $envVar -Ensure Absent
        }

        It 'Should return true when a matching but shuffled path exists in a path environment variable' {
            $envVar = 'PathVar'                     
            $val = 'A;B;C'  
            Set-TargetResource -Name $envVar -Value $val -Path $true
                                         
            $subpath = 'B;a;c'
                                                  
            Test-TargetResource -Name $envVar -Value $subpath -Path $true | Should Be $true
    
            # Remove the created test variable
            Set-TargetResource -Name $envVar -Ensure Absent
        }

        It 'Should return true when a path does not exist in a path environment variable and should not' {
            $envVar = 'PathVar'                     
            $val = 'A;B;C'  
            Set-TargetResource -Name $envVar -Value $val -Path $true
                                          
            $subpath = 'D;E'
                                                  
            Test-TargetResource -Name $envVar -Value $subpath -Path $true -Ensure Absent | Should Be $true
    
            # Remove the created test variable
            Set-TargetResource -Name $envVar -Ensure Absent
        }

        It 'Should retrieve an existing environment variable using Get-TargetResource' {
            $envVar = 'windir'
    
            $retrievedVar = Get-TargetResource -Name $envVar

            # Verify the environmnet variable $envVar is successfully retrieved
            $retrievedVar.Ensure | Should Be 'Present'

            $matchVar = '%SystemRoot%'
            $retrievedVarValue = $retrievedVar.Value

            # Verify the $retrievedVar environmnet variable value matches the value retrieved using [Environment] API
            $retrievedVarValue | Should Be $matchVar
        }
    }
}
finally
{
    Exit-DscResourceTestEnvironment -TestEnvironment $script:testEnvironment
}

