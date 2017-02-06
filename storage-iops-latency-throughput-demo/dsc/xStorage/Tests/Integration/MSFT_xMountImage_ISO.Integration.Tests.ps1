# In order to run these tests, a basic ISO file called 'test.iso' must be put
# in the same folder as this file. The ISO file must be a valid ISO file that can
# normally be mounted. If the test.iso file is not found the tests will not run.
# The ISO is not included with this repository because of size contstraints.
# It is up to the user or mechanism running these tests to put a valid 'test.iso'
# into this folder.
$script:DSCModuleName      = 'xStorage'
$script:DSCResourceName    = 'MSFT_xMountImage'

#region HEADER
# Integration Test Template Version: 1.1.1
[String] $script:moduleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
if ( (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests'))) -or `
     (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1'))) )
{
    & git @('clone','https://github.com/PowerShell/DscResource.Tests.git',(Join-Path -Path $script:moduleRoot -ChildPath '\DSCResource.Tests\'))
}

Import-Module (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1') -Force
$TestEnvironment = Initialize-TestEnvironment `
    -DSCModuleName $script:DSCModuleName `
    -DSCResourceName $script:DSCResourceName `
    -TestType Integration
#endregion

# Using try/finally to always cleanup even if something awful happens.
try
{
    #region Integration Tests for ISO
    $ISOPath = Join-Path -Path $PSScriptRoot -ChildPath 'test.iso'

    # Ensure that the ISO tests can be performed on this computer
    if (-not (Test-Path -Path $ISOPath))
    {
        Write-Verbose -Message "$($script:DSCResourceName) integration tests cannot be run because the ISO File '$ISOPath' is not available." -Verbose
        Return
    } # if

    # Get a spare drive letter
    $LastDrive = ((Get-Volume).DriveLetter | Sort-Object | Select-Object -Last 1)
    $DriveLetter = [char](([int][char]$LastDrive)+1)

    # Create a config data object to pass to the DSC Configs
    $ConfigData = @{
        AllNodes = @(
            @{
                NodeName    = 'localhost'
                ImagePath   = $ISOPath
                DriveLetter = $DriveLetter
            }
        )
    }

    # Mount ISO
    $ConfigFile = Join-Path -Path $PSScriptRoot -ChildPath "$($script:DSCResourceName)_mount.config.ps1"
    . $ConfigFile -Verbose -ErrorAction Stop

    Describe "$($script:DSCResourceName)_MountISO_Integration" {
        Context 'Mount an ISO and assign a Drive Letter' {
            #region DEFAULT TESTS
            It 'Should compile without throwing' {
                {
                    & "$($script:DSCResourceName)_Mount_Config" `
                        -OutputPath $TestDrive `
                        -ConfigurationData $ConfigData
                    Start-DscConfiguration -Path $TestDrive `
                        -ComputerName localhost -Wait -Verbose -Force
                } | Should not throw
            }

            It 'should be able to call Get-DscConfiguration without throwing' {
                { Get-DscConfiguration -Verbose -ErrorAction Stop } | Should Not throw
            }
            #endregion

            It 'Should have set the resource and all the parameters should match' {
                $current = Get-DscConfiguration | Where-Object {
                    $_.ConfigurationName -eq "$($script:DSCResourceName)_Mount_Config"
                }
                $current.Imagepath        | Should Be $ISOPath
                $current.DriveLetter      | Should Be $DriveLetter
                $current.StorageType      | Should Be 'ISO'
                $current.Access           | Should Be 'ReadOnly'
                $current.Ensure           | Should Be 'Present'
            }
        }
    }

    # Dismount ISO
    $ConfigFile = Join-Path -Path $PSScriptRoot -ChildPath "$($script:DSCResourceName)_dismount.config.ps1"
    . $ConfigFile -Verbose -ErrorAction Stop

    Describe "$($script:DSCResourceName)_DismountISO_Integration" {
        Context 'Dismount a previously mounted ISO' {
            #region DEFAULT TESTS
            It 'Should compile without throwing' {
                {
                    & "$($script:DSCResourceName)_Dismount_Config" `
                        -OutputPath $TestDrive `
                        -ConfigurationData $ConfigData
                    Start-DscConfiguration -Path $TestDrive `
                        -ComputerName localhost -Wait -Verbose -Force
                } | Should not throw
            }

            It 'should be able to call Get-DscConfiguration without throwing' {
                { Get-DscConfiguration -Verbose -ErrorAction Stop } | Should Not throw
            }
            #endregion

            It 'Should have set the resource and all the parameters should match' {
                $current = Get-DscConfiguration | Where-Object {
                    $_.ConfigurationName -eq "$($script:DSCResourceName)_Dismount_Config"
                }
                $current.Imagepath        | Should Be $ISOPath
                $current.Ensure           | Should Be 'Absent'
            }
        }
    }
    #endregion Integration Tests for ISO
}
finally
{
    #region FOOTER
    Restore-TestEnvironment -TestEnvironment $TestEnvironment
    #endregion
}
