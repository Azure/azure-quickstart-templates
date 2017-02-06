$errorActionPreference = 'Stop'
Set-StrictMode -Version 'Latest'

# Import CommonTestHelper for Enter-DscResourceTestEnvironment, Exit-DscResourceTestEnvironment
$script:testsFolderFilePath = Split-Path $PSScriptRoot -Parent
$script:commonTestHelperFilePath = Join-Path -Path $testsFolderFilePath -ChildPath 'CommonTestHelper.psm1'
Import-Module -Name $commonTestHelperFilePath

$script:testEnvironment = Enter-DscResourceTestEnvironment `
    -DscResourceModuleName 'xPSDesiredStateConfiguration' `
    -DscResourceName 'xProcessSet' `
    -TestType 'Integration'

try
{
    Describe 'xProcessSet Integration Tests' {
        BeforeAll {
            $script:configurationFilePath = Join-Path -Path $PSScriptRoot -ChildPath 'xProcessSet.config.ps1'

            $originalProcessPath = Join-Path -Path $script:testsFolderFilePath -ChildPath 'WindowsProcessTestProcessSet.exe'
            $copiedProcessPath = Join-Path -Path $TestDrive -ChildPath 'TestWindowsProcess2.exe'

            Copy-Item -Path $originalProcessPath -Destination $copiedProcessPath -Force

            $script:processPaths = @( $originalProcessPath, $copiedProcessPath)
        }

        AfterAll {
            foreach ($processPath in $script:processPaths)
            {
                $processName = [System.IO.Path]::GetFileNameWithoutExtension($processPath)
                $process = Get-Process -Name $processName -ErrorAction 'SilentlyContinue'

                if ($null -ne $process)
                {
                    Stop-Process -Name $processName -ErrorAction 'SilentlyContinue' -Force
                }
            }
        }

        Context 'Start two processes' {
            $configurationName = 'StartProcessSet'

            $processSetParameters = @{
                ProcessPaths = $script:processPaths
                Ensure = 'Present'
            }

            foreach ($processPath in $processSetParameters.ProcessPaths)
            {
                $processName = [System.IO.Path]::GetFileNameWithoutExtension($processPath)
                $process = Get-Process -Name $processName -ErrorAction 'SilentlyContinue'

                if ($null -ne $process)
                {
                    $null = Stop-Process -Name $processName -ErrorAction 'SilentlyContinue' -Force

                    # May need to wait a moment for the correct state to populate
                    $millisecondsElapsed = 0
                    $startTime = Get-Date
                    while ($null -eq $process -and $millisecondsElapsed -lt 3000)
                    {
                        $process = Get-Process -Name $processName -ErrorAction 'SilentlyContinue'
                        $millisecondsElapsed = ((Get-Date) - $startTime).TotalMilliseconds
                    }
                }

                It "Should not have started process $processName before configuration" {
                    $process | Should Be $null
                }
            }

            It 'Should compile and run configuration' {
                { 
                    . $script:configurationFilePath -ConfigurationName $configurationName
                    & $configurationName -OutputPath $TestDrive @processSetParameters
                    Start-DscConfiguration -Path $TestDrive -ErrorAction 'Stop' -Wait -Force
                } | Should Not Throw
            }

            foreach ($processPath in $processSetParameters.ProcessPaths)
            {
                $processName = [System.IO.Path]::GetFileNameWithoutExtension($processPath)
                $process = Get-Process -Name $processName -ErrorAction 'SilentlyContinue'

                It "Should have started process $processName after configuration" {
                    $process | Should Not Be $null
                }
            }
        }

        Context 'Stop two processes' {
            $configurationName = 'StopProcessSet'

            $processSetParameters = @{
                ProcessPaths = $script:processPaths
                Ensure = 'Absent'
            }

            foreach ($processPath in $processSetParameters.ProcessPaths)
            {
                $processName = [System.IO.Path]::GetFileNameWithoutExtension($processPath)
                $process = Get-Process -Name $processName -ErrorAction 'SilentlyContinue'

                if ($null -eq $process)
                {
                    $null = Start-Process -FilePath $processPath -ErrorAction 'SilentlyContinue'

                    # May need to wait a moment for the correct state to populate
                    $millisecondsElapsed = 0
                    $startTime = Get-Date
                    while ($null -eq $process -and $millisecondsElapsed -lt 3000)
                    {
                        $process = Get-Process -Name $processName -ErrorAction 'SilentlyContinue'
                        $millisecondsElapsed = ((Get-Date) - $startTime).TotalMilliseconds
                    }
                }

                It "Should have started process $processName before configuration" {
                    $process | Should Not Be $null
                }
            }

            It 'Should compile and run configuration' {
                { 
                    . $script:configurationFilePath -ConfigurationName $configurationName
                    & $configurationName -OutputPath $TestDrive @processSetParameters
                    Start-DscConfiguration -Path $TestDrive -ErrorAction 'Stop' -Wait -Force
                } | Should Not Throw
            }

            foreach ($processPath in $processSetParameters.ProcessPaths)
            {
                $processName = [System.IO.Path]::GetFileNameWithoutExtension($processPath)
                $process = Get-Process -Name $processName -ErrorAction 'SilentlyContinue'

                It "Should have stopped process $processName after configuration" {
                    $process | Should Be $null
                }
            }
        }
    }
}
finally
{
    Exit-DscResourceTestEnvironment -TestEnvironment $script:testEnvironment
}
