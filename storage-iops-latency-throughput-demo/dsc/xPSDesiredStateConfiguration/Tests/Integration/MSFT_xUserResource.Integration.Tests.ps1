<#
    To run these tests, the currently logged on user must have rights to create a user.
    These integration tests cover creating a brand new user, updating values 
    of a user that already exists, and deleting a user that exists.
#> 

# Suppressing this rule since we need to create a plaintext password to test this resource
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingConvertToSecureStringWithPlainText', '')]
param ()

Import-Module -Name (Join-Path -Path (Split-Path $PSScriptRoot -Parent) `
                               -ChildPath 'CommonTestHelper.psm1') `
                               -Force

$script:testEnvironment = Enter-DscResourceTestEnvironment `
    -DscResourceModuleName 'xPSDesiredStateConfiguration' `
    -DscResourceName 'MSFT_xUserResource' `
    -TestType 'Integration'

try {

    $configFile = Join-Path -Path $PSScriptRoot -ChildPath 'MSFT_xUserResource.config.ps1'


    Describe 'xUserResource Integration Tests' {
        $ConfigData = @{
            AllNodes = @(
                @{
                    NodeName = '*'
                    PSDscAllowPlainTextPassword = $true
                }
                @{
                    NodeName = 'localhost'
                }
            )
        }
    
        Context 'Should create a new user' {
            $configurationName = 'MSFT_xUser_NewUser'
            $configurationPath = Join-Path -Path $TestDrive -ChildPath $configurationName

            $logPath = Join-Path -Path $TestDrive -ChildPath 'NewUser.log'
            
            $testUserName = 'TestUserName12345'
            $testUserPassword = 'StrongOne7.'
            $testDescription = 'Test Description'
            $secureTestPassword = ConvertTo-SecureString $testUserPassword -AsPlainText -Force
            $testCredential = New-Object PSCredential ($testUserName, $secureTestPassword)

            try
            {
                It 'Should compile without throwing' {
                    {
                        . $configFile -ConfigurationName $configurationName
                        & $configurationName -UserName $testUserName `
                                             -Password $testCredential `
                                             -Description $testDescription `
                                             -OutputPath $configurationPath `
                                             -ConfigurationData $ConfigData `
                                             -ErrorAction Stop
                        Start-DscConfiguration -Path $configurationPath -Wait -Force
                    } | Should Not Throw
                }

                It 'Should be able to call Get-DscConfiguration without throwing' {
                    { Get-DscConfiguration -Verbose -ErrorAction Stop } | Should Not Throw
                }
                
                It 'Should return the correct configuration' {
                    $currentConfig = Get-DscConfiguration -Verbose -ErrorAction Stop
                    $currentConfig.UserName | Should Be $testUserName
                    $currentConfig.Ensure | Should Be 'Present'
                    $currentConfig.Description | Should Be $TestDescription
                    $currentConfig.Disabled | Should Be $false
                    $currentConfig.PasswordChangeRequired | Should Be $null
                }
            }
            finally
            {
                if (Test-Path -Path $logPath) {
                    Remove-Item -Path $logPath -Recurse -Force
                }

                if (Test-Path -Path $configurationPath)
                {
                    Remove-Item -Path $configurationPath -Recurse -Force
                }
            }
        }
        
        Context 'Should update an existing user' {
            $configurationName = 'MSFT_xUser_UpdateUser'
            $configurationPath = Join-Path -Path $TestDrive -ChildPath $configurationName

            $logPath = Join-Path -Path $TestDrive -ChildPath 'UpdateUser.log'
            
            $testUserName = 'TestUserName12345'
            $testUserPassword = 'StrongOne7.'
            $testDescription = 'New Test Description'
            $secureTestPassword = ConvertTo-SecureString $testUserPassword -AsPlainText -Force
            $testCredential = New-Object PSCredential ($testUserName, $secureTestPassword)

            try
            {
                It 'Should compile without throwing' {
                    {
                        . $configFile -ConfigurationName $configurationName
                        & $configurationName -UserName $testUserName `
                                             -Password $testCredential `
                                             -Description $testDescription `
                                             -OutputPath $configurationPath `
                                             -ConfigurationData $ConfigData `
                                             -ErrorAction Stop
                        Start-DscConfiguration -Path $configurationPath -Wait -Force
                    } | Should Not Throw
                }

                It 'Should be able to call Get-DscConfiguration without throwing' {
                    { Get-DscConfiguration -Verbose -ErrorAction Stop } | Should Not Throw
                }
                
                It 'Should return the correct configuration' {
                    $currentConfig = Get-DscConfiguration -Verbose -ErrorAction Stop
                    $currentConfig.UserName | Should Be $testUserName
                    $currentConfig.Ensure | Should Be 'Present'
                    $currentConfig.Description | Should Be $TestDescription
                    $currentConfig.Disabled | Should Be $false
                    $currentConfig.PasswordChangeRequired | Should Be $null
                }
            }
            finally
            {
                if (Test-Path -Path $logPath) {
                    Remove-Item -Path $logPath -Recurse -Force
                }

                if (Test-Path -Path $configurationPath)
                {
                    Remove-Item -Path $configurationPath -Recurse -Force
                }
            }
        }
        
        Context 'Should delete an existing user' {
            $configurationName = 'MSFT_xUser_DeleteUser'
            $configurationPath = Join-Path -Path $TestDrive -ChildPath $configurationName

            $logPath = Join-Path -Path $TestDrive -ChildPath 'DeleteUser.log'
            
            $testUserName = 'TestUserName12345'
            $testUserPassword = 'StrongOne7.'
            $secureTestPassword = ConvertTo-SecureString $testUserPassword -AsPlainText -Force
            $testCredential = New-Object PSCredential ($testUserName, $secureTestPassword)

            try
            {
                It 'Should compile without throwing' {
                    {
                        . $configFile -ConfigurationName $configurationName
                        & $configurationName -UserName $testUserName `
                                             -Password $testCredential `
                                             -OutputPath $configurationPath `
                                             -ConfigurationData $ConfigData `
                                             -Ensure 'Absent' `
                                             -ErrorAction Stop
                        Start-DscConfiguration -Path $configurationPath -Wait -Force
                    } | Should Not Throw
                }

                It 'Should be able to call Get-DscConfiguration without throwing' {
                    { Get-DscConfiguration -Verbose -ErrorAction Stop } | Should Not Throw
                }
                
                It 'Should return the correct configuration' {
                    $currentConfig = Get-DscConfiguration -Verbose -ErrorAction Stop
                    $currentConfig.UserName | Should Be $testUserName
                    $currentConfig.Ensure | Should Be 'Absent'
                }
            }
            finally
            {
                if (Test-Path -Path $logPath) {
                    Remove-Item -Path $logPath -Recurse -Force
                }

                if (Test-Path -Path $configurationPath)
                {
                    Remove-Item -Path $configurationPath -Recurse -Force
                }
            }
        }
        
    }
}
finally
{
    Exit-DscResourceTestEnvironment -TestEnvironment $script:testEnvironment
}


