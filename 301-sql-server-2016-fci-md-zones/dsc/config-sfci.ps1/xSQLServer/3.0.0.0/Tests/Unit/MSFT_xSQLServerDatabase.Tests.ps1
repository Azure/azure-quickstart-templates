$script:DSCModuleName      = 'xSQLServer'
$script:DSCResourceName    = 'MSFT_xSQLServerDatabase'

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
    #region Pester Test Initialization

    # Loading mocked classes
    Add-Type -Path (Join-Path -Path $script:moduleRoot -ChildPath 'Tests\Unit\Stubs\SMO.cs')

    $nodeName = 'localhost'
    $instanceName = 'MSSQLSERVER'

    $defaultParameters = @{
        SQLInstanceName = $instanceName
        SQLServer = $nodeName
    }

    #endregion Pester Test Initialization

    Describe "$($script:DSCResourceName)\Get-TargetResource" {
        Mock -CommandName Connect-SQL -MockWith {
            return New-Object Object | 
                Add-Member ScriptProperty Databases {
                    return @{
                        'AdventureWorks' = @( ( New-Object Microsoft.SqlServer.Management.Smo.Database -ArgumentList @( $null, 'AdventureWorks') ) )
                    }
                } -PassThru -Force 
        } -ModuleName $script:DSCResourceName -Verifiable

        Context 'When the system is not in the desired state' {
            $testParameters = $defaultParameters
            $testParameters += @{
                Name = 'UnknownDatabase'
            }

            $result = Get-TargetResource @testParameters

            It 'Should return the state as absent' {
                $result.Ensure | Should Be 'Absent'
            }

            It 'Should return the same values as passed as parameters' {
                $result.SQLServer | Should Be $testParameters.SQLServer
                $result.SQLInstanceName | Should Be $testParameters.SQLInstanceName
                $result.Name | Should Be $testParameters.Name
            }

            It 'Should call the mock function Connect-SQL' {
                 Assert-MockCalled Connect-SQL -Exactly -Times 1 -ModuleName $script:DSCResourceName -Scope Context
            }
        }
    
        Context 'When the system is in the desired state for a database' {
            $testParameters = $defaultParameters
            $testParameters += @{
                Name = 'AdventureWorks'
            }
    
            $result = Get-TargetResource @testParameters

            It 'Should return the state as present' {
                $result.Ensure | Should Be 'Present'
            }

            It 'Should return the same values as passed as parameters' {
                $result.SQLServer | Should Be $testParameters.SQLServer
                $result.SQLInstanceName | Should Be $testParameters.SQLInstanceName
                $result.Name | Should Be $testParameters.Name
            }

            It 'Should call the mock function Connect-SQL' {
                 Assert-MockCalled Connect-SQL -Exactly -Times 1 -ModuleName $script:DSCResourceName -Scope Context
            }
        }

        Assert-VerifiableMocks
    }
    
    Describe "$($script:DSCResourceName)\Test-TargetResource" {
        Mock -CommandName Connect-SQL -MockWith {
            return New-Object Object | 
                Add-Member ScriptProperty Databases {
                    return @{
                        'AdventureWorks' = @( ( New-Object Microsoft.SqlServer.Management.Smo.Database -ArgumentList @( $null, 'AdventureWorks') ) )
                    }
                } -PassThru -Force 
        } -ModuleName $script:DSCResourceName -Verifiable

        Context 'When the system is not in the desired state' {
            It 'Should return the state as absent when desired database does not exist' {
                $testParameters = $defaultParameters
                $testParameters += @{
                    Name = 'UnknownDatabase'
                }

                $result = Test-TargetResource @testParameters
                $result | Should Be $false

                Assert-MockCalled Connect-SQL -Exactly -Times 1 -ModuleName $script:DSCResourceName -Scope It 
            }

            It 'Should return the state as present when desired database exist' {
                $testParameters = $defaultParameters
                $testParameters += @{
                    Name = 'AdventureWorks'
                }

                $result = Test-TargetResource @testParameters
                $result | Should Be $true

                Assert-MockCalled Connect-SQL -Exactly -Times 1 -ModuleName $script:DSCResourceName -Scope It 
            }
        }

        Context 'When the system is in the desired state' {
            It 'Should return the state as present when desired database exist' {
                $testParameters = $defaultParameters
                $testParameters += @{
                    Name = 'AdventureWorks'
                }

                $result = Test-TargetResource @testParameters
                $result | Should Be $true

                Assert-MockCalled Connect-SQL -Exactly -Times 1 -ModuleName $script:DSCResourceName -Scope It 
            }
            
            It 'Should return the state as absent when desired database does not exist' {
                $testParameters = $defaultParameters
                $testParameters += @{
                    Name = 'UnknownDatabase'
                }

                $result = Test-TargetResource @testParameters
                $result | Should Be $false

                Assert-MockCalled Connect-SQL -Exactly -Times 1 -ModuleName $script:DSCResourceName -Scope It 
            }
        }

        Assert-VerifiableMocks
    }
    
    Describe "$($script:DSCResourceName)\Set-TargetResource" {
        Mock -CommandName Connect-SQL -MockWith {
            return New-Object Object | 
                Add-Member ScriptProperty Databases {
                    return @{
                        'AdventureWorks' = @( ( New-Object Microsoft.SqlServer.Management.Smo.Database -ArgumentList @( $null, 'AdventureWorks') ) )
                    }
                } -PassThru -Force 
        } -ModuleName $script:DSCResourceName -Verifiable

        Mock -CommandName New-SqlDatabase -MockWith {} -ModuleName $script:DSCResourceName -Verifiable        
        Mock -CommandName Remove-SqlDatabase -MockWith {} -ModuleName $script:DSCResourceName -Verifiable

        Context 'When the system is not in the desired state' {
            It 'Should call the function New-SqlDatabase when desired database should be present' {
                $testParameters = $defaultParameters
                $testParameters += @{
                    Name = 'NewDatabase'
                    Ensure = 'Present'
                }

                Set-TargetResource @testParameters

                Assert-MockCalled Connect-SQL -Exactly -Times 1 -ModuleName $script:DSCResourceName -Scope It
                Assert-MockCalled New-SqlDatabase -Exactly -Times 1 -ModuleName $script:DSCResourceName -Scope It
            }
        }

        Context 'When the system is not in the desired state' {
            It 'Should call the function Remove-SqlDatabase when desired database should be absent' {
                $testParameters = $defaultParameters
                $testParameters += @{
                    Name = 'AdventureWorks'
                    Ensure = 'Absent'
                }             

                Set-TargetResource @testParameters

                Assert-MockCalled Connect-SQL -Exactly -Times 1 -ModuleName $script:DSCResourceName -Scope It
                Assert-MockCalled Remove-SqlDatabase -Exactly -Times 1 -ModuleName $script:DSCResourceName -Scope It
            }
        }
    }
}
finally
{
    #region FOOTER

    Restore-TestEnvironment -TestEnvironment $TestEnvironment 

    #endregion
}
