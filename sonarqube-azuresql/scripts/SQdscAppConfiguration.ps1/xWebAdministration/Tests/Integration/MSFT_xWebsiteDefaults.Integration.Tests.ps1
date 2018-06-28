
$script:DSCModuleName = 'xWebAdministration'
$script:DSCResourceName = 'MSFT_xWebsiteDefaults'

#region HEADER
$script:moduleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
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

[string]$tempName = "$($script:DSCResourceName)_" + (Get-Date).ToString("yyyyMMdd_HHmmss")

try
{
    $null = Backup-WebConfiguration -Name $tempName

    $ConfigFile = Join-Path -Path $PSScriptRoot -ChildPath "$($script:DSCResourceName).config.ps1"
    . $ConfigFile

    Describe "$($script:DSCResourceName)_Integration" {
        #region DEFAULT TESTS
        It 'Should compile without throwing' {
            {
                Invoke-Expression -Command "$($script:DSCResourceName)_Config -OutputPath `$TestDrive"
                Start-DscConfiguration -Path $TestDrive -ComputerName localhost -Wait -Verbose -Force
            } | Should not throw
        }

        It 'should be able to call Get-DscConfiguration without throwing' {
            { Get-DscConfiguration -Verbose -ErrorAction Stop } | Should Not throw
        }
        #endregion

        It 'Changing Default virtualDirectoryDefaults' -test {
            function GetSiteValue([string]$path,[string]$name)
            {
                return (Get-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST' -filter "system.applicationHost/sites/$path" -name $name).value
            }

            # get the current value

            [string] $originalValue = (Get-WebConfigurationProperty `
                -PSPath 'MACHINE/WEBROOT/APPHOST' `
                -Filter 'system.applicationHost/sites/virtualDirectoryDefaults' `
                -Name 'allowSubDirConfig').Value

            Invoke-Expression -Command "$($script:DSCResourceName)_Config -OutputPath `$TestDrive"
            Start-DscConfiguration -Path $TestDrive -ComputerName localhost -Wait -Verbose -Force

            $changedValue = (Get-WebConfigurationProperty -PSPath 'MACHINE/WEBROOT/APPHOST' -filter 'system.applicationHost/sites/virtualDirectoryDefaults' -name 'allowSubDirConfig').Value
            $changedValue | should be $env:PesterVirtualDirectoryDefaults
        }
    }
}
finally
{
    #region FOOTER
    Restore-WebConfiguration -Name $tempName
    Remove-WebConfigurationBackup -Name $tempName

    Restore-TestEnvironment -TestEnvironment $TestEnvironment
    #endregion
}
