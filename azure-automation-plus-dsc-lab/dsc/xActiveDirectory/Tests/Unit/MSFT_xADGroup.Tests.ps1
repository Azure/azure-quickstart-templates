[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingConvertToSecureStringWithPlainText', '')]
param()

$Global:DSCModuleName      = 'xActiveDirectory' # Example xNetworking
$Global:DSCResourceName    = 'MSFT_xADGroup' # Example MSFT_xFirewall

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
        $testPresentParams = @{
            GroupName = 'TestGroup'
            GroupScope = 'Global';
            Category = 'Security';
            Path = 'OU=Fake,DC=contoso,DC=com';
            Description = 'Test AD group description';
            DisplayName = 'Test display name';
            Ensure = 'Present';
            Notes = 'This is a test AD group';
            ManagedBy = 'CN=User 1,CN=Users,DC=contoso,DC=com';
        }

        $testAbsentParams = $testPresentParams.Clone();
        $testAbsentParams['Ensure'] = 'Absent';

        $fakeADGroup = @{
            Name = $testPresentParams.GroupName;
            Identity = $testPresentParams.GroupName;
            GroupScope = $testPresentParams.GroupScope;
            GroupCategory = $testPresentParams.Category;
            DistinguishedName = "CN=$($testPresentParams.GroupName),$($testPresentParams.Path)";
            Description = $testPresentParams.Description;
            DisplayName = $testPresentParams.DisplayName;
            ManagedBy = $testPresentParams.ManagedBy;
            Info = $testPresentParams.Notes;
        }

        $fakeADUser1 = [PSCustomObject] @{
            DistinguishedName = 'CN=User 1,CN=Users,DC=contoso,DC=com';
            ObjectGUID = 'a97cc867-0c9e-4928-8387-0dba0c883b8e';
            SamAccountName = 'USER1';
            SID = 'S-1-5-21-1131554080-2861379300-292325817-1106'
        }
        $fakeADUser2 = [PSCustomObject] @{
            DistinguishedName = 'CN=User 2,CN=Users,DC=contoso,DC=com';
            ObjectGUID = 'a97cc867-0c9e-4928-8387-0dba0c883b8f';
            SamAccountName = 'USER2';
            SID = 'S-1-5-21-1131554080-2861379300-292325817-1107'
        }
        $fakeADUser3 = [PSCustomObject] @{
            DistinguishedName = 'CN=User 3,CN=Users,DC=contoso,DC=com';
            ObjectGUID = 'a97cc867-0c9e-4928-8387-0dba0c883b90';
            SamAccountName = 'USER3';
            SID = 'S-1-5-21-1131554080-2861379300-292325817-1108'
        }

        $testDomainController = 'TESTDC';
        $testCredentials = New-Object System.Management.Automation.PSCredential 'DummyUser', (ConvertTo-SecureString 'DummyPassword' -AsPlainText -Force);

        #region Function Get-TargetResource
        Describe "$($Global:DSCResourceName)\Get-TargetResource" {

            Mock Assert-Module -ParameterFilter { $ModuleName -eq 'ActiveDirectory' } { }

            It 'Calls "Assert-Module" to check AD module is installed' {
                Mock Get-ADGroup { return $fakeADGroup; }
                Mock Get-ADGroupMember { return @($fakeADUser1, $fakeADUser2); }

                $result = Get-TargetResource @testPresentParams; # -DomainName $correctDomainName;

                Assert-MockCalled Assert-Module -ParameterFilter { $ModuleName -eq 'ActiveDirectory' } -Scope It;
            }

            It "Returns 'Ensure' is 'Present' when group exists" {
                Mock Get-ADGroup { return $fakeADGroup; }
                Mock Get-ADGroupMember { return @($fakeADUser1, $fakeADUser2); }

                (Get-TargetResource @testPresentParams).Ensure | Should Be 'Present';
            }

            It "Returns 'Ensure' is 'Absent' when group does not exist" {
                Mock Get-ADGroup { throw New-Object Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException }

                (Get-TargetResource @testPresentParams).Ensure | Should Be 'Absent';
            }


            It "Calls 'Get-ADGroup' with 'Server' parameter when 'DomainController' specified" {
                Mock Get-ADGroup -ParameterFilter { $Server -eq $testDomainController } -MockWith { return $fakeADGroup; }
                Mock Get-ADGroupMember { return @($fakeADUser1, $fakeADUser2); }

                Get-TargetResource @testPresentParams -DomainController $testDomainController;

                Assert-MockCalled Get-ADGroup -ParameterFilter { $Server -eq $testDomainController } -Scope It;
            }

            It "Calls 'Get-ADGroup' with 'Credential' parameter when specified" {
                Mock Get-ADGroup -ParameterFilter { $Credential -eq $testCredentials } -MockWith { return $fakeADGroup; }
                Mock Get-ADGroupMember { return @($fakeADUser1, $fakeADUser2); }

                Get-TargetResource @testPresentParams -Credential $testCredentials;

                Assert-MockCalled Get-ADGroup -ParameterFilter { $Credential -eq $testCredentials } -Scope It;
            }

            It "Calls 'Get-ADGroupMember' with 'Server' parameter when 'DomainController' specified" {
                Mock Get-ADGroup  -MockWith { return $fakeADGroup; }
                Mock Get-ADGroupMember -ParameterFilter { $Server -eq $testDomainController } -MockWith { return @($fakeADUser1, $fakeADUser2); }

                Get-TargetResource @testPresentParams -DomainController $testDomainController;

                Assert-MockCalled Get-ADGroupMember -ParameterFilter { $Server -eq $testDomainController } -Scope It;
            }

            It "Calls 'Get-ADGroupMember' with 'Credential' parameter when specified" {
                Mock Get-ADGroup -MockWith { return $fakeADGroup; }
                Mock Get-ADGroupMember -ParameterFilter { $Credential -eq $testCredentials } -MockWith { return @($fakeADUser1, $fakeADUser2); }

                Get-TargetResource @testPresentParams -Credential $testCredentials;

                Assert-MockCalled Get-ADGroupMember -ParameterFilter { $Credential -eq $testCredentials } -Scope It;
            }

        }
        #end region

        #region Function Test-TargetResource
        Describe "$($Global:DSCResourceName)\Test-TargetResource" {

            Mock Assert-Module -ParameterFilter { $ModuleName -eq 'ActiveDirectory' } { }

            foreach ($attribute in @('SamAccountName','DistinguishedName','ObjectGUID','SID')) {

                It "Passes when group 'Members' match using '$attribute'" {
                    Mock Get-ADGroup { return $fakeADGroup; }
                    Mock Get-ADGroupMember { return @($fakeADUser1, $fakeADUser2); }

                    $targetResource = Test-TargetResource @testPresentParams -Members $fakeADUser1.$attribute, $fakeADUser2.$attribute -MembershipAttribute $attribute;

                    $targetResource | Should Be $true;
                }

                It "Fails when group membership counts do not match using '$attribute'" {
                    Mock Get-ADGroup { return $fakeADGroup; }
                    Mock Get-ADGroupMember { return @($fakeADUser1); }

                    $targetResource = Test-TargetResource @testPresentParams -Members $fakeADUser2.$attribute, $fakeADUser3.$attribute -MembershipAttribute $attribute;

                    $targetResource | Should Be $false;
                }

                It "Fails when group 'Members' do not match using '$attribute'" {
                    Mock Get-ADGroup { return $fakeADGroup; }
                    Mock Get-ADGroupMember { return @($fakeADUser1, $fakeADUser2); }

                    $targetResource = Test-TargetResource @testPresentParams -Members $fakeADUser2.$attribute, $fakeADUser3.$attribute -MembershipAttribute $attribute;

                    $targetResource | Should Be $false;
                }

                It "Passes when specified 'MembersToInclude' match using '$attribute'" {
                    Mock Get-ADGroup { return $fakeADGroup; }
                    Mock Get-ADGroupMember { return @($fakeADUser1, $fakeADUser2); }

                    $targetResource = Test-TargetResource @testPresentParams -MembersToInclude $fakeADUser2.$attribute -MembershipAttribute $attribute;

                    $targetResource | Should Be $true;
                }

                It "Fails when specified 'MembersToInclude' are missing using '$attribute'" {
                    Mock Get-ADGroup { return $fakeADGroup; }
                    Mock Get-ADGroupMember { return @($fakeADUser1, $fakeADUser2); }

                    $targetResource = Test-TargetResource @testPresentParams -MembersToInclude $fakeADUser3.$attribute -MembershipAttribute $attribute;

                    $targetResource | Should Be $false;
                }

                It "Passes when specified 'MembersToExclude' are missing using '$attribute'" {
                    Mock Get-ADGroup { return $fakeADGroup; }
                    Mock Get-ADGroupMember { return @($fakeADUser1, $fakeADUser2); }

                    $targetResource = Test-TargetResource @testPresentParams -MembersToExclude $fakeADUser3.$attribute -MembershipAttribute $attribute;

                    $targetResource | Should Be $true;
                }

                It "Fails when when specified 'MembersToExclude' match using '$attribute'" {
                    Mock Get-ADGroup { return $fakeADGroup; }
                    Mock Get-ADGroupMember { return @($fakeADUser1, $fakeADUser2); }

                    $targetResource = Test-TargetResource @testPresentParams -MembersToExclude $fakeADUser2.$attribute -MembershipAttribute $attribute;

                    $targetResource | Should Be $false;
                }

            } #end foreach attribute

            It "Fails when group does not exist and 'Ensure' is 'Present'" {
                Mock Get-TargetResource { return $testAbsentParams }

                Test-TargetResource @testPresentParams | Should Be $false
            }

            It "Fails when group exists, 'Ensure' is 'Present' but 'Scope' is wrong" {
                Mock Get-TargetResource {
                    $duffADGroup = $testPresentParams.Clone();
                    $duffADGroup['GroupScope'] = 'Universal';
                    return $duffADGroup;
                }

                Test-TargetResource @testPresentParams | Should Be $false;
            }

            It "Fails when group exists, 'Ensure' is 'Present' but 'Category' is wrong" {
                Mock Get-TargetResource {
                    $duffADGroup = $testPresentParams.Clone();
                    $duffADGroup['Category'] = 'Distribution';
                    return $duffADGroup;
                }

                Test-TargetResource @testPresentParams | Should Be $false;
            }

            It "Fails when group exists, 'Ensure' is 'Present' but 'Path' is wrong" {
                Mock Get-TargetResource {
                    $duffADGroup = $testPresentParams.Clone();
                    $duffADGroup['Path'] = 'OU=WrongPath,DC=contoso,DC=com';
                    return $duffADGroup;
                }

                Test-TargetResource @testPresentParams | Should Be $false;
            }

            It "Fails when group exists, 'Ensure' is 'Present' but 'Description' is wrong" {
                Mock Get-TargetResource {
                    $duffADGroup = $testPresentParams.Clone();
                    $duffADGroup['Description'] = 'Test AD group description is wrong';
                    return $duffADGroup;
                }

                Test-TargetResource @testPresentParams | Should Be $false;
            }

            It "Fails when group exists, 'Ensure' is 'Present' but 'DisplayName' is wrong" {
                Mock Get-TargetResource {
                    $duffADGroup = $testPresentParams.Clone();
                    $duffADGroup['DisplayName'] = 'Wrong display name';
                    return $duffADGroup;
                }

                Test-TargetResource @testPresentParams | Should Be $false;
            }

            It "Fails when group exists, 'Ensure' is 'Present' but 'ManagedBy' is wrong" {
                Mock Get-TargetResource {
                    $duffADGroup = $testPresentParams.Clone();
                    $duffADGroup['ManagedBy'] = $fakeADUser3.DistinguishedName;
                    return $duffADGroup;
                }

                Test-TargetResource @testPresentParams | Should Be $false;
            }

            It "Fails when group exists, 'Ensure' is 'Present' but 'Notes' is wrong" {
                Mock Get-TargetResource {
                    $duffADGroup = $testPresentParams.Clone();
                    $duffADGroup['Notes'] = 'These notes are clearly wrong';
                    return $duffADGroup;
                }

                Test-TargetResource @testPresentParams | Should Be $false;
            }

            It "Fails when group exists and 'Ensure' is 'Absent'" {
                Mock Get-TargetResource { return $testPresentParams }

                Test-TargetResource @testAbsentParams | Should Be $false
            }

            It "Passes when group exists, target matches and 'Ensure' is 'Present'" {
                Mock Get-TargetResource { return $testPresentParams }

                Test-TargetResource @testPresentParams | Should Be $true
            }

            It "Passes when group does not exist and 'Ensure' is 'Absent'" {
                Mock Get-TargetResource { return $testAbsentParams }

                Test-TargetResource @testAbsentParams | Should Be $true
            }

        }
        #end region

        #region Function Set-TargetResource
        Describe "$($Global:DSCResourceName)\Set-TargetResource" {

            Mock Assert-Module -ParameterFilter { $ModuleName -eq 'ActiveDirectory' } { }

            It "Calls 'New-ADGroup' when 'Ensure' is 'Present' and the group does not exist" {
                Mock Get-ADGroup { throw New-Object Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException }
                Mock Set-ADGroup { }
                Mock New-ADGroup { return [PSCustomObject] $fakeADGroup; }

                Set-TargetResource @testPresentParams;

                Assert-MockCalled New-ADGroup -Scope It;
            }

            $testProperties = @{
                Description = 'Test AD Group description is wrong';
                ManagedBy = $fakeADUser3.DistinguishedName;
                DisplayName = 'Test DisplayName';
            }

            foreach ($property in $testProperties.Keys) {
                It "Calls 'Set-ADGroup' when 'Ensure' is 'Present' and '$property' is specified" {
                    Mock Set-ADGroup { }
                    Mock Get-ADGroupMember { }
                    Mock Get-ADGroup {
                        $duffADGroup = $fakeADGroup.Clone();
                        $duffADGroup[$property] = $testProperties.$property;
                        return $duffADGroup;
                    }

                    Set-TargetResource @testPresentParams;

                    Assert-MockCalled Set-ADGroup -Scope It -Exactly 1;
                }
            }

            It "Calls 'Set-ADGroup' when 'Ensure' is 'Present' and 'Category' is specified" {
                Mock Set-ADGroup -ParameterFilter { $GroupCategory -eq $testPresentParams.Category } { }
                Mock Get-ADGroupMember { }
                Mock Get-ADGroup {
                    $duffADGroup = $fakeADGroup.Clone();
                    $duffADGroup['GroupCategory'] = 'Distribution';
                    return $duffADGroup;
                }

                Set-TargetResource @testPresentParams;

                Assert-MockCalled Set-ADGroup -ParameterFilter { $GroupCategory -eq $testPresentParams.Category } -Scope It -Exactly 1;
            }

            It "Calls 'Set-ADGroup' when 'Ensure' is 'Present' and 'Notes' is specified" {
                Mock Set-ADGroup -ParameterFilter { $Replace -ne $null } { }
                Mock Get-ADGroupMember { }
                Mock Get-ADGroup {
                    $duffADGroup = $fakeADGroup.Clone();
                    $duffADGroup['Info'] = 'My test note..';
                    return $duffADGroup;
                }

                Set-TargetResource @testPresentParams;

                Assert-MockCalled Set-ADGroup -ParameterFilter { $Replace -ne $null } -Scope It -Exactly 1;
            }

            It "Calls 'Set-ADGroup' twice when 'Ensure' is 'Present', the group exists but the 'Scope' has changed" {
                Mock Set-ADGroup { }
                Mock Get-ADGroupMember { }
                Mock Get-ADGroup {
                    $duffADGroup = $fakeADGroup.Clone();
                    $duffADGroup['GroupScope'] = 'DomainLocal';
                    return $duffADGroup;
                }

                Set-TargetResource @testPresentParams;

                Assert-MockCalled Set-ADGroup -Scope It -Exactly 2;
            }

            It "Adds group members when 'Ensure' is 'Present', the group exists and 'Members' are specified" {
                Mock Get-ADGroup { throw New-Object Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException }
                Mock Set-ADGroup { }
                Mock Add-ADGroupMember { }
                Mock New-ADGroup { return [PSCustomObject] $fakeADGroup; }

                Set-TargetResource @testPresentParams -Members @($fakeADUser1.SamAccountName, $fakeADUser2.SamAccountName);

                Assert-MockCalled Add-ADGroupMember -Scope It;
            }

            It "Adds group members when 'Ensure' is 'Present', the group exists and 'MembersToInclude' are specified" {
                Mock Get-ADGroup { throw New-Object Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException }
                Mock Set-ADGroup { }
                Mock Add-ADGroupMember { }
                Mock New-ADGroup { return [PSCustomObject] $fakeADGroup; }

                Set-TargetResource @testPresentParams -MembersToInclude @($fakeADUser1.SamAccountName, $fakeADUser2.SamAccountName);

                Assert-MockCalled Add-ADGroupMember -Scope It;
            }

            It "Moves group when 'Ensure' is 'Present', the group exists but the 'Path' has changed" {
                Mock Set-ADGroup { }
                Mock Get-ADGroupMember { }
                Mock Move-ADObject { }
                Mock Get-ADGroup {
                    $duffADGroup = $fakeADGroup.Clone();
                    $duffADGroup['DistinguishedName'] = "CN=$($testPresentParams.GroupName),OU=WrongPath,DC=contoso,DC=com";
                    return $duffADGroup;
                }

                Set-TargetResource @testPresentParams;

                Assert-MockCalled Move-ADObject -Scope It;
            }

            It "Resets group membership when 'Ensure' is 'Present' and 'Members' is incorrect" {
                Mock Get-ADGroup { return [PSCustomObject] $fakeADGroup; }
                Mock Set-ADGroup { }
                Mock Get-ADGroupMember { return @($fakeADUser1, $fakeADUser2); }
                Mock Add-ADGroupMember { }
                Mock Remove-ADGroupMember { }

                Set-TargetResource @testPresentParams -Members $fakeADuser1.SamAccountName;

                Assert-MockCalled Remove-ADGroupMember -Scope It -Exactly 1;
                Assert-MockCalled Add-ADGroupMember -Scope It -Exactly 1;
            }

            It "Does not reset group membership when 'Ensure' is 'Present' and existing group is empty" {
                Mock Get-ADGroup { return [PSCustomObject] $fakeADGroup; }
                Mock Set-ADGroup { }
                Mock Get-ADGroupMember { }
                Mock Remove-ADGroupMember { }

                Set-TargetResource @testPresentParams -MembersToExclude $fakeADuser1.SamAccountName;

                Assert-MockCalled Remove-ADGroupMember -Scope It -Exactly 0;
            }

            It "Removes members when 'Ensure' is 'Present' and 'MembersToExclude' is incorrect" {
                Mock Get-ADGroup { return [PSCustomObject] $fakeADGroup; }
                Mock Set-ADGroup { }
                Mock Get-ADGroupMember { return @($fakeADUser1, $fakeADUser2); }
                Mock Remove-ADGroupMember { }

                Set-TargetResource @testPresentParams -MembersToExclude $fakeADuser1.SamAccountName;

                Assert-MockCalled Remove-ADGroupMember -Scope It -Exactly 1;
            }

            It "Adds members when 'Ensure' is 'Present' and 'MembersToInclude' is incorrect" {
                Mock Get-ADGroup { return [PSCustomObject] $fakeADGroup; }
                Mock Set-ADGroup { }
                Mock Get-ADGroupMember { return @($fakeADUser1, $fakeADUser2); }
                Mock Add-ADGroupMember { }

                Set-TargetResource @testPresentParams -MembersToInclude $fakeADuser3.SamAccountName;

                Assert-MockCalled Add-ADGroupMember -Scope It -Exactly 1;
            }

            It "Removes group when 'Ensure' is 'Absent' and group exists" {
                Mock Get-ADGroup { return $fakeADGroup; }
                Mock Remove-ADGroup { }

                Set-TargetResource @testAbsentParams;

                Assert-MockCalled Remove-ADGroup -Scope It;
            }

            It "Calls 'Set-ADGroup' with credentials when 'Ensure' is 'Present' and the group exists (#106)" {
                Mock Get-ADGroup { return $fakeADGroup; }
                Mock New-ADGroup { return [PSCustomObject] $fakeADGroup; }
                Mock Get-ADGroupMember { }
                Mock Set-ADGroup -ParameterFilter { $Credential -eq $testCredentials } -MockWith { }

                Set-TargetResource @testPresentParams -Credential $testCredentials;

                Assert-MockCalled Set-ADGroup -ParameterFilter { $Credential -eq $testCredentials } -Scope It;
            }

            It "Calls 'Set-ADGroup' with credentials when 'Ensure' is 'Present' and the group does not exist  (#106)" {
                Mock Get-ADGroup { throw New-Object Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException }
                Mock Set-ADGroup -ParameterFilter { $Credential -eq $testCredentials }  { }
                Mock New-ADGroup { return [PSCustomObject] $fakeADGroup; }

                Set-TargetResource @testPresentParams -Credential $testCredentials;

                Assert-MockCalled Set-ADGroup -ParameterFilter { $Credential -eq $testCredentials } -Scope It;
            }

            It "Calls 'Move-ADObject' with credentials when specified (#106)" {
                Mock Set-ADGroup { }
                Mock Get-ADGroupMember { }
                Mock Move-ADObject -ParameterFilter { $Credential -eq $testCredentials } { }
                Mock Get-ADGroup {
                    $duffADGroup = $fakeADGroup.Clone();
                    $duffADGroup['DistinguishedName'] = "CN=$($testPresentParams.GroupName),OU=WrongPath,DC=contoso,DC=com";
                    return $duffADGroup;
                }

                Set-TargetResource @testPresentParams -Credential $testCredentials;

                Assert-MockCalled Move-ADObject -ParameterFilter { $Credential -eq $testCredentials } -Scope It;
            }

        }
        #end region

    }
    #end region
}
finally
{
    #region FOOTER
    Restore-TestEnvironment -TestEnvironment $TestEnvironment
    #endregion

    # TODO: Other Optional Cleanup Code Goes Here...
}
