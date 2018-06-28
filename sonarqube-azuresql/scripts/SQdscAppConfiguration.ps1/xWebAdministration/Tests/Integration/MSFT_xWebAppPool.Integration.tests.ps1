#requires -Version 4.0

$script:DSCModuleName   = 'xWebAdministration'
$script:DSCResourceName = 'MSFT_xWebAppPool'

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

# Test Setup
if ((Get-Service -Name 'W3SVC').Status -ne 'Running')
{
    Start-Service -Name 'W3SVC'
}

$tempBackupName = "$($script:DSCResourceName)_$(Get-Date -Format 'yyyyMMdd_HHmmss')"

# Using try/finally to always cleanup even if something awful happens.

try
{
    # Create configuration backup
    
    Backup-WebConfiguration -Name $tempBackupName | Out-Null

    #region Integration Tests

    $ConfigFile = Join-Path -Path $PSScriptRoot -ChildPath "$($script:DSCResourceName).config.ps1"
    . $ConfigFile

    Describe "$($script:DSCResourceName)_Integration" {

        #region Default Tests

        It 'Should be able to compile and apply without throwing' {
            {
                Invoke-Expression -Command (
                    '{0}_Config -OutputPath $TestDrive -ConfigurationData $ConfigData -ErrorAction Stop' -f
                    $script:DSCResourceName
                )

                Start-DscConfiguration -Path $TestDrive -ComputerName localhost -Force -Wait -Verbose
            } | Should Not Throw
        }

        It 'Should be able to call Get-DscConfiguration without throwing' {
            {
                Get-DscConfiguration -Verbose -ErrorAction Stop
            } | Should Not Throw
        }

        #endregion

        It 'Should have set the resource and all the parameters should match' {

            $currentConfiguration = Get-DscConfiguration

            foreach ($parameter in $TestParameters.GetEnumerator())
            {
                Write-Verbose -Message "The $($parameter.Name) property should be set."

                if ($parameter.Name -eq 'Credential')
                {
                    $appPool = Get-WebConfiguration -Filter '/system.applicationHost/applicationPools/add' |
                        Where-Object -FilterScript {$_.name -eq $TestParameters['Name']}

                    $appPool.processModel.userName |
                    Should Be $TestParameters['Credential'].UserName

                    $appPool.processModel.password |
                    Should Be $TestParameters['Credential'].GetNetworkCredential().Password
                }
                else
                {
                    $currentConfiguration."$($parameter.Name)" |
                    Should Be $TestParameters[$parameter.Name]
                }
            }

        }

        It 'Actual configuration should match the desired configuration' {
            Test-DscConfiguration -Verbose | Should Be $true
        }

    }

    #endregion
}
finally
{
    #region FOOTER
    Restore-WebConfiguration -Name $tempBackupName
    Remove-WebConfigurationBackup -Name $tempBackupName

    Restore-TestEnvironment -TestEnvironment $TestEnvironment
    #endregion
}
