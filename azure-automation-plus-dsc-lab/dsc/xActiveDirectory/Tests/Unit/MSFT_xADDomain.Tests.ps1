[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingConvertToSecureStringWithPlainText', '')]
param()

$Global:DSCModuleName      = 'xActiveDirectory' # Example xNetworking
$Global:DSCResourceName    = 'MSFT_xADDomain' # Example MSFT_xFirewall

#region HEADER
[String] $moduleRoot = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $Script:MyInvocation.MyCommand.Path))
Write-Host $moduleRoot -ForegroundColor Green;
if ( (-not (Test-Path -Path (Join-Path -Path $moduleRoot -ChildPath 'DSCResource.Tests'))) -or `
     (-not (Test-Path -Path (Join-Path -Path $moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1'))) )
{
    & git @('clone','https://github.com/PowerShell/DscResource.Tests.git',(Join-Path -Path $moduleRoot -ChildPath '\DSCResource.Tests\'))
}

Import-Module (Join-Path -Path $moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1') -Force
$TestEnvironment = Initialize-TestEnvironment `
    -DSCModuleName $Global:DSCModuleName `
    -DSCResourceName $Global:DSCResourceName `
    -TestType Unit
#endregion


# Begin Testing
try
{

    #region Pester Tests

    # The InModuleScope command allows you to perform white-box unit testing on the internal
    # (non-exported) code of a Script Module.
    InModuleScope $Global:DSCResourceName {

        #region Pester Test Initialization

        $correctDomainName = 'present.com';
        $incorrectDomainName = 'incorrect.com';
        $missingDomainName = 'missing.com';
        $testAdminCredential = New-Object System.Management.Automation.PSCredential 'DummyUser', (ConvertTo-SecureString 'DummyPassword' -AsPlainText -Force);
        $invalidCredential = New-Object System.Management.Automation.PSCredential 'Invalid', (ConvertTo-SecureString 'InvalidPassword' -AsPlainText -Force);

        $testDefaultParams = @{
            DomainAdministratorCredential = $testAdminCredential;
            SafemodeAdministratorPassword = $testAdminCredential;
        }

        #endregion

        #region Function Get-TargetResource
        Describe "$($Global:DSCResourceName)\Get-TargetResource" {

            Mock Assert-Module -ParameterFilter { $ModuleName -eq 'ADDSDeployment' } { }

            It 'Calls "Assert-Module" to check "ADDSDeployment" module is installed' {
                Mock Get-ADDomain { }
                $result = Get-TargetResource @testDefaultParams -DomainName $correctDomainName;

                Assert-MockCalled Assert-Module -ParameterFilter { $ModuleName -eq 'ADDSDeployment' } -Scope It;
            }

            It 'Returns "System.Collections.Hashtable" object type' {
                Mock Get-ADDomain { }
                $result = Get-TargetResource @testDefaultParams -DomainName $correctDomainName;

                $result -is [System.Collections.Hashtable] | Should Be $true;
            }

            It 'Calls "Get-ADDomain" without credentials if domain member' {
                Mock Test-DomainMember { $true; }
                Mock Get-ADDomain -ParameterFilter { $Credential -eq $null } {  }

                $result = Get-TargetResource @testDefaultParams -DomainName $correctDomainName;

                Assert-MockCalled Get-ADDomain -ParameterFilter { $Credential -eq $null } -Scope It;
            }

            It 'Throws "Invalid credentials" when domain is available but authentication fails' {
                Mock Get-ADDomain -ParameterFilter { $Identity.ToString() -eq $incorrectDomainName } -MockWith {
                    Write-Error -Exception (New-Object System.Security.Authentication.AuthenticationException);
                }
                ## Match operator is case-sensitive!
                { Get-TargetResource @testDefaultParams -DomainName $incorrectDomainName } | Should Throw 'invalid credentials';
            }

            It 'Throws "Computer is already a domain member" when is already a domain member' {
                Mock Get-ADDomain -ParameterFilter { $Identity.ToString() -eq $incorrectDomainName } -MockWith {
                    Write-Error -Exception (New-Object Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException);
                }

                { Get-TargetResource @testDefaultParams -DomainName $incorrectDomainName } | Should Throw 'Computer is already a domain member';
            }

            It 'Does not throw when domain cannot be located' {
                Mock Get-ADDomain -ParameterFilter { $Identity.ToString() -eq $missingDomainName } -MockWith {
                    Write-Error -Exception (New-Object Microsoft.ActiveDirectory.Management.ADServerDownException);
                }

                { Get-TargetResource @testDefaultParams -DomainName $missingDomainName } | Should Not Throw;
            }

        }
        #endregion

        #region Function Test-TargetResource
        Describe "$($Global:DSCResourceName)\Test-TargetResource" {

            $correctDomainName = 'present.com';
            $correctChildDomainName = 'present';
            $correctDomainNetBIOSName = 'PRESENT';
            $incorrectDomainName = 'incorrect.com';
            $parentDomainName = 'parent.com';
            $testAdminCredential = New-Object System.Management.Automation.PSCredential 'DummyUser', (ConvertTo-SecureString 'DummyPassword' -AsPlainText -Force);

            $testDefaultParams = @{
                DomainAdministratorCredential = $testAdminCredential;
                SafemodeAdministratorPassword = $testAdminCredential;
            }

            $stubDomain = @{
                DomainName = $correctDomainName;
                DomainNetBIOSName = $correctDomainNetBIOSName;
            }

            ## Get-TargetResource returns the domain FQDN for .DomainName
            $stubChildDomain = @{
                DomainName = "$correctChildDomainName.$parentDomainName";
                ParentDomainName = $parentDomainName;
                DomainNetBIOSName = $correctDomainNetBIOSName;
            }

            It 'Returns "True" when "DomainName" matches' {
                Mock Get-TargetResource { return $stubDomain; }

                $result = Test-TargetResource @testDefaultParams -DomainName $correctDomainName;

                $result | Should Be $true;
            }

            It 'Returns "False" when "DomainName" does not match' {
                Mock Get-TargetResource { return $stubDomain; }

                $result = Test-TargetResource @testDefaultParams -DomainName $incorrectDomainName;

                $result | Should Be $false;
            }

            It 'Returns "True" when "DomainNetBIOSName" matches' {
                Mock Get-TargetResource { return $stubDomain; }

                $result = Test-TargetResource @testDefaultParams -DomainName $correctDomainName -DomainNetBIOSName $correctDomainNetBIOSName;

                $result | Should Be $true;
            }

            It 'Returns "False" when "DomainNetBIOSName" does not match' {
                Mock Get-TargetResource { return $stubDomain; }

                $result = Test-TargetResource @testDefaultParams -DomainName $correctDomainName -DomainNetBIOSName 'INCORRECT';

                $result | Should Be $false;
            }

            It 'Returns "True" when "ParentDomainName" matches' {
                Mock Get-TargetResource { return $stubChildDomain; }

                $result = Test-TargetResource @testDefaultParams -DomainName $correctChildDomainName -ParentDomainName $parentDomainName;

                $result | Should Be $true;
            }

            It 'Returns "False" when "ParentDomainName" does not match' {
                Mock Get-TargetResource { return $stubChildDomain; }

                $result = Test-TargetResource @testDefaultParams -DomainName $correctChildDomainName -ParentDomainName 'incorrect.com';

                $result | Should Be $false;
            }

        }
        #endregion

        #region Function Set-TargetResource
        Describe "$($Global:DSCResourceName)\Set-TargetResource" {

            function Install-ADDSForest {
                param (
                     $DomainName, $SafeModeAdministratorPassword, $CreateDnsDelegation, $DatabasePath,
                     $DnsDelegationCredential, $InstallDns, $LogPath, $NoRebootOnCompletion, $SysvolPath,
                     $DomainNetbiosName
                 )
            }
            function Install-ADDSDomain {
                param (
                    $NewDomainName, $ParentDomainName, $SafeModeAdministratorPassword, $CreateDnsDelegation,
                    $Credential, $DatabasePath, $DnsDelegationCredential, $DomainType, $InstallDns, $LogPath,
                    $NewDomainNetbiosName, $NoRebootOnCompletion, $SysvolPath
                )
            }

            $testDomainName = 'present.com';
            $testParentDomainName = 'parent.com';
            $testDomainNetBIOSNameName = 'PRESENT';
            $testAdminCredential = New-Object System.Management.Automation.PSCredential 'Admin', (ConvertTo-SecureString 'DummyPassword' -AsPlainText -Force);
            $testSafemodePassword = (ConvertTo-SecureString 'DummyPassword' -AsPlainText -Force);
            $testSafemodeCredential = New-Object System.Management.Automation.PSCredential 'Safemode', $testSafemodePassword;
            $testDelegationCredential = New-Object System.Management.Automation.PSCredential 'Delegation', (ConvertTo-SecureString 'DummyPassword' -AsPlainText -Force);

            $newForestParams = @{
                DomainName = $testDomainName;
                DomainAdministratorCredential = $testAdminCredential;
                SafemodeAdministratorPassword = $testSafemodeCredential;
            }

            $newDomainParams = @{
                DomainName = $testDomainName;
                ParentDomainName = $testParentDomainName;
                DomainAdministratorCredential = $testAdminCredential;
                SafemodeAdministratorPassword = $testSafemodeCredential;
            }

            $stubTargetResource = @{
                DomainName = $testDomainName;
                ParentDomainName = $testParentDomainName;
                DomainNetBIOSName = $testDomainNetBIOSNameName;
            }
            Mock Get-TargetResource { return $stubTargetResource; }

            It 'Calls "Install-ADDSForest" with "DomainName" when creating forest' {
                Mock Install-ADDSForest -ParameterFilter { $DomainName -eq $testDomainName } { }

                Set-TargetResource @newForestParams;

                Assert-MockCalled Install-ADDSForest -ParameterFilter  { $DomainName -eq $testDomainName } -Scope It;
            }

            It 'Calls "Install-ADDSForest" with "SafemodeAdministratorPassword" when creating forest' {
                Mock Install-ADDSForest -ParameterFilter { $SafemodeAdministratorPassword -eq $testSafemodePassword } { }

                Set-TargetResource @newForestParams;

                Assert-MockCalled Install-ADDSForest -ParameterFilter { $SafemodeAdministratorPassword -eq $testSafemodePassword } -Scope It;
            }

            It 'Calls "Install-ADDSForest" with "DnsDelegationCredential" when creating forest, if specified' {
                Mock Install-ADDSForest -ParameterFilter { $DnsDelegationCredential -eq $testDelegationCredential } { }

                Set-TargetResource @newForestParams -DnsDelegationCredential $testDelegationCredential;

                Assert-MockCalled Install-ADDSForest -ParameterFilter  { $DnsDelegationCredential -eq $testDelegationCredential } -Scope It;
            }

            It 'Calls "Install-ADDSForest" with "CreateDnsDelegation" when creating forest, if specified' {
                Mock Install-ADDSForest -ParameterFilter { $CreateDnsDelegation -eq $true } { }

                Set-TargetResource @newForestParams -DnsDelegationCredential $testDelegationCredential;

                Assert-MockCalled Install-ADDSForest -ParameterFilter  { $CreateDnsDelegation -eq $true } -Scope It;
            }

            It 'Calls "Install-ADDSForest" with "DatabasePath" when creating forest, if specified' {
                $testPath = 'TestPath';
                Mock Install-ADDSForest -ParameterFilter { $DatabasePath -eq $testPath } { }

                Set-TargetResource @newForestParams -DatabasePath $testPath;

                Assert-MockCalled Install-ADDSForest -ParameterFilter { $DatabasePath -eq $testPath } -Scope It;
            }

            It 'Calls "Install-ADDSForest" with "LogPath" when creating forest, if specified' {
                $testPath = 'TestPath';
                Mock Install-ADDSForest -ParameterFilter { $LogPath -eq $testPath } { }

                Set-TargetResource @newForestParams -LogPath $testPath;

                Assert-MockCalled Install-ADDSForest -ParameterFilter { $LogPath -eq $testPath } -Scope It;
            }

            It 'Calls "Install-ADDSForest" with "SysvolPath" when creating forest, if specified' {
                $testPath = 'TestPath';
                Mock Install-ADDSForest -ParameterFilter { $SysvolPath -eq $testPath } { }

                Set-TargetResource @newForestParams -SysvolPath $testPath;

                Assert-MockCalled Install-ADDSForest -ParameterFilter { $SysvolPath -eq $testPath } -Scope It;
            }

            It 'Calls "Install-ADDSForest" with "DomainNetbiosName" when creating forest, if specified' {
                Mock Install-ADDSForest -ParameterFilter { $DomainNetbiosName -eq $testDomainNetBIOSNameName } { }

                Set-TargetResource @newForestParams -DomainNetBIOSName $testDomainNetBIOSNameName;

                Assert-MockCalled Install-ADDSForest -ParameterFilter { $DomainNetbiosName -eq $testDomainNetBIOSNameName } -Scope It;
            }

            #### ADDSDomain

            It 'Calls "Install-ADDSDomain" with "NewDomainName" when creating child domain' {
                Mock Install-ADDSDomain -ParameterFilter { $NewDomainName -eq $testDomainName } { }

                Set-TargetResource @newDomainParams;

                Assert-MockCalled Install-ADDSDomain -ParameterFilter  { $NewDomainName -eq $testDomainName } -Scope It;
            }

            It 'Calls "Install-ADDSDomain" with "ParentDomainName" when creating child domain' {
                Mock Install-ADDSDomain -ParameterFilter { $ParentDomainName -eq $testParentDomainName } { }

                Set-TargetResource @newDomainParams;

                Assert-MockCalled Install-ADDSDomain -ParameterFilter  { $ParentDomainName -eq $testParentDomainName } -Scope It;
            }

            It 'Calls "Install-ADDSDomain" with "DomainType" when creating child domain' {
                Mock Install-ADDSDomain -ParameterFilter { $DomainType -eq 'ChildDomain' } { }

                Set-TargetResource @newDomainParams;

                Assert-MockCalled Install-ADDSDomain -ParameterFilter  { $DomainType -eq 'ChildDomain' } -Scope It;
            }

            It 'Calls "Install-ADDSDomain" with "SafemodeAdministratorPassword" when creating child domain' {
                Mock Install-ADDSDomain -ParameterFilter { $SafemodeAdministratorPassword -eq $testSafemodePassword } { }

                Set-TargetResource @newDomainParams;

                Assert-MockCalled Install-ADDSDomain -ParameterFilter { $SafemodeAdministratorPassword -eq $testSafemodePassword } -Scope It;
            }

            It 'Calls "Install-ADDSDomain" with "Credential" when creating child domain' {
                Mock Install-ADDSDomain -ParameterFilter { $Credential -eq $testParentDomainName } { }

                Set-TargetResource @newDomainParams;

                Assert-MockCalled Install-ADDSDomain -ParameterFilter  { $ParentDomainName -eq $testParentDomainName } -Scope It;
            }

            It 'Calls "Install-ADDSDomain" with "ParentDomainName" when creating child domain' {
                Mock Install-ADDSDomain -ParameterFilter { $ParentDomainName -eq $testParentDomainName } { }

                Set-TargetResource @newDomainParams;

                Assert-MockCalled Install-ADDSDomain -ParameterFilter  { $ParentDomainName -eq $testParentDomainName } -Scope It;
            }

            It 'Calls "Install-ADDSDomain" with "DnsDelegationCredential" when creating child domain, if specified' {
                Mock Install-ADDSDomain -ParameterFilter { $DnsDelegationCredential -eq $testDelegationCredential } { }

                Set-TargetResource @newDomainParams -DnsDelegationCredential $testDelegationCredential;

                Assert-MockCalled Install-ADDSDomain -ParameterFilter  { $DnsDelegationCredential -eq $testDelegationCredential } -Scope It;
            }

            It 'Calls "Install-ADDSDomain" with "CreateDnsDelegation" when creating child domain, if specified' {
                Mock Install-ADDSDomain -ParameterFilter { $CreateDnsDelegation -eq $true } { }

                Set-TargetResource @newDomainParams -DnsDelegationCredential $testDelegationCredential;

                Assert-MockCalled Install-ADDSDomain -ParameterFilter  { $CreateDnsDelegation -eq $true } -Scope It;
            }

            It 'Calls "Install-ADDSDomain" with "DatabasePath" when creating child domain, if specified' {
                $testPath = 'TestPath';
                Mock Install-ADDSDomain -ParameterFilter { $DatabasePath -eq $testPath } { }

                Set-TargetResource @newDomainParams -DatabasePath $testPath;

                Assert-MockCalled Install-ADDSDomain -ParameterFilter { $DatabasePath -eq $testPath } -Scope It;
            }

            It 'Calls "Install-ADDSDomain" with "LogPath" when creating child domain, if specified' {
                $testPath = 'TestPath';
                Mock Install-ADDSDomain -ParameterFilter { $LogPath -eq $testPath } { }

                Set-TargetResource @newDomainParams -LogPath $testPath;

                Assert-MockCalled Install-ADDSDomain -ParameterFilter { $LogPath -eq $testPath } -Scope It;
            }

            It 'Calls "Install-ADDSDomain" with "SysvolPath" when creating child domain, if specified' {
                $testPath = 'TestPath';
                Mock Install-ADDSDomain -ParameterFilter { $SysvolPath -eq $testPath } { }

                Set-TargetResource @newDomainParams -SysvolPath $testPath;

                Assert-MockCalled Install-ADDSDomain -ParameterFilter { $SysvolPath -eq $testPath } -Scope It;
            }

            It 'Calls "Install-ADDSDomain" with "NewDomainNetbiosName" when creating child domain, if specified' {
                Mock Install-ADDSDomain -ParameterFilter { $NewDomainNetbiosName -eq $testDomainNetBIOSNameName } { }

                Set-TargetResource @newDomainParams -DomainNetBIOSName $testDomainNetBIOSNameName;

                Assert-MockCalled Install-ADDSDomain -ParameterFilter { $NewDomainNetbiosName -eq $testDomainNetBIOSNameName } -Scope It;
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
