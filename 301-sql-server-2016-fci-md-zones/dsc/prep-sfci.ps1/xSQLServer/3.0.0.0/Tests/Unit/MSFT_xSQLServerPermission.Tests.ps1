$script:DSCModuleName      = 'xSQLServer'
$script:DSCResourceName    = 'MSFT_xSQLServerPermission'

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
    $permission = @( 'AlterAnyAvailabilityGroup','ViewServerState' )

    #endregion Pester Test Initialization

    $defaultParameters = @{
        InstanceName = $instanceName
        NodeName = $nodeName
        Principal = $principal
        Permission = $permission
    }

    Describe "$($script:DSCResourceName)\Get-TargetResource" {
        Context 'When the system is not in the desired state' {
            Mock -CommandName Get-SQLPSInstance -MockWith {
                [Microsoft.SqlServer.Management.Smo.Globals]::GenerateMockData = $false

                $mockObjectSmoServer = New-Object Microsoft.SqlServer.Management.Smo.Server
                $mockObjectSmoServer.Name = "$nodeName\$instanceName"
                $mockObjectSmoServer.DisplayName = $instanceName
                $mockObjectSmoServer.InstanceName = $instanceName
                $mockObjectSmoServer.IsHadrEnabled = $False
                $mockObjectSmoServer.MockGranteeName = $principal

                return $mockObjectSmoServer
            } -ModuleName $script:DSCResourceName -Verifiable
    
            $testParameters = $defaultParameters

            $result = Get-TargetResource @testParameters

            It 'Should return the desired state as absent' {
                $result.Ensure | Should Be 'Absent'
            }

            It 'Should return the same values as passed as parameters' {
                $result.NodeName | Should Be $nodeName
                $result.InstanceName | Should Be $instanceName
                $result.Principal | Should Be $principal
            }

            It 'Should not return any permissions' {
                $result.Permission | Should Be $null
            }

            It 'Should call the mock function Get-SQLPSInstance' {
                 Assert-MockCalled Get-SQLPSInstance -Exactly -Times 1 -ModuleName $script:DSCResourceName -Scope Context 
            }
        }
    
        Context 'When the system is in the desired state' {
            Mock -CommandName Get-SQLPSInstance -MockWith {
                [Microsoft.SqlServer.Management.Smo.Globals]::GenerateMockData = $true

                $mockObjectSmoServer = New-Object Microsoft.SqlServer.Management.Smo.Server
                $mockObjectSmoServer.Name = "$nodeName\$instanceName"
                $mockObjectSmoServer.DisplayName = $instanceName
                $mockObjectSmoServer.InstanceName = $instanceName
                $mockObjectSmoServer.IsHadrEnabled = $False
                $mockObjectSmoServer.MockGranteeName = $principal

                return $mockObjectSmoServer
            } -ModuleName $script:DSCResourceName -Verifiable
    
            $testParameters = $defaultParameters

            $result = Get-TargetResource @testParameters

            It 'Should return the desired state as present' {
                $result.Ensure | Should Be 'Present'
            }

            It 'Should return the same values as passed as parameters' {
                $result.NodeName | Should Be $nodeName
                $result.InstanceName | Should Be $instanceName
                $result.Principal | Should Be $principal
            }

            It 'Should return the permissions passed as parameter' {
                foreach ($currentPermission in $permission) {
                    if( $result.Permission -ccontains $currentPermission ) {
                        $permissionState = $true 
                    } else {
                        $permissionState = $false
                        break
                    }
                } 
                
                $permissionState | Should Be $true
            }

            It 'Should call the mock function Get-SQLPSInstance' {
                 Assert-MockCalled Get-SQLPSInstance -Exactly -Times 1 -ModuleName $script:DSCResourceName -Scope Context 
            }
        }

        Assert-VerifiableMocks
    }

    Describe "$($script:DSCResourceName)\Test-TargetResource" {
        Context 'When the system is not in the desired state' {
            It 'Should return that desired state is absent when wanted desired state is to be Present' {
                Mock -CommandName Get-SQLPSInstance -MockWith {
                    [Microsoft.SqlServer.Management.Smo.Globals]::GenerateMockData = $false

                    $mockObjectSmoServer = New-Object Microsoft.SqlServer.Management.Smo.Server
                    $mockObjectSmoServer.Name = "$nodeName\$instanceName"
                    $mockObjectSmoServer.DisplayName = $instanceName
                    $mockObjectSmoServer.InstanceName = $instanceName
                    $mockObjectSmoServer.IsHadrEnabled = $False
                    $mockObjectSmoServer.MockGranteeName = $principal

                    return $mockObjectSmoServer
                } -ModuleName $script:DSCResourceName -Verifiable
        
                $testParameters = $defaultParameters
                $testParameters += @{
                    Ensure = 'Present'
                }

                $result = Test-TargetResource @testParameters
                $result | Should Be $false

                 Assert-MockCalled Get-SQLPSInstance -Exactly -Times 1 -ModuleName $script:DSCResourceName -Scope It 
            }

            It 'Should return that desired state is absent when wanted desired state is to be Absent' {
                Mock -CommandName Get-SQLPSInstance -MockWith {
                    [Microsoft.SqlServer.Management.Smo.Globals]::GenerateMockData = $true

                    $mockObjectSmoServer = New-Object Microsoft.SqlServer.Management.Smo.Server
                    $mockObjectSmoServer.Name = "$nodeName\$instanceName"
                    $mockObjectSmoServer.DisplayName = $instanceName
                    $mockObjectSmoServer.InstanceName = $instanceName
                    $mockObjectSmoServer.IsHadrEnabled = $False
                    $mockObjectSmoServer.MockGranteeName = $principal

                    return $mockObjectSmoServer
                } -ModuleName $script:DSCResourceName -Verifiable
        
                $testParameters = $defaultParameters
                $testParameters += @{
                    Ensure = 'Absent'
                }

                $result = Test-TargetResource @testParameters
                $result | Should Be $false

                Assert-MockCalled Get-SQLPSInstance -Exactly -Times 1 -ModuleName $script:DSCResourceName -Scope It 
            }
        }

        Context 'When the system is in the desired state' {
            It 'Should return that desired state is present when wanted desired state is to be Present' {
                Mock -CommandName Get-SQLPSInstance -MockWith {
                    [Microsoft.SqlServer.Management.Smo.Globals]::GenerateMockData = $true

                    $mockObjectSmoServer = New-Object Microsoft.SqlServer.Management.Smo.Server
                    $mockObjectSmoServer.Name = "$nodeName\$instanceName"
                    $mockObjectSmoServer.DisplayName = $instanceName
                    $mockObjectSmoServer.InstanceName = $instanceName
                    $mockObjectSmoServer.IsHadrEnabled = $False
                    $mockObjectSmoServer.MockGranteeName = $principal

                    return $mockObjectSmoServer
                } -ModuleName $script:DSCResourceName -Verifiable
        
                $testParameters = $defaultParameters
                $testParameters += @{
                    Ensure = 'Present'
                }

                $result = Test-TargetResource @testParameters
                $result | Should Be $true

                 Assert-MockCalled Get-SQLPSInstance -Exactly -Times 1 -ModuleName $script:DSCResourceName -Scope It 
            }

            It 'Should return that desired state is present when wanted desired state is to be Absent' {
                Mock -CommandName Get-SQLPSInstance -MockWith {
                    [Microsoft.SqlServer.Management.Smo.Globals]::GenerateMockData = $false

                    $mockObjectSmoServer = New-Object Microsoft.SqlServer.Management.Smo.Server
                    $mockObjectSmoServer.Name = "$nodeName\$instanceName"
                    $mockObjectSmoServer.DisplayName = $instanceName
                    $mockObjectSmoServer.InstanceName = $instanceName
                    $mockObjectSmoServer.IsHadrEnabled = $False
                    $mockObjectSmoServer.MockGranteeName = $principal

                    return $mockObjectSmoServer
                } -ModuleName $script:DSCResourceName -Verifiable
        
                $testParameters = $defaultParameters
                $testParameters += @{
                    Ensure = 'Absent'
                }

                $result = Test-TargetResource @testParameters
                $result | Should Be $true

                Assert-MockCalled Get-SQLPSInstance -Exactly -Times 1 -ModuleName $script:DSCResourceName -Scope It 
            }
        }

        Assert-VerifiableMocks
    }

    Describe "$($script:DSCResourceName)\Set-TargetResource" {
        Context 'When the system is not in the desired state' {
            It 'Should not throw error when desired state is to be Present' {
                Mock -CommandName Get-SQLPSInstance -MockWith {
                    [Microsoft.SqlServer.Management.Smo.Globals]::GenerateMockData = $false

                    $mockObjectSmoServer = New-Object Microsoft.SqlServer.Management.Smo.Server
                    $mockObjectSmoServer.Name = "$nodeName\$instanceName"
                    $mockObjectSmoServer.DisplayName = $instanceName
                    $mockObjectSmoServer.InstanceName = $instanceName
                    $mockObjectSmoServer.IsHadrEnabled = $False
                    $mockObjectSmoServer.MockGranteeName = $principal   

                    return $mockObjectSmoServer
                } -ModuleName $script:DSCResourceName -Verifiable
        
                $testParameters = $defaultParameters
                $testParameters += @{
                    Ensure = 'Present'
                }

                { Set-TargetResource @testParameters } | Should Not Throw

                 Assert-MockCalled Get-SQLPSInstance -Exactly -Times 2 -ModuleName $script:DSCResourceName -Scope It 
            }

            It 'Should not throw error when desired state is to be Absent' {
                Mock -CommandName Get-SQLPSInstance -MockWith {
                    [Microsoft.SqlServer.Management.Smo.Globals]::GenerateMockData = $true

                    $mockObjectSmoServer = New-Object Microsoft.SqlServer.Management.Smo.Server
                    $mockObjectSmoServer.Name = "$nodeName\$instanceName"
                    $mockObjectSmoServer.DisplayName = $instanceName
                    $mockObjectSmoServer.InstanceName = $instanceName
                    $mockObjectSmoServer.IsHadrEnabled = $False
                    $mockObjectSmoServer.MockGranteeName = $principal

                    return $mockObjectSmoServer
                } -ModuleName $script:DSCResourceName -Verifiable
        
                $testParameters = $defaultParameters
                $testParameters += @{
                    Ensure = 'Absent'
                }

                { Set-TargetResource @testParameters } | Should Not Throw

                 Assert-MockCalled Get-SQLPSInstance -Exactly -Times 2 -ModuleName $script:DSCResourceName -Scope It 
            }
        }

        Context 'When the system is in the desired state' {
            It 'Should not throw error when desired state is to be Present' {
                Mock -CommandName Get-SQLPSInstance -MockWith {
                    [Microsoft.SqlServer.Management.Smo.Globals]::GenerateMockData = $true

                    $mockObjectSmoServer = New-Object Microsoft.SqlServer.Management.Smo.Server
                    $mockObjectSmoServer.Name = "$nodeName\$instanceName"
                    $mockObjectSmoServer.DisplayName = $instanceName
                    $mockObjectSmoServer.InstanceName = $instanceName
                    $mockObjectSmoServer.IsHadrEnabled = $False
                    $mockObjectSmoServer.MockGranteeName = 'Should not call Grant() or Revoke()'   

                    return $mockObjectSmoServer
                } -ModuleName $script:DSCResourceName -Verifiable
        
                $testParameters = $defaultParameters
                $testParameters += @{
                    Ensure = 'Present'
                }

                { Set-TargetResource @testParameters } | Should Not Throw

                 Assert-MockCalled Get-SQLPSInstance -Exactly -Times 1 -ModuleName $script:DSCResourceName -Scope It 
            }

            It 'Should not throw error when desired state is to be Absent' {
                Mock -CommandName Get-SQLPSInstance -MockWith {
                    [Microsoft.SqlServer.Management.Smo.Globals]::GenerateMockData = $false

                    $mockObjectSmoServer = New-Object Microsoft.SqlServer.Management.Smo.Server
                    $mockObjectSmoServer.Name = "$nodeName\$instanceName"
                    $mockObjectSmoServer.DisplayName = $instanceName
                    $mockObjectSmoServer.InstanceName = $instanceName
                    $mockObjectSmoServer.IsHadrEnabled = $False
                    $mockObjectSmoServer.MockGranteeName = 'Should not call Grant() or Revoke()'

                    return $mockObjectSmoServer
                } -ModuleName $script:DSCResourceName -Verifiable
        
                $testParameters = $defaultParameters
                $testParameters += @{
                    Ensure = 'Absent'
                }

                { Set-TargetResource @testParameters } | Should Not Throw

                 Assert-MockCalled Get-SQLPSInstance -Exactly -Times 1 -ModuleName $script:DSCResourceName -Scope It 
            }
        }
#>
        Assert-VerifiableMocks
    }
}
finally
{
    #region FOOTER

    Restore-TestEnvironment -TestEnvironment $TestEnvironment 

    #endregion
}
