[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingConvertToSecureStringWithPlainText', '')]
param()

$Global:DSCModuleName      = 'xActiveDirectory' # Example xNetworking
$Global:DSCResourceName    = 'MSFT_xADCommon' # Example MSFT_xFirewall

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

        #endregion

        #region Function ResolveDomainFQDN
        Describe "$($Global:DSCResourceName)\Resolve-DomainFQDN" {

            It 'Returns "DomainName" when "ParentDomainName" not supplied' {
                $testDomainName = 'contoso.com';
                $testParentDomainName = $null;

                $result = Resolve-DomainFQDN -DomainName $testDomainName -ParentDomainName $testParentDOmainName;

                $result | Should Be $testDomainName;
            }

            It 'Returns compound "DomainName.ParentDomainName" when "ParentDomainName" supplied' {
                $testDomainName = 'subdomain';
                $testParentDomainName = 'contoso.com';

                $result = Resolve-DomainFQDN -DomainName $testDomainName -ParentDomainName $testParentDomainName;

                $result | Should Be "$testDomainName.$testParentDomainName";
            }

        }
        #endregion

        #region Function TestDomainMember
        Describe "$($Global:DSCResourceName)\Test-DomainMember" {

            It 'Returns "True" when domain member' {
                Mock Get-CimInstance { return @{ Name = $env:COMPUTERNAME; PartOfDomain = $true; } }

                Test-DomainMember | Should Be $true;
            }

            It 'Returns "False" when workgroup member' {
                Mock Get-CimInstance { return @{ Name = $env:COMPUTERNAME; } }

                Test-DomainMember | Should Be $false;
            }

        }
        #endregion

        #region Function Get-DomainName
        Describe "$($Global:DSCResourceName)\Get-DomainName" {

            It 'Returns exepected domain name' {
                Mock Get-CimInstance { return @{ Name = $env:COMPUTERNAME; Domain = 'contoso.com'; } }

                Get-DomainName | Should Be 'contoso.com';
            }

        }
        #endregion

        #region Function Assert-Module
        Describe "$($Global:DSCResourceName)\Assert-Module" {

            It 'Does not throw when module is installed' {
                $testModuleName = 'TestModule';
                Mock Get-Module -ParameterFilter { $Name -eq $testModuleName } { return $true; }

                { Assert-Module -ModuleName $testModuleName } | Should Not Throw;
            }

            It 'Throws when module is not installed' {
                $testModuleName = 'TestModule';
                Mock Get-Module -ParameterFilter { $Name -eq $testModuleName } { }

                { Assert-Module -ModuleName $testModuleName } | Should Throw;
            }

        }
        #endregion

        #region Function Assert-Module
        Describe "$($Global:DSCResourceName)\Get-ADObjectParentDN" {

            It "Returns CN object parent path" {
                Get-ADObjectParentDN -DN 'CN=Administrator,CN=Users,DC=contoso,DC=com' | Should Be 'CN=Users,DC=contoso,DC=com';
            }

            It "Returns OU object parent path" {
                Get-ADObjectParentDN -DN 'CN=Administrator,OU=Custom Organizational Unit,DC=contoso,DC=com' | Should Be 'OU=Custom Organizational Unit,DC=contoso,DC=com';
            }

        }
        #endregion

        #region Function Remove-DuplicateMembers
        Describe "$($Global:DSCResourceName)\Remove-DuplicateMembers" {

            It 'Removes one duplicate' {
                $members = Remove-DuplicateMembers -Members 'User1','User2','USER1';

                $members.Count | Should Be 2;
                $members -contains 'User1' | Should Be $true;
                $members -contains 'User2' | Should Be $true;
            }

            It 'Removes two duplicates' {
                $members = Remove-DuplicateMembers -Members 'User1','User2','USER1','USER2';

                $members.Count | Should Be 2;
                $members -contains 'User1' | Should Be $true;
                $members -contains 'User2' | Should Be $true;
            }

            It 'Removes double duplicates' {
                $members = Remove-DuplicateMembers -Members 'User1','User2','USER1','user1';

                $members.Count | Should Be 2;
                $members -contains 'User1' | Should Be $true;
                $members -contains 'User2' | Should Be $true;
            }

        }
        #endregion

        #region Function Test-Members
        Describe "$($Global:DSCResourceName)\Test-Members" {

            It 'Passes when nothing is passed' {
                Test-Members -ExistingMembers $null | Should Be $true;
            }

            It 'Passes when there are existing members but members are required' {
                $testExistingMembers = @('USER1', 'USER2');

                Test-Members -ExistingMembers $testExistingMembers | Should Be $true;
            }

            It 'Passes when existing members match required members' {
                $testExistingMembers = @('USER1', 'USER2');
                $testMembers = @('USER2', 'USER1');

                Test-Members -ExistingMembers $testExistingMembers -Members $testMembers | Should Be $true;
            }

            It 'Fails when there are no existing members and members are required' {
                $testExistingMembers = @('USER1', 'USER2');
                $testMembers = @('USER1', 'USER3');

                Test-Members -ExistingMembers $null -Members $testMembers | Should Be $false;
            }

            It 'Fails when there are more existing members than the members required' {
                $testExistingMembers = @('USER1', 'USER2', 'USER3');
                $testMembers = @('USER1', 'USER3');

                Test-Members -ExistingMembers $null -Members $testMembers | Should Be $false;
            }

            It 'Fails when there are more existing members than the members required' {
                $testExistingMembers = @('USER1', 'USER2');
                $testMembers = @('USER1', 'USER3', 'USER2');

                Test-Members -ExistingMembers $null -Members $testMembers | Should Be $false;
            }

            It 'Fails when existing members do not match required members' {
                $testExistingMembers = @('USER1', 'USER2');
                $testMembers = @('USER1', 'USER3');

                Test-Members -ExistingMembers $testExistingMembers -Members $testMembers | Should Be $false;
            }

            It 'Passes when existing members include required member' {
                $testExistingMembers = @('USER1', 'USER2');
                $testMembersToInclude = @('USER2');

                Test-Members -ExistingMembers $testExistingMembers -MembersToInclude $testMembersToInclude | Should Be $true;
            }

            It 'Passes when existing members include required members' {
                $testExistingMembers = @('USER1', 'USER2');
                $testMembersToInclude = @('USER2', 'USER1');

                Test-Members -ExistingMembers $testExistingMembers -MembersToInclude $testMembersToInclude | Should Be $true;
            }

            It 'Fails when existing members is missing a required member' {
                $testExistingMembers = @('USER1');
                $testMembersToInclude = @('USER2');

                Test-Members -ExistingMembers $testExistingMembers -MembersToInclude $testMembersToInclude | Should Be $false;
            }

            It 'Fails when existing members is missing a required member' {
                $testExistingMembers = @('USER1', 'USER3');
                $testMembersToInclude = @('USER2');

                Test-Members -ExistingMembers $testExistingMembers -MembersToInclude $testMembersToInclude | Should Be $false;
            }

            It 'Fails when existing members is missing a required members' {
                $testExistingMembers = @('USER3');
                $testMembersToInclude = @('USER1', 'USER2');

                Test-Members -ExistingMembers $testExistingMembers -MembersToInclude $testMembersToInclude | Should Be $false;
            }

            It 'Passes when existing member does not include excluded member' {
                $testExistingMembers = @('USER1');
                $testMembersToExclude = @('USER2');

                Test-Members -ExistingMembers $testExistingMembers -MembersToExclude $testMembersToInclude | Should Be $true;
            }

            It 'Passes when existing member does not include excluded members' {
                $testExistingMembers = @('USER1');
                $testMembersToExclude = @('USER2', 'USER3');

                Test-Members -ExistingMembers $testExistingMembers -MembersToExclude $testMembersToInclude | Should Be $true;
            }

            It 'Passes when existing members does not include excluded member' {
                $testExistingMembers = @('USER1', 'USER2');
                $testMembersToExclude = @('USER3');

                Test-Members -ExistingMembers $testExistingMembers -MembersToExclude $testMembersToInclude | Should Be $true;
            }
        }
        #endregion

        #region Function Assert-MemberParameters
        Describe "$($Global:DSCResourceName)\Assert-MemberParameters" {

            It "Throws if 'Members' is specified but is empty" {
                { Assert-MemberParameters -Members @() } | Should Throw 'The Members parameter value is null';
            }

            It "Throws if 'Members' and 'MembersToInclude' are specified" {
                { Assert-MemberParameters -Members @('User1') -MembersToInclude @('User1') } | Should Throw 'parameters conflict';
            }

            It "Throws if 'Members' and 'MembersToExclude' are specified" {
                { Assert-MemberParameters -Members @('User1') -MembersToExclude @('User2') } | Should Throw 'parameters conflict';
            }

            It "Throws if 'MembersToInclude' and 'MembersToExclude' contain the same member" {
                { Assert-MemberParameters -MembersToExclude @('user1') -MembersToInclude @('USER1') } | Should Throw 'member must not be included in both';
            }

            It "Throws if 'MembersToInclude' and 'MembersToExclude' are empty" {
                { Assert-MemberParameters -MembersToExclude @() -MembersToInclude @() } | Should Throw 'At least one member must be specified';
            }

        }
        #endregion

        #region Function ConvertTo-Timespan
        Describe "$($Global:DSCResourceName)\ConvertTo-Timespan" {

            It "Returns 'System.TimeSpan' object type" {
                $testIntTimeSpan = 60;

                $result = ConvertTo-TimeSpan -TimeSpan $testIntTimeSpan -TimeSpanType Minutes;

                $result -is [System.TimeSpan] | Should Be $true;
            }

            It "Creates TimeSpan from seconds" {
                $testIntTimeSpan = 60;

                $result = ConvertTo-TimeSpan -TimeSpan $testIntTimeSpan -TimeSpanType Seconds;

                $result.TotalSeconds | Should Be $testIntTimeSpan;
            }

            It "Creates TimeSpan from minutes" {
                $testIntTimeSpan = 60;

                $result = ConvertTo-TimeSpan -TimeSpan $testIntTimeSpan -TimeSpanType Minutes;

                $result.TotalMinutes | Should Be $testIntTimeSpan;
            }

            It "Creates TimeSpan from hours" {
                $testIntTimeSpan = 60;

                $result = ConvertTo-TimeSpan -TimeSpan $testIntTimeSpan -TimeSpanType Hours;

                $result.TotalHours | Should Be $testIntTimeSpan;
            }

            It "Creates TimeSpan from days" {
                $testIntTimeSpan = 60;

                $result = ConvertTo-TimeSpan -TimeSpan $testIntTimeSpan -TimeSpanType Days;

                $result.TotalDays | Should Be $testIntTimeSpan;
            }

        }
        #endregion

        #region Function ConvertTo-Timespan
        Describe "$($Global:DSCResourceName)\ConvertFrom-Timespan" {

            It "Returns 'System.UInt32' object type" {
                $testIntTimeSpan = 60;
                $testTimeSpan = New-TimeSpan -Seconds $testIntTimeSpan;

                $result = ConvertFrom-TimeSpan -TimeSpan $testTimeSpan -TimeSpanType Seconds;

                $result -is [System.UInt32] | Should Be $true;
            }

            It "Converts TimeSpan to total seconds" {
                $testIntTimeSpan = 60;
                $testTimeSpan = New-TimeSpan -Seconds $testIntTimeSpan;

                $result = ConvertFrom-TimeSpan -TimeSpan $testTimeSpan -TimeSpanType Seconds;

                $result | Should Be $testTimeSpan.TotalSeconds;
            }

            It "Converts TimeSpan to total minutes" {
                $testIntTimeSpan = 60;
                $testTimeSpan = New-TimeSpan -Minutes $testIntTimeSpan;

                $result = ConvertFrom-TimeSpan -TimeSpan $testTimeSpan -TimeSpanType Minutes;

                $result | Should Be $testTimeSpan.TotalMinutes;
            }

            It "Converts TimeSpan to total hours" {
                $testIntTimeSpan = 60;
                $testTimeSpan = New-TimeSpan -Hours $testIntTimeSpan;

                $result = ConvertFrom-TimeSpan -TimeSpan $testTimeSpan -TimeSpanType Hours;

                $result | Should Be $testTimeSpan.TotalHours;
            }

            It "Converts TimeSpan to total days" {
                $testIntTimeSpan = 60;
                $testTimeSpan = New-TimeSpan -Days $testIntTimeSpan;

                $result = ConvertFrom-TimeSpan -TimeSpan $testTimeSpan -TimeSpanType Days;

                $result | Should Be $testTimeSpan.TotalDays;
            }

        }
        #endregion

        #region Function Get-ADCommonParameters
        Describe "$($Global:DSCResourceName)\Get-ADCommonParameters" {

            It "Returns 'System.Collections.Hashtable' object type" {
                $testIdentity = 'contoso.com';

                $result = Get-ADCommonParameters -Identity $testIdentity;

                $result -is [System.Collections.Hashtable] | Should Be $true;
            }

            It "Returns 'Identity' key by default" {
                $testIdentity = 'contoso.com';

                $result = Get-ADCommonParameters -Identity $testIdentity;

                $result['Identity'] | Should Be $testIdentity;
            }

            It "Returns 'Name' key when 'UseNameParameter' is specified" {
                $testIdentity = 'contoso.com';

                $result = Get-ADCommonParameters -Identity $testIdentity -UseNameParameter;

                $result['Name'] | Should Be $testIdentity;
            }

            foreach ($identityParam in @('UserName','GroupName','ComputerName')) {
                It "Returns 'Identity' key when '$identityParam' alias is specified" {
                    $testIdentity = 'contoso.com';
                    $getADCommonParameters = @{
                        $identityParam = $testIdentity;
                    }

                    $result = Get-ADCommonParameters @getADCommonParameters;

                    $result['Identity'] | Should Be $testIdentity;
                }
            }

            It "Returns 'Identity' key by default when 'Identity' and 'CommonName' are specified" {
                $testIdentity = 'contoso.com';
                $testCommonName = 'Test Common Name';

                $result = Get-ADCommonParameters -Identity $testIdentity -CommonName $testCommonName;

                $result['Identity'] | Should Be $testIdentity;
            }

            It "Returns 'Identity' key with 'CommonName' when 'Identity', 'CommonName' and 'PreferCommonName' are specified" {
                $testIdentity = 'contoso.com';
                $testCommonName = 'Test Common Name';

                $result = Get-ADCommonParameters -Identity $testIdentity -CommonName $testCommonName -PreferCommonName;

                $result['Identity'] | Should Be $testCommonName;
            }

            It "Returns 'Identity' key with 'Identity' when 'Identity' and 'PreferCommonName' are specified" {
                $testIdentity = 'contoso.com';

                $result = Get-ADCommonParameters -Identity $testIdentity -PreferCommonName;

                $result['Identity'] | Should Be $testIdentity;
            }

            it "Returns 'Name' key when 'UseNameParameter' and 'PreferCommonName' are supplied" {
                $testIdentity = 'contoso.com';
                $testCommonName = 'Test Common Name';

                $result = Get-ADCommonParameters -Identity $testIdentity -UseNameParameter -CommonName $testCommonName -PreferCommonName;

                $result['Name'] | Should Be $testCommonName;
            }

            It "Does not return 'Credential' key by default" {
                $testIdentity = 'contoso.com';

                $result = Get-ADCommonParameters -Identity $testIdentity;

                $result.ContainsKey('Credential') | Should Be $false;
            }

            It "Returns 'Credential' key when specified" {
                $testIdentity = 'contoso.com';
                $testCredential = [System.Management.Automation.PSCredential]::Empty;

                $result = Get-ADCommonParameters -Identity $testIdentity -Credential $testCredential;

                $result['Credential'] | Should Be $testCredential;
            }

            It "Does not return 'Server' key by default" {
                $testIdentity = 'contoso.com';

                $result = Get-ADCommonParameters -Identity $testIdentity;

                $result.ContainsKey('Server') | Should Be $false;
            }

            It "Returns 'Server' key when specified" {
                $testIdentity = 'contoso.com';
                $testServer = 'testserver.contoso.com';

                $result = Get-ADCommonParameters -Identity $testIdentity -Server $testServer;

                $result['Server'] | Should Be $testServer;
            }

            It "Converts 'DomainAdministratorCredential' parameter to 'Credential' key" {
                $testIdentity = 'contoso.com';
                $testCredential = [System.Management.Automation.PSCredential]::Empty;

                $result = Get-ADCommonParameters -Identity $testIdentity -DomainAdministratorCredential $testCredential;

                $result['Credential'] | Should Be $testCredential;
            }

            It "Converts 'DomainController' parameter to 'Server' key" {
                $testIdentity = 'contoso.com';
                $testServer = 'testserver.contoso.com';

                $result = Get-ADCommonParameters -Identity $testIdentity -DomainController $testServer;

                $result['Server'] | Should Be $testServer;
            }

            It 'Accepts remaining arguments' {
                $testIdentity = 'contoso.com';

                $result = Get-ADCommonParameters -Identity $testIdentity -UnexpectedParameter 42;

                $result['Identity'] | Should Be $testIdentity;
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
