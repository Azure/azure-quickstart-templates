$script:DSCModuleName   = 'xWebAdministration'
$script:DSCResourceName = 'MSFT_xSSLSettings'

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

[String] $tempName = "$($script:DSCResourceName)_" + (Get-Date).ToString('yyyyMMdd_HHmmss')

try
{
    $null = Backup-WebConfiguration -Name $tempName
    
    # Now that xWebAdministration should be discoverable load the configuration data
    $configFile = Join-Path -Path $PSScriptRoot -ChildPath "$($script:DSCResourceName).config.ps1"
    . $configFile

    $DSCConfig = Import-LocalizedData -BaseDirectory $PSScriptRoot -FileName "$($script:DSCResourceName).config.psd1"

    #region HelperFunctions

    # Function needed to test SslFlags
    function Get-SslFlags
    {
        [CmdletBinding()]
        param
        (
            [Parameter(Mandatory = $true)]
            [String] $Website

        )
        
        Get-WebConfiguration `
                -PSPath IIS:\Sites `
                -Location "$Website" `
                -Filter 'system.webserver/security/access' | `
                 ForEach-Object { $_.sslFlags }
    }

    #endregion

    # Create a new website for the SSLSettings

    New-Website -Name $DSCConfig.AllNodes.Website `
        -Id 200 `
        -PhysicalPath $DSCConfig.AllNodes.PhysicalPath `
        -ApplicationPool $DSCConfig.AllNodes.AppPool `
        -SslFlags $DSCConfig.AllNodes.SslFlags `
        -Port $DSCConfig.AllNodes.HTTPSPort `
        -IPAddress '*' `
        -HostHeader $DSCConfig.AllNodes.HTTPSHostname `
        -Ssl `
        -Force `
        -ErrorAction Stop

    Describe "$($script:DSCResourceName)_Present" {
        #region DEFAULT TESTS
        It 'Should compile without throwing' {
            {
                Invoke-Expression -Command "$($script:DSCResourceName)_Present -ConfigurationData `$DSCConfig -OutputPath `$TestDrive"
                Start-DscConfiguration -Path $TestDrive -ComputerName localhost -Wait -Verbose -Force
            } | Should not throw
        }

        It 'should be able to call Get-DscConfiguration without throwing' {
            { Get-DscConfiguration -Verbose -ErrorAction Stop } | Should Not throw
        }
        #endregion

        It 'Should add SSLBindings to a Website' -test {
            
            Invoke-Expression -Command "$($script:DSCResourceName)_Present -ConfigurationData `$DSCConfg  -OutputPath `$TestDrive"
           
            # Test SslFlags
            Get-SslFlags -Website $DSCConfig.AllNodes.Website | Should Be $DSCConfig.AllNodes.Bindings
            
            }

    }

    Describe "$($script:DSCResourceName)_Absent" {
        #region DEFAULT TESTS
        It 'Should compile without throwing' {
            {
                Invoke-Expression -Command "$($script:DSCResourceName)_Absent -ConfigurationData `$DSCConfig -OutputPath `$TestDrive"
                Start-DscConfiguration -Path $TestDrive -ComputerName localhost -Wait -Verbose -Force
            } | Should not throw
        }

        It 'should be able to call Get-DscConfiguration without throwing' {
            { Get-DscConfiguration -Verbose -ErrorAction Stop } | Should Not throw
        }
        #endregion
        
        It 'Should remove SSLBindings from a Website' -test {
            
            Invoke-Expression -Command "$($script:DSCResourceName)_Absent -ConfigurationData `$DSCConfg  -OutputPath `$TestDrive"

            # Test SslFlags
            Get-SslFlags -Website $DSCConfig.AllNodes.Website | Should BeNullOrEmpty
            
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
