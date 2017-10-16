$script:DSCModuleName      = 'xSQLServer'
$script:DSCResourceName    = 'MSFT_xSQLServerAvailabilityGroupListener'

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

    # Loading stub cmdlets
    Import-Module (Join-Path -Path $script:moduleRoot -ChildPath 'Tests\Unit\Stubs\SQLPSStub.psm1') -Force

    # Static parameter values
    $nodeName = 'localhost'
    $instanceName = 'DEFAULT'
    $availabilityGroup = 'AG01'
    $listnerName = 'AGListner'
    
    $defaultParameters = @{
        InstanceName = $instanceName
        NodeName = $nodeName 
        Name = $listnerName
        AvailabilityGroup = $availabilityGroup
    }

    #endregion Pester Test Initialization

    Describe "$($script:DSCResourceName)\Get-TargetResource" {
        Context 'When the system is not in the desired state' {
            $testParameters = $defaultParameters

            Mock -CommandName Get-SQLAlwaysOnAvailabilityGroupListener -MockWith {} -ModuleName $script:DSCResourceName -Verifiable
    
            $result = Get-TargetResource @testParameters

            It 'Should return the desired state as absent' {
                $result.Ensure | Should Be 'Absent'
            }

            It 'Should return the same values as passed as parameters' {
                $result.NodeName | Should Be $testParameters.NodeName
                $result.InstanceName | Should Be $testParameters.InstanceName
                $result.Name | Should Be $testParameters.Name
                $result.AvailabilityGroup | Should Be $testParameters.AvailabilityGroup
            }

            It 'Should not return any IP addresses' {
                $result.IpAddress | Should Be $null
            }

            It 'Should not return port' {
                $result.Port | Should Be 0
            }

            It 'Should return that DHCP is not used' {
                $result.DHCP | Should Be $false
            }

            It 'Should call the mock function Get-SQLAlwaysOnAvailabilityGroupListener' {
                 Assert-MockCalled Get-SQLAlwaysOnAvailabilityGroupListener -Exactly -Times 1 -ModuleName $script:DSCResourceName -Scope Context 
            }
        }

        Context 'When the system is in the desired state, without DHCP' {
            $testParameters = $defaultParameters

            Mock -CommandName Get-SQLAlwaysOnAvailabilityGroupListener -MockWith {
                # TypeName: Microsoft.SqlServer.Management.Smo.AvailabilityGroupListener
                return New-Object Object | 
                    Add-Member NoteProperty PortNumber 5030 -PassThru | 
                    Add-Member ScriptProperty AvailabilityGroupListenerIPAddresses {
                        return @(
                            # TypeName: Microsoft.SqlServer.Management.Smo.AvailabilityGroupListenerIPAddressCollection
                            (New-Object Object |    # TypeName: Microsoft.SqlServer.Management.Smo.AvailabilityGroupListenerIPAddress
                                Add-Member NoteProperty IsDHCP $false -PassThru | 
                                Add-Member NoteProperty IPAddress '192.168.0.1' -PassThru |
                                Add-Member NoteProperty SubnetMask '255.255.255.0' -PassThru
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
                $result.AvailabilityGroup | Should Be $testParameters.AvailabilityGroup
            }

            It 'Should return correct IP address' {
                $result.IpAddress | Should Be '192.168.0.1/255.255.255.0'
            }

            It 'Should return correct port' {
                $result.Port | Should Be 5030
            }

            It 'Should return that DHCP is not used' {
                $result.DHCP | Should Be $false
            }

            It 'Should call the mock function Get-SQLAlwaysOnAvailabilityGroupListener' {
                 Assert-MockCalled Get-SQLAlwaysOnAvailabilityGroupListener -Exactly -Times 1 -ModuleName $script:DSCResourceName -Scope Context 
            }
        }

        Context 'When the system is in the desired state, with DHCP' {
            $testParameters = $defaultParameters

            Mock -CommandName Get-SQLAlwaysOnAvailabilityGroupListener -MockWith {
                # TypeName: Microsoft.SqlServer.Management.Smo.AvailabilityGroupListener
                return New-Object Object | 
                    Add-Member NoteProperty PortNumber 5031 -PassThru | 
                    Add-Member ScriptProperty AvailabilityGroupListenerIPAddresses {
                        return @(
                            # TypeName: Microsoft.SqlServer.Management.Smo.AvailabilityGroupListenerIPAddressCollection
                            (New-Object Object |    # TypeName: Microsoft.SqlServer.Management.Smo.AvailabilityGroupListenerIPAddress
                                Add-Member NoteProperty IsDHCP $true -PassThru | 
                                Add-Member NoteProperty IPAddress '192.168.0.1' -PassThru |
                                Add-Member NoteProperty SubnetMask '255.255.255.0' -PassThru
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
                $result.AvailabilityGroup | Should Be $testParameters.AvailabilityGroup
            }

            It 'Should return correct IP address' {
                $result.IpAddress | Should Be '192.168.0.1/255.255.255.0'
            }

            It 'Should return correct port' {
                $result.Port | Should Be 5031
            }

            It 'Should return that DHCP is used' {
                $result.DHCP | Should Be $true
            }

            It 'Should call the mock function Get-SQLAlwaysOnAvailabilityGroupListener' {
                 Assert-MockCalled Get-SQLAlwaysOnAvailabilityGroupListener -Exactly -Times 1 -ModuleName $script:DSCResourceName -Scope Context 
            }
        }

        Assert-VerifiableMocks
    }

    Describe "$($script:DSCResourceName)\Test-TargetResource" {
        Context 'When the system is not in the desired state (for static IP)' {
            It 'Should return that desired state is absent when wanted desired state is to be Present' {
                $testParameters = $defaultParameters
                $testParameters += @{
                    Ensure = 'Present'
                    IpAddress = '192.168.10.45/255.255.252.0'
                    Port = 5030
                    DHCP = $false
                }            

                Mock -CommandName Get-SQLAlwaysOnAvailabilityGroupListener -MockWith {} -ModuleName $script:DSCResourceName -Verifiable

                $result = Test-TargetResource @testParameters
                $result | Should Be $false

                Assert-MockCalled Get-SQLAlwaysOnAvailabilityGroupListener -Exactly -Times 1 -ModuleName $script:DSCResourceName -Scope It 
            }

            Mock -CommandName Get-SQLAlwaysOnAvailabilityGroupListener -MockWith {
                # TypeName: Microsoft.SqlServer.Management.Smo.AvailabilityGroupListener
                return New-Object Object | 
                    Add-Member NoteProperty PortNumber 5030 -PassThru | 
                    Add-Member ScriptProperty AvailabilityGroupListenerIPAddresses {
                        return @(
                            # TypeName: Microsoft.SqlServer.Management.Smo.AvailabilityGroupListenerIPAddressCollection
                            (New-Object Object |    # TypeName: Microsoft.SqlServer.Management.Smo.AvailabilityGroupListenerIPAddress
                                Add-Member NoteProperty IsDHCP $false -PassThru | 
                                Add-Member NoteProperty IPAddress '192.168.0.1' -PassThru |
                                Add-Member NoteProperty SubnetMask '255.255.255.0' -PassThru
                            )
                        )
                    } -PassThru -Force 
            } -ModuleName $script:DSCResourceName -Verifiable

            It 'Should return that desired state is absent when wanted desired state is to be Absent' {
                $testParameters = $defaultParameters
                $testParameters += @{
                    Ensure = 'Absent'
                }            

                $result = Test-TargetResource @testParameters
                $result | Should Be $false

                Assert-MockCalled Get-SQLAlwaysOnAvailabilityGroupListener -Exactly -Times 1 -ModuleName $script:DSCResourceName -Scope It 
            }

            It 'Should return that desired state is absent when IP address is different' {
                $testParameters = $defaultParameters
                $testParameters += @{
                    Ensure = 'Present'
                    IpAddress = '192.168.10.45/255.255.252.0'
                    Port = 5030
                    DHCP = $false
                }            

                $result = Test-TargetResource @testParameters
                $result | Should Be $false

                Assert-MockCalled Get-SQLAlwaysOnAvailabilityGroupListener -Exactly -Times 1 -ModuleName $script:DSCResourceName -Scope It 
            }

            It 'Should return that desired state is absent when DHCP is absent but should be present' {
                $testParameters = $defaultParameters
                $testParameters += @{
                    Ensure = 'Present'
                    IpAddress = '192.168.0.1/255.255.255.0'
                    Port = 5030
                    DHCP = $true
                }            

                $result = Test-TargetResource @testParameters
                $result | Should Be $false

                Assert-MockCalled Get-SQLAlwaysOnAvailabilityGroupListener -Exactly -Times 1 -ModuleName $script:DSCResourceName -Scope It 
            }

            It 'Should return that desired state is absent when DHCP is the only set parameter' {
                $testParameters = $defaultParameters
                $testParameters += @{
                    DHCP = $true
                }            

                $result = Test-TargetResource @testParameters
                $result | Should Be $false

                Assert-MockCalled Get-SQLAlwaysOnAvailabilityGroupListener -Exactly -Times 1 -ModuleName $script:DSCResourceName -Scope It 
            }

            Mock -CommandName Get-SQLAlwaysOnAvailabilityGroupListener -MockWith {
                # TypeName: Microsoft.SqlServer.Management.Smo.AvailabilityGroupListener
                return New-Object Object | 
                    Add-Member NoteProperty PortNumber 5555 -PassThru | 
                    Add-Member ScriptProperty AvailabilityGroupListenerIPAddresses { 
                        return @(
                            # TypeName: Microsoft.SqlServer.Management.Smo.AvailabilityGroupListenerIPAddressCollection
                            (New-Object Object |    # TypeName: Microsoft.SqlServer.Management.Smo.AvailabilityGroupListenerIPAddress
                                Add-Member NoteProperty IsDHCP $false -PassThru | 
                                Add-Member NoteProperty IPAddress '192.168.0.1' -PassThru |
                                Add-Member NoteProperty SubnetMask '255.255.255.0' -PassThru
                            )
                        )
                    } -PassThru -Force 
            } -ModuleName $script:DSCResourceName -Verifiable

            It 'Should return that desired state is absent when port is different' {
                $testParameters = $defaultParameters
                $testParameters += @{
                    Ensure = 'Present'
                    IpAddress = '192.168.0.1/255.255.255.0'
                    Port = 5030
                    DHCP = $false
                }            

                $result = Test-TargetResource @testParameters
                $result | Should Be $false

                Assert-MockCalled Get-SQLAlwaysOnAvailabilityGroupListener -Exactly -Times 1 -ModuleName $script:DSCResourceName -Scope It 
            }
        }

        Context 'When the system is not in the desired state (for DHCP)' {
            Mock -CommandName Get-SQLAlwaysOnAvailabilityGroupListener -MockWith {
                # TypeName: Microsoft.SqlServer.Management.Smo.AvailabilityGroupListener
                return New-Object Object | 
                    Add-Member NoteProperty PortNumber 5030 -PassThru | 
                    Add-Member ScriptProperty AvailabilityGroupListenerIPAddresses {
                        return @(
                            # TypeName: Microsoft.SqlServer.Management.Smo.AvailabilityGroupListenerIPAddressCollection
                            (New-Object Object |    # TypeName: Microsoft.SqlServer.Management.Smo.AvailabilityGroupListenerIPAddress
                                Add-Member NoteProperty IsDHCP $true -PassThru | 
                                Add-Member NoteProperty IPAddress '192.168.0.1' -PassThru |
                                Add-Member NoteProperty SubnetMask '255.255.255.0' -PassThru
                            )
                        )
                    } -PassThru -Force 
            } -ModuleName $script:DSCResourceName -Verifiable

            It 'Should return that desired state is absent when DHCP is present but should be absent' {
                $testParameters = $defaultParameters
                $testParameters += @{
                    Ensure = 'Present'
                    IpAddress = '192.168.0.100/255.255.255.0'
                    Port = 5030
                    DHCP = $false
                }            

                $result = Test-TargetResource @testParameters
                $result | Should Be $false

                Assert-MockCalled Get-SQLAlwaysOnAvailabilityGroupListener -Exactly -Times 1 -ModuleName $script:DSCResourceName -Scope It 
            }

            It 'Should return that desired state is absent when IP address is the only set parameter' {
                $testParameters = $defaultParameters
                $testParameters += @{
                    IpAddress = '192.168.10.45/255.255.252.0'
                }            

                $result = Test-TargetResource @testParameters
                $result | Should Be $false

                Assert-MockCalled Get-SQLAlwaysOnAvailabilityGroupListener -Exactly -Times 1 -ModuleName $script:DSCResourceName -Scope It 
            }

            Mock -CommandName Get-SQLAlwaysOnAvailabilityGroupListener -MockWith {
                # TypeName: Microsoft.SqlServer.Management.Smo.AvailabilityGroupListener
                return New-Object Object | 
                    Add-Member NoteProperty PortNumber 5555 -PassThru | 
                    Add-Member ScriptProperty AvailabilityGroupListenerIPAddresses {
                        return @(
                            # TypeName: Microsoft.SqlServer.Management.Smo.AvailabilityGroupListenerIPAddressCollection
                            (New-Object Object |    # TypeName: Microsoft.SqlServer.Management.Smo.AvailabilityGroupListenerIPAddress
                                Add-Member NoteProperty IsDHCP $true -PassThru | 
                                Add-Member NoteProperty IPAddress '192.168.0.1' -PassThru |
                                Add-Member NoteProperty SubnetMask '255.255.255.0' -PassThru
                            )
                        )
                    } -PassThru -Force 
            } -ModuleName $script:DSCResourceName -Verifiable

            It 'Should return that desired state is absent when port is the only set parameter' {
                $testParameters = $defaultParameters
                $testParameters += @{
                    Port = 5030
                }            

                $result = Test-TargetResource @testParameters
                $result | Should Be $false

                Assert-MockCalled Get-SQLAlwaysOnAvailabilityGroupListener -Exactly -Times 1 -ModuleName $script:DSCResourceName -Scope It 
            }
        }

        Context 'When the system is in the desired state (for static IP)' {
            It 'Should return that desired state is present when wanted desired state is to be Absent' {
                $testParameters = $defaultParameters
                $testParameters += @{
                    Ensure = 'Absent'
                    IpAddress = '192.168.10.45/255.255.252.0'
                    Port = 5030
                    DHCP = $false
                }            

                Mock -CommandName Get-SQLAlwaysOnAvailabilityGroupListener -MockWith {} -ModuleName $script:DSCResourceName -Verifiable

                $result = Test-TargetResource @testParameters
                $result | Should Be $true

                Assert-MockCalled Get-SQLAlwaysOnAvailabilityGroupListener -Exactly -Times 1 -ModuleName $script:DSCResourceName -Scope It 
            }

            Mock -CommandName Get-SQLAlwaysOnAvailabilityGroupListener -MockWith {
                # TypeName: Microsoft.SqlServer.Management.Smo.AvailabilityGroupListener
                return New-Object Object | 
                    Add-Member NoteProperty PortNumber 5030 -PassThru | 
                    Add-Member ScriptProperty AvailabilityGroupListenerIPAddresses {
                        return @(
                            # TypeName: Microsoft.SqlServer.Management.Smo.AvailabilityGroupListenerIPAddressCollection
                            (New-Object Object |    # TypeName: Microsoft.SqlServer.Management.Smo.AvailabilityGroupListenerIPAddress
                                Add-Member NoteProperty IsDHCP $false -PassThru | 
                                Add-Member NoteProperty IPAddress '192.168.0.1' -PassThru |
                                Add-Member NoteProperty SubnetMask '255.255.255.0' -PassThru
                            )
                        )
                    } -PassThru -Force 
            } -ModuleName $script:DSCResourceName -Verifiable

            It 'Should return that desired state is present when wanted desired state is to be Present, without DHCP' {
                $testParameters = $defaultParameters
                $testParameters += @{
                    Ensure = 'Present'
                    IpAddress = '192.168.0.1/255.255.255.0'
                    Port = 5030
                    DHCP = $false
                }            

                $result = Test-TargetResource @testParameters
                $result | Should Be $true

                Assert-MockCalled Get-SQLAlwaysOnAvailabilityGroupListener -Exactly -Times 1 -ModuleName $script:DSCResourceName -Scope It 
            }

            It 'Should return that desired state is present when IP address is the only set parameter' {
                $testParameters = $defaultParameters
                $testParameters += @{
                    IpAddress = '192.168.0.1/255.255.255.0'
                }            

                $result = Test-TargetResource @testParameters
                $result | Should Be $true

                Assert-MockCalled Get-SQLAlwaysOnAvailabilityGroupListener -Exactly -Times 1 -ModuleName $script:DSCResourceName -Scope It 
            }

            It 'Should return that desired state is present when port is the only set parameter' {
                $testParameters = $defaultParameters
                $testParameters += @{
                    Port = 5030
                }            

                $result = Test-TargetResource @testParameters
                $result | Should Be $true

                Assert-MockCalled Get-SQLAlwaysOnAvailabilityGroupListener -Exactly -Times 1 -ModuleName $script:DSCResourceName -Scope It 
            }
        }

        Context 'When the system is in the desired state (for DHCP)' {
            Mock -CommandName Get-SQLAlwaysOnAvailabilityGroupListener -MockWith {
                # TypeName: Microsoft.SqlServer.Management.Smo.AvailabilityGroupListener
                return New-Object Object | 
                    Add-Member NoteProperty PortNumber 5030 -PassThru | 
                    Add-Member ScriptProperty AvailabilityGroupListenerIPAddresses {
                        return @(
                            # TypeName: Microsoft.SqlServer.Management.Smo.AvailabilityGroupListenerIPAddressCollection
                            (New-Object Object |    # TypeName: Microsoft.SqlServer.Management.Smo.AvailabilityGroupListenerIPAddress
                                Add-Member NoteProperty IsDHCP $true -PassThru | 
                                Add-Member NoteProperty IPAddress '192.168.0.1' -PassThru |
                                Add-Member NoteProperty SubnetMask '255.255.255.0' -PassThru
                            )
                        )
                    } -PassThru -Force 
            } -ModuleName $script:DSCResourceName -Verifiable

            It 'Should return that desired state is present when wanted desired state is to be Present, with DHCP' {
                $testParameters = $defaultParameters
                $testParameters += @{
                    Ensure = 'Present'
                    IpAddress = '192.168.0.1/255.255.255.0'
                    Port = 5030
                    DHCP = $true
                }            

                $result = Test-TargetResource @testParameters
                $result | Should Be $true

                Assert-MockCalled Get-SQLAlwaysOnAvailabilityGroupListener -Exactly -Times 1 -ModuleName $script:DSCResourceName -Scope It 
            }

            It 'Should return that desired state is present when DHCP is the only set parameter' {
                $testParameters = $defaultParameters
                $testParameters += @{
                    DHCP = $true
                }            

                $result = Test-TargetResource @testParameters
                $result | Should Be $true

                Assert-MockCalled Get-SQLAlwaysOnAvailabilityGroupListener -Exactly -Times 1 -ModuleName $script:DSCResourceName -Scope It 
            }
        }

        Assert-VerifiableMocks
    }

    Describe "$($script:DSCResourceName)\Set-TargetResource" {
        Mock -CommandName New-SqlAvailabilityGroupListener -MockWith {} -ModuleName $script:DSCResourceName -Verifiable
        Mock -CommandName Set-SqlAvailabilityGroupListener -MockWith {} -ModuleName $script:DSCResourceName -Verifiable
        Mock -CommandName Add-SqlAvailabilityGroupListenerStaticIp -MockWith {} -ModuleName $script:DSCResourceName -Verifiable

        Context 'When the system is not in the desired state' {
            It 'Should call the cmdlet New-SqlAvailabilityGroupListener when system is not in desired state' {
                $testParameters = $defaultParameters
                $testParameters += @{
                    Ensure = 'Present'
                    IpAddress = '192.168.10.45/255.255.252.0'
                    Port = 5030
                    DHCP = $false
                }            

                Mock -CommandName Get-SQLAlwaysOnAvailabilityGroupListener -MockWith {} -ModuleName $script:DSCResourceName -Verifiable

                Set-TargetResource @testParameters | Out-Null

                Assert-MockCalled Get-SQLAlwaysOnAvailabilityGroupListener -Exactly -Times 1 -ModuleName $script:DSCResourceName -Scope It 
                Assert-MockCalled New-SqlAvailabilityGroupListener -Exactly -Times 1 -ModuleName $script:DSCResourceName -Scope It
                Assert-MockCalled Set-SqlAvailabilityGroupListener -Exactly -Times 0 -ModuleName $script:DSCResourceName -Scope It
                Assert-MockCalled Add-SqlAvailabilityGroupListenerStaticIp -Exactly -Times 0 -ModuleName $script:DSCResourceName -Scope It
            }

            Mock -CommandName Get-SQLAlwaysOnAvailabilityGroupListener -MockWith {
                # TypeName: Microsoft.SqlServer.Management.Smo.AvailabilityGroupListener
                return New-Object Object | 
                    Add-Member NoteProperty PortNumber 5030 -PassThru | 
                    Add-Member ScriptProperty AvailabilityGroupListenerIPAddresses {
                        return @(
                            # TypeName: Microsoft.SqlServer.Management.Smo.AvailabilityGroupListenerIPAddressCollection
                            (New-Object Object |    # TypeName: Microsoft.SqlServer.Management.Smo.AvailabilityGroupListenerIPAddress
                                Add-Member NoteProperty IsDHCP $false -PassThru | 
                                Add-Member NoteProperty IPAddress '192.168.0.1' -PassThru |
                                Add-Member NoteProperty SubnetMask '255.255.255.0' -PassThru
                            )
                        )
                    } -PassThru -Force 
            } -ModuleName $script:DSCResourceName -Verifiable

            It 'Should throw when trying to change an existing IP address' {
                $testParameters = $defaultParameters
                $testParameters += @{
                    IpAddress = '10.0.0.1/255.255.252.0'
                    Port = 5030
                    DHCP = $false
                }            

                { Set-TargetResource @testParameters } | Should Throw

                Assert-MockCalled Get-SQLAlwaysOnAvailabilityGroupListener -Exactly -Times 1 -ModuleName $script:DSCResourceName -Scope It 
                Assert-MockCalled New-SqlAvailabilityGroupListener -Exactly -Times 0 -ModuleName $script:DSCResourceName -Scope It
                Assert-MockCalled Set-SqlAvailabilityGroupListener -Exactly -Times 0 -ModuleName $script:DSCResourceName -Scope It
                Assert-MockCalled Add-SqlAvailabilityGroupListenerStaticIp -Exactly -Times 0 -ModuleName $script:DSCResourceName -Scope It
            }

            It 'Should throw when trying to change from static IP to DHCP' {
                $testParameters = $defaultParameters
                $testParameters += @{
                    IpAddress = '192.168.0.1/255.255.255.0'
                    Port = 5030
                    DHCP = $true
                }            

                { Set-TargetResource @testParameters } | Should Throw

                Assert-MockCalled Get-SQLAlwaysOnAvailabilityGroupListener -Exactly -Times 1 -ModuleName $script:DSCResourceName -Scope It 
                Assert-MockCalled New-SqlAvailabilityGroupListener -Exactly -Times 0 -ModuleName $script:DSCResourceName -Scope It
                Assert-MockCalled Set-SqlAvailabilityGroupListener -Exactly -Times 0 -ModuleName $script:DSCResourceName -Scope It
                Assert-MockCalled Add-SqlAvailabilityGroupListenerStaticIp -Exactly -Times 0 -ModuleName $script:DSCResourceName -Scope It
            }

            It 'Should call the cmdlet Add-SqlAvailabilityGroupListenerStaticIp, when adding another IP address, and system is not in desired state' {
                $testParameters = $defaultParameters
                $testParameters += @{
                    IpAddress = @('192.168.0.1/255.255.255.0','10.0.0.1/255.255.252.0')
                    Port = 5030
                    DHCP = $false
                }            

                Set-TargetResource @testParameters | Out-Null

                Assert-MockCalled Get-SQLAlwaysOnAvailabilityGroupListener -Exactly -Times 1 -ModuleName $script:DSCResourceName -Scope It 
                Assert-MockCalled New-SqlAvailabilityGroupListener -Exactly -Times 0 -ModuleName $script:DSCResourceName -Scope It
                Assert-MockCalled Set-SqlAvailabilityGroupListener -Exactly -Times 0 -ModuleName $script:DSCResourceName -Scope It
                Assert-MockCalled Add-SqlAvailabilityGroupListenerStaticIp -Exactly -Times 1 -ModuleName $script:DSCResourceName -Scope It
            }

            Mock -CommandName Get-SQLAlwaysOnAvailabilityGroupListener -MockWith {
                # TypeName: Microsoft.SqlServer.Management.Smo.AvailabilityGroupListener
                return New-Object Object | 
                    Add-Member NoteProperty PortNumber 5555 -PassThru | 
                    Add-Member ScriptProperty AvailabilityGroupListenerIPAddresses {
                        return @(
                            # TypeName: Microsoft.SqlServer.Management.Smo.AvailabilityGroupListenerIPAddressCollection
                            (New-Object Object |    # TypeName: Microsoft.SqlServer.Management.Smo.AvailabilityGroupListenerIPAddress
                                Add-Member NoteProperty IsDHCP $false -PassThru | 
                                Add-Member NoteProperty IPAddress '192.168.10.45' -PassThru |
                                Add-Member NoteProperty SubnetMask '255.255.252.0' -PassThru
                            )
                        )
                    } -PassThru -Force 
            } -ModuleName $script:DSCResourceName -Verifiable

            It 'Should call the cmdlet Set-SqlAvailabilityGroupListener when port is not in desired state' {
                $testParameters = $defaultParameters
                $testParameters += @{
                    IpAddress = '192.168.10.45/255.255.252.0'
                    Port = 5030
                    DHCP = $false
                }            

                Set-TargetResource @testParameters | Out-Null

                Assert-MockCalled Get-SQLAlwaysOnAvailabilityGroupListener -Exactly -Times 1 -ModuleName $script:DSCResourceName -Scope It 
                Assert-MockCalled New-SqlAvailabilityGroupListener -Exactly -Times 0 -ModuleName $script:DSCResourceName -Scope It
                Assert-MockCalled Set-SqlAvailabilityGroupListener -Exactly -Times 1 -ModuleName $script:DSCResourceName -Scope It
                Assert-MockCalled Add-SqlAvailabilityGroupListenerStaticIp -Exactly -Times 0 -ModuleName $script:DSCResourceName -Scope It
            }
        }

        Mock -CommandName Get-SQLAlwaysOnAvailabilityGroupListener -MockWith {
            # TypeName: Microsoft.SqlServer.Management.Smo.AvailabilityGroupListener
            return New-Object Object | 
                Add-Member NoteProperty PortNumber 5030 -PassThru | 
                Add-Member ScriptProperty AvailabilityGroupListenerIPAddresses {
                    return @(
                        # TypeName: Microsoft.SqlServer.Management.Smo.AvailabilityGroupListenerIPAddressCollection
                        (New-Object Object |    # TypeName: Microsoft.SqlServer.Management.Smo.AvailabilityGroupListenerIPAddress
                            Add-Member NoteProperty IsDHCP $false -PassThru | 
                            Add-Member NoteProperty IPAddress '192.168.0.1' -PassThru |
                            Add-Member NoteProperty SubnetMask '255.255.255.0' -PassThru
                        )
                    )
                } -PassThru -Force 
        } -ModuleName $script:DSCResourceName -Verifiable

        Context 'When the system is in the desired state' {
            It 'Should not call the any cmdlet *-SqlAvailability* when system is in desired state' {
                $testParameters = $defaultParameters
                $testParameters += @{
                    Ensure = 'Present'
                    IpAddress = '192.168.0.1/255.255.255.0'
                    Port = 5030
                    DHCP = $false
                }            

                Set-TargetResource @testParameters | Out-Null

                Assert-MockCalled Get-SQLAlwaysOnAvailabilityGroupListener -Exactly -Times 1 -ModuleName $script:DSCResourceName -Scope It 
                Assert-MockCalled New-SqlAvailabilityGroupListener -Exactly -Times 0 -ModuleName $script:DSCResourceName -Scope It
                Assert-MockCalled Set-SqlAvailabilityGroupListener -Exactly -Times 0 -ModuleName $script:DSCResourceName -Scope It
                Assert-MockCalled Add-SqlAvailabilityGroupListenerStaticIp -Exactly -Times 0 -ModuleName $script:DSCResourceName -Scope It
            }

            It 'Should not call the any cmdlet *-SqlAvailability* when system is in desired state (without ensure parameter)' {
                $testParameters = $defaultParameters
                $testParameters += @{
                    IpAddress = '192.168.0.1/255.255.255.0'
                    Port = 5030
                }            

                Set-TargetResource @testParameters | Out-Null

                Assert-MockCalled Get-SQLAlwaysOnAvailabilityGroupListener -Exactly -Times 1 -ModuleName $script:DSCResourceName -Scope It 
                Assert-MockCalled New-SqlAvailabilityGroupListener -Exactly -Times 0 -ModuleName $script:DSCResourceName -Scope It
                Assert-MockCalled Set-SqlAvailabilityGroupListener -Exactly -Times 0 -ModuleName $script:DSCResourceName -Scope It
                Assert-MockCalled Add-SqlAvailabilityGroupListenerStaticIp -Exactly -Times 0 -ModuleName $script:DSCResourceName -Scope It
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
