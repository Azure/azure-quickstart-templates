# Suppressing this rule because PlainText is required for one of the functions used in this test
[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingConvertToSecureStringWithPlainText', '')]
param ()

$script:DSCModuleName      = 'xSQLServer' 
$script:DSCResourceName    = 'MSFT_xSQLAOGroupEnsure' 

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

try
{

    #region Pester Test Initialization

    # Loading mocked classes
    Add-Type -Path (Join-Path -Path $script:moduleRoot -ChildPath 'Tests\Unit\Stubs\SMO.cs')

    $mockpassword = "dummyPassw0rd" | ConvertTo-SecureString -asPlainText -Force
    $mockusername = "dba" 
    $mockcredential = New-Object System.Management.Automation.PSCredential($mockusername,$mockpassword)

    #endregion Pester Test Initialization
    
    #region Get-TargetResource
    Describe 'Get-TargetResource' {
        Mock -CommandName Connect-SQL -MockWith {
            # build a custom object to return which is close to the real SMO object
            $smoObj = [PSCustomObject] @{
                SQLServer = 'Node01'
                SQLInstanceName = 'Prd01'
                ClusterName = 'Clust01'
            }

            # add the AvailabilityGroups entry as this is an ArrayList and allows us the functionality later
            $smoObj | Add-Member -MemberType NoteProperty -Name 'AvailabilityGroups' -Value @{
                'AG01' = @{
                    AvailabilityGroupListeners = @{ 
                        name = 'AgList01'
                        availabilitygrouplisteneripaddresses = [System.Collections.ArrayList] @(@{IpAddress = '192.168.0.1'; SubnetMask = '255.255.255.0'})
                        portnumber = 5022
                    }
                    
                    AvailabilityDatabases = @(
                        @{
                            name='AdventureWorks'
                        } 
                    )
                }
            }

            $smoObj.AvailabilityGroups['AG01'] | Add-Member -MemberType NoteProperty -Name Name -Value 'AG01' -Force
            $smoObj.AvailabilityGroups | Add-Member -MemberType ScriptMethod -Name 'Add' -Value {
                 return $true 
            } -Force

            $smoObj.AvailabilityGroups['AG01'] | Add-Member -MemberType ScriptMethod -Name ToString -Value {
                return 'AG01'
            } -Force

            $smoObj.AvailabilityGroups['AG01'] | Add-Member -MemberType ScriptMethod -Name Drop -Value {
                return $true
            } -Force

            return $smoObj
        }  -ModuleName $script:DSCResourceName
        
        Context "When the system is in the desired state" {
            $SqlAOGroup = Get-TargetResource -Ensure 'Present' -AvailabilityGroupName 'AG01' -SQLServer 'localhost' -SQLInstanceName 'MSSQLSERVER' -SetupCredential $mockcredential
    
            It 'Should return hashtable with Ensure = $true'{
                $SqlAOGroup.Ensure | Should Be $true
            }
         }
    
         Context "When the system is not in the desired state" {
            $SqlAOGroup = Get-TargetResource -Ensure 'Absent' -AvailabilityGroupName 'AG01' -SQLServer 'localhost' -SQLInstanceName 'MSSQLSERVER' -SetupCredential $mockcredential
    
            It 'Should return hashtable with Ensure = $false' {
                $SqlAOGroup.Ensure | Should Be $false
            }
         }
    }
    #endregion Get-TargetResource

    #region Test-TargetResource
    Describe 'Test-TargetResource' {
        Mock -CommandName Connect-SQL -MockWith {
            # build a custom object to return which is close to the real SMO object
            $smoObj = [PSCustomObject] @{
                SQLServer = 'Node01'
                SQLInstanceName = 'Prd01'
                ClusterName = 'Clust01'
            }

            # add the AvailabilityGroups entry as this is an ArrayList and allows us the functionality later
            $smoObj | Add-Member -MemberType NoteProperty -Name 'AvailabilityGroups' -Value @{
                'AG01' = @{
                    AvailabilityGroupListeners = @{ 
                        name = 'AgList01'
                        availabilitygrouplisteneripaddresses = [System.Collections.ArrayList] @(@{IpAddress = '192.168.0.1'; SubnetMask = '255.255.255.0'})
                        portnumber = 5022
                    }
                    
                    AvailabilityDatabases = @(
                        @{
                            name='AdventureWorks'
                        }
                    )
                }
            }

            $smoObj.AvailabilityGroups['AG01'] | Add-Member -MemberType NoteProperty -Name Name -Value 'AG01' -Force
            $smoObj.AvailabilityGroups | Add-Member -MemberType ScriptMethod -Name 'Add' -Value {
                return $true
            } -Force

            $smoObj.AvailabilityGroups['AG01'] | Add-Member -MemberType ScriptMethod -Name ToString -Value {
                return 'AG01'
            } -Force

            $smoObj.AvailabilityGroups['AG01'] | Add-Member -MemberType ScriptMethod -Name Drop -Value {
                return $true
            } -Force

            return $smoObj
        } -ModuleName $script:DSCResourceName
    
        Context "When the system is in the desired state" {
            $SqlAOGroupTest = Test-TargetResource -Ensure 'Present' -AvailabilityGroupName 'AG01' -SQLServer 'localhost' -SQLInstanceName 'MSSQLSERVER' -SetupCredential $mockcredential
    
            It 'Should return $true'{
                $SqlAOGroupTest | Should Be $true
            }
         }
    
         Context "When the system is not in the desired state" {
            $SqlAOGroupTest = Test-TargetResource -Ensure 'Absent' -AvailabilityGroupName 'AG01' -SQLServer 'localhost' -SQLInstanceName 'MSSQLSERVER' -SetupCredential $mockcredential
    
            It 'Should return $false' {
                $SqlAOGroupTest | Should Be $false
            }
         }
    }
    #endregion Test-TargetResource

    Describe 'Set-TargetResource' {
        # Mocking the module FailoverCluster, to be able to mock the function Get-ClusterNode
        Get-Module -Name FailoverClusters | Remove-Module
        New-Module -Name FailoverClusters  -ScriptBlock {
            # This was generated by Write-ModuleStubFile function from the folder Tests\Unit\Stubs
            function Get-ClusterNode {
                [CmdletBinding(DefaultParameterSetName='InputObject', HelpUri='http://go.microsoft.com/fwlink/?LinkId=216215')]
                param(
                    [Parameter(Position=0)]
                    [ValidateNotNullOrEmpty()]
                    [System.Collections.Specialized.StringCollection]
                    ${Name},

                    [Parameter(ParameterSetName='InputObject', ValueFromPipeline=$true)]
                    [ValidateNotNull()]
                    [psobject]
                    ${InputObject},

                    [ValidateNotNullOrEmpty()]
                    [string]
                    ${Cluster}
                )

                throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
            }
        
            Export-ModuleMember -Function *-Cluster*
        } | Import-Module -Force

        Mock Grant-ServerPerms -MockWith {} -ModuleName $script:DSCResourceName -Verifiable
        Mock New-ListenerADObject -MockWith {} -ModuleName $script:DSCResourceName -Verifiable
        Mock Get-ClusterNode -MockWith {
            $clusterNode = @(
                [PSCustomObject] @{
                    Name = 'Node01'
                }, 
                [PSCustomObject] @{
                    Name = 'Node02'
                },
                [PSCustomObject] @{
                    Name = 'Node03'
                },
                [PSCustomObject] @{
                    Name = 'Node04'
                }
            )
            return $clusterNode
        } -ModuleName $script:DSCResourceName -Verifiable

        Mock Connect-SQL -MockWith {
            # build a custom object to return which is close to the real SMO object
            $smoObj = [PSCustomObject] @{
                SQLServer = 'Node01'
                SQLInstanceName = 'Prd01'
                ClusterName = 'Clust01'
            }

            # add the AvailabilityGroups entry as this is an ArrayList and allows us the functionality later
            $smoObj | Add-Member -MemberType NoteProperty -Name 'AvailabilityGroups' -Value @{
                'AG01' = @{
                    AvailabilityGroupListeners = @{ 
                        name = 'AgList01'
                        availabilitygrouplisteneripaddresses = [System.Collections.ArrayList] @(@{IpAddress = '192.168.0.1'; SubnetMask = '255.255.255.0'})
                        portnumber = 5022
                    }

                    AvailabilityDatabases = @(
                        @{
                            name='AdventureWorks'
                        }
                    )
                }
            }

            $smoObj.AvailabilityGroups | Add-Member -MemberType ScriptMethod -Name 'Add' -Value {return $true} -Force
            $smoObj.AvailabilityGroups['AG01'] | Add-Member -MemberType NoteProperty -Name Name -Value 'AG01' -Force
            $smoObj.AvailabilityGroups['AG01'] | Add-Member -MemberType ScriptMethod -Name ToString -Value {return 'AG01'} -Force
            $smoObj.AvailabilityGroups['AG01'] | Add-Member -MemberType ScriptMethod -Name Drop -Value {return $true} -Force

            return $smoObj
        } -ModuleName $script:DSCResourceName -Verifiable

        Mock New-Object -MockWith {
            Param($TypeName)
            Switch ($TypeName)
            {
                'Microsoft.SqlServer.Management.Smo.AvailabilityGroup' {
                    $object = [PSCustomObject] @{
                                Name = "MockedObject"
                                AutomatedBackupPreference = ''
                                FailureConditionLevel = ''
                                HealthCheckTimeout = ''
                                AvailabilityReplicas = [System.Collections.ArrayList] @()
                                AvailabilityGroupListeners = [System.Collections.ArrayList] @()
                            }
                    $object | Add-Member -MemberType ScriptMethod -Name Create -Value {return $true}
                }

                'Microsoft.SqlServer.Management.Smo.AvailabilityReplica' {
                    $object = [PSCustomObject] @{
                                Name = "MockedObject"
                                EndpointUrl = ''
                                FailoverMode = ''
                                AvailabilityMode = ''
                                BackupPriority = 0
                                ConnectionModeInPrimaryRole = ''
                                ConnectionModeInSecondaryRole = ''
                             }
                }

                'Microsoft.SqlServer.Management.Smo.AvailabilityGroupListener' {
                    $object = [PSCustomObject] @{
                                Name = "MockedObject"
                                PortNumber = ''
                                AvailabilityGroupListenerIPAddresses = [System.Collections.ArrayList] @()
                            }
                }

                'Microsoft.SqlServer.Management.Smo.AvailabilityGroupListenerIPAddress' {
                    $object = [PSCustomObject] @{
                                Name = "MockedObject"
                                IsDHCP = ''
                                IPAddress = ''
                                SubnetMask = ''
                            }
                }

                Default {
                    $object = [PSCustomObject] @{
                                Name = "MockedObject"
                            }
                }
            }

            return $object
        } -ModuleName $script:DSCResourceName -Verifiable

        Context "When the system is not in the desired state" {
            $params = @{
                Ensure = 'Present'
                AvailabilityGroupName = 'AG01'
                AvailabilityGroupNameListener = 'AgList01'
                AvailabilityGroupNameIP = '192.168.0.1'
                AvailabilityGroupSubMask = '255.255.255.0'
                AvailabilityGroupPort = 1433
                ReadableSecondary = 'ReadOnly'
                AutoBackupPreference = 'Primary'
                SQLServer = 'localhost'
                SQLInstanceName = 'MSSQLSERVER'
                SetupCredential = $mockcredential
            }

            It 'Should not throw when calling Set-method' {
                { Set-TargetResource @Params } | Should Not Throw
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
