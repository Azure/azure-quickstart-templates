[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingConvertToSecureStringWithPlainText', '')]
param()

$Script:DSCModuleName      = 'xActiveDirectory'
$Script:DSCResourceName    = 'MSFT_xADDomainController'

#region HEADER
[String] $script:moduleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
if ( (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests'))) -or `
     (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1'))) )
{
    & git @('clone','https://github.com/PowerShell/DscResource.Tests.git',(Join-Path -Path $script:moduleRoot -ChildPath '\DSCResource.Tests\'))
}

Import-Module (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1') -Force
$TestEnvironment = Initialize-TestEnvironment `
    -DSCModuleName $Script:DSCModuleName `
    -DSCResourceName $Script:DSCResourceName `
    -TestType Unit
#endregion

# Begin Testing
try
{
    #region Pester Test Initialization
    $correctDomainName   = 'present.com'
    $testAdminCredential = [System.Management.Automation.PSCredential]::Empty
    $correctDatabasePath = 'C:\Windows\NTDS'
    $correctLogPath      = 'C:\Windows\NTDS'
    $correctSysvolPath   = 'C:\Windows\SYSVOL'
    $correctSiteName     = 'PresentSite'
    $incorrectSiteName   = 'IncorrectSite'

    $testDefaultParams = @{
        DomainAdministratorCredential = $testAdminCredential
        SafemodeAdministratorPassword = $testAdminCredential
    }

    $commonMockParams = @{
        ModuleName = $Script:DSCResourceName
    }

    $commonAssertParams = @{
        ModuleName = $Script:DSCResourceName
        Scope = 'It'
        Exactly = $true
    }

    #Fake function because it is only available on Windows Server
    function Install-ADDSDomainController {
        param(
            $DomainName, $SafeModeAdministratorPassword, $Credential, $NoRebootOnCompletion, $Force, $DatabasePath,
            $LogPath, $SysvolPath, $SiteName
        )

        throw [exception] 'Not Implemented'
    }
    #endregion Pester Test Initialization

    #region Function Get-TargetResource
    Describe -Tag 'xADDomainController' "$($Script:DSCResourceName)\Get-TargetResource" {

        Mock Get-ADDomain { return $true } @commonMockParams
        Mock Get-ADDomainController {
            return $stubDomainController = @{
                Site = 'PresentSite'
                Domain = 'present.com'
            }
        } @commonMockParams
        Mock Get-ItemProperty -ParameterFilter { $Path -eq 'HKLM:\SYSTEM\CurrentControlSet\Services\NTDS\Parameters' } {
            return @{
                'Database log files path' = 'C:\Windows\NTDS'
                'DSA Working Directory'   = 'C:\Windows\NTDS'
            }
        } @commonMockParams
        Mock Get-ItemProperty -ParameterFilter { $Path -eq 'HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters' } {
            return @{
                'SysVol' = 'C:\Windows\SYSVOL\sysvol'
            }
        } @commonMockParams

        It 'Returns current "DatabasePath"' {
            $result = Get-TargetResource @testDefaultParams -DomainName $correctDomainName
            $result.DatabasePath | Should Be $correctDatabasePath
        }

        It 'Returns current "LogPath"' {
            $result = Get-TargetResource @testDefaultParams -DomainName $correctDomainName
            $result.LogPath | Should Be $correctLogPath
        }

        It 'Returns current "SysvolPath"' {
            $result = Get-TargetResource @testDefaultParams -DomainName $correctDomainName
            $result.SysvolPath | Should Be $correctSysvolPath
        }

        It 'Returns current "SiteName"' {
            $result = Get-TargetResource @testDefaultParams -DomainName $correctDomainName
            $result.SiteName | Should Be $correctSiteName
        }
    }
    #endregion

    #region Function Test-TargetResource
    Describe -Tag 'xADDomainController' "$($Script:DSCResourceName)\Test-TargetResource" {
        InModuleScope $Script:DSCResourceName {
            $correctSiteName = 'PresentSite'
            $incorrectSiteName = 'IncorrectSite'
            $correctDomainName = 'present.com'
            $testAdminCredential = [System.Management.Automation.PSCredential]::Empty

            $testDefaultParams = @{
                DomainAdministratorCredential = $testAdminCredential
                SafemodeAdministratorPassword = $testAdminCredential
            }

            It 'Returns "False" when "SiteName" does not match' {
                $stubDomain = @{
                    DNSRoot = $correctDomainName
                }

                $stubDomainController = @{
                    Site = $incorrectSiteName
                    Domain = $correctDomainName
                }

                Mock Get-ADDomain { return $true }
                Mock Get-ADDomainController { return $stubDomainController }
                Mock Test-ADReplicationSite { return $true }
                Mock Get-ItemProperty { return @{} }

                $result = Test-TargetResource @testDefaultParams -DomainName $correctDomainName -SiteName $correctSiteName

                $result | Should Be $false
            }

            It 'Returns "True" when "SiteName" matches' {

                $stubDomainController = @{
                    Site = $correctSiteName
                    Domain = $correctDomainName
                }

                Mock Get-ADDomain { return $true }
                Mock Get-ADDomainController { return $stubDomainController }
                Mock Test-ADReplicationSite { return $true }
                Mock Get-ItemProperty { return @{} }

                $result = Test-TargetResource @testDefaultParams -DomainName $correctDomainName -SiteName $correctSiteName

                $result | Should Be $true
            }

            It 'Throws if "SiteName" is wrong' {

                $stubDomainController = @{
                    Site = $correctSiteName
                    Domain = $correctDomainName
                }

                Mock Get-ADDomain { return $true }
                Mock Get-ADDomainController { return $stubDomainController }
                Mock Test-ADReplicationSite { return $false }
                { Test-TargetResource @testDefaultParams -DomainName $correctDomainName -SiteName $incorrectSiteName } |
                    Should Throw "Site '$($incorrectSiteName)' could not be found."
            }
        }
    }
    #endregion

    #region Function Set-TargetResource
    Describe -Tag 'xADDomainController' "$($Script:DSCResourceName)\Set-TargetResource" {
        It 'Calls "Install-ADDSDomainController" with "Site", if specified' {
            Mock Get-ADDomain {
                return $true
            } @commonMockParams

            Mock Get-TargetResource {
                return $stubTargetResource = @{
                    Ensure = $false
                }
            } @commonMockParams
            Mock Install-ADDSDomainController -MockWith {} -ParameterFilter { $SiteName -eq $correctSiteName } @commonMockParams

            Set-TargetResource @testDefaultParams -DomainName $correctDomainName -SiteName $correctSiteName

            Assert-MockCalled Install-ADDSDomainController -Times 1 -ParameterFilter { $SiteName -eq $correctSiteName } @commonAssertParams
        }

        It 'Calls "Move-ADDirectoryServer" when "SiteName" does not match' {
            Mock Get-TargetResource {
                return $stubTargetResource = @{
                    Ensure = $true
                    SiteName = 'IncorrectSite'
                }
            } @commonMockParams

            Mock Move-ADDirectoryServer -MockWith {} -ParameterFilter { $Site.ToString() -eq $correctSiteName } @commonMockParams
            Mock Move-ADDirectoryServer -MockWith {} @commonMockParams

            Set-TargetResource @testDefaultParams -DomainName $correctDomainName -SiteName $correctSiteName

            Assert-MockCalled Move-ADDirectoryServer -Times 1 -ParameterFilter { $Site.ToString() -eq $correctSiteName } @commonAssertParams
        }

        It 'Does not call "Move-ADDirectoryServer" when "SiteName" matches' {
            Mock Get-TargetResource {
                return $stubTargetResource = @{
                    Ensure = $true
                    SiteName = 'PresentSite'
                }
            } @commonMockParams

            Mock Move-ADDirectoryServer {} @commonMockParams

            Set-TargetResource @testDefaultParams -DomainName $correctDomainName -SiteName $correctSiteName

            Assert-MockCalled Move-ADDirectoryServer -Times 0 @commonAssertParams
        }

        It 'Does not call "Move-ADDirectoryServer" when "SiteName" is not specified' {
            Mock Get-TargetResource {
                return $stubTargetResource = @{
                    Ensure = $true
                    SiteName = 'PresentSite'
                }
            } @commonMockParams

            Mock Move-ADDirectoryServer {} @commonMockParams

            Set-TargetResource @testDefaultParams -DomainName $correctDomainName

            Assert-MockCalled Move-ADDirectoryServer -Times 0 @commonAssertParams
        }
    }
    #endregion
}
finally
{
    #region FOOTER

    Restore-TestEnvironment -TestEnvironment $TestEnvironment

    #endregion
}
