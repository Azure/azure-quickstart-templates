$errorActionPreference = 'Stop'
Set-StrictMode -Version 'Latest'

# Import CommonTestHelper for Enter-DscResourceTestEnvironment, Exit-DscResourceTestEnvironment
$script:testsFolderFilePath = Split-Path $PSScriptRoot -Parent
$script:commonTestHelperFilePath = Join-Path -Path $testsFolderFilePath -ChildPath 'CommonTestHelper.psm1'
Import-Module -Name $commonTestHelperFilePath

$script:testEnvironment = Enter-DscResourceTestEnvironment `
    -DscResourceModuleName 'xPSDesiredStateConfiguration' `
    -DscResourceName 'MSFT_xScriptResource' `
    -TestType 'Integration'

try
{
    Describe 'xScript Integration Tests' {
        BeforeAll {
            # Import xScript module for Get-TargetResource, Test-TargetResource
            $moduleRootFilePath = Split-Path -Path $script:testsFolderFilePath -Parent
            $dscResourcesFolderFilePath = Join-Path -Path $moduleRootFilePath -ChildPath 'DscResources'
            $scriptResourceFolderFilePath = Join-Path -Path $dscResourcesFolderFilePath -ChildPath 'MSFT_xScriptResource'
            $scriptResourceModuleFilePath = Join-Path -Path $scriptResourceFolderFilePath -ChildPath 'MSFT_xScriptResource.psm1'
            Import-Module -Name $scriptResourceModuleFilePath

            $script:configurationNoCredentialFilePath = Join-Path -Path $PSScriptRoot -ChildPath 'MSFT_xScriptResource_NoCredential.config.ps1'
            $script:configurationWithCredentialFilePath = Join-Path -Path $PSScriptRoot -ChildPath 'MSFT_xScriptResource_WithCredential.config.ps1'

            # Cannot use $TestDrive here because script is run outside of Pester
            $script:testFilePath = Join-Path -Path $env:SystemDrive -ChildPath 'TestFile.txt'

            if (Test-Path -Path $script:testFilePath)
            {
                Remove-Item -Path $script:testFilePath -Force
            }
        }

        AfterAll {
            if (Test-Path -Path $script:testFilePath)
            {
                Remove-Item -Path $script:testFilePath -Force
            }
        }

        Context 'Get, set, and test scripts specified and Credential not specified' {
            if (Test-Path -Path $script:testFilePath)
            {
                Remove-Item -Path $script:testFilePath -Force
            }

            $configurationName = 'TestScriptNoCredential'

            # Cannot use $TestDrive here because script is run outside of Pester
            $resourceParameters = @{
                FilePath = $script:testFilePath
                FileContent = 'Test file content' 
            }

            It 'Should have removed test file before config runs' {
                Test-Path -Path $resourceParameters.FilePath | Should Be $false
            }

            It 'Should compile and apply the MOF without throwing' {
                { 
                    . $script:configurationNoCredentialFilePath -ConfigurationName $configurationName
                    & $configurationName -OutputPath $TestDrive @resourceParameters
                    Start-DscConfiguration -Path $TestDrive -ErrorAction 'Stop' -Wait -Force
                } | Should Not Throw
            }

            It 'Should have created the test file' {
                Test-Path -Path $resourceParameters.FilePath | Should Be $true
            }

            It 'Should have set file content correctly' {
                Get-Content -Path $resourceParameters.FilePath -Raw | Should Be "$($resourceParameters.FileContent)`r`n"
            }
        }

        Context 'Get, set, and test scripts specified and Credential specified' {
            if (Test-Path -Path $script:testFilePath)
            {
                Remove-Item -Path $script:testFilePath -Force
            }

            $configurationName = 'TestScriptWithCredential'
            
            # Cannot use $TestDrive here because script is run outside of Pester
            $resourceParameters = @{
                FilePath = $script:testFilePath
                FileContent = 'Test file content'
                Credential = Get-AppVeyorAdministratorCredential
            }

            It 'Should have removed test file before config runs' {
                Test-Path -Path $resourceParameters.FilePath | Should Be $false
            }

            $configData = @{
                AllNodes = @(
                    @{
                        NodeName = 'localhost'
                        PSDscAllowPlainTextPassword = $true
                        PSDscAllowDomainUser = $true
                    }
                )
            }

            It 'Should compile and apply the MOF without throwing' {
                { 
                    . $script:configurationWithCredentialFilePath -ConfigurationName $configurationName
                    & $configurationName -OutputPath $TestDrive -ConfigurationData $configData @resourceParameters
                    Start-DscConfiguration -Path $TestDrive -ErrorAction 'Stop' -Wait -Force
                } | Should Not Throw
            }

            It 'Should have created the test file' {
                Test-Path -Path $resourceParameters.FilePath | Should Be $true
            }

            It 'Should have set file content correctly' {
                Get-Content -Path $resourceParameters.FilePath -Raw | Should Be "$($resourceParameters.FileContent)`r`n"
            }
        }
    }
}
finally
{
    Exit-DscResourceTestEnvironment -TestEnvironment $script:testEnvironment
}
