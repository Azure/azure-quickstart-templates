[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingConvertToSecureStringWithPlainText', '')]
param()

$Global:DSCModuleName      = 'xActiveDirectory' # Example xNetworking
$Global:DSCResourceName    = 'MSFT_xADOrganizationalUnit' # Example MSFT_xFirewall

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

        function Get-ADOrganizationalUnit { param ($Name) }
        function Set-ADOrganizationalUnit { param ($Identity, $Credential) }
        function Remove-ADOrganizationalUnit { param ($Name, $Credential) }
        function New-ADOrganizationalUnit { param ($Name, $Credential) }

        $testCredential = New-Object System.Management.Automation.PSCredential 'DummyUser', (ConvertTo-SecureString 'DummyPassword' -AsPlainText -Force);

        $testPresentParams = @{
            Name = 'TestOU'
            Path = 'OU=Fake,DC=contoso,DC=com';
            Description = 'Test AD OU description';
            Ensure = 'Present';
        }

        $testAbsentParams = $testPresentParams.Clone();
        $testAbsentParams['Ensure'] = 'Absent';

        $protectedFakeAdOu = @{
            Name = $testPresentParams.Name;
            ProtectedFromAccidentalDeletion = $true;
            Description = $testPresentParams.Description;
        }

        #region Function Get-TargetResource
        Describe "$($Global:DSCResourceName)\Get-TargetResource" {

            It 'Returns a "System.Collections.Hashtable" object type' {
                Mock Assert-Module -MockWith { }
                Mock Get-ADOrganizationalUnit -MockWith { return [PSCustomObject] $protectedFakeAdOu }
                $targetResource = Get-TargetResource -Name $testPresentParams.Name -Path $testPresentParams.Path

                $targetResource -is [System.Collections.Hashtable] | Should Be $true
            }

            It 'Returns "Ensure" = "Present" when OU exists' {
                Mock Assert-Module -MockWith { }
                Mock Get-ADOrganizationalUnit -MockWith { return [PSCustomObject] $protectedFakeAdOu }
                $targetResource = Get-TargetResource -Name $testPresentParams.Name -Path $testPresentParams.Path

                $targetResource.Ensure | Should Be 'Present'
            }

            It 'Returns "Ensure" = "Absent" when OU does not exist' {
                Mock Assert-Module -MockWith { }
                Mock Get-ADOrganizationalUnit -MockWith { }
                $targetResource = Get-TargetResource -Name $testPresentParams.Name -Path $testPresentParams.Path

                $targetResource.Ensure | Should Be 'Absent'
            }

            It 'Returns "ProtectedFromAccidentalDeletion" = "$true" when OU is protected' {
                Mock Assert-Module -MockWith { }
                Mock Get-ADOrganizationalUnit -MockWith { return [PSCustomObject] $protectedFakeAdOu }
                $targetResource = Get-TargetResource -Name $testPresentParams.Name -Path $testPresentParams.Path

                $targetResource.ProtectedFromAccidentalDeletion | Should Be $true
            }

            It 'Returns "ProtectedFromAccidentalDeletion" = "$false" when OU is not protected' {
                Mock Assert-Module -MockWith { }
                Mock Get-ADOrganizationalUnit -MockWith {
                    $unprotectedFakeAdOu = $protectedFakeAdOu.Clone();
                    $unprotectedFakeAdOu['ProtectedFromAccidentalDeletion'] = $false;
                    return [PSCustomObject] $unprotectedFakeAdOu
                }
                $targetResource = Get-TargetResource -Name $testPresentParams.Name -Path $testPresentParams.Path

                $targetResource.ProtectedFromAccidentalDeletion | Should Be $false
            }

            It 'Returns an empty description' {
                Mock Assert-Module -MockWith { }
                Mock Get-ADOrganizationalUnit -MockWith {
                    $noDescriptionFakeAdOu = $protectedFakeAdOu.Clone();
                    $noDescriptionFakeAdOu['Description'] = '';
                    return [PSCustomObject] $noDescriptionFakeAdOu
                }

                $targetResource = Get-TargetResource -Name $testPresentParams.Name -Path $testPresentParams.Path

                $targetResource.Description | Should BeNullOrEmpty
            }

        }
        #endregion

        #region Function Test-TargetResource
        Describe "$($Global:DSCResourceName)\Test-TargetResource" {

            It 'Returns a "System.Boolean" object type' {
                Mock Assert-Module -MockWith { }
                Mock Get-ADOrganizationalUnit { return [PSCustomObject] $protectedFakeAdOu }
                $targetResource = Test-TargetResource @testPresentParams

                $targetResource -is [System.Boolean] | Should Be $true
            }

            It 'Fails when OU does not exist and "Ensure" = "Present"' {
                Mock Assert-Module -MockWith { }
                Mock Get-ADOrganizationalUnit -MockWith { }

                Test-TargetResource @testPresentParams | Should Be $false
            }

            It 'Fails when OU does exist and "Ensure" = "Absent"' {
                Mock Assert-Module -MockWith { }
                Mock Get-ADOrganizationalUnit -MockWith { return [PSCustomObject] $protectedFakeAdOu }

                Test-TargetResource @testAbsentParams | Should Be $false
            }

            It 'Fails when OU does exist but "Description" is incorrect' {
                Mock Assert-Module -MockWith { }
                Mock Get-ADOrganizationalUnit { return [PSCustomObject] $protectedFakeAdOu }
                $testDescriptionParams = $testPresentParams.Clone()
                $testDescriptionParams['Description'] = 'Wrong description'

                Test-TargetResource @testDescriptionParams | Should Be $false
            }

            It 'Fails when OU does exist but "ProtectedFromAccidentalDeletion" is incorrect' {
                Mock Assert-Module -MockWith { }
                Mock Get-ADOrganizationalUnit { return [PSCustomObject] $protectedFakeAdOu }
                $testProtectedFromAccidentalDeletionParams = $testPresentParams.Clone()
                $testProtectedFromAccidentalDeletionParams['ProtectedFromAccidentalDeletion'] = $false

                Test-TargetResource @testProtectedFromAccidentalDeletionParams | Should Be $false
            }

            It 'Passes when OU does exist, "Ensure" = "Present" and all properties are correct' {
                Mock Assert-Module -MockWith { }
                Mock Get-ADOrganizationalUnit -MockWith { return [PSCustomObject] $protectedFakeAdOu }

                Test-TargetResource @testPresentParams | Should Be $true
            }

            It 'Passes when OU does not exist and "Ensure" = "Absent"' {
                Mock Assert-Module -MockWith { }
                Mock Get-ADOrganizationalUnit -MockWith { }

                Test-TargetResource @testAbsentParams | Should Be $true
            }

            It 'Passes when no OU description is specified with existing OU description' {
                Mock Assert-Module -MockWith { }
                Mock Get-ADOrganizationalUnit { return [PSCustomObject] $protectedFakeAdOu }
                $testEmptyDescriptionParams = $testPresentParams.Clone()
                $testEmptyDescriptionParams['Description'] = ''

                Test-TargetResource @testEmptyDescriptionParams | Should Be $true
            }

        }
        #endregion

        #region Function Set-TargetResource
        Describe "$($Global:DSCResourceName)\Set-TargetResource" {

            It 'Calls "New-ADOrganizationalUnit" when "Ensure" = "Present" and OU does not exist' {
                Mock Assert-Module -MockWith { }
                Mock Get-ADOrganizationalUnit -MockWith { }
                Mock New-ADOrganizationalUnit -ParameterFilter { $Name -eq $testPresentParams.Name } -MockWith { }

                Set-TargetResource @testPresentParams
                Assert-MockCalled New-ADOrganizationalUnit -ParameterFilter { $Name -eq $testPresentParams.Name } -Scope It
            }

            It 'Calls "New-ADOrganizationalUnit" with credentials when specified' {
                Mock Assert-Module -MockWith { }
                Mock Get-ADOrganizationalUnit -MockWith { }
                Mock New-ADOrganizationalUnit -ParameterFilter { $Credential -eq $testCredential } -MockWith { }

                Set-TargetResource @testPresentParams -Credential $testCredential
                Assert-MockCalled New-ADOrganizationalUnit -ParameterFilter { $Credential -eq $testCredential } -Scope It
            }

            It 'Calls "Set-ADOrganizationalUnit" when "Ensure" = "Present" and OU does exist' {
                Mock Assert-Module -MockWith { }
                Mock Get-ADOrganizationalUnit -MockWith { return [PSCustomObject] $protectedFakeAdOu }
                Mock Set-ADOrganizationalUnit -MockWith { }

                Set-TargetResource @testPresentParams
                Assert-MockCalled Set-ADOrganizationalUnit -Scope It
            }

            It 'Calls "Set-ADOrganizationalUnit" with credentials when specified' {
                Mock Assert-Module -MockWith { }
                Mock Get-ADOrganizationalUnit -MockWith { return [PSCustomObject] $protectedFakeAdOu }
                Mock Set-ADOrganizationalUnit -ParameterFilter { $Credential -eq $testCredential } -MockWith { }

                Set-TargetResource @testPresentParams -Credential $testCredential
                Assert-MockCalled Set-ADOrganizationalUnit -ParameterFilter { $Credential -eq $testCredential } -Scope It
            }

            It 'Calls "Remove-ADOrganizationalUnit" when "Ensure" = "Absent" and OU does exist but is unprotected' {
                Mock Assert-Module -MockWith { }
                Mock Get-ADOrganizationalUnit -MockWith {
                    $unprotectedFakeAdOu = $protectedFakeAdOu.Clone()
                    $unprotectedFakeAdOu['ProtectedFromAccidentalDeletion'] = $false
                    return [PSCustomObject] $unprotectedFakeAdOu
                }
                Mock Remove-ADOrganizationalUnit -MockWith { }

                Set-TargetResource @testAbsentParams
                Assert-MockCalled Remove-ADOrganizationalUnit -Scope It
            }

            It 'Calls "Remove-ADOrganizationalUnit" when "Ensure" = "Absent" and OU does exist and is protected' {
                Mock Assert-Module -MockWith { }
                Mock Get-ADOrganizationalUnit -MockWith { return [PSCustomObject] $protectedFakeAdOu }
                Mock Remove-ADOrganizationalUnit -MockWith { }

                Set-TargetResource @testAbsentParams
                Assert-MockCalled Remove-ADOrganizationalUnit -Scope It
            }

            It 'Calls "Remove-ADOrganizationalUnit" with credentials when specified' {
                Mock Assert-Module -MockWith { }
                Mock Get-ADOrganizationalUnit -MockWith { return [PSCustomObject] $protectedFakeAdOu }
                Mock Remove-ADOrganizationalUnit -ParameterFilter { $Credential -eq $testCredential } -MockWith { }

                Set-TargetResource @testAbsentParams -Credential $testCredential
                Assert-MockCalled Remove-ADOrganizationalUnit -ParameterFilter { $Credential -eq $testCredential } -Scope It
            }

            It 'Calls "Set-ADOrganizationalUnit" when "Ensure" = "Absent", OU does exist but is protected' {
                Mock Assert-Module -MockWith { }
                Mock Get-ADOrganizationalUnit -MockWith { return [PSCustomObject] $protectedFakeAdOu }
                Mock Remove-ADOrganizationalUnit -MockWith { }
                Mock Set-ADOrganizationalUnit -MockWith { }

                Set-TargetResource @testAbsentParams
                Assert-MockCalled Set-ADOrganizationalUnit -Scope It
            }

            It 'Does not call "Set-ADOrganizationalUnit" when "Ensure" = "Absent", OU does exist but is unprotected' {
                Mock Assert-Module -MockWith { }
                Mock Get-ADOrganizationalUnit -MockWith {
                    $unprotectedFakeAdOu = $protectedFakeAdOu.Clone()
                    $unprotectedFakeAdOu['ProtectedFromAccidentalDeletion'] = $false
                    return [PSCustomObject] $unprotectedFakeAdOu
                }
                Mock Remove-ADOrganizationalUnit -MockWith { }
                Mock Set-ADOrganizationalUnit -MockWith { }

                Set-TargetResource @testAbsentParams
                Assert-MockCalled Set-ADOrganizationalUnit -Scope It -Exactly 0
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
