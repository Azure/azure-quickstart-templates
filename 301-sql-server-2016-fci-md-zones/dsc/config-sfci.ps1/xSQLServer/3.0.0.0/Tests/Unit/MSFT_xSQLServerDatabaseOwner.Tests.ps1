$script:DSCModuleName      = 'xSQLServer'
$script:DSCResourceName    = 'MSFT_xSQLServerDatabaseOwner'

#region HEADER

# Unit Test Template Version: 1.1.0
[String] $script:moduleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
if ( (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests'))) -or `
     (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1'))) )
{
    & git @('clone','https://github.com/PowerShell/DscResource.Tests.git',(Join-Path -Path $script:moduleRoot -ChildPath '\DSCResource.Tests\'))
}

Import-Module (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1') -Force

$TestEnvironment = Initialize-TestEnvironment -DSCModuleName $script:DSCModuleName `
                                              -DSCResourceName $script:DSCResourceName `
                                              -TestType Unit 
#endregion HEADER

# Begin Testing
try
{
    #region Pester Test Initialization

    # Loading mocked classes
    Add-Type -Path (Join-Path -Path $script:moduleRoot -ChildPath 'Tests\Unit\Stubs\SMO.cs')

    $defaultParameters = @{
        SQLInstanceName = 'MSSQLSERVER'
        SQLServer = 'localhost'
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
                Database = 'AdventureWorks'
                Name = 'CONTOSO\SqlServiceAcct'
            }

            Mock -CommandName Get-SqlDatabaseOwner -MockWith { 
                return $null
            } -ModuleName $script:DSCResourceName -Verifiable

            $result = Get-TargetResource @testParameters

            It 'Should return the name as null from the get method' {
                $result.Name | Should Be $null
            }

            It 'Should return the same values as passed as parameters' {
                $result.SQLServer | Should Be $testParameters.SQLServer
                $result.SQLInstanceName | Should Be $testParameters.SQLInstanceName
                $result.Database | Should Be $testParameters.Database
            }

            It 'Should call the mock functions Connect-SQL and Get-SqlDatabaseOwner' {
                 Assert-MockCalled Connect-SQL -Exactly -Times 1 -ModuleName $script:DSCResourceName -Scope Context
                 Assert-MockCalled Get-SqlDatabaseOwner -Exactly -Times 1 -ModuleName $script:DSCResourceName -Scope Context
            }
        }

        Context 'When the specified database does not exist' {
            $testParameters = $defaultParameters
            $testParameters += @{
                Database = 'UnknownDatabase'
                Name = 'CONTOSO\SqlServiceAcct'
            }

            Mock -CommandName Get-SqlDatabaseOwner -MockWith { 
                return $null
            } -ModuleName $script:DSCResourceName -Verifiable

            $result = Get-TargetResource @testParameters

            It 'Should return the name as null from the get method' {
                $result.Name | Should Be $null
            }

            It 'Should return the same values as passed as parameters' {
                $result.SQLServer | Should Be $testParameters.SQLServer
                $result.SQLInstanceName | Should Be $testParameters.SQLInstanceName
                $result.Database | Should Be $testParameters.Database
            }

            It 'Should call the mock functions Connect-SQL and Get-SqlDatabaseOwner' {
                 Assert-MockCalled Connect-SQL -Exactly -Times 1 -ModuleName $script:DSCResourceName -Scope Context
                 Assert-MockCalled Get-SqlDatabaseOwner -Exactly -Times 1 -ModuleName $script:DSCResourceName -Scope Context
            }
        }

        Context 'When the system is in the desired state' {
            $testParameters = $defaultParameters
            $testParameters += @{
                Database = 'AdventureWorks'
                Name = 'CONTOSO\SqlServiceAcct'
            }

            Mock -CommandName Get-SqlDatabaseOwner -MockWith { return 'CONTOSO\SqlServiceAcct' } -ModuleName $script:DSCResourceName -Verifiable

            $result = Get-TargetResource @testParameters

            It 'Should return the name of the owner from the get method' {
                $result.Name | Should Be $testParameters.Name
            }

            It 'Should return the same values as passed as parameters' {
                $result.SQLServer | Should Be $testParameters.SQLServer
                $result.SQLInstanceName | Should Be $testParameters.SQLInstanceName
                $result.Database | Should Be $testParameters.Database
            }

            It 'Should call the mock functions Connect-SQL and Get-SqlDatabaseOwner' {
                 Assert-MockCalled Connect-SQL -Exactly -Times 1 -ModuleName $script:DSCResourceName -Scope Context
                 Assert-MockCalled Get-SqlDatabaseOwner -Exactly -Times 1 -ModuleName $script:DSCResourceName -Scope Context
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
            It 'Should return the state as false when desired login is not the database owner' {
                $testParameters = $defaultParameters
                $testParameters += @{
                    Database = 'AdventureWorks'
                    Name = 'CONTOSO\SqlServiceAcct'
                }       

                Mock -CommandName Get-SqlDatabaseOwner -MockWith { 
                    return $null
                } -ModuleName $script:DSCResourceName -Verifiable

                $result = Test-TargetResource @testParameters
                $result | Should Be $false

                Assert-MockCalled Connect-SQL -Exactly -Times 1 -ModuleName $script:DSCResourceName -Scope It
                Assert-MockCalled Get-SqlDatabaseOwner -Exactly -Times 1 -ModuleName $script:DSCResourceName -Scope It
            }
        }

        Context 'When the system is in the desired state' {
            It 'Should return the state as true when desired login is the database owner' {
                $testParameters = $defaultParameters
                $testParameters += @{
                    Database = 'AdventureWorks'
                    Name = 'CONTOSO\SqlServiceAcct'
                } 

                Mock -CommandName Get-SqlDatabaseOwner -MockWith { 
                    'CONTOSO\SqlServiceAcct' 
                } -ModuleName $script:DSCResourceName -Verifiable

                $result = Test-TargetResource @testParameters
                $result | Should Be $true

                Assert-MockCalled Connect-SQL -Exactly -Times 1 -ModuleName $script:DSCResourceName -Scope It
                Assert-MockCalled Get-SqlDatabaseOwner -Exactly -Times 1 -ModuleName $script:DSCResourceName -Scope It
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

        Context 'When the system is not in the desired state' {
            $testParameters = $defaultParameters
            $testParameters += @{
                Database = 'AdventureWorks'
                Name = 'CONTOSO\SqlServiceAcct'
            }

            It 'Should call the function Set-SqlDatabaseOwner when desired login is not the database owner' {
                Mock -CommandName Set-SqlDatabaseOwner -MockWith { } -ModuleName $script:DSCResourceName -Verifiable
                
                Set-TargetResource @testParameters
               
                Assert-MockCalled Connect-SQL -Exactly -Times 1 -ModuleName $script:DSCResourceName -Scope It
                Assert-MockCalled Set-SqlDatabaseOwner -Exactly -Times 1 -ModuleName $script:DSCResourceName -Scope It
            }
            
            $testParameters.Database = 'UnknownDatabase'

            It 'Should throw an error when desired database does not exist' {
                Mock -CommandName Set-SqlDatabaseOwner -MockWith {
                    return Throw
                } -ModuleName $script:DSCResourceName -Verifiable
                
                { Set-TargetResource @testParameters } | Should Throw "Failed to setting the owner of database UnknownDatabase"
                
                Assert-MockCalled Connect-SQL -Exactly -Times 1 -ModuleName $script:DSCResourceName -Scope It
                Assert-MockCalled Set-SqlDatabaseOwner -Exactly -Times 1 -ModuleName $script:DSCResourceName -Scope It
            }
        }

        Context 'When the system is in the desired state' {
            $testParameters = $defaultParameters
            $testParameters += @{
                Database = 'AdventureWorks'
                Name = 'CONTOSO\SqlServiceAcct'
            }

            It 'Should not call the function Set-SqlDatabaseOwner when desired login is the database owner' {
                Mock -CommandName Get-SqlDatabaseOwner -MockWith { 
                    'CONTOSO\SqlServiceAcct' 
                } -ModuleName $script:DSCResourceName -Verifiable
                
                $result = Get-TargetResource @testParameters
             
                Assert-MockCalled Connect-SQL -Exactly -Times 1 -ModuleName $script:DSCResourceName -Scope It
                Assert-MockCalled Get-SqlDatabaseOwner -Exactly -Times 1 -ModuleName $script:DSCResourceName -Scope It
                Assert-MockCalled Set-SqlDatabaseOwner -Exactly -Times 0 -ModuleName $script:DSCResourceName -Scope It
            }
        }

        Assert-VerifiableMocks
    }
}
finally
{
    #region FOOTER

    Restore-TestEnvironment -TestEnvironment $TestEnvironment 

    #endregion
}
