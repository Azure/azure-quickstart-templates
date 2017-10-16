<# 
.summary
    Test suite for MSFT_xPendingReboot.psm1
    For PR https://github.com/PowerShell/xPendingReboot/pull/1 
#>
[CmdletBinding()]
param()


Import-Module $PSScriptRoot\..\DSCResources\MSFT_xPendingReboot\MSFT_xPendingReboot.psm1 -Force

$ErrorActionPreference = 'stop'
Set-StrictMode -Version latest

Describe 'Get-TargetResource' {
    Context "All Reboots Are Required" {
        # Used by ComponentBasedServicing
        Mock Get-ChildItem {
            return @{ Name = 'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending' }
        } -ParameterFilter { $Path -eq 'hklm:SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\' }  -ModuleName "MSFT_xPendingReboot" -Verifiable

        # Used by WindowsUpdate
        Mock Get-ChildItem {
            return @{ Name = 'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired' } 
        } -ParameterFilter { $Path -eq 'hklm:SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\' }  -ModuleName "MSFT_xPendingReboot" -Verifiable

        # Used by PendingFileRename
        Mock Get-ItemProperty {
            return @{ PendingFileRenameOperations= @("File1", "File2") }
        } -ParameterFilter { $Path -eq 'hklm:\SYSTEM\CurrentControlSet\Control\Session Manager\' }  -ModuleName "MSFT_xPendingReboot" -Verifiable

         # Used by PendingComputerRename
        Mock Get-ItemProperty {
            return @{ ComputerName = "box2" }
        } -ParameterFilter { $Path -eq 'hklm:\SYSTEM\CurrentControlSet\Control\ComputerName\ActiveComputerName' }  -ModuleName "MSFT_xPendingReboot" -Verifiable

        Mock Get-ItemProperty {
            return @{ ComputerName = "box" }
        } -ParameterFilter { $Path -eq 'hklm:\SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName' }  -ModuleName "MSFT_xPendingReboot" -Verifiable

        Mock Invoke-WmiMethod {
            return New-Object PSObject -Property @{
                    ReturnValue = 0
                    IsHardRebootPending = $false
                    RebootPending = $true
                }
        } -ModuleName "MSFT_xPendingReboot" -Verifiable

        $value = Get-TargetResource -Name "Test"
        It "All mocks were called" {
            Assert-VerifiableMocks
        }
        
        It "Component Based Servicing should be true" {
            $value.ComponentBasedServicing | Should Be $true
        }

        It "WindowsUpdate should be true" {
            $value.ComponentBasedServicing | Should Be $true
        }
        It "Pending File Rename should be true" {
            $value.PendingFileRename | Should Be $true
        }
        It "Pending Computer Rename should be true" {
            $value.PendingComputerRename | Should Be $true
        }
        It "Ccm Client SDK should be true" {
            $value.CcmClientSDK | Should Be $true
        }
    }
    
    Context "No Reboots Are Required" {
        # Used by ComponentBasedServicing
        Mock Get-ChildItem {
            <# return nothing to catch issue #4 #>
        } -ParameterFilter { $Path -eq 'hklm:SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\' }  -ModuleName "MSFT_xPendingReboot" -Verifiable

        # Used by WindowsUpdate
        Mock Get-ChildItem {
            <# return nothing to catch issue #4 #>
        } -ParameterFilter { $Path -eq 'hklm:SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\' }  -ModuleName "MSFT_xPendingReboot" -Verifiable

        # Used by PendingFileRename
        Mock Get-ItemProperty {
            return @{ PendingFileRenameOperations= @() }
        } -ParameterFilter { $Path -eq 'hklm:\SYSTEM\CurrentControlSet\Control\Session Manager\' }  -ModuleName "MSFT_xPendingReboot" -Verifiable

         # Used by PendingComputerRename
        Mock Get-ItemProperty {
            return @{  }
        } -ParameterFilter { $Path -eq 'hklm:\SYSTEM\CurrentControlSet\Control\ComputerName\ActiveComputerName' }  -ModuleName "MSFT_xPendingReboot" -Verifiable

        Mock Get-ItemProperty {
            return @{  }
        } -ParameterFilter { $Path -eq 'hklm:\SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName' }  -ModuleName "MSFT_xPendingReboot" -Verifiable

        Mock Invoke-WmiMethod {
            return New-Object PSObject -Property @{
                    ReturnValue = 0
                    IsHardRebootPending = $false
                    RebootPending = $false
                }
        } -ModuleName "MSFT_xPendingReboot" -Verifiable

        $value = Get-TargetResource -Name "Test"
        
        It "Component Based Servicing should be false" {
            $value.ComponentBasedServicing | Should Be $false
        }

        It "WindowsUpdate should be false" {
            $value.ComponentBasedServicing | Should Be $false
        }
        It "Pending File Rename should be false" {
            $value.PendingFileRename | Should Be $false
        }
        It "Pending Computer Rename should be false" {
            $value.PendingComputerRename | Should Be $false
        }
        It "Ccm Client SDK should be false" {
            $value.CcmClientSDK | Should Be $false
        }
    }
    
    Context "SkipCcmClientSdk" {
        
        It "Calls 'Invoke-WmiMethod' when 'SkipCcmClientSdk' is not specified" {
            Mock Invoke-WmiMethod { } -ModuleName "MSFT_xPendingReboot"
            
            $value = Get-TargetResource -Name "Test" -SkipCcmClientSdk $false
            
            Assert-MockCalled Invoke-WmiMethod -Scope It -ModuleName "MSFT_xPendingReboot"
        }
        
        It "Does not call 'Invoke-WmiMethod' when 'SkipCcmClientSdk' is specified" {
            Mock Invoke-WmiMethod { } -ModuleName "MSFT_xPendingReboot"
            
            $value = Get-TargetResource -Name "Test" -SkipCcmClientSdk $true
            
            Assert-MockCalled Invoke-WmiMethod -Scope It -Exactly 0 -ModuleName "MSFT_xPendingReboot"
        }
         
    }
}

Describe 'Test-TargetResource' {
    Context "All Reboots Are Required" {
        # Used by ComponentBasedServicing
        Mock Get-TargetResource -ModuleName "MSFT_xPendingReboot" {
            return @{
            Name = $Name
            ComponentBasedServicing = $true
            WindowsUpdate = $true
            PendingFileRename = $true
            PendingComputerRename = $true
            CcmClientSDK = $true
            }
        }

        It "All Reboots are Skipped" {
            $result = Test-TargetResource -Name "Test" -SkipComponentBasedServicing $true -SkipWindowsUpdate $true -SkipPendingFileRename $true -SkipPendingComputerRename $true -SkipCcmClientSDK $true

            $result | Should Be $true
        }

        It "No Reboots are Skipped" {
            $result = Test-TargetResource -Name "Test" -SkipComponentBasedServicing $false -SkipWindowsUpdate $false -SkipPendingFileRename $false -SkipPendingComputerRename $false -SkipCcmClientSDK $false

            $result | Should Be $false
        }
    }
}