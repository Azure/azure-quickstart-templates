<#
    These tests should only be run in AppVeyor since they currently require the AppVeyor
    administrator account credential to run.

    Also please note that these tests are currently dependent on each other.
    They must be run in the order given and if one test fails, subsequent tests will
    also fail.
#>

$errorActionPreference = 'Stop'
Set-StrictMode -Version 'Latest'

# Import CommonTestHelper for Enter-DscResourceTestEnvironment, Exit-DscResourceTestEnvironment
$script:testsFolderFilePath = Split-Path $PSScriptRoot -Parent
$script:commonTestHelperFilePath = Join-Path -Path $testsFolderFilePath -ChildPath 'CommonTestHelper.psm1'
Import-Module -Name $commonTestHelperFilePath

$script:testEnvironment = Enter-DscResourceTestEnvironment `
    -DscResourceModuleName 'xPSDesiredStateConfiguration' `
    -DscResourceName 'MSFT_xServiceResource' `
    -TestType 'Integration'

try
{
    Describe 'xService Integration Tests' {
        BeforeAll {
            # Import CommonResourceHelper for Test-IsNanoServer, Get-AppveyorAdministratorCredential
            $moduleRootFilePath = Split-Path -Path $script:testsFolderFilePath -Parent
            $dscResourcesFolderFilePath = Join-Path -Path $moduleRootFilePath -ChildPath 'DscResources'
            $commonResourceHelperFilePath = Join-Path -Path $dscResourcesFolderFilePath -ChildPath 'CommonResourceHelper.psm1'
            Import-Module -Name $commonResourceHelperFilePath

            # Import DscResource.Tests TestHelper for Reset-Dsc
            $dscResourceTestsFilePath = Join-Path -Path $moduleRootFilePath -ChildPath 'DscResource.Tests'
            $dscResourceTestHelperFilePath = Join-Path -Path $dscResourceTestsFilePath -ChildPath 'TestHelper.psm1'
            Import-Module -Name $dscResourceTestHelperFilePath

            # Import xService test helper for New-ServiceBinary, Test-ServiceExists, Remove-ServiceWithTimeout
            $serviceTestHelperFilePath = Join-Path -Path $script:testsFolderFilePath -ChildPath 'MSFT_xServiceResource.TestHelper.psm1'
            Import-Module -Name $serviceTestHelperFilePath

            # Import xService resource module for Test-TargetResource
            $serviceResourceFolderFilePath = Join-Path -Path $dscResourcesFolderFilePath -ChildPath 'MSFT_xServiceResource'
            $serviceResourceModuleFilePath = Join-Path -Path $serviceResourceFolderFilePath -ChildPath 'MSFT_xServiceResource.psm1'
            Import-Module -Name $serviceResourceModuleFilePath

            # Configuration file paths
            $script:configurationAllExceptCredentialFilePath = Join-Path -Path $PSScriptRoot -ChildPath 'MSFT_xServiceResource_AllExceptCredential.config.ps1'
            $script:configurationCredentialOnlyFilePath = Join-Path -Path $PSScriptRoot -ChildPath 'MSFT_xServiceResource_CredentialOnly.config.ps1'

            # Create test service binary to be the existing service
            $script:existingServiceProperties = @{
                Name = 'TestService'
                DisplayName = 'TestDisplayName'
                Description = 'Test service description'
                Dependencies = @( 'winrm' )
                Path = Join-Path -Path $TestDrive -ChildPath 'DscTestService.exe'
            }

            $existingServiceNewExecutableParameters = @{
                ServiceName = $script:existingServiceProperties.Name
                ServiceCodePath = Join-Path -Path $script:testsFolderFilePath -ChildPath 'DscTestService.cs'
                ServiceDisplayName = $script:existingServiceProperties.DisplayName
                ServiceDescription = $script:existingServiceProperties.Description
                ServiceDependsOn = $script:existingServiceProperties.Dependencies -join ', '
                OutputPath = $script:existingServiceProperties.Path
            }

            New-ServiceExecutable @existingServiceNewExecutableParameters

            # Create test service binary to be the new service with the same name as the existing service
            $script:newServiceProperties = @{
                Name = $script:existingServiceProperties.Name
                DisplayName = 'NewTestDisplayName'
                Description = 'New test service description'
                Dependencies = @( 'spooler' )
                Path = Join-Path -Path $TestDrive -ChildPath 'NewDscTestService.exe'
            }

            if (Test-IsNanoServer)
            {
                # Nano Server does not recognize 'spooler', so keep the dependencies value as 'winrm'
                $newServiceProperties['Dependencies'] = @( 'winrm' )
            }

            $newServiceNewExecutableParameters = @{
                ServiceName = $script:newServiceProperties.Name
                ServiceCodePath = Join-Path -Path $script:testsFolderFilePath -ChildPath 'DscTestServiceNew.cs'
                ServiceDisplayName = $script:newServiceProperties.DisplayName
                ServiceDescription = $script:newServiceProperties.Description
                ServiceDependsOn = $script:newServiceProperties.Dependencies -join ', '
                OutputPath = $script:newServiceProperties.Path
            }

            New-ServiceExecutable @newServiceNewExecutableParameters

            $script:testServiceNames = @( $script:existingServiceProperties.Name )
            $script:testServiceExecutables = @( $script:existingServiceProperties.Path, $script:newServiceProperties.Path )
        }

        AfterAll {
            # Remove any created services
            foreach ($testServiceName in $script:testServiceNames)
            {
                if (Test-ServiceExists -Name $testServiceName)
                {
                    Remove-ServiceWithTimeout -Name $testServiceName
                }
            }
        }

        Context 'Create a service' {
            Reset-DSC

            $configurationName = 'TestCreateService'
            $resourceParameters = $script:existingServiceProperties

            It 'Should compile and apply the MOF without throwing' {
                { 
                    . $script:configurationAllExceptCredentialFilePath -ConfigurationName $configurationName
                    & $configurationName -OutputPath $TestDrive @resourceParameters
                    Start-DscConfiguration -Path $TestDrive -ErrorAction 'Stop' -Wait -Force
                } | Should Not Throw
            }

            $service = Get-Service -Name $resourceParameters.Name -ErrorAction 'SilentlyContinue'
            $serviceCimInstance = Get-CimInstance -ClassName 'Win32_Service' -Filter "Name='$($resourceParameters.Name)'" -ErrorAction 'SilentlyContinue'

            It 'Should have created a new service with the specified name' {
                 $service | Should Not Be $null
                 $serviceCimInstance | Should Not Be $null

                 $service.Name | Should Be $resourceParameters.Name
                 $serviceCimInstance.Name | Should Be $resourceParameters.Name
            }

            It 'Should have created a new service with the specified path' {
                $serviceCimInstance.PathName | Should Be $resourceParameters.Path
            }

            It 'Should have created a new service with the specified display name' {
                $service.DisplayName | Should Be $resourceParameters.DisplayName
            }

            It 'Should have created a new service with the specified description' {
                $serviceCimInstance.Description | Should Be $resourceParameters.Description
            }

            It 'Should have created a new service with the specified dependencies' {
                $differentDependencies = Compare-Object -ReferenceObject $resourceParameters.Dependencies -DifferenceObject $service.ServicesDependedOn.Name
                $differentDependencies | Should Be $null
            }

            It 'Should have created a new service with the default state as Running' {
                $service.Status | Should Be 'Running'
            }

            It 'Should have created a new service with the default startup type as Auto' {
                $serviceCimInstance.StartMode | Should Be 'Auto'
            }

            It 'Should have created a new service with the default startup account name as LocalSystem' {
                $serviceCimInstance.StartName | Should Be 'LocalSystem'
            }

            It 'Should have created a new service with the default desktop interaction setting as False' {
                $serviceCimInstance.DesktopInteract | Should Be $false
            }

            It 'Should return true from Test-TargetResource with the same parameters' {
                MSFT_xServiceResource\Test-TargetResource @resourceParameters | Should Be $true
            }
        }

        Context 'Edit the service path, display name, description, and dependencies' {
            Reset-DSC

            $configurationName = 'TestCreateService'
            $resourceParameters = $script:newServiceProperties

            It 'Should compile and apply the MOF without throwing' {
                { 
                    . $script:configurationAllExceptCredentialFilePath -ConfigurationName $configurationName
                    & $configurationName -OutputPath $TestDrive @resourceParameters
                    Start-DscConfiguration -Path $TestDrive -ErrorAction 'Stop' -Wait -Force
                } | Should Not Throw
            }

            $service = Get-Service -Name $resourceParameters.Name -ErrorAction 'SilentlyContinue'
            $serviceCimInstance = Get-CimInstance -ClassName 'Win32_Service' -Filter "Name='$($resourceParameters.Name)'" -ErrorAction 'SilentlyContinue'

            It 'Should not have removed service with specified name' {
                 $service | Should Not Be $null
                 $serviceCimInstance | Should Not Be $null

                 $service.Name | Should Be $resourceParameters.Name
                 $serviceCimInstance.Name | Should Be $resourceParameters.Name
            }

            It 'Should have edited service to have the specified path' {
                $serviceCimInstance.PathName | Should Be $resourceParameters.Path
            }

            It 'Should have edited service to have the specified display name' {
                $service.DisplayName | Should Be $resourceParameters.DisplayName
            }

            It 'Should have edited service to have the specified description' {
                $serviceCimInstance.Description | Should Be $resourceParameters.Description
            }

            It 'Should have edited service to have the specified dependencies' {
                $differentDependencies = Compare-Object -ReferenceObject $resourceParameters.Dependencies -DifferenceObject $service.ServicesDependedOn.Name
                $differentDependencies | Should Be $null
            }

            It 'Should not have changed the service state from Running' {
                $service.Status | Should Be 'Running'
            }

            It 'Should not have changed the service startup type from Auto' {
                $serviceCimInstance.StartMode | Should Be 'Auto'
            }

            It 'Should not have changed the service startup account name from LocalSystem' {
                $serviceCimInstance.StartName | Should Be 'LocalSystem'
            }

            It 'Should not have changed the service desktop interaction setting from False' {
                $serviceCimInstance.DesktopInteract | Should Be $false
            }

            It 'Should return true from Test-TargetResource with the same parameters' {
                MSFT_xServiceResource\Test-TargetResource @resourceParameters | Should Be $true
            }
        }

        Context 'Edit the service startup type and state' {
            Reset-DSC

            $configurationName = 'TestCreateService'
            $resourceParameters = @{
                Name = $script:existingServiceProperties.Name
                Path = $script:newServiceProperties.Path
                StartupType = 'Manual'
                State = 'Stopped'
            }

            It 'Should compile and apply the MOF without throwing' {
                { 
                    . $script:configurationAllExceptCredentialFilePath -ConfigurationName $configurationName
                    & $configurationName -OutputPath $TestDrive @resourceParameters
                    Start-DscConfiguration -Path $TestDrive -ErrorAction 'Stop' -Wait -Force
                } | Should Not Throw
            }

            $service = Get-Service -Name $resourceParameters.Name -ErrorAction 'SilentlyContinue'
            $serviceCimInstance = Get-CimInstance -ClassName 'Win32_Service' -Filter "Name='$($resourceParameters.Name)'" -ErrorAction 'SilentlyContinue'

            It 'Should not have removed service with specified name' {
                 $service | Should Not Be $null
                 $serviceCimInstance | Should Not Be $null

                 $service.Name | Should Be $resourceParameters.Name
                 $serviceCimInstance.Name | Should Be $resourceParameters.Name
            }

            It 'Should have edited the service to have the specified state' {
                $service.Status | Should Be $resourceParameters.State
            }

            It 'Should have edited the service to have the specified startup type' {
                $serviceCimInstance.StartMode | Should Be $resourceParameters.StartupType
            }

            It 'Should return true from Test-TargetResource with the same parameters' {
                MSFT_xServiceResource\Test-TargetResource @resourceParameters | Should Be $true
            }
        }

        Context 'Edit the service start name and start password with Credential' {
            Reset-DSC

            $configData = @{
                AllNodes = @(
                    @{
                        NodeName = 'localhost'
                        PSDscAllowPlainTextPassword = $true
                    }
                )
            }

            $configurationName = 'TestCreateService'
            $resourceParameters = @{
                Name = 'TestService'
                Credential = Get-AppVeyorAdministratorCredential
            }

            It 'Should compile and apply the MOF without throwing' {
                { 
                    . $script:configurationCredentialOnlyFilePath -ConfigurationName $configurationName
                    & $configurationName -OutputPath $TestDrive -ConfigurationData $configData @resourceParameters
                    Start-DscConfiguration -Path $TestDrive -ErrorAction 'Stop' -Wait -Force
                } | Should Not Throw
            }

            $service = Get-Service -Name $resourceParameters.Name -ErrorAction 'SilentlyContinue'
            $serviceCimInstance = Get-CimInstance -ClassName 'Win32_Service' -Filter "Name='$($resourceParameters.Name)'" -ErrorAction 'SilentlyContinue'

            It 'Should not have removed service with specified name' {
                    $service | Should Not Be $null
                    $serviceCimInstance | Should Not Be $null

                    $service.Name | Should Be $resourceParameters.Name
                    $serviceCimInstance.Name | Should Be $resourceParameters.Name
            }

            It 'Should have edited the service to have the specified startup account name' {
                $expectedStartName = $resourceParameters.Credential.UserName

                if ($expectedStartName.StartsWith("$env:COMPUTERNAME\"))
                {
                    $expectedStartName = $expectedStartName.TrimStart("$env:COMPUTERNAME\")
                }

                $serviceCimInstance.StartName | Should Be ".\$expectedStartName"
            }

            It 'Should return true from Test-TargetResource with the same parameters' {
                MSFT_xServiceResource\Test-TargetResource @resourceParameters | Should Be $true
            }
        }

        Context 'Edit the service start name and start password with BuiltInAccount' {
            Reset-DSC

            $configurationName = 'TestCreateService'
            $resourceParameters = @{
                Name = 'TestService'
                Path = $script:newServiceProperties.Path
                BuiltInAccount = 'LocalService'
            }

            It 'Should compile and apply the MOF without throwing' {
                { 
                    . $script:configurationAllExceptCredentialFilePath -ConfigurationName $configurationName
                    & $configurationName -OutputPath $TestDrive @resourceParameters
                    Start-DscConfiguration -Path $TestDrive -ErrorAction 'Stop' -Wait -Force
                } | Should Not Throw
            }

            $service = Get-Service -Name $resourceParameters.Name -ErrorAction 'SilentlyContinue'
            $serviceCimInstance = Get-CimInstance -ClassName 'Win32_Service' -Filter "Name='$($resourceParameters.Name)'" -ErrorAction 'SilentlyContinue'

            It 'Should not have removed service with specified name' {
                 $service | Should Not Be $null
                 $serviceCimInstance | Should Not Be $null

                 $service.Name | Should Be $resourceParameters.Name
                 $serviceCimInstance.Name | Should Be $resourceParameters.Name
            }

            It 'Should have edited the service to have the specified startup account name' {
                $serviceCimInstance.StartName | Should Be 'NT Authority\LocalService'
            }

            It 'Should return true from Test-TargetResource with the same parameters' {
                MSFT_xServiceResource\Test-TargetResource @resourceParameters | Should Be $true
            }
        }

        Context 'Remove the service' {
            Reset-DSC

            $configurationName = 'TestCreateService'
            $resourceParameters = @{
                Name = $script:existingServiceProperties.Name
                Path = $script:existingServiceProperties.Path
                Ensure = 'Absent'
            }

            It 'Should compile and apply the MOF without throwing' {
                { 
                    . $script:configurationAllExceptCredentialFilePath -ConfigurationName $configurationName
                    & $configurationName -OutputPath $TestDrive @resourceParameters
                    Start-DscConfiguration -Path $TestDrive -ErrorAction 'Stop' -Wait -Force
                } | Should Not Throw
            }

            $service = Get-Service -Name $resourceParameters.Name -ErrorAction 'SilentlyContinue'
            $serviceCimInstance = Get-CimInstance -ClassName 'Win32_Service' -Filter "Name='$($resourceParameters.Name)'" -ErrorAction 'SilentlyContinue'

            It 'Should have removed the service with specified name' {
                 $service | Should Be $null
                 $serviceCimInstance | Should Be $null
            }

            It 'Should return true from Test-TargetResource with the same parameters' {
                MSFT_xServiceResource\Test-TargetResource @resourceParameters | Should Be $true
            }
        }
    }
}
finally
{
    Exit-DscResourceTestEnvironment -TestEnvironment $script:testEnvironment
}
