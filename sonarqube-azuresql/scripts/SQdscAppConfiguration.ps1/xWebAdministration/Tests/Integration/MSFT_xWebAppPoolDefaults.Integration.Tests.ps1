
$script:DSCModuleName      = 'xWebAdministration'
$script:DSCResourceName    = 'MSFT_xWebAppPoolDefaults'

#region HEADER

# Integration Test Template Version: 1.1.0
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

[string] $tempName = "$($script:DSCResourceName)_" + (Get-Date).ToString("yyyyMMdd_HHmmss")

# Using try/finally to always cleanup even if something awful happens.
try
{
    #region Integration Tests

    # some constants
    [string]$constPsPath = 'MACHINE/WEBROOT/APPHOST'
    [string]$constAPDFilter = 'system.applicationHost/applicationPools/applicationPoolDefaults'
    [string]$constSiteFilter = 'system.applicationHost/sites/'

    $ConfigFile = Join-Path -Path $PSScriptRoot -ChildPath "$($script:DSCResourceName).config.ps1"
    . $ConfigFile

    $null = Backup-WebConfiguration -Name $tempName

    function Get-SiteValue([string]$path,[string]$name)
    {
        return (Get-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST' -filter "system.applicationHost/sites/$path" -name $name).value
    }

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

        It 'Changing ManagedRuntimeVersion' {
            {
                # get the current value
                [string] $originalValue = (Get-WebConfigurationProperty -pspath $constPsPath -filter $constAPDFilter -name managedRuntimeVersion)

                # We are using environment variables here, because a inline PowerShell variable was empty after executing  Start-DscConfiguration

                # change the value to something else
                if ($originalValue -eq 'v4.0')
                {
                    $env:PesterManagedRuntimeVersion =  'v2.0'
                }
                else
                {
                    $env:PesterManagedRuntimeVersion =  'v4.0'
                }

                Invoke-Expression -Command "$($script:DSCResourceName)_ManagedRuntimeVersion -OutputPath `$TestDrive"
                Start-DscConfiguration -Path $TestDrive -ComputerName localhost -Wait -Verbose -Force
            }  | should not throw

            # get the configured value again
            $changedValue = (Get-WebConfigurationProperty -pspath $constPsPath -filter $constAPDFilter -name managedRuntimeVersion).Value

            # compare it to the one we just tried to set.
            $changedValue | should be $env:PesterManagedRuntimeVersion
        }

        It 'Changing IdentityType' {
            # get the current value
            [string] $originalValue = (Get-WebConfigurationProperty `
                -PSPath $constPsPath `
                -Filter $constAPDFilter/processModel `
                -Name identityType)

            if ($originalValue -eq 'ApplicationPoolIdentity')
            {
                $env:PesterApplicationPoolIdentity = 'LocalService'
            }
            else
            {
                $env:PesterApplicationPoolIdentity = 'ApplicationPoolIdentity'
            }

            # Compile the MOF File
            {
                Invoke-Expression -Command "$($script:DSCResourceName)_AppPoolIdentityType -OutputPath `$TestDrive"
                Start-DscConfiguration -Path $TestDrive -ComputerName localhost -Wait -Verbose -Force
            } | Should not throw

            $changedValue = (Get-WebConfigurationProperty -PSPath $constPsPath -Filter $constAPDFilter/processModel -Name identityType)

            $changedValue | Should Be $env:PesterApplicationPoolIdentity
        }


        It 'Changing LogFormat' {
            [string] $originalValue = Get-SiteValue 'logFile' 'logFormat'

            if ($originalValue -eq 'W3C')
            {
                $env:PesterLogFormat =  'IIS'
            }
            else
            {
                $env:PesterLogFormat =  'W3C'
            }

            # Compile the MOF File
            {
                Invoke-Expression -Command "$($script:DSCResourceName)_LogFormat -OutputPath `$TestDrive"
                Start-DscConfiguration -Path $TestDrive -ComputerName localhost -Wait -Verbose -Force
            } | Should not throw

            $changedValue = Get-SiteValue 'logFile' 'logFormat'

            $changedValue | Should Be $env:PesterALogFormat
        }

        It 'Changing Default AppPool' {
            # get the current value

            [string] $originalValue = Get-SiteValue 'applicationDefaults' 'applicationPool'

            $env:PesterDefaultPool =  'DefaultAppPool'
            # Compile the MOF File
            {
                Invoke-Expression -Command "$($script:DSCResourceName)_DefaultPool -OutputPath `$TestDrive"
                Start-DscConfiguration -Path $TestDrive -ComputerName localhost -Wait -Verbose -Force
            } | Should not throw

            $changedValue = Get-SiteValue 'applicationDefaults' 'applicationPool'
            $changedValue | should be $env:PesterDefaultPool
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
