$script:DSCModuleName      = 'xSQLServer'
$script:DSCResourceName    = 'MSFT_xSQLServerEndpointPermission'

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
    $instanceName = 'DEFAULT'
    $principal = 'COMPANY\SqlServiceAcct'
    $otherPrincipal = 'COMPANY\OtherAcct'
    $endpointName = 'DefaultEndpointMirror'

    $defaultParameters = @{
        InstanceName = $instanceName
        NodeName = $nodeName 
        Name = $endpointName
        Principal = $principal
    }

    #endregion Pester Test Initialization

    Describe "$($script:DSCResourceName)\Get-TargetResource" {
        Context 'When the system is not in the desired state' {
            $testParameters = $defaultParameters

            Mock -CommandName Get-SQLAlwaysOnEndpoint -MockWith {
                # TypeName: Microsoft.SqlServer.Management.Smo.Endpoint
                return New-Object Object | 
                    Add-Member NoteProperty Name $endpointName -PassThru | 
                    Add-Member ScriptMethod EnumObjectPermissions {
                        param($permissionSet)
                        return @(
                            (New-Object Object |
                                Add-Member NoteProperty Grantee $otherPrincipal -PassThru |
                                Add-Member NoteProperty PermissionState 'Grant' -PassThru
                            )
                        )
                    } -PassThru -Force 
            } -ModuleName $script:DSCResourceName -Verifiable
    
            $result = Get-TargetResource @testParameters

            It 'Should return the desired state as absent' {
                $result.Ensure | Should Be 'Absent'
            }

            It 'Should return the same values as passed as parameters' {
                $result.NodeName | Should Be $testParameters.NodeName
                $result.InstanceName | Should Be $testParameters.InstanceName
                $result.Name | Should Be $testParameters.Name
                $result.Principal | Should Be $testParameters.Principal
            }

            It 'Should not return any permissions' {
                $result.Permission | Should Be ''
            }

            It 'Should call the mock function Get-SQLAlwaysOnEndpoint' {
                 Assert-MockCalled Get-SQLAlwaysOnEndpoint -Exactly -Times 1 -ModuleName $script:DSCResourceName -Scope Context 
            }
        }
    
        Context 'When the system is in the desired state' {
            $testParameters = $defaultParameters

            Mock -CommandName Get-SQLAlwaysOnEndpoint -MockWith {
                # TypeName: Microsoft.SqlServer.Management.Smo.Endpoint
                return New-Object Object | 
                    Add-Member NoteProperty Name $endpointName -PassThru | 
                    Add-Member ScriptMethod EnumObjectPermissions {
                        param($permissionSet)
                        return @(
                            (New-Object Object |
                                Add-Member NoteProperty Grantee $principal -PassThru |
                                Add-Member NoteProperty PermissionState 'Grant' -PassThru
                            )
                        )
                    } -PassThru -Force 
            } -ModuleName $script:DSCResourceName -Verifiable
    
            $result = Get-TargetResource @testParameters

            It 'Should return the desired state as present' {
                $result.Ensure | Should Be 'Present'
            }

            It 'Should return the same values as passed as parameters' {
                $result.NodeName | Should Be $testParameters.NodeName
                $result.InstanceName | Should Be $testParameters.InstanceName
                $result.Name | Should Be $testParameters.Name
                $result.Principal | Should Be $testParameters.Principal
            }

            It 'Should return the permissions passed as parameter' {
                $result.Permission | Should Be 'CONNECT'
            }

            It 'Should call the mock function Get-SQLAlwaysOnEndpoint' {
                 Assert-MockCalled Get-SQLAlwaysOnEndpoint -Exactly -Times 1 -ModuleName $script:DSCResourceName -Scope Context 
            }
        }

        Assert-VerifiableMocks
    }

    Describe "$($script:DSCResourceName)\Test-TargetResource" {
        Context 'When the system is not in the desired state' {
            $testParameters = $defaultParameters
            $testParameters += @{
                Ensure = 'Present'
                Permission = 'CONNECT'
            }

            It 'Should return that desired state is absent when wanted desired state is to be Present' {
                Mock -CommandName Get-SQLAlwaysOnEndpoint -MockWith {
                    # TypeName: Microsoft.SqlServer.Management.Smo.Endpoint
                    return New-Object Object | 
                        Add-Member NoteProperty Name $endpointName -PassThru | 
                        Add-Member ScriptMethod EnumObjectPermissions {
                            param($permissionSet)
                            return @(
                                (New-Object Object |
                                    Add-Member NoteProperty Grantee $otherPrincipal -PassThru |
                                    Add-Member NoteProperty PermissionState 'Grant' -PassThru
                                )
                            )
                        } -PassThru -Force 
                } -ModuleName $script:DSCResourceName -Verifiable

                $result = Test-TargetResource @testParameters
                $result | Should Be $false

                Assert-MockCalled Get-SQLAlwaysOnEndpoint -Exactly -Times 1 -ModuleName $script:DSCResourceName -Scope It
            }

            $testParameters = $defaultParameters
            $testParameters += @{
                Ensure = 'Absent'
                Permission = 'CONNECT'
            }

            It 'Should return that desired state is absent when wanted desired state is to be Absent' {
                Mock -CommandName Get-SQLAlwaysOnEndpoint -MockWith {
                    # TypeName: Microsoft.SqlServer.Management.Smo.Endpoint
                    return New-Object Object | 
                        Add-Member NoteProperty Name $endpointName -PassThru | 
                        Add-Member ScriptMethod EnumObjectPermissions {
                            param($permissionSet)
                            return @(
                                (New-Object Object |
                                    Add-Member NoteProperty Grantee $principal -PassThru |
                                    Add-Member NoteProperty PermissionState 'Grant' -PassThru
                                )
                            )
                        } -PassThru -Force 
                } -ModuleName $script:DSCResourceName -Verifiable

                $result = Test-TargetResource @testParameters
                $result | Should Be $false

                Assert-MockCalled Get-SQLAlwaysOnEndpoint -Exactly -Times 1 -ModuleName $script:DSCResourceName -Scope It
            }
        }

        Context 'When the system is in the desired state' {
            It 'Should return that desired state is present when wanted desired state is to be Present' {
                $testParameters = $defaultParameters
                $testParameters += @{
                    Ensure = 'Present'
                    Permission = 'CONNECT'
                }

                Mock -CommandName Get-SQLAlwaysOnEndpoint -MockWith {
                    # TypeName: Microsoft.SqlServer.Management.Smo.Endpoint
                    return New-Object Object | 
                        Add-Member NoteProperty Name $endpointName -PassThru | 
                        Add-Member ScriptMethod EnumObjectPermissions {
                            param($permissionSet)
                            return @(
                                (New-Object Object |
                                    Add-Member NoteProperty Grantee $principal -PassThru |
                                    Add-Member NoteProperty PermissionState 'Grant' -PassThru
                                )
                            )
                        } -PassThru -Force 
                } -ModuleName $script:DSCResourceName -Verifiable

                $result = Test-TargetResource @testParameters
                $result | Should Be $true

                Assert-MockCalled Get-SQLAlwaysOnEndpoint -Exactly -Times 1 -ModuleName $script:DSCResourceName -Scope It
            }

            It 'Should return that desired state is present when wanted desired state is to be Absent' {
                $testParameters = $defaultParameters
                $testParameters += @{
                    Ensure = 'Absent'
                    Permission = 'CONNECT'
                }

                Mock -CommandName Get-SQLAlwaysOnEndpoint -MockWith {
                    # TypeName: Microsoft.SqlServer.Management.Smo.Endpoint
                    return New-Object Object | 
                        Add-Member NoteProperty Name $endpointName -PassThru | 
                        Add-Member ScriptMethod EnumObjectPermissions {
                            param($permissionSet)
                            return @(
                                (New-Object Object |
                                    Add-Member NoteProperty Grantee $otherPrincipal -PassThru |
                                    Add-Member NoteProperty PermissionState 'Grant' -PassThru
                                )
                            )
                        } -PassThru -Force 
                } -ModuleName $script:DSCResourceName -Verifiable

                $result = Test-TargetResource @testParameters
                $result | Should Be $true

                Assert-MockCalled Get-SQLAlwaysOnEndpoint -Exactly -Times 1 -ModuleName $script:DSCResourceName -Scope It
            }
        }

        Assert-VerifiableMocks
    }

    Describe "$($script:DSCResourceName)\Set-TargetResource" {
        Context 'When the system is not in the desired state' {
            It 'Should call the the method Grant when desired state is to be Present' {
                $testParameters = $defaultParameters
                $testParameters += @{
                    Ensure = 'Present'
                    Permission = 'CONNECT'
                }

                Mock -CommandName Get-SQLAlwaysOnEndpoint -MockWith {
                    # TypeName: Microsoft.SqlServer.Management.Smo.Endpoint
                    return New-Object Object | 
                        Add-Member NoteProperty Name $endpointName -PassThru | 
                        Add-Member ScriptMethod EnumObjectPermissions {
                            param($permissionSet)
                            return @(
                                (New-Object Object |
                                    Add-Member NoteProperty Grantee $otherPrincipal -PassThru |
                                    Add-Member NoteProperty PermissionState 'Grant' -PassThru
                                )
                            )
                        } -PassThru | 
                        Add-Member ScriptMethod Grant {
                            param(
                                $permissionSet, 
                                $principal 
                            )
                            return
                        } -PassThru | 
                        Add-Member ScriptMethod Revoke {
                            param(
                                $permissionSet, 
                                $principal 
                            )
                            throw 'Called Revoke() when it shouldn''t been called'
                        } -PassThru -Force 
                } -ModuleName $script:DSCResourceName -Verifiable

                { Set-TargetResource @testParameters } | Should Not Throw

                Assert-MockCalled Get-SQLAlwaysOnEndpoint -Exactly -Times 2 -ModuleName $script:DSCResourceName -Scope It
            }

            It 'Should call the the method Revoke when desired state is to be Absent' {
                $testParameters = $defaultParameters
                $testParameters += @{
                    Ensure = 'Absent'
                    Permission = 'CONNECT'
                }

                Mock -CommandName Get-SQLAlwaysOnEndpoint -MockWith {
                    # TypeName: Microsoft.SqlServer.Management.Smo.Endpoint
                    return New-Object Object | 
                        Add-Member NoteProperty Name $endpointName -PassThru | 
                        Add-Member ScriptMethod EnumObjectPermissions {
                            param($permissionSet)
                            return @(
                                (New-Object Object |
                                    Add-Member NoteProperty Grantee $principal -PassThru |
                                    Add-Member NoteProperty PermissionState 'Grant' -PassThru
                                )
                            )
                        } -PassThru | 
                        Add-Member ScriptMethod Grant {
                            param(
                                $permissionSet, 
                                $principal 
                            )
                            throw 'Called Grant() when it shouldn''t been called'
                        } -PassThru | 
                        Add-Member ScriptMethod Revoke {
                            param(
                                $permissionSet, 
                                $principal 
                            )
                            return
                        } -PassThru -Force 
                } -ModuleName $script:DSCResourceName -Verifiable

                { Set-TargetResource @testParameters } | Should Not Throw

                Assert-MockCalled Get-SQLAlwaysOnEndpoint -Exactly -Times 2 -ModuleName $script:DSCResourceName -Scope It
            }
        }

        Context 'When the system is in the desired state' {
            It 'Should not throw error when desired state is already Present' {
                $testParameters = $defaultParameters
                $testParameters += @{
                    Ensure = 'Present'
                    Permission = 'CONNECT'
                }

                Mock -CommandName Get-SQLAlwaysOnEndpoint -MockWith {
                    # TypeName: Microsoft.SqlServer.Management.Smo.Endpoint
                    return New-Object Object | 
                        Add-Member NoteProperty Name $endpointName -PassThru | 
                        Add-Member ScriptMethod EnumObjectPermissions {
                            param($permissionSet)
                            return @(
                                (New-Object Object |
                                    Add-Member NoteProperty Grantee $principal -PassThru |
                                    Add-Member NoteProperty PermissionState 'Grant' -PassThru
                                )
                            )
                        } -PassThru | 
                        Add-Member ScriptMethod Grant {
                            param(
                                $permissionSet, 
                                $principal 
                            )
                            throw 'Called Grant() when it shouldn''t been called'
                        } -PassThru | 
                        Add-Member ScriptMethod Revoke {
                            param(
                                $permissionSet, 
                                $principal 
                            )
                            throw 'Called Revoke() when it shouldn''t been called'
                        } -PassThru -Force 
                } -ModuleName $script:DSCResourceName -Verifiable

                { Set-TargetResource @testParameters } | Should Not Throw

                Assert-MockCalled Get-SQLAlwaysOnEndpoint -Exactly -Times 1 -ModuleName $script:DSCResourceName -Scope It
            }

            It 'Should not throw error when desired state is already Absent' {
                $testParameters = $defaultParameters
                $testParameters += @{
                    Ensure = 'Absent'
                    Permission = 'CONNECT'
                }

                Mock -CommandName Get-SQLAlwaysOnEndpoint -MockWith {
                    # TypeName: Microsoft.SqlServer.Management.Smo.Endpoint
                    return New-Object Object | 
                        Add-Member NoteProperty Name $endpointName -PassThru | 
                        Add-Member ScriptMethod EnumObjectPermissions {
                            param($permissionSet)
                            return @(
                                (New-Object Object |
                                    Add-Member NoteProperty Grantee $otherPrincipal -PassThru |
                                    Add-Member NoteProperty PermissionState 'Grant' -PassThru
                                )
                            )
                        } -PassThru | 
                        Add-Member ScriptMethod Grant {
                            param(
                                $permissionSet, 
                                $principal 
                            )
                            throw 'Called Grant() when it shouldn''t been called'
                        } -PassThru | 
                        Add-Member ScriptMethod Revoke {
                            param(
                                $permissionSet, 
                                $principal 
                            )
                            throw 'Called Revoke() when it shouldn''t been called'
                        } -PassThru -Force 
                } -ModuleName $script:DSCResourceName -Verifiable

                { Set-TargetResource @testParameters } | Should Not Throw

                Assert-MockCalled Get-SQLAlwaysOnEndpoint -Exactly -Times 1 -ModuleName $script:DSCResourceName -Scope It
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
