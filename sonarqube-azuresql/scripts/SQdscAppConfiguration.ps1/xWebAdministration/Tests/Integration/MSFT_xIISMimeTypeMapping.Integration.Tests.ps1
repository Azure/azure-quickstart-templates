
$script:DSCModuleName      = 'xWebAdministration'
$script:DSCResourceName    = 'MSFT_xIISMimeTypeMapping'

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

# Using try/finally to always cleanup even if something awful happens.
try
{
    #region Integration Tests
    $ConfigFile = Join-Path -Path $PSScriptRoot -ChildPath "$($script:DSCResourceName).config.ps1"
    . $ConfigFile

    $null = Backup-WebConfiguration -Name $tempName

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

        It 'Adding an existing MimeType' {
            $node = (Get-WebConfigurationProperty -PSPath 'MACHINE/WEBROOT/APPHOST' -Filter "system.webServer/staticContent/mimeMap" -Name .) | Select-Object -First 1

            $env:PesterFileExtension2 = $node.fileExtension
            $env:PesterMimeType2 = $node.mimeType

            {
                Invoke-Expression -Command "$($script:DSCResourceName)_AddMimeType -OutputPath `$TestDrive"
                Start-DscConfiguration -Path $TestDrive -ComputerName localhost -Wait -Verbose -Force
            } | Should not throw

            [string] $filter = "system.webServer/staticContent/mimeMap[@fileExtension='" + $env:PesterFileExtension2 + "' and @mimeType='" + "$env:PesterMimeType2" + "']"
            $expected = ((Get-WebConfigurationProperty  -PSPath 'MACHINE/WEBROOT/APPHOST' -Filter $filter -Name .) | Measure-Object).Count

            $expected | should be 1
        }

        It 'Removing a MimeType' {
            $node = (Get-WebConfigurationProperty  -PSPath 'MACHINE/WEBROOT/APPHOST' -Filter "system.webServer/staticContent/mimeMap" -Name .) | Select-Object -First 1
            $env:PesterFileExtension = $node.fileExtension
            $env:PesterMimeType = $node.mimeType

            {
                Invoke-Expression -Command "$($script:DSCResourceName)_RemoveMimeType -OutputPath `$TestDrive"
                Start-DscConfiguration -Path $TestDrive -ComputerName localhost -Wait -Verbose -Force
            } | Should not throw

            [string] $filter = "system.webServer/staticContent/mimeMap[@fileExtension='" + $env:PesterFileExtension + "' and @mimeType='" + "$env:PesterMimeType" + "']"
            ((Get-WebConfigurationProperty  -PSPath 'MACHINE/WEBROOT/APPHOST' -Filter $filter -Name .) | Measure-Object).Count | should be 0
        }

        It 'Removing a non existing MimeType' {
            {
                Invoke-Expression -Command "$($script:DSCResourceName)_RemoveDummyMime -OutputPath `$TestDrive"
                Start-DscConfiguration -Path $TestDrive -ComputerName localhost -Wait -Verbose -Force
            } | Should not throw
        }
    }
    #endregion
}
finally
{
    #region FOOTER
    Restore-WebConfiguration -Name $tempName
    Remove-WebConfigurationBackup -Name $tempName

    Restore-TestEnvironment -TestEnvironment $TestEnvironment
    #endregion
}
