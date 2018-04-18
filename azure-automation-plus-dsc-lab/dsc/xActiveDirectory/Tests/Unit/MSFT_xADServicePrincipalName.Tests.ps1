$Global:DSCModuleName   = 'xActiveDirectory'
$Global:DSCResourceName = 'MSFT_xADServicePrincipalName'

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

    InModuleScope $Global:DSCResourceName {

        #region Function Get-TargetResource
        Describe "$($Global:DSCResourceName)\Get-TargetResource" {

            $testDefaultParameters = @{
                ServicePrincipalName = 'HOST/demo'
            }

            Context 'No SPN set' {

                Mock -CommandName Get-ADObject

                It 'Should return absent' {

                    $result = Get-TargetResource @testDefaultParameters

                    $result.Ensure               | Should Be 'Absent'
                    $result.ServicePrincipalName | Should Be 'HOST/demo'
                    $result.Account              | Should Be ''
                }
            }

            Context 'One SPN set' {

                Mock -CommandName Get-ADObject -MockWith {
                    [PSCustomObject] @{ SamAccountName = 'User' }
                }

                It 'Should return present with the correct account' {

                    $result = Get-TargetResource @testDefaultParameters

                    $result.Ensure               | Should Be 'Present'
                    $result.ServicePrincipalName | Should Be 'HOST/demo'
                    $result.Account              | Should Be 'User'
                }
            }

            Context 'Multiple SPN set' {

                Mock -CommandName Get-ADObject -MockWith {
                    [PSCustomObject] @{ SamAccountName = 'User' },
                    [PSCustomObject] @{ SamAccountName = 'Computer' }
                }

                It 'Should return present with the multiple accounts' {

                    $result = Get-TargetResource @testDefaultParameters

                    $result.Ensure               | Should Be 'Present'
                    $result.ServicePrincipalName | Should Be 'HOST/demo'
                    $result.Account              | Should Be 'User;Computer'
                }
            }
        }
        #endregion

        #region Function Test-TargetResource
        Describe "$($Global:DSCResourceName)\Test-TargetResource" {

            $testDefaultParameters = @{
                ServicePrincipalName = 'HOST/demo'
                Account              = 'User'
            }

            Context 'No SPN set' {

                Mock -CommandName Get-ADObject

                It 'Should return false for present' {

                    $result = Test-TargetResource -Ensure 'Present' @testDefaultParameters
                    $result | Should Be $false
                }

                It 'Should return true for absent' {

                    $result = Test-TargetResource -Ensure 'Absent' @testDefaultParameters
                    $result | Should Be $true
                }
            }

            Context 'Correct SPN set' {

                Mock -CommandName Get-ADObject -MockWith {
                    [PSCustomObject] @{ SamAccountName = 'User' }
                }

                It 'Should return true for present' {

                    $result = Test-TargetResource -Ensure 'Present' @testDefaultParameters
                    $result | Should Be $true
                }

                It 'Should return false for absent' {

                    $result = Test-TargetResource -Ensure 'Absent' @testDefaultParameters
                    $result | Should Be $false
                }
            }

            Context 'Wrong SPN set' {

                Mock -CommandName Get-ADObject -MockWith {
                    [PSCustomObject] @{ SamAccountName = 'Computer' }
                }

                It 'Should return false for present' {

                    $result = Test-TargetResource -Ensure 'Present' @testDefaultParameters
                    $result | Should Be $false
                }

                It 'Should return false for absent' {

                    $result = Test-TargetResource -Ensure 'Absent' @testDefaultParameters
                    $result | Should Be $false
                }
            }

            Context 'Multiple SPN set' {

                Mock -CommandName Get-ADObject -MockWith {
                    [PSCustomObject] @{ SamAccountName = 'User' },
                    [PSCustomObject] @{ SamAccountName = 'Computer' }
                }

                It 'Should return false for present' {

                    $result = Test-TargetResource -Ensure 'Present' @testDefaultParameters
                    $result | Should Be $false
                }

                It 'Should return false for absent' {

                    $result = Test-TargetResource -Ensure 'Absent' @testDefaultParameters
                    $result | Should Be $false
                }
            }

        }
        #endregion

        #region Function Set-TargetResource
        Describe "$($Global:DSCResourceName)\Set-TargetResource" {

            $testPresentParams = @{
                Ensure               = 'Present'
                ServicePrincipalName = 'HOST/demo'
                Account              = 'User'
            }

            $testAbsentParams = @{
                Ensure               = 'Absent'
                ServicePrincipalName = 'HOST/demo'
            }

            Context 'AD Object not existing' {

                Mock -CommandName Get-ADObject

                It 'Should throw the correct exception' {

                    { Set-TargetResource @testPresentParams } | Should Throw "AD object with SamAccountName = 'User' not found!"
                }
            }

            Context 'No SPN set' {

                Mock -CommandName Get-ADObject -ParameterFilter { $Filter -eq ([ScriptBlock]::Create(' ServicePrincipalName -eq $ServicePrincipalName ')) }
                Mock -CommandName Get-ADObject -MockWith {
                    [PSCustomObject] @{ SamAccountName = 'User' }
                }
                Mock -CommandName Set-ADObject

                It 'Should call the Set-ADObject' {

                    $result = Set-TargetResource @testPresentParams

                    Assert-MockCalled Set-ADObject -Scope It -Times 1 -Exactly
                }
            }

            Context 'Wrong SPN set' {

                Mock -CommandName Get-ADObject -ParameterFilter { $Filter -eq ([ScriptBlock]::Create(' ServicePrincipalName -eq $ServicePrincipalName ')) } -MockWith {
                    [PSCustomObject] @{ SamAccountName = 'Computer'; DistinguishedName = 'CN=Computer,OU=Corp,DC=contoso,DC=com' }
                }
                Mock -CommandName Get-ADObject -MockWith {
                    [PSCustomObject] @{ SamAccountName = 'User' }
                }
                Mock -CommandName Set-ADObject -ParameterFilter { $null -ne $Add }
                Mock -CommandName Set-ADObject -ParameterFilter { $null -ne $Remove }

                It 'Should call the Set-ADObject twice' {

                    $result = Set-TargetResource @testPresentParams

                    Assert-MockCalled Set-ADObject -Scope It -Times 1 -Exactly -ParameterFilter { $null -ne $Add }
                    Assert-MockCalled Set-ADObject -Scope It -Times 1 -Exactly -ParameterFilter { $null -ne $Remove }
                }
            }

            Context 'Remove all SPNs' {

                Mock -CommandName Get-ADObject -ParameterFilter { $Filter -eq ([ScriptBlock]::Create(' ServicePrincipalName -eq $ServicePrincipalName ')) } -MockWith {
                    [PSCustomObject] @{ SamAccountName = 'User'; DistinguishedName = 'CN=User,OU=Corp,DC=contoso,DC=com' }
                }
                Mock -CommandName Set-ADObject

                It 'Should call the Set-ADObject' {

                    $result = Set-TargetResource @testAbsentParams

                    Assert-MockCalled Set-ADObject -Scope It -Times 1 -Exactly
                }
            }
        }
        #endregion
    }
}
finally
{
    #region FOOTER
    Restore-TestEnvironment -TestEnvironment $TestEnvironment
    #endregion
}
