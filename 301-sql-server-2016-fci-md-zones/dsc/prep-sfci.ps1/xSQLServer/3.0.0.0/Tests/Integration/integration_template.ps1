<#
.Synopsis
   Template for creating DSC Resource Integration Tests
.DESCRIPTION
   To Use:
     1. Copy to \Tests\Integration\ folder and rename <ResourceName>.Integration.tests.ps1 (e.g. MSFT_xNeworking.Integration.tests.ps1)
     2. Customize TODO sections.
     3. Create test DSC Configurtion file <ResourceName>.config.ps1 (e.g. MSFT_xNeworking.config.ps1) from integration_config_template.ps1 file.

.NOTES
   Code in HEADER, FOOTER and DEFAULT TEST regions are standard and may be moved into
   DSCResource.Tools in Future and therefore should not be altered if possible.
#>

# TODO: Customize these parameters...
$script:DSCModuleName      = '<ModuleName>' # Example xNetworking
$script:DSCResourceName    = '<ResourceName>' # Example MSFT_xFirewall
# /TODO

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

# TODO: Other Init Code Goes Here...

# Using try/finally to always cleanup even if something awful happens.
try
{
    #region Integration Tests
    $ConfigFile = Join-Path -Path $PSScriptRoot -ChildPath "$($script:DSCResourceName).config.ps1"
    . $ConfigFile

    Describe "$($script:DSCResourceName)_Integration" {
        #region DEFAULT TESTS
        It 'Should compile without throwing' {
            {
                Invoke-Expression -Command "$($script:DSCResourceName)_Config -OutputPath `$TestEnvironment.WorkingFolder"
                Start-DscConfiguration -Path $TestEnvironment.WorkingFolder `
                    -ComputerName localhost -Wait -Verbose -Force
            } | Should not throw
        }

        It 'should be able to call Get-DscConfiguration without throwing' {
            { Get-DscConfiguration -Verbose -ErrorAction Stop } | Should Not throw
        }
        #endregion

        It 'Should have set the resource and all the parameters should match' {
            # TODO: Validate the Config was Set Correctly Here...
        }
    }
    #endregion

}
finally
{
    #region FOOTER

    Restore-TestEnvironment -TestEnvironment $TestEnvironment

    #endregion

    # TODO: Other Optional Cleanup Code Goes Here...
}
