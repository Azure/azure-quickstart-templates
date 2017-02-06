$errorActionPreference = 'Stop'
Set-StrictMode -Version 'Latest'

# Import CommonTestHelper for Enter-DscResourceTestEnvironment, Exit-DscResourceTestEnvironment
$script:testsFolderFilePath = Split-Path $PSScriptRoot -Parent
$script:commonTestHelperFilePath = Join-Path -Path $testsFolderFilePath -ChildPath 'CommonTestHelper.psm1'
Import-Module -Name $commonTestHelperFilePath

$script:testEnvironment = Enter-DscResourceTestEnvironment `
    -DscResourceModuleName 'xPSDesiredStateConfiguration' `
    -DscResourceName 'xWindowsOptionalFeatureSet' `
    -TestType 'Integration'

try
{
    Describe 'xWindowsOptionalFeatureSet Integration Tests' {
        BeforeAll {
            $script:confgurationFilePath = Join-Path -Path $PSScriptRoot -ChildPath 'xWindowsOptionalFeatureSet.config.ps1'

            $script:enabledStates = @( 'Enabled', 'EnablePending' )
            $script:disabledStates = @( 'Disabled', 'DisablePending' )

            $script:validFeatureNames = @( 'RSAT-RDS-Tools-Feature', 'Xps-Foundation-Xps-Viewer' )

            $script:originalFeatures = @{}

            foreach ($validFeatureName in $script:validFeatureNames)
            {
                $script:originalFeatures[$validFeatureName] = Dism\Get-WindowsOptionalFeature -FeatureName $validFeatureName -Online
            }
        }

        AfterAll {
            foreach ($validFeatureName in $script:originalFeatures.Keys)
            {
                $originalFeature = $script:originalFeatures[$validFeatureName]

                if ($null -ne $originalFeature)
                {
                    if ($originalFeature.State -in $script:disabledStates)
                    {
                        Dism\Disable-WindowsOptionalFeature -Online -FeatureName $validFeatureName -NoRestart
                    }
                    elseif ($originalFeature.State -in $script:enabledStates)
                    {
                        Dism\Enable-WindowsOptionalFeature -Online -FeatureName $windowsOptionalFeatureName -NoRestart
                    }
                }
            }
        }

        Context 'Install two valid Windows optional features' {
            $configurationName = 'InstallOptionalFeature'

            $wofSetParameters = @{
                WindowsOptionalFeatureNames = $script:validFeatureNames
                Ensure = 'Present'
                LogPath = Join-Path -Path $TestDrive -ChildPath 'InstallOptionalFeature.log'
            }

            foreach ($windowsOptionalFeatureName in $wofSetParameters.WindowsOptionalFeatureNames)
            {
                $windowsOptionalFeature = Dism\Get-WindowsOptionalFeature -Online -FeatureName $windowsOptionalFeatureName

                It "Should be able to retrieve Windows optional feature $windowsOptionalFeatureName before the configuration" {
                    $windowsOptionalFeature | Should Not Be $null
                }

                if ($windowsOptionalFeature.State -in $script:enabledStates)
                {
                    Dism\Disable-WindowsOptionalFeature -Online -FeatureName $windowsOptionalFeatureName -NoRestart
                    $windowsOptionalFeature = Dism\Get-WindowsOptionalFeature -Online -FeatureName $windowsOptionalFeatureName

                    # May need to wait a moment for the correct state to populate
                    $millisecondsElapsed = 0
                    $startTime = Get-Date
                    while (-not ($windowsOptionalFeature.State -in $script:disabledStates) -and $millisecondsElapsed -lt 3000)
                    {
                        $windowsOptionalFeature = Dism\Get-WindowsOptionalFeature -Online -FeatureName $windowsOptionalFeatureName
                        $millisecondsElapsed = ((Get-Date) - $startTime).TotalMilliseconds
                    }
                }

                It "Should have disabled Windows optional feature $windowsOptionalFeatureName before the configuration" {
                    $windowsOptionalFeature.State -in $script:disabledStates | Should Be $true
                }
            }

            It 'Should compile and run configuration' {
                { 
                    . $script:confgurationFilePath -ConfigurationName $configurationName
                    & $configurationName -OutputPath $TestDrive @wofSetParameters
                    Start-DscConfiguration -Path $TestDrive -ErrorAction 'Stop' -Wait -Force
                } | Should Not Throw
            }

            foreach ($windowsOptionalFeatureName in $wofSetParameters.WindowsOptionalFeatureNames)
            {
                $windowsOptionalFeature = Dism\Get-WindowsOptionalFeature -Online -FeatureName $windowsOptionalFeatureName

                It "Should be able to retrieve Windows optional feature $windowsOptionalFeatureName after the configuration" {
                    $windowsOptionalFeature | Should Not Be $null
                }

                # May need to wait a moment for the correct state to populate
                $millisecondsElapsed = 0
                $startTime = Get-Date
                while (-not ($windowsOptionalFeature.State -in $script:enabledStates) -and $millisecondsElapsed -lt 3000)
                {
                    $windowsOptionalFeature = Dism\Get-WindowsOptionalFeature -Online -FeatureName $windowsOptionalFeatureName
                    $millisecondsElapsed = ((Get-Date) - $startTime).TotalMilliseconds
                }

                It "Should have enabled Windows optional feature $windowsOptionalFeatureName after the configuration" {
                    $windowsOptionalFeature.State -in $script:enabledStates | Should Be $true
                }
            }
                
            It 'Should have created the log file' {
                Test-Path -Path $wofSetParameters.LogPath | Should Be $true
            }

            It 'Should have created content in the log file' {
                Get-Content -Path $wofSetParameters.LogPath -Raw | Should Not Be $null
            }
        }

        Context 'Uninstall two valid Windows optional features' {
            $configurationName = 'UninstallOptionalFeature'

            $wofSetParameters = @{
                WindowsOptionalFeatureNames = $script:validFeatureNames
                Ensure = 'Absent'
                LogPath = Join-Path -Path $TestDrive -ChildPath 'UninstallOptionalFeature.log'
            }

            foreach ($windowsOptionalFeatureName in $wofSetParameters.WindowsOptionalFeatureNames)
            {
                $windowsOptionalFeature = Dism\Get-WindowsOptionalFeature -Online -FeatureName $windowsOptionalFeatureName

                It "Should be able to retrieve Windows optional feature $windowsOptionalFeatureName before the configuration" {
                    $windowsOptionalFeature | Should Not Be $null
                }

                if ($windowsOptionalFeature.State -in $script:disabledStates)
                {
                    Dism\Enable-WindowsOptionalFeature -Online -FeatureName $windowsOptionalFeatureName -NoRestart
                    $windowsOptionalFeature = Dism\Get-WindowsOptionalFeature -Online -FeatureName $windowsOptionalFeatureName

                    # May need to wait a moment for the correct state to populate
                    $millisecondsElapsed = 0
                    $startTime = Get-Date
                    while (-not ($windowsOptionalFeature.State -in $script:enabledStates) -and $millisecondsElapsed -lt 3000)
                    {
                        $windowsOptionalFeature = Dism\Get-WindowsOptionalFeature -Online -FeatureName $windowsOptionalFeatureName
                        $millisecondsElapsed = ((Get-Date) - $startTime).TotalMilliseconds
                    }
                }

                It "Should have enabled Windows optional feature $windowsOptionalFeatureName before the configuration" {
                    $windowsOptionalFeature.State -in $script:enabledStates | Should Be $true
                }
            }

            It 'Should compile and run configuration' {
                { 
                    . $script:confgurationFilePath -ConfigurationName $configurationName
                    & $configurationName -OutputPath $TestDrive @wofSetParameters
                    Start-DscConfiguration -Path $TestDrive -ErrorAction 'Stop' -Wait -Force
                } | Should Not Throw
            }

            foreach ($windowsOptionalFeatureName in $wofSetParameters.WindowsOptionalFeatureNames)
            {
                $windowsOptionalFeature = Dism\Get-WindowsOptionalFeature -Online -FeatureName $windowsOptionalFeatureName

                It "Should be able to retrieve Windows optional feature $windowsOptionalFeatureName after the confguration" {
                    $windowsOptionalFeature | Should Not Be $null
                }

                # May need to wait a moment for the correct state to populate
                $millisecondsElapsed = 0
                $startTime = Get-Date
                while (-not ($windowsOptionalFeature.State -in $script:disabledStates) -and $millisecondsElapsed -lt 3000)
                {
                    $windowsOptionalFeature = Dism\Get-WindowsOptionalFeature -Online -FeatureName $windowsOptionalFeatureName
                    $millisecondsElapsed = ((Get-Date) - $startTime).TotalMilliseconds
                }

                It "Should have disabled Windows optional feature $windowsOptionalFeatureName after the confguration" {
                    $windowsOptionalFeature.State -in $script:disabledStates | Should Be $true
                }
            }
                
            It 'Should have created the log file' {
                Test-Path -Path $wofSetParameters.LogPath | Should Be $true
            }

            It 'Should have created content in the log file' {
                Get-Content -Path $wofSetParameters.LogPath -Raw | Should Not Be $null
            }
        }
    }
}
finally
{
    Exit-DscResourceTestEnvironment -TestEnvironment $script:testEnvironment
}
