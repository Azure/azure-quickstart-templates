$Module = "$PSScriptRoot\..\DSCResources\MSFT_xComputer\MSFT_xComputer.psm1"
Remove-Module -Name MSFT_xComputer -Force -ErrorAction SilentlyContinue
Import-Module -Name $Module -Force -ErrorAction Stop

InModuleScope MSFT_xComputer {
    
    Describe 'MSFT_xComputer' {
        
        $SecPassword = ConvertTo-SecureString -String 'password' -AsPlainText -Force
        $Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList 'USER',$SecPassword
        $NotComputerName  = if($env:COMPUTERNAME -ne 'othername'){'othername'}else{'name'}
    
        Context Test-TargetResource {
            Mock Get-WMIObject {[PSCustomObject]@{DomainName = 'ContosoLtd'}} -ParameterFilter {$Class -eq 'Win32_NTDomain'}
            It 'Throws if both DomainName and WorkGroupName are specified' {
                {Test-TargetResource -Name $Env:ComputerName -DomainName 'contoso.com' -WorkGroupName 'workgroup'} | Should Throw
            }
            It 'Throws if Domain is specified without Credentials' {
                {Test-TargetResource -Name $Env:ComputerName -DomainName 'contoso.com'} | Should Throw
            }
            It 'Should return True if Domain name is same as specified' {
                Mock Get-WMIObject {[PSCustomObject]@{Domain = 'Contoso.com';Workgroup='Contoso.com';PartOfDomain=$true}}
                Mock GetComputerDomain {'contoso.com'}
                Test-TargetResource -Name $Env:ComputerName -DomainName 'Contoso.com' -Credential $Credential | Should Be $true
            }
            It 'Should return True if Workgroup name is same as specified' {
                Mock Get-WMIObject {[PSCustomObject]@{Domain = 'Workgroup';Workgroup='Workgroup';PartOfDomain=$false}}
                Mock GetComputerDomain {''}
                Test-TargetResource -Name $Env:ComputerName -WorkGroupName 'workgroup' | Should Be $true
            }
            It 'Should return True if ComputerName and Domain name is same as specified' {
                Mock Get-WMIObject {[PSCustomObject]@{Domain = 'Contoso.com';Workgroup='Contoso.com';PartOfDomain=$true}}
                Mock GetComputerDomain {'contoso.com'}
                Test-TargetResource -Name $Env:ComputerName -DomainName 'contoso.com' -Credential $Credential | Should Be $true
            }
            It 'Should return True if ComputerName and Workgroup is same as specified' {
                Mock Get-WMIObject {[PSCustomObject]@{Domain = 'Workgroup';Workgroup='Workgroup';PartOfDomain=$false}}
                Mock GetComputerDomain {''}
                Test-TargetResource -Name $Env:ComputerName -WorkGroupName 'workgroup' | Should Be $true
            }
            It 'Should return True if ComputerName is same and no Domain or Workgroup specified' {
                Mock Get-WmiObject {[PSCustomObject]@{Domain = 'Workgroup';Workgroup='Workgroup';PartOfDomain=$false}}
                Mock GetComputerDomain {''}
                Test-TargetResource -Name $Env:ComputerName | Should Be $true
                Mock Get-WmiObject {[PSCustomObject]@{Domain = 'Contoso.com';Workgroup='Contoso.com';PartOfDomain=$true}}
                Mock GetComputerDomain {'contoso.com'}
                Test-TargetResource -Name $Env:ComputerName | Should Be $true
            }
            It 'Should return False if ComputerName is not same and no Domain or Workgroup specified' {
                Mock Get-WmiObject {[PSCustomObject]@{Domain = 'Workgroup';Workgroup='Workgroup';PartOfDomain=$false}}
                Mock GetComputerDomain {''}
                Test-TargetResource -Name $NotComputerName | Should Be $false
                Mock Get-WmiObject {[PSCustomObject]@{Domain = 'Contoso.com';Workgroup='Contoso.com';PartOfDomain=$true}}
                Mock GetComputerDomain {'contoso.com'}
                Test-TargetResource -Name $NotComputerName | Should Be $false
            }
            It 'Should return False if Domain name is not same as specified' {
                Mock Get-WMIObject {[PSCustomObject]@{Domain = 'Contoso.com';Workgroup='Contoso.com';PartOfDomain=$true}}
                Mock GetComputerDomain {'contoso.com'}
                Test-TargetResource -Name $Env:ComputerName -DomainName 'adventure-works.com' -Credential $Credential  | Should Be $false
            }
            It 'Should return False if Workgroup name is not same as specified' {
                Mock Get-WMIObject {[PSCustomObject]@{Domain = 'Workgroup';Workgroup='Workgroup';PartOfDomain=$false}}
                Mock GetComputerDomain {''}
                Test-TargetResource -Name $Env:ComputerName -WorkGroupName 'NOTworkgroup' | Should Be $false
            }
            It 'Should return False if ComputerName is not same as specified' {
                Mock Get-WMIObject {[PSCustomObject]@{Domain = 'Workgroup';Workgroup='Workgroup';PartOfDomain=$false}}
                Mock GetComputerDomain {''}
                Test-TargetResource -Name $NotComputerName -WorkGroupName 'workgroup' | Should Be $false
                Mock Get-WMIObject {[PSCustomObject]@{Domain = 'Contoso.com';Workgroup='Contoso.com';PartOfDomain=$true}}
                Mock GetComputerDomain {'contoso.com'}
                Test-TargetResource -Name $NotComputerName -DomainName 'contoso.com' -Credential $Credential | Should Be $false
            }
            It 'Should return False if Computer is in Workgroup and Domain is specified' {
                Mock Get-WMIObject {[PSCustomObject]@{Domain = 'Contoso.com';Workgroup='Contoso.com';PartOfDomain=$false}}
                Mock GetComputerDomain {''}
                Test-TargetResource -Name $Env:ComputerName -DomainName 'contoso.com' -Credential $Credential | Should Be $false
            }
            It 'Should return False if ComputerName is in Domain and Workgroup is specified' {
                Mock Get-WMIObject {[PSCustomObject]@{Domain = 'Contoso.com';Workgroup='Contoso.com';PartOfDomain=$true}}
                Mock GetComputerDomain {'contoso.com'}
                Test-TargetResource -Name $Env:ComputerName -WorkGroupName 'Contoso' -Credential $Credential -UnjoinCredential $Credential | Should Be $false
            }
            It 'Throws if name is to long' {
                {Test-TargetResource -Name "ThisNameIsTooLong"} | Should Throw
            }
            It 'Throws if name contains illigal characters' {
                {Test-TargetResource -Name "ThisIsBad<>"} | Should Throw
            }
            
        }
        Context Get-TargetResource {
            It 'should not throw' {
                {Get-TargetResource -Name $env:COMPUTERNAME} | Should Not Throw
            }
            It 'Should return a hashtable containing Name, DomainName, JoinOU, CurrentOU, Credential, UnjoinCredential and WorkGroupName' {
                $Result = Get-TargetResource -Name $env:COMPUTERNAME
                $Result.GetType().Fullname | Should Be 'System.Collections.Hashtable'
                $Result.Keys | Should Be @('Name', 'DomainName', 'JoinOU', 'CurrentOU', 'Credential', 'UnjoinCredential', 'WorkGroupName')
            }
            It 'Throws if name is to long' {
                {Get-TargetResource -Name "ThisNameIsTooLong"} | Should Throw
            }
            It 'Throws if name contains illigal characters' {
                {Get-TargetResource -Name "ThisIsBad<>"} | Should Throw
            }
        }
        Context Set-TargetResource {
            Mock Rename-Computer {}
            Mock Add-Computer {}
            It 'Throws if both DomainName and WorkGroupName are specified' {
                {Set-TargetResource -Name $Env:ComputerName -DomainName 'contoso.com' -WorkGroupName 'workgroup'} | Should Throw
                Assert-MockCalled -CommandName Rename-Computer -Exactly 0 -Scope It
                Assert-MockCalled -CommandName Add-Computer -Exactly 0 -Scope It
            }
            It 'Throws if Domain is specified without Credentials' {
                {Set-TargetResource -Name $Env:ComputerName -DomainName 'contoso.com'} | Should Throw
                Assert-MockCalled -CommandName Rename-Computer -Exactly 0 -Scope It
                Assert-MockCalled -CommandName Add-Computer -Exactly 0 -Scope It
            }
            It 'Changes ComputerName and changes Domain to new Domain' {
                Mock Get-WMIObject {[PSCustomObject]@{Domain = 'Contoso.com';Workgroup='Contoso.com';PartOfDomain=$true}}
                Mock GetComputerDomain {'contoso.com'}
                Set-TargetResource -Name $NotComputerName -DomainName 'adventure-works.com' -Credential $Credential -UnjoinCredential $Credential | Should BeNullOrEmpty
                Assert-MockCalled -CommandName Rename-Computer -Exactly 0 -Scope It
                Assert-MockCalled -CommandName Add-Computer -Exactly 1 -Scope It -ParameterFilter {$DomainName -and $NewName}
                Assert-MockCalled -CommandName Add-Computer -Exactly 0 -Scope It -ParameterFilter {$WorkGroupName}
            }
            It 'Changes ComputerName and changes Domain to new Domain with specified OU' {
                Mock Get-WMIObject {[PSCustomObject]@{Domain = 'Contoso.com';Workgroup='Contoso.com';PartOfDomain=$true}}
                Mock GetComputerDomain {'contoso.com'}
                Set-TargetResource -Name $NotComputerName -DomainName 'adventure-works.com' -JoinOU 'OU=Computers,DC=contoso,DC=com' -Credential $Credential -UnjoinCredential $Credential | Should BeNullOrEmpty
                Assert-MockCalled -CommandName Rename-Computer -Exactly 0 -Scope It
                Assert-MockCalled -CommandName Add-Computer -Exactly 1 -Scope It -ParameterFilter {$DomainName -and $NewName}
                Assert-MockCalled -CommandName Add-Computer -Exactly 0 -Scope It -ParameterFilter {$WorkGroupName}
            }
            It 'Changes ComputerName and changes Domain to Workgroup' {
                Mock Get-WMIObject {[PSCustomObject]@{Domain = 'Contoso.com';Workgroup='Contoso.com';PartOfDomain=$true}}
                Mock GetComputerDomain {'contoso.com'}
                Set-TargetResource -Name $NotComputerName -WorkGroupName 'contoso' -Credential $Credential | Should BeNullOrEmpty
                Assert-MockCalled -CommandName Rename-Computer -Exactly 0 -Scope It
                Assert-MockCalled -CommandName Add-Computer -Exactly 1 -Scope It -ParameterFilter {$WorkGroupName -and $NewName -and $Credential}
                Assert-MockCalled -CommandName Add-Computer -Exactly 0 -Scope It -ParameterFilter {$DomainName -or $UnjoinCredential}
            }
            It 'Changes ComputerName and changes Workgroup to Domain' {
                Mock Get-WMIObject {[PSCustomObject]@{Domain = 'Contoso';Workgroup='Contoso';PartOfDomain=$false}}
                Mock GetComputerDomain {''}
                Set-TargetResource -Name $NotComputerName -DomainName 'Contoso.com' -Credential $Credential | Should BeNullOrEmpty
                Assert-MockCalled -CommandName Rename-Computer -Exactly 0 -Scope It
                Assert-MockCalled -CommandName Add-Computer -Exactly 1 -Scope It -ParameterFilter {$DomainName -and $NewName}
                Assert-MockCalled -CommandName Add-Computer -Exactly 0 -Scope It -ParameterFilter {$WorkGroupName}
            }
            It 'Changes ComputerName and changes Workgroup to Domain with specified OU' {
                Mock Get-WMIObject {[PSCustomObject]@{Domain = 'Contoso';Workgroup='Contoso';PartOfDomain=$false}}
                Mock GetComputerDomain {''}
                Set-TargetResource -Name $NotComputerName -DomainName 'Contoso.com' -JoinOU 'OU=Computers,DC=contoso,DC=com' -Credential $Credential | Should BeNullOrEmpty
                Assert-MockCalled -CommandName Rename-Computer -Exactly 0 -Scope It
                Assert-MockCalled -CommandName Add-Computer -Exactly 1 -Scope It -ParameterFilter {$DomainName -and $NewName}
                Assert-MockCalled -CommandName Add-Computer -Exactly 0 -Scope It -ParameterFilter {$WorkGroupName}
            }
            It 'Changes ComputerName and changes Workgroup to new Workgroup' {
                Mock Get-WMIObject {[PSCustomObject]@{Domain = 'Contoso';Workgroup='Contoso';PartOfDomain=$false}}
                Mock GetComputerDomain {''}
                Set-TargetResource -Name $NotComputerName -WorkGroupName 'adventure-works' | Should BeNullOrEmpty
                Assert-MockCalled -CommandName Rename-Computer -Exactly 0 -Scope It
                Assert-MockCalled -CommandName Add-Computer -Exactly 1 -Scope It -ParameterFilter {$WorkGroupName -and $NewName}
                Assert-MockCalled -CommandName Add-Computer -Exactly 0 -Scope It -ParameterFilter {$DomainName}
            }
            It 'Changes only the Domain to new Domain' {
                Mock Get-WMIObject {[PSCustomObject]@{Domain = 'Contoso.com';Workgroup='Contoso.com';PartOfDomain=$true}}
                Mock GetComputerDomain {'contoso.com'}
                Set-TargetResource -Name $Env:ComputerName -DomainName 'adventure-works.com' -Credential $Credential -UnjoinCredential $Credential | Should BeNullOrEmpty
                Assert-MockCalled -CommandName Rename-Computer -Exactly 0 -Scope It
                Assert-MockCalled -CommandName Add-Computer -Exactly 1 -Scope It -ParameterFilter {$DomainName}
                Assert-MockCalled -CommandName Add-Computer -Exactly 0 -Scope It -ParameterFilter {$NewName}
                Assert-MockCalled -CommandName Add-Computer -Exactly 0 -Scope It -ParameterFilter {$WorkGroupName}
            }
            It 'Changes only the Domain to new Domain with specified OU' {
                Mock Get-WMIObject {[PSCustomObject]@{Domain = 'Contoso.com';Workgroup='Contoso.com';PartOfDomain=$true}}
                Mock GetComputerDomain {'contoso.com'}
                Set-TargetResource -Name $Env:ComputerName -DomainName 'adventure-works.com' -JoinOU 'OU=Computers,DC=contoso,DC=com' -Credential $Credential -UnjoinCredential $Credential | Should BeNullOrEmpty
                Assert-MockCalled -CommandName Rename-Computer -Exactly 0 -Scope It
                Assert-MockCalled -CommandName Add-Computer -Exactly 1 -Scope It -ParameterFilter {$DomainName}
                Assert-MockCalled -CommandName Add-Computer -Exactly 0 -Scope It -ParameterFilter {$NewName}
                Assert-MockCalled -CommandName Add-Computer -Exactly 0 -Scope It -ParameterFilter {$WorkGroupName}
            }
            It 'Changes only Domain to Workgroup' {
                Mock Get-WMIObject {[PSCustomObject]@{Domain = 'Contoso.com';Workgroup='Contoso.com';PartOfDomain=$true}}
                Mock GetComputerDomain {''}
                Set-TargetResource -Name $Env:ComputerName -WorkGroupName 'Contoso' -UnjoinCredential $Credential | Should BeNullOrEmpty
                Assert-MockCalled -CommandName Rename-Computer -Exactly 0 -Scope It
                Assert-MockCalled -CommandName Add-Computer -Exactly 0 -Scope It -ParameterFilter {$NewName}
                Assert-MockCalled -CommandName Add-Computer -Exactly 1 -Scope It -ParameterFilter {$WorkGroupName}
                Assert-MockCalled -CommandName Add-Computer -Exactly 0 -Scope It -ParameterFilter {$DomainName}
            }
            It 'Changes only ComputerName in Domain' {
                Mock Get-WMIObject {[PSCustomObject]@{Domain = 'Contoso.com';Workgroup='Contoso.com';PartOfDomain=$true}}
                Mock GetComputerDomain {'contoso.com'}
                Set-TargetResource -Name $NotComputerName -Credential $Credential | Should BeNullOrEmpty
                Assert-MockCalled -CommandName Rename-Computer -Exactly 1 -Scope It
                Assert-MockCalled -CommandName Add-Computer -Exactly 0 -Scope It
            }
            It 'Changes only ComputerName in Workgroup' {
                Mock GetComputerDomain {''}
                Mock Get-WMIObject {[PSCustomObject]@{Domain = 'Contoso';Workgroup='Contoso';PartOfDomain=$false}}
                Set-TargetResource -Name $NotComputerName | Should BeNullOrEmpty
                Assert-MockCalled -CommandName Rename-Computer -Exactly 1 -Scope It
                Assert-MockCalled -CommandName Add-Computer -Exactly 0 -Scope It
            }
            It 'Throws if name is to long' {
                {Set-TargetResource -Name "ThisNameIsTooLong"} | Should Throw
            }
            It 'Throws if name contains illigal characters' {
                {Set-TargetResource -Name "ThisIsBad<>"} | Should Throw
            }
        }
    }
}
