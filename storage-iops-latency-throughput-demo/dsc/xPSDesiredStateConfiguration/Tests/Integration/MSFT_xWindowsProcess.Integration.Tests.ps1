<#
    These tests should only be run in AppVeyor since the second half of the tests require
    the AppVeyor administrator account credential to run.

    Also please note that some of these tests depend on each other.
    They must be run in the order given - if one test fails, subsequent tests may
    also fail.
#>
$errorActionPreference = 'Stop'
Set-StrictMode -Version 'Latest'

Import-Module -Name (Join-Path -Path (Split-Path $PSScriptRoot -Parent) `
                               -ChildPath 'CommonTestHelper.psm1') `
                               -Force

$script:testEnvironment = Enter-DscResourceTestEnvironment `
    -DscResourceModuleName 'xPSDesiredStateConfiguration' `
    -DscResourceName 'MSFT_xWindowsProcess' `
    -TestType 'Integration'

try
{
    Describe 'xWindowsProcess Integration Tests without Credential' {
        $testProcessPath = Join-Path -Path (Split-Path $PSScriptRoot -Parent) `
                                     -ChildPath 'WindowsProcessTestProcess.exe'
        $logFilePath = Join-Path -Path (Split-Path $PSScriptRoot -Parent) `
                                 -ChildPath 'processTestLog.txt'

        $configFile = Join-Path -Path $PSScriptRoot `
                                -ChildPath 'MSFT_xWindowsProcess.config.ps1'

        Context 'Should stop any current instances of the testProcess running' {
            $configurationName = 'MSFT_xWindowsProcess_Setup'
            $configurationPath = Join-Path -Path $TestDrive -ChildPath $configurationName

            It 'Should compile without throwing' {
                {
                    if (Test-Path -Path $logFilePath)
                    {
                        Remove-Item -Path $logFilePath
                    }

                    .$configFile -ConfigurationName $configurationName
                    & $configurationName -Path $testProcessPath `
                                         -Arguments $logFilePath `
                                         -Ensure 'Absent' `
                                         -ErrorAction 'Stop' `
                                         -OutputPath $configurationPath
                    Start-DscConfiguration -Path $configurationPath -ErrorAction 'Stop' -Wait -Force
                } | Should Not Throw
            }
            
            It 'Should be able to call Get-DscConfiguration without throwing' {
                { Get-DscConfiguration -ErrorAction 'Stop' } | Should Not Throw
            }

            It 'Should return the correct configuration' {
                $currentConfig = Get-DscConfiguration -ErrorAction 'Stop'
                $currentConfig.Path | Should Be $testProcessPath
                $currentConfig.Arguments | Should Be $logFilePath
                $currentConfig.Ensure | Should Be 'Absent'
            }

            It 'Should not create a logfile' {
                $pathResult = Test-Path $logFilePath
                $pathResult | Should Be $false
            }
        }

        Context 'Should start a new testProcess instance as running' {
            $configurationName = 'MSFT_xWindowsProcess_StartProcess'
            $configurationPath = Join-Path -Path $TestDrive -ChildPath $configurationName

            It 'Should not have a logfile already present' {
                $pathResult = Test-Path $logFilePath
                $pathResult | Should Be $false
            }

            It 'Should compile without throwing' {
                {
                    .$configFile -ConfigurationName $configurationName
                    & $configurationName -Path $testProcessPath `
                                         -Arguments $logFilePath `
                                         -Ensure 'Present' `
                                         -ErrorAction 'Stop' `
                                         -OutputPath $configurationPath
                    Start-DscConfiguration -Path $configurationPath -ErrorAction 'Stop' -Wait -Force
                } | Should Not Throw
            }
       
            It 'Should be able to call Get-DscConfiguration without throwing' {
                { Get-DscConfiguration -ErrorAction 'Stop' } | Should Not Throw
            }

            It 'Should return the correct configuration' {
                $currentConfig = Get-DscConfiguration -ErrorAction 'Stop'
                $currentConfig.Path | Should Be $testProcessPath
                $currentConfig.Arguments | Should Be $logFilePath
                $currentConfig.Ensure | Should Be 'Present'
                $currentConfig.ProcessCount | Should Be 1
            }

            It 'Should create a logfile' {
                $pathResult = Test-Path $logFilePath
                $pathResult | Should Be $true
            }
        }

        Context 'Should not start a second new testProcess instance when one is already running' {
            $configurationName = 'MSFT_xWindowsProcess_StartSecondProcess'
            $configurationPath = Join-Path -Path $TestDrive -ChildPath $configurationName

            It 'Should have a logfile already present' {
                $pathResult = Test-Path $logFilePath
                $pathResult | Should Be $true
            }

            It 'Should not throw when removing the log file' {
                { Remove-Item -Path $logFilePath } | Should not Throw
            }

            It 'Should compile without throwing' {
                {
                    .$configFile -ConfigurationName $configurationName
                    & $configurationName -Path $testProcessPath `
                                         -Arguments $logFilePath `
                                         -Ensure 'Present' `
                                         -ErrorAction 'Stop' `
                                         -OutputPath $configurationPath
                    Start-DscConfiguration -Path $configurationPath -ErrorAction 'Stop' -Wait -Force
                } | Should Not Throw
            }
       
            It 'Should be able to call Get-DscConfiguration without throwing' {
                { Get-DscConfiguration -ErrorAction 'Stop' } | Should Not Throw
            }

            It 'Should return the correct configuration' {
                $currentConfig = Get-DscConfiguration -ErrorAction 'Stop'
                $currentConfig.Path | Should Be $testProcessPath
                $currentConfig.Arguments | Should Be $logFilePath
                $currentConfig.Ensure | Should Be 'Present'
                $currentConfig.ProcessCount | Should Be 1
            }

            It 'Should not create a logfile' {
                $pathResult = Test-Path $logFilePath
                $pathResult | Should Be $false
            }
        }

        Context 'Should stop the testProcess instance from running' {
            $configurationName = 'MSFT_xWindowsProcess_StopProcesses'
            $configurationPath = Join-Path -Path $TestDrive -ChildPath $configurationName

            It 'Should not have a logfile already present' {
                $pathResult = Test-Path $logFilePath
                $pathResult | Should Be $false
            }

            It 'Should compile without throwing' {
                {
                    .$configFile -ConfigurationName $configurationName
                    & $configurationName -Path $testProcessPath `
                                         -Arguments $logFilePath `
                                         -Ensure 'Absent' `
                                         -ErrorAction 'Stop' `
                                         -OutputPath $configurationPath
                    Start-DscConfiguration -Path $configurationPath -ErrorAction 'Stop' -Wait -Force
                } | Should Not Throw
            }
       
            It 'Should be able to call Get-DscConfiguration without throwing' {
                { Get-DscConfiguration -ErrorAction 'Stop' } | Should Not Throw
            }

            It 'Should return the correct configuration' {
                $currentConfig = Get-DscConfiguration -ErrorAction 'Stop'
                $currentConfig.Path | Should Be $testProcessPath
                $currentConfig.Arguments | Should Be $logFilePath
                $currentConfig.Ensure | Should Be 'Absent'
            }

            It 'Should not create a logfile' {
                $pathResult = Test-Path $logFilePath
                $pathResult | Should Be $false
            }
        }

        Context 'Should return correct amount of processes running when more than 1 are running' {
            $configurationName = 'MSFT_xWindowsProcess_StartMultipleProcesses'
            $configurationPath = Join-Path -Path $TestDrive -ChildPath $configurationName

            It 'Should not have a logfile already present' {
                $pathResult = Test-Path $logFilePath
                $pathResult | Should Be $false
            }

            It 'Should compile without throwing' {
                {
                    .$configFile -ConfigurationName $configurationName
                    & $configurationName -Path $testProcessPath `
                                         -Arguments $logFilePath `
                                         -Ensure 'Present' `
                                         -ErrorAction 'Stop' `
                                         -OutputPath $configurationPath
                    Start-DscConfiguration -Path $configurationPath -ErrorAction 'Stop' -Wait -Force
                } | Should Not Throw
            }

            It 'Should start another process running' {
                Start-Process -FilePath $testProcessPath -ArgumentList @($logFilePath)
            }
       
            It 'Should be able to call Get-DscConfiguration without throwing' {
                { Get-DscConfiguration -ErrorAction 'Stop' } | Should Not Throw
            }

            It 'Should return the correct configuration' {
                $currentConfig = Get-DscConfiguration -ErrorAction 'Stop'
                $currentConfig.Path | Should Be $testProcessPath
                $currentConfig.Arguments | Should Be $logFilePath
                $currentConfig.Ensure | Should Be 'Present'
                $currentConfig.ProcessCount | Should Be 2
            }

            It 'Should create a logfile' {
                $pathResult = Test-Path $logFilePath
                $pathResult | Should Be $true
            }
        }

        Context 'Should stop all of the testProcess instances from running' {
            $configurationName = 'MSFT_xWindowsProcess_StopAllProcesses'
            $configurationPath = Join-Path -Path $TestDrive -ChildPath $configurationName

            It 'Should have a logfile already present' {
                $pathResult = Test-Path $logFilePath
                $pathResult | Should Be $true
            }

            It 'Should not throw when removing the log file' {
                { Remove-Item -Path $logFilePath } | Should not Throw
            }

            It 'Should compile without throwing' {
                {
                    .$configFile -ConfigurationName $configurationName
                    & $configurationName -Path $testProcessPath `
                                         -Arguments $logFilePath `
                                         -Ensure 'Absent' `
                                         -ErrorAction 'Stop' `
                                         -OutputPath $configurationPath
                    Start-DscConfiguration -Path $configurationPath -ErrorAction 'Stop' -Wait -Force
                } | Should Not Throw
            }
       
            It 'Should be able to call Get-DscConfiguration without throwing' {
                { Get-DscConfiguration -ErrorAction 'Stop' } | Should Not Throw
            }

            It 'Should return the correct configuration' {
                $currentConfig = Get-DscConfiguration -ErrorAction 'Stop'
                $currentConfig.Path | Should Be $testProcessPath
                $currentConfig.Arguments | Should Be $logFilePath
                $currentConfig.Ensure | Should Be 'Absent'
            }

            It 'Should not create a logfile' {
                $pathResult = Test-Path $logFilePath
                $pathResult | Should Be $false
            }
        }
    }
    
    Describe 'xWindowsProcess Integration Tests with Credential' {
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

        $testCredential = Get-AppVeyorAdministratorCredential

        $testProcessPath = Join-Path -Path (Split-Path $PSScriptRoot -Parent) `
                                     -ChildPath 'WindowsProcessTestProcess.exe'
        $logFilePath = Join-Path -Path (Split-Path $PSScriptRoot -Parent) `
                                 -ChildPath 'processTestLog.txt'

        $configFile = Join-Path -Path $PSScriptRoot `
                                -ChildPath 'MSFT_xWindowsProcessWithCredential.config.ps1'

        Context 'Should stop any current instances of the testProcess running' {
            $configurationName = 'MSFT_xWindowsProcess_SetupWithCredential'
            $configurationPath = Join-Path -Path $TestDrive -ChildPath $configurationName

            It 'Should compile without throwing' {
                {
                    if (Test-Path -Path $logFilePath)
                    {
                        Remove-Item -Path $logFilePath
                    }

                    .$configFile -ConfigurationName $configurationName
                    & $configurationName -Path $testProcessPath `
                                         -Arguments $logFilePath `
                                         -Ensure 'Absent' `
                                         -Credential $testCredential `
                                         -ErrorAction 'Stop' `
                                         -OutputPath $configurationPath `
                                         -ConfigurationData $ConfigData
                    Start-DscConfiguration -Path $configurationPath -ErrorAction 'Stop' -Wait -Force
                } | Should Not Throw
            }

            It 'Should be able to call Get-DscConfiguration without throwing' {
                { Get-DscConfiguration -ErrorAction 'Stop' } | Should Not Throw
            }

            It 'Should return the correct configuration' {
                $currentConfig = Get-DscConfiguration -ErrorAction 'Stop'
                $currentConfig.Path | Should Be $testProcessPath
                $currentConfig.Arguments | Should Be $logFilePath
                $currentConfig.Ensure | Should Be 'Absent'
            }

            It 'Should not create a logfile' {
                $pathResult = Test-Path $logFilePath
                $pathResult | Should Be $false
            }
        }
        
        Context 'Should start a new testProcess instance as running' {
            $configurationName = 'MSFT_xWindowsProcess_StartProcessWithCredential'
            $configurationPath = Join-Path -Path $TestDrive -ChildPath $configurationName

            It 'Should not have a logfile already present' {
                $pathResult = Test-Path $logFilePath
                $pathResult | Should Be $false
            }

            It 'Should compile without throwing' {
                {
                    .$configFile -ConfigurationName $configurationName
                    & $configurationName -Path $testProcessPath `
                                         -Arguments $logFilePath `
                                         -Ensure 'Present' `
                                         -Credential $testCredential `
                                         -ErrorAction 'Stop' `
                                         -OutputPath $configurationPath `
                                         -ConfigurationData $ConfigData
                    Start-DscConfiguration -Path $configurationPath -ErrorAction 'Stop' -Wait -Force
                } | Should Not Throw
            }

            It 'Should be able to call Get-DscConfiguration without throwing' {
                { Get-DscConfiguration -ErrorAction 'Stop' } | Should Not Throw
            }

            It 'Should return the correct configuration' {
                $currentConfig = Get-DscConfiguration -ErrorAction 'Stop'
                $currentConfig.Path | Should Be $testProcessPath
                $currentConfig.Arguments | Should Be $logFilePath
                $currentConfig.Ensure | Should Be 'Present'
                $currentConfig.ProcessCount | Should Be 1
            }

            It 'Should create a logfile' {
                $pathResult = Test-Path $logFilePath
                $pathResult | Should Be $true
            }
        }

        Context 'Should not start a second new testProcess instance when one is already running' {
            $configurationName = 'MSFT_xWindowsProcess_StartSecondProcessWithCredential'
            $configurationPath = Join-Path -Path $TestDrive -ChildPath $configurationName

            It 'Should have a logfile already present' {
                $pathResult = Test-Path $logFilePath
                $pathResult | Should Be $true
            }

            It 'Should not throw when removing the log file' {
                { Remove-Item -Path $logFilePath } | Should not Throw
            }

            It 'Should compile without throwing' {
                {
                    .$configFile -ConfigurationName $configurationName
                    & $configurationName -Path $testProcessPath `
                                         -Arguments $logFilePath `
                                         -Ensure 'Present' `
                                         -Credential $testCredential `
                                         -ErrorAction 'Stop' `
                                         -OutputPath $configurationPath `
                                         -ConfigurationData $ConfigData
                    Start-DscConfiguration -Path $configurationPath -ErrorAction 'Stop' -Wait -Force
                } | Should Not Throw
            }
       
            It 'Should be able to call Get-DscConfiguration without throwing' {
                { Get-DscConfiguration -ErrorAction 'Stop' } | Should Not Throw
            }

            It 'Should return the correct configuration' {
                $currentConfig = Get-DscConfiguration -ErrorAction 'Stop'
                $currentConfig.Path | Should Be $testProcessPath
                $currentConfig.Arguments | Should Be $logFilePath
                $currentConfig.Ensure | Should Be 'Present'
                $currentConfig.ProcessCount | Should Be 1
            }

            It 'Should not create a logfile' {
                $pathResult = Test-Path $logFilePath
                $pathResult | Should Be $false
            }
        }

        Context 'Should stop the testProcess instance from running' {
            $configurationName = 'MSFT_xWindowsProcess_StopProcessesWithCredential'
            $configurationPath = Join-Path -Path $TestDrive -ChildPath $configurationName

            It 'Should not have a logfile already present' {
                $pathResult = Test-Path $logFilePath
                $pathResult | Should Be $false
            }

            It 'Should compile without throwing' {
                {
                    .$configFile -ConfigurationName $configurationName
                    & $configurationName -Path $testProcessPath `
                                         -Arguments $logFilePath `
                                         -Ensure 'Absent' `
                                         -Credential $testCredential `
                                         -ErrorAction 'Stop' `
                                         -OutputPath $configurationPath `
                                         -ConfigurationData $ConfigData
                    Start-DscConfiguration -Path $configurationPath -ErrorAction 'Stop' -Wait -Force
                } | Should Not Throw
            }
       
            It 'Should be able to call Get-DscConfiguration without throwing' {
                { Get-DscConfiguration -ErrorAction 'Stop' } | Should Not Throw
            }

            It 'Should return the correct configuration' {
                $currentConfig = Get-DscConfiguration -ErrorAction 'Stop'
                $currentConfig.Path | Should Be $testProcessPath
                $currentConfig.Arguments | Should Be $logFilePath
                $currentConfig.Ensure | Should Be 'Absent'
            }

            It 'Should not create a logfile' {
                $pathResult = Test-Path $logFilePath
                $pathResult | Should Be $false
            }
        }

        Context 'Should return correct amount of processes running when more than 1 are running' {
            $configurationName = 'MSFT_xWindowsProcess_StartMultipleProcessesWithCredential'
            $configurationPath = Join-Path -Path $TestDrive -ChildPath $configurationName

            It 'Should not have a logfile already present' {
                $pathResult = Test-Path $logFilePath
                $pathResult | Should Be $false
            }

            It 'Should compile without throwing' {
                {
                    .$configFile -ConfigurationName $configurationName
                    & $configurationName -Path $testProcessPath `
                                         -Arguments $logFilePath `
                                         -Ensure 'Present' `
                                         -ErrorAction 'Stop' `
                                         -Credential $testCredential `
                                         -OutputPath $configurationPath `
                                         -ConfigurationData $ConfigData
                    Start-DscConfiguration -Path $configurationPath -ErrorAction 'Stop' -Wait -Force
                } | Should Not Throw
            }

            It 'Should start another process running' {
                Start-Process -FilePath $testProcessPath -ArgumentList @($logFilePath)
            }
       
            It 'Should be able to call Get-DscConfiguration without throwing' {
                { Get-DscConfiguration -ErrorAction 'Stop' } | Should Not Throw
            }

            It 'Should return the correct configuration' {
                $currentConfig = Get-DscConfiguration -ErrorAction 'Stop'
                $currentConfig.Path | Should Be $testProcessPath
                $currentConfig.Arguments | Should Be $logFilePath
                $currentConfig.Ensure | Should Be 'Present'
                $currentConfig.ProcessCount | Should Be 2
            }

            It 'Should create a logfile' {
                $pathResult = Test-Path $logFilePath
                $pathResult | Should Be $true
            }
        }

        Context 'Should stop all of the testProcess instances from running' {
            $configurationName = 'MSFT_xWindowsProcess_StopAllProcessesWithCredential'
            $configurationPath = Join-Path -Path $TestDrive -ChildPath $configurationName

            It 'Should have a logfile already present' {
                $pathResult = Test-Path $logFilePath
                $pathResult | Should Be $true
            }

            It 'Should not throw when removing the log file' {
                { Remove-Item -Path $logFilePath } | Should not Throw
            }

            It 'Should compile without throwing' {
                {
                    if (Test-Path -Path $logFilePath)
                    {
                        Remove-Item -Path $logFilePath
                    }

                    .$configFile -ConfigurationName $configurationName
                    & $configurationName -Path $testProcessPath `
                                         -Arguments $logFilePath `
                                         -Ensure 'Absent' `
                                         -Credential $testCredential `
                                         -ErrorAction 'Stop' `
                                         -OutputPath $configurationPath `
                                         -ConfigurationData $ConfigData
                    Start-DscConfiguration -Path $configurationPath -ErrorAction 'Stop' -Wait -Force
                } | Should Not Throw
            }
       
            It 'Should be able to call Get-DscConfiguration without throwing' {
                { Get-DscConfiguration -ErrorAction 'Stop' } | Should Not Throw
            }

            It 'Should return the correct configuration' {
                $currentConfig = Get-DscConfiguration -ErrorAction 'Stop'
                $currentConfig.Path | Should Be $testProcessPath
                $currentConfig.Arguments | Should Be $logFilePath
                $currentConfig.Ensure | Should Be 'Absent'
            }
        }
    }
}
finally
{
    Exit-DscResourceTestEnvironment -TestEnvironment $script:testEnvironment
}
