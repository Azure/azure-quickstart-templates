$script:DSCModuleName   = 'xNetworking'
$script:DSCResourceName = 'MSFT_xNetBIOS'

#region HEADER
# Unit Test Template Version: 1.1.0
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
    -TestType Unit
#endregion HEADER

# Begin Testing
try
{
    #region Pester Tests
    InModuleScope $script:DSCResourceName {

        $InterfaceAlias = (Get-NetAdapter -Physical | Select-Object -First 1).Name

        $MockNetadapterSettingsDefault = New-Object -TypeName CimInstance -ArgumentList 'Win32_NetworkAdapterConfiguration' | Add-Member -MemberType NoteProperty -Name TcpipNetbiosOptions -Value 0 -PassThru
        $MockNetadapterSettingsEnable = New-Object -TypeName CimInstance -ArgumentList 'Win32_NetworkAdapterConfiguration' | Add-Member -MemberType NoteProperty -Name TcpipNetbiosOptions -Value 1 -PassThru
        $MockNetadapterSettingsDisable = New-Object -TypeName CimInstance -ArgumentList 'Win32_NetworkAdapterConfiguration' | Add-Member -MemberType NoteProperty -Name TcpipNetbiosOptions -Value 2 -PassThru

        #region Function Get-TargetResource
        Describe "MSFT_xNetBIOS\Get-TargetResource" {

            Mock -CommandName Get-CimAssociatedInstance -MockWith {return $MockNetadapterSettingsDefault}

            It 'Returns a hashtable' {
                $targetResource = Get-TargetResource -InterfaceAlias $InterfaceAlias -Setting 'Default'
                $targetResource -is [System.Collections.Hashtable] | Should Be $true
            }

            It 'NetBIOS over TCP/IP numerical setting "0" should translate to "Default"' {
                $Result = Get-TargetResource -InterfaceAlias $InterfaceAlias -Setting 'Default'
                $Result.Setting | should be 'Default'
            }

            It 'NetBIOS over TCP/IP setting should return real value "Default", not parameter value "Enable"' {
                $Result = Get-TargetResource -InterfaceAlias $InterfaceAlias -Setting 'Enable'
                $Result.Setting | should be 'Default'
            }
        }
        #endregion


        #region Function Test-TargetResource
        Describe "MSFT_xNetBIOS\Test-TargetResource" {
            Context 'invoking with NetBIOS over TCP/IP set to default' {

                Mock -CommandName Get-CimAssociatedInstance -MockWith {return $MockNetadapterSettingsDefault}

                It 'should return true when value "Default" is set' {
                    Test-TargetResource -InterfaceAlias $InterfaceAlias -Setting 'Default' | Should Be $true
                }
                It 'should return false when value "Disable" is set' {
                    Test-TargetResource -InterfaceAlias $InterfaceAlias -Setting 'Disable' | Should Be $false
                }
            }

            Context 'invoking with NetBIOS over TCP/IP set to Disable' {

                Mock -CommandName Get-CimAssociatedInstance -MockWith {return $MockNetadapterSettingsDisable}

                It 'should return true when value "Disable" is set' {
                    Test-TargetResource -InterfaceAlias $InterfaceAlias -Setting 'Disable' | Should Be $true
                }
                It 'should return false when value "Enable" is set' {
                    Test-TargetResource -InterfaceAlias $InterfaceAlias -Setting 'Enable' | Should Be $false
                }
            }

            Context 'invoking with NetBIOS over TCP/IP set to Enable' {

                Mock -CommandName Get-CimAssociatedInstance -MockWith {return $MockNetadapterSettingsEnable}

                It 'should return true when value "Enable" is set' {
                    Test-TargetResource -InterfaceAlias $InterfaceAlias -Setting 'Enable' | Should Be $true
                }
                It 'should return false when value "Disable" is set' {
                    Test-TargetResource -InterfaceAlias $InterfaceAlias -Setting 'Disable' | Should Be $false
                }
            }

            Context 'Invoking with NonExisting Network Adapter' {
                Mock -CommandName Get-CimAssociatedInstance -MockWith { }
                $ErrorRecord = New-Object System.Management.Automation.ErrorRecord 'Interface BogusAdapter was not found.', 'NICNotFound', 'ObjectNotFound', $null
                It 'should throw ObjectNotFound exception' {
                    {Test-TargetResource -InterfaceAlias 'BogusAdapter' -Setting 'Enable'} | Should Throw $ErrorRecord
                }
            }
        }
        #endregion


        #region Function Set-TargetResource
        Describe "MSFT_xNetBIOS\Set-TargetResource" {
            Mock Set-ItemProperty
            Mock Invoke-CimMethod

            Context '"Setting" is "Default"' {

                Mock -CommandName Get-CimAssociatedInstance -MockWith {return $MockNetadapterSettingsEnable}

                It 'Should call "Set-ItemProperty" instead of "Invoke-CimMethod"' {
                    $Null = Set-TargetResource -InterfaceAlias $InterfaceAlias -Setting 'Default'

                    Assert-MockCalled -CommandName Set-ItemProperty -Exactly -Times 1
                    Assert-MockCalled -CommandName Invoke-CimMethod -Exactly -Times 0
                }
            }

            Context '"Setting" is "Disable"' {

                It 'Should call "Invoke-CimMethod" instead of "Set-ItemProperty"' {
                    Mock -CommandName Get-CimAssociatedInstance -MockWith {return $MockNetadapterSettingsEnable}
                    Mock Invoke-CimMethod

                    $Null = Set-TargetResource -InterfaceAlias $InterfaceAlias -Setting 'Disable'

                    Assert-MockCalled -CommandName Set-ItemProperty -Exactly -Times 0
                    Assert-MockCalled -CommandName Invoke-CimMethod -Exactly -Times 1
                }
            }
        }
        #endregion
    }
    #endregion
}
finally
{
    #region FOOTER
    Restore-TestEnvironment -TestEnvironment $TestEnvironment
    #endregion
}

