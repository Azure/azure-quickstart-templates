$script:DSCModuleName   = 'xNetworking'
$script:DSCResourceName = 'MSFT_xDnsClientGlobalSetting'

#region HEADER
# Integration Test Template Version: 1.1.0
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

# Backup the existing settings
$CurrentDnsClientGlobalSetting = Get-DnsClientGlobalSetting

# Using try/finally to always cleanup even if something awful happens.
try
{
    # Set the DNS Client Global settings to known values
    Set-DnsClientGlobalSetting `
        -SuffixSearchList 'fabrikam.com' `
        -UseDevolution $False `
        -DevolutionLevel 4

    #region Integration Tests
    $ConfigFile = Join-Path -Path $PSScriptRoot -ChildPath "$($script:DSCResourceName).config.ps1"
    . $ConfigFile

    Describe "$($script:DSCResourceName)_Integration" {
        #region DEFAULT TESTS
        It 'Should compile without throwing' {
            {
                & "$($script:DSCResourceName)_Config" -OutputPath $TestEnvironment.WorkingFolder
                Start-DscConfiguration -Path $TestEnvironment.WorkingFolder -ComputerName localhost -Wait -Verbose -Force
            } | Should not throw
        }

        It 'should be able to call Get-DscConfiguration without throwing' {
            { Get-DscConfiguration -Verbose -ErrorAction Stop } | Should Not throw
        }
        #endregion

        It 'Should have set the resource and all the parameters should match' {
            # Get the Rule details
            $DnsClientGlobalSettingNew = Get-DnsClientGlobalSetting
            $DnsClientGlobalSettingNew.SuffixSearchList | Should Be $DnsClientGlobalSetting.SuffixSearchList
            $DnsClientGlobalSettingNew.UseDevolution    | Should Be $DnsClientGlobalSetting.UseDevolution
            $DnsClientGlobalSettingNew.DevolutionLevel  | Should Be $DnsClientGlobalSetting.DevolutionLevel
        }
    }
    #endregion
}
finally
{
    # Clean up
    Set-DnsClientGlobalSetting `
        -SuffixSearchList $CurrentDnsClientGlobalSetting.SuffixSearchList `
        -UseDevolution $CurrentDnsClientGlobalSetting.UseDevolution `
        -DevolutionLevel $CurrentDnsClientGlobalSetting.DevolutionLevel

    #region FOOTER
    Restore-TestEnvironment -TestEnvironment $TestEnvironment
    #endregion
}
