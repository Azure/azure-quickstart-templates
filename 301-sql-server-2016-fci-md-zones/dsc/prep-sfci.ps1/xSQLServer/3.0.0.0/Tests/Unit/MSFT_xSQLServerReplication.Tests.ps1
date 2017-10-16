[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingConvertToSecureStringWithPlainText", "")]
param ()

$script:DSCModuleName   = 'xSQLServer'
$script:DSCResourceName = 'MSFT_xSQLServerReplication'

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
    InModuleScope $script:DSCResourceName {

        Describe 'Helper functions' {
            Context 'Get-SqlServerMajorVersion' {

                Mock -CommandName Get-ItemProperty `
                    -MockWith { return [pscustomobject]@{ MSSQLSERVER = 'MSSQL12.MSSQLSERVER'} } `
                    -ParameterFilter { $Path -eq 'HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\Instance Names\SQL' }

                It 'Should return corrent major version for default instance' {

                    Mock -CommandName Get-ItemProperty `
                        -MockWith { return [pscustomobject]@{ Version = '12.1.4100.1' } } `
                        -ParameterFilter { $Path -eq 'HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\MSSQL12.MSSQLSERVER\Setup' }

                    Get-SqlServerMajorVersion -InstanceName 'MSSQLSERVER' | Should be '12'
                }

                It 'Should throw error if major version cannot be resolved' {

                    Mock -CommandName Get-ItemProperty `
                        -MockWith { return [pscustomobject]@{ Version = '' } }`
                        -ParameterFilter { $Path -eq 'HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\MSSQL12.MSSQLSERVER\Setup' }

                    { Get-SqlServerMajorVersion -InstanceName 'MSSQLSERVER' } | Should Throw "instance: MSSQLSERVER!"
                }
            }

            Context 'Get-SqlLocalServerName' {

                It 'Should return COMPUTERNAME given MSSQLSERVER' {
                    Get-SqlLocalServerName -InstanceName MSSQLSERVER | Should be $env:COMPUTERNAME
                }

                It 'Should return COMPUTERNAME\InstanceName given InstanceName' {
                    Get-SqlLocalServerName -InstanceName InstanceName | Should be "$($env:COMPUTERNAME)\InstanceName"
                }

            }
        }

        $secpasswd = ConvertTo-SecureString 'P@$$w0rd1' -AsPlainText -Force
        $credentials = New-Object System.Management.Automation.PSCredential ('AdminLink', $secpasswd)

        Describe 'The system is not in the desired state given Local distribution mode' {

            $testParameters = @{
                InstanceName = 'MSSQLSERVER'
                AdminLinkCredentials = $credentials
                DistributorMode = 'Local'
                WorkingDirectory = 'C:\temp'
                Ensure = 'Present'
            }

            Mock -CommandName Get-SqlServerMajorVersion -MockWith { return '99' }
            Mock -CommandName Get-SqlLocalServerName -MockWith { return 'SERVERNAME' }
            Mock -CommandName New-ServerConnection -MockWith { 
                return [pscustomobject]@{
                    ServerInstance = $SqlServerName
                } 
            }
            Mock -CommandName New-ReplicationServer -MockWith {
                return [pscustomobject]@{
                    IsDistributor = $false
                    IsPublisher = $false
                    DistributionDatabase = ''
                    DistributionServer = 'SERVERNAME'
                    WorkingDirectory = ''
                }
            }
            Mock -CommandName New-DistributionDatabase -MockWith { return [pscustomobject]@{} } 
            Mock -CommandName Install-LocalDistributor -MockWith { }
            Mock -CommandName Install-RemoteDistributor -MockWith { }
            Mock -CommandName Register-DistributorPublisher -MockWith { }
            Mock -CommandName Uninstall-Distributor -MockWith {}

            Context 'Get methot' {
                $result = Get-TargetResource @testParameters
                It 'Get method calls Get-SqlServerMajorVersion with InstanceName = MSSQLSERVER' {
                    Assert-MockCalled -CommandName Get-SqlServerMajorVersion -Times 1 `
                        -ParameterFilter { $InstanceName -eq 'MSSQLSERVER' }
                }
                It 'Get method calls Get-SqlLocalServerName with $InstanceName = MSSQLSERVER' {
                    Assert-MockCalled -CommandName Get-SqlLocalServerName -Times 1 `
                        -ParameterFilter { $InstanceName -eq 'MSSQLSERVER' }
                }
                It 'Get method calls New-ServerConnection with $SqlServerName = SERVERNAME' {
                    Assert-MockCalled -CommandName New-ServerConnection -Times 1 `
                        -ParameterFilter { $SqlServerName -eq 'SERVERNAME' }
                }
                It 'Get method calls New-ReplicationServer with $ServerConnection.ServerInstance = SERVERNAME' {
                    Assert-MockCalled -CommandName New-ReplicationServer -Times 1 `
                        -ParameterFilter { $ServerConnection.ServerInstance -eq 'SERVERNAME' }
                }
                It 'Get method doesnt call New-DistributionDatabase' {
                    Assert-MockCalled -CommandName New-DistributionDatabase -Times 0 
                }
                It 'Get method doesnt call Install-LocalDistributor' {
                    Assert-MockCalled -CommandName Install-LocalDistributor -Times 0 
                }
                It 'Get method doesnt call Install-RemoteDistributor' {
                    Assert-MockCalled -CommandName Install-RemoteDistributor -Times 0 
                }
                It 'Ger method doesnt call Register-DistributorPublisher' {
                    Assert-MockCalled -CommandName Register-DistributorPublisher -Times 0 
                }
                It 'Ger method doesnt call Uninstall-Distributor' {
                    Assert-MockCalled -CommandName Uninstall-Distributor -Times 0 
                }
                It 'Get method returns Ensure = Absent' {
                    $result.Ensure | Should Be 'Absent'
                }
                It "Get method returns InstanceName = $($testParameters.InstanceName)" {
                    $result.InstanceName | Should Be $testParameters.InstanceName
                }
                It "Get method returns DistributorMode = $($testParameters.DistributorMode)" {
                    $result.DistributorMode | Should Be $testParameters.DistributorMode
                }
                It 'Get method returns DistributionDBName = distribution' {
                    $result.DistributionDBName | Should Be 'distribution'
                }
                It 'Get method returns RemoteDistributor is empty' {
                    $result.RemoteDistributor | Should Be ''
                }
                It 'Get method returns WorkingDirectory = C:\temp' {
                    $result.WorkingDirectory | Should Be 'C:\temp'
                }
            }

            Context 'Test method' {
                It 'Test method returns false' {
                    Test-TargetResource @testParameters | Should be $false
                }
            }

            Context 'Set method' {
                Set-TargetResource @testParameters
                It 'Set method calls Get-SqlServerMajorVersion with $InstanceName = MSSQLSERVER' {
                    Assert-MockCalled -CommandName Get-SqlServerMajorVersion -Times 1 `
                        -ParameterFilter { $InstanceName -eq 'MSSQLSERVER' }
                }
                It 'Set method calls Get-SqlLocalServerName with $InstanceName = MSSQLSERVER' {
                    Assert-MockCalled -CommandName Get-SqlLocalServerName -Times 1 `
                        -ParameterFilter { $InstanceName -eq 'MSSQLSERVER' }
                }
                It 'Set method calls New-ServerConnection with $SqlServerName = SERVERNAME' {
                    Assert-MockCalled -CommandName New-ServerConnection -Times 1 `
                        -ParameterFilter { $SqlServerName -eq 'SERVERNAME' }
                }
                It 'Set method calls New-ReplicationServer with $ServerConnection.ServerInstance = SERVERNAME' {
                    Assert-MockCalled -CommandName New-ReplicationServer -Times 1 `
                        -ParameterFilter { $ServerConnection.ServerInstance -eq 'SERVERNAME' }
                }
                It 'Set method calls New-DistributionDatabase with $DistributionDBName = distribution' {
                    Assert-MockCalled -CommandName New-DistributionDatabase -Times 1 `
                        -ParameterFilter { $DistributionDBName -eq 'distribution' }
                }
                It 'Set method calls Install-LocalDistributor' {
                    Assert-MockCalled -CommandName Install-LocalDistributor -Times 1 `
                        -ParameterFilter { $ReplicationServer.DistributionServer -eq 'SERVERNAME' }
                }
                It 'Set method calls Register-DistributorPublisher' {
                    Assert-MockCalled -CommandName Register-DistributorPublisher -Times 1 `
                        -ParameterFilter { $PublisherName -eq 'SERVERNAME' }
                }
                It 'Set method doesnt call Install-RemoteDistributor' {
                    Assert-MockCalled -CommandName Install-RemoteDistributor -Times 0 
                }
                It 'Set method doesnt call Uninstall-Distributor' {
                    Assert-MockCalled -CommandName Uninstall-Distributor -Times 0 
                }
            }
        }

        Describe 'The system is not in the desired state given Remote distribution mode' {

            $testParameters = @{
                InstanceName = 'INSTANCENAME'
                AdminLinkCredentials = $credentials
                DistributorMode = 'Remote'
                RemoteDistributor = 'REMOTESERVER'
                WorkingDirectory = 'C:\temp'
                Ensure = 'Present'
            }

            Mock -CommandName Get-SqlServerMajorVersion -MockWith { return '99' }
            Mock -CommandName Get-SqlLocalServerName -MockWith { return 'SERVERNAME\INSTANCENAME' }
            Mock -CommandName New-ServerConnection -MockWith { 
                return [pscustomobject]@{
                    ServerInstance = $SqlServerName
                } 
            }
            Mock -CommandName New-ReplicationServer -MockWith {
                return [pscustomobject]@{
                    IsDistributor = $false
                    IsPublisher = $false
                    DistributionDatabase = ''
                    DistributionServer = ''
                    WorkingDirectory = ''
                }
            }
            Mock -CommandName New-DistributionDatabase -MockWith { return [pscustomobject]@{} } 
            Mock -CommandName Install-LocalDistributor -MockWith { }
            Mock -CommandName Install-RemoteDistributor -MockWith { }
            Mock -CommandName Register-DistributorPublisher -MockWith { }
            Mock -CommandName Uninstall-Distributor -MockWith {}

            Context 'Get methot' {
                $result = Get-TargetResource @testParameters
                It 'Get method calls Get-SqlServerMajorVersion with $InstanceName = INSTANCENAME' {
                    Assert-MockCalled -CommandName Get-SqlServerMajorVersion -Times 1 `
                        -ParameterFilter { $InstanceName -eq 'INSTANCENAME' }
                }
                It 'Get method calls Get-SqlLocalServerName with $InstanceName = INSTANCENAME' {
                    Assert-MockCalled -CommandName Get-SqlLocalServerName -Times 1 `
                        -ParameterFilter { $InstanceName -eq 'INSTANCENAME' }
                }
                It 'Get method calls New-ServerConnection with $SqlServerName = SERVERNAME\INSTANCENAME' {
                    Assert-MockCalled -CommandName New-ServerConnection -Times 1 `
                        -ParameterFilter { $SqlServerName -eq 'SERVERNAME\INSTANCENAME' }
                }
                It 'Get method calls New-ReplicationServer with $ServerConnection.ServerInstance = SERVERNAME\INSTANCENAME' {
                    Assert-MockCalled -CommandName New-ReplicationServer -Times 1 `
                        -ParameterFilter { $ServerConnection.ServerInstance -eq 'SERVERNAME\INSTANCENAME' }
                }
                It 'Get method doesnt call New-DistributionDatabase' {
                    Assert-MockCalled -CommandName New-DistributionDatabase -Times 0 
                }
                It 'Get method doesnt call Install-LocalDistributor' {
                    Assert-MockCalled -CommandName Install-LocalDistributor -Times 0 
                }
                It 'Get method doesnt call Install-RemoteDistributor' {
                    Assert-MockCalled -CommandName Install-RemoteDistributor -Times 0 
                }
                It 'Ger method doesnt call Register-DistributorPublisher' {
                    Assert-MockCalled -CommandName Register-DistributorPublisher -Times 0 
                }
                It 'Ger method doesnt call Uninstall-Distributor' {
                    Assert-MockCalled -CommandName Uninstall-Distributor -Times 0 
                }
                It 'Get method returns Ensure = Absent' {
                    $result.Ensure | Should Be 'Absent'
                }
                It "Get method returns InstanceName = $($testParameters.InstanceName)" {
                    $result.InstanceName | Should Be $testParameters.InstanceName
                }
                It "Get method returns DistributorMode = $($testParameters.DistributorMode)" {
                    $result.DistributorMode | Should Be $testParameters.DistributorMode
                }
                It 'Get method returns DistributionDBName = distribution' {
                    $result.DistributionDBName | Should Be 'distribution'
                }
                It "Get method returns RemoteDistributor = $($testParameters.RemoteDistributor)" {
                    $result.RemoteDistributor | Should Be $testParameters.RemoteDistributor
                }
                It 'Get method returns WorkingDirectory = C:\temp' {
                    $result.WorkingDirectory | Should Be 'C:\temp'
                }
            }

            Context 'Test method' {
                It 'Test method returns false' {
                    Test-TargetResource @testParameters | Should be $false
                }
            }

            Context 'Set method' {
                Set-TargetResource @testParameters
                It 'Set method calls Get-SqlServerMajorVersion with $InstanceName = INSTANCENAME' {
                    Assert-MockCalled -CommandName Get-SqlServerMajorVersion -Times 1 `
                        -ParameterFilter { $InstanceName -eq 'INSTANCENAME' }
                }
                It 'Set method calls Get-SqlLocalServerName with $InstanceName = INSTANCENAME' {
                    Assert-MockCalled -CommandName Get-SqlLocalServerName -Times 1 `
                        -ParameterFilter { $InstanceName -eq 'INSTANCENAME' }
                }
                It 'Set method calls New-ServerConnection with $SqlServerName = SERVERNAME\INSTANCENAME' {
                    Assert-MockCalled -CommandName New-ServerConnection -Times 1 `
                        -ParameterFilter { $SqlServerName -eq 'SERVERNAME\INSTANCENAME' }
                }
                It 'Set method calls New-ReplicationServer with $ServerConnection.ServerInstance = SERVERNAME\INSTANCENAME' {
                    Assert-MockCalled -CommandName New-ReplicationServer -Times 1 `
                        -ParameterFilter { $ServerConnection.ServerInstance -eq 'SERVERNAME\INSTANCENAME' }
                }
                It "Set method calls New-ServerConnection with $SqlServerName = $($testParameters.RemoteDistributor)" {
                    Assert-MockCalled -CommandName New-ServerConnection -Times 1 `
                        -ParameterFilter { $SqlServerName -eq $testParameters.RemoteDistributor }
                }
                It 'Set method calls Register-DistributorPublisher with RemoteDistributor connection' {
                    Assert-MockCalled -CommandName Register-DistributorPublisher -Times 1 `
                        -ParameterFilter { 
                            $PublisherName -eq 'SERVERNAME\INSTANCENAME' `
                            -and $ServerConnection.ServerInstance -eq $testParameters.RemoteDistributor
                        }
                }
                It 'Set method calls Install-RemoteDistributor' {
                    Assert-MockCalled -CommandName Install-RemoteDistributor -Times 1 `
                        -ParameterFilter { $RemoteDistributor -eq $testParameters.RemoteDistributor }
                }
                It 'Set method doesnt call Install-LocalDistributor' {
                    Assert-MockCalled -CommandName Install-LocalDistributor -Times 0 
                }
                It 'Set method doesnt call Uninstall-Distributor' {
                    Assert-MockCalled -CommandName Uninstall-Distributor -Times 0 
                }
            }
        }

        Describe 'The system is in sync given Local distribution mode' {

            $testParameters = @{
                InstanceName = 'MSSQLSERVER'
                AdminLinkCredentials = $credentials
                DistributorMode = 'Local'
                WorkingDirectory = 'C:\temp'
                Ensure = 'Present'
            }

            Mock -CommandName Get-SqlServerMajorVersion -MockWith { return '99' }
            Mock -CommandName Get-SqlLocalServerName -MockWith { return 'SERVERNAME' }
            Mock -CommandName New-ServerConnection -MockWith { 
                return [pscustomobject]@{
                    ServerInstance = $SqlServerName
                } 
            }
            Mock -CommandName New-ReplicationServer -MockWith {
                return [pscustomobject]@{
                    IsDistributor = $true
                    IsPublisher = $true
                    DistributionDatabase = 'distribution'
                    DistributionServer = 'SERVERNAME'
                    WorkingDirectory = 'C:\temp'
                }
            }
            Mock -CommandName New-DistributionDatabase -MockWith { return [pscustomobject]@{} } 
            Mock -CommandName Install-LocalDistributor -MockWith { }
            Mock -CommandName Install-RemoteDistributor -MockWith { }
            Mock -CommandName Register-DistributorPublisher -MockWith { }
            Mock -CommandName Uninstall-Distributor -MockWith {}

            Context 'Get method' {
                $result = Get-TargetResource @testParameters
                It 'Get method calls Get-SqlServerMajorVersion with InstanceName = MSSQLSERVER' {
                    Assert-MockCalled -CommandName Get-SqlServerMajorVersion -Times 1 `
                        -ParameterFilter { $InstanceName -eq 'MSSQLSERVER' }
                }
                It 'Get method calls Get-SqlLocalServerName with $InstanceName = MSSQLSERVER' {
                    Assert-MockCalled -CommandName Get-SqlLocalServerName -Times 1 `
                        -ParameterFilter { $InstanceName -eq 'MSSQLSERVER' }
                }
                It 'Get method calls New-ServerConnection with $SqlServerName = SERVERNAME' {
                    Assert-MockCalled -CommandName New-ServerConnection -Times 1 `
                        -ParameterFilter { $SqlServerName -eq 'SERVERNAME' }
                }
                It 'Get method calls New-ReplicationServer with $ServerConnection.ServerInstance = SERVERNAME' {
                    Assert-MockCalled -CommandName New-ReplicationServer -Times 1 `
                        -ParameterFilter { $ServerConnection.ServerInstance -eq 'SERVERNAME' }
                }
                It 'Get method doesnt call New-DistributionDatabase' {
                    Assert-MockCalled -CommandName New-DistributionDatabase -Times 0 
                }
                It 'Get method doesnt call Install-LocalDistributor' {
                    Assert-MockCalled -CommandName Install-LocalDistributor -Times 0 
                }
                It 'Get method doesnt call Install-RemoteDistributor' {
                    Assert-MockCalled -CommandName Install-RemoteDistributor -Times 0 
                }
                It 'Ger method doesnt call Register-DistributorPublisher' {
                    Assert-MockCalled -CommandName Register-DistributorPublisher -Times 0 
                }
                It 'Ger method doesnt call Uninstall-Distributor' {
                    Assert-MockCalled -CommandName Uninstall-Distributor -Times 0 
                }
                It 'Get method returns Ensure = Present' {
                    $result.Ensure | Should Be 'Present'
                }
                It "Get method returns InstanceName = $($testParameters.InstanceName)" {
                    $result.InstanceName | Should Be $testParameters.InstanceName
                }
                It "Get method returns DistributorMode = $($testParameters.DistributorMode)" {
                    $result.DistributorMode | Should Be $testParameters.DistributorMode
                }
                It 'Get method returns DistributionDBName = distribution' {
                    $result.DistributionDBName | Should Be 'distribution'
                }
                It 'Get method returns RemoteDistributor = SERVERNAME' {
                    $result.RemoteDistributor | Should Be 'SERVERNAME'
                }
                It 'Get method returns WorkingDirectory = C:\temp' {
                    $result.WorkingDirectory | Should Be 'C:\temp'
                }
            }
            
            Context 'Test method' {
                It 'Test method returns true' {
                    Test-TargetResource @testParameters | Should be $true
                }
            }
            
            Context 'Set method' {
                Set-TargetResource @testParameters
                It 'Set method calls Get-SqlServerMajorVersion with $InstanceName = MSSQLSERVER' {
                    Assert-MockCalled -CommandName Get-SqlServerMajorVersion -Times 1 `
                        -ParameterFilter { $InstanceName -eq 'MSSQLSERVER' }
                }
                It 'Set method calls Get-SqlLocalServerName with $InstanceName = MSSQLSERVER' {
                    Assert-MockCalled -CommandName Get-SqlLocalServerName -Times 1 `
                        -ParameterFilter { $InstanceName -eq 'MSSQLSERVER' }
                }
                It 'Set method calls New-ServerConnection with $SqlServerName = SERVERNAME' {
                    Assert-MockCalled -CommandName New-ServerConnection -Times 1 `
                        -ParameterFilter { $SqlServerName -eq 'SERVERNAME' }
                }
                It 'Set method calls New-ReplicationServer with $ServerConnection.ServerInstance = SERVERNAME' {
                    Assert-MockCalled -CommandName New-ReplicationServer -Times 1 `
                        -ParameterFilter { $ServerConnection.ServerInstance -eq 'SERVERNAME' }
                }
                It 'Set method doesnt call New-DistributionDatabase with $DistributionDBName = distribution' {
                    Assert-MockCalled -CommandName New-DistributionDatabase -Times 0 
                }
                It 'Set method doesnt call Install-LocalDistributor' {
                    Assert-MockCalled -CommandName Install-LocalDistributor -Times 0
                }
                It 'Set method doesnt call Install-RemoteDistributor' {
                    Assert-MockCalled -CommandName Install-RemoteDistributor -Times 0 
                }
                It 'Set method doesnt call Register-DistributorPublisher' {
                    Assert-MockCalled -CommandName Register-DistributorPublisher -Times 0 
                }
                It 'Set method doesnt call Uninstall-Distributor' {
                    Assert-MockCalled -CommandName Uninstall-Distributor -Times 0 
                }
            }
        }

        Describe 'The system is in sync given Remote distribution mode' {

            $testParameters = @{
                InstanceName = 'INSTANCENAME'
                AdminLinkCredentials = $credentials
                DistributorMode = 'Remote'
                RemoteDistributor = 'REMOTESERVER'
                WorkingDirectory = 'C:\temp'
                Ensure = 'Present'
            }

            Mock -CommandName Get-SqlServerMajorVersion -MockWith { return '99' }
            Mock -CommandName Get-SqlLocalServerName -MockWith { return 'SERVERNAME\INSTANCENAME' }
            Mock -CommandName New-ServerConnection -MockWith { 
                return [pscustomobject]@{
                    ServerInstance = $SqlServerName
                } 
            }
            Mock -CommandName New-ReplicationServer -MockWith {
                return [pscustomobject]@{
                    IsDistributor = $false
                    IsPublisher = $true
                    DistributionDatabase = 'distribution'
                    DistributionServer = 'REMOTESERVER'
                    WorkingDirectory = 'C:\temp'
                }
            }
            Mock -CommandName New-DistributionDatabase -MockWith { return [pscustomobject]@{} } 
            Mock -CommandName Install-LocalDistributor -MockWith { }
            Mock -CommandName Install-RemoteDistributor -MockWith { }
            Mock -CommandName Register-DistributorPublisher -MockWith { }
            Mock -CommandName Uninstall-Distributor -MockWith {}

            Context 'Get methot' {
                $result = Get-TargetResource @testParameters
                It 'Get method calls Get-SqlServerMajorVersion with $InstanceName = INSTANCENAME' {
                    Assert-MockCalled -CommandName Get-SqlServerMajorVersion -Times 1 `
                        -ParameterFilter { $InstanceName -eq 'INSTANCENAME' }
                }
                It 'Get method calls Get-SqlLocalServerName with $InstanceName = INSTANCENAME' {
                    Assert-MockCalled -CommandName Get-SqlLocalServerName -Times 1 `
                        -ParameterFilter { $InstanceName -eq 'INSTANCENAME' }
                }
                It 'Get method calls New-ServerConnection with $SqlServerName = SERVERNAME\INSTANCENAME' {
                    Assert-MockCalled -CommandName New-ServerConnection -Times 1 `
                        -ParameterFilter { $SqlServerName -eq 'SERVERNAME\INSTANCENAME' }
                }
                It 'Get method calls New-ReplicationServer with $ServerConnection.ServerInstance = SERVERNAME\INSTANCENAME' {
                    Assert-MockCalled -CommandName New-ReplicationServer -Times 1 `
                        -ParameterFilter { $ServerConnection.ServerInstance -eq 'SERVERNAME\INSTANCENAME' }
                }
                It 'Get method doesnt call New-DistributionDatabase' {
                    Assert-MockCalled -CommandName New-DistributionDatabase -Times 0 
                }
                It 'Get method doesnt call Install-LocalDistributor' {
                    Assert-MockCalled -CommandName Install-LocalDistributor -Times 0 
                }
                It 'Get method doesnt call Install-RemoteDistributor' {
                    Assert-MockCalled -CommandName Install-RemoteDistributor -Times 0 
                }
                It 'Ger method doesnt call Register-DistributorPublisher' {
                    Assert-MockCalled -CommandName Register-DistributorPublisher -Times 0 
                }
                It 'Ger method doesnt call Uninstall-Distributor' {
                    Assert-MockCalled -CommandName Uninstall-Distributor -Times 0 
                }
                It 'Get method returns Ensure = Present' {
                    $result.Ensure | Should Be 'Present'
                }
                It "Get method returns InstanceName = $($testParameters.InstanceName)" {
                    $result.InstanceName | Should Be $testParameters.InstanceName
                }
                It "Get method returns DistributorMode = $($testParameters.DistributorMode)" {
                    $result.DistributorMode | Should Be $testParameters.DistributorMode
                }
                It 'Get method returns DistributionDBName = distribution' {
                    $result.DistributionDBName | Should Be 'distribution'
                }
                It "Get method returns RemoteDistributor = $($testParameters.RemoteDistributor)" {
                    $result.RemoteDistributor | Should Be $testParameters.RemoteDistributor
                }
                It 'Get method returns WorkingDirectory = C:\temp' {
                    $result.WorkingDirectory | Should Be 'C:\temp'
                }
            }

            Context 'Test method' {
                It 'Test method returns true' {
                    Test-TargetResource @testParameters | Should be $true
                }
            }

            Context 'Set method' {
                Set-TargetResource @testParameters
                It 'Set method calls Get-SqlServerMajorVersion with $InstanceName = INSTANCENAME' {
                    Assert-MockCalled -CommandName Get-SqlServerMajorVersion -Times 1 `
                        -ParameterFilter { $InstanceName -eq 'INSTANCENAME' }
                }
                It 'Set method calls Get-SqlLocalServerName with $InstanceName = INSTANCENAME' {
                    Assert-MockCalled -CommandName Get-SqlLocalServerName -Times 1 `
                        -ParameterFilter { $InstanceName -eq 'INSTANCENAME' }
                }
                It 'Set method calls New-ServerConnection with $SqlServerName = SERVERNAME\INSTANCENAME' {
                    Assert-MockCalled -CommandName New-ServerConnection -Times 1 `
                        -ParameterFilter { $SqlServerName -eq 'SERVERNAME\INSTANCENAME' }
                }
                It 'Set method calls New-ReplicationServer with $ServerConnection.ServerInstance = SERVERNAME\INSTANCENAME' {
                    Assert-MockCalled -CommandName New-ReplicationServer -Times 1 `
                        -ParameterFilter { $ServerConnection.ServerInstance -eq 'SERVERNAME\INSTANCENAME' }
                }
                It 'Set method doesnt call New-DistributionDatabase' {
                    Assert-MockCalled -CommandName New-DistributionDatabase -Times 0 
                }
                It 'Set method doesnt call Install-LocalDistributor' {
                    Assert-MockCalled -CommandName Install-LocalDistributor -Times 0
                }
                It 'Set method doesnt call Install-RemoteDistributor' {
                    Assert-MockCalled -CommandName Install-RemoteDistributor -Times 0 
                }
                It 'Set method doesnt call Register-DistributorPublisher' {
                    Assert-MockCalled -CommandName Register-DistributorPublisher -Times 0 
                }
                It 'Set method doesnt call Uninstall-Distributor' {
                    Assert-MockCalled -CommandName Uninstall-Distributor -Times 0 
                }
            }
        }

        Describe 'The system is not in desired state given Local distribution, but should be Absent' {

            $testParameters = @{
                InstanceName = 'MSSQLSERVER'
                AdminLinkCredentials = $credentials
                DistributorMode = 'Local'
                WorkingDirectory = 'C:\temp'
                Ensure = 'Absent'
            }

            Mock -CommandName Get-SqlServerMajorVersion -MockWith { return '99' }
            Mock -CommandName Get-SqlLocalServerName -MockWith { return 'SERVERNAME' }
            Mock -CommandName New-ServerConnection -MockWith { 
                return [pscustomobject]@{
                    ServerInstance = $SqlServerName
                } 
            }
            Mock -CommandName New-ReplicationServer -MockWith {
                return [pscustomobject]@{
                    IsDistributor = $true
                    IsPublisher = $true
                    DistributionDatabase = 'distribution'
                    DistributionServer = 'SERVERNAME'
                    WorkingDirectory = 'C:\temp'
                }
            }
            Mock -CommandName New-DistributionDatabase -MockWith { return [pscustomobject]@{} } 
            Mock -CommandName Install-LocalDistributor -MockWith { }
            Mock -CommandName Install-RemoteDistributor -MockWith { }
            Mock -CommandName Register-DistributorPublisher -MockWith { }
            Mock -CommandName Uninstall-Distributor -MockWith {}

            Context 'Get method' {
                $result = Get-TargetResource @testParameters
                It 'Get method calls Get-SqlServerMajorVersion with InstanceName = MSSQLSERVER' {
                    Assert-MockCalled -CommandName Get-SqlServerMajorVersion -Times 1 `
                        -ParameterFilter { $InstanceName -eq 'MSSQLSERVER' }
                }
                It 'Get method calls Get-SqlLocalServerName with $InstanceName = MSSQLSERVER' {
                    Assert-MockCalled -CommandName Get-SqlLocalServerName -Times 1 `
                        -ParameterFilter { $InstanceName -eq 'MSSQLSERVER' }
                }
                It 'Get method calls New-ServerConnection with $SqlServerName = SERVERNAME' {
                    Assert-MockCalled -CommandName New-ServerConnection -Times 1 `
                        -ParameterFilter { $SqlServerName -eq 'SERVERNAME' }
                }
                It 'Get method calls New-ReplicationServer with $ServerConnection.ServerInstance = SERVERNAME' {
                    Assert-MockCalled -CommandName New-ReplicationServer -Times 1 `
                        -ParameterFilter { $ServerConnection.ServerInstance -eq 'SERVERNAME' }
                }
                It 'Get method doesnt call New-DistributionDatabase' {
                    Assert-MockCalled -CommandName New-DistributionDatabase -Times 0 
                }
                It 'Get method doesnt call Install-LocalDistributor' {
                    Assert-MockCalled -CommandName Install-LocalDistributor -Times 0 
                }
                It 'Get method doesnt call Install-RemoteDistributor' {
                    Assert-MockCalled -CommandName Install-RemoteDistributor -Times 0 
                }
                It 'Ger method doesnt call Register-DistributorPublisher' {
                    Assert-MockCalled -CommandName Register-DistributorPublisher -Times 0 
                }
                It 'Ger method doesnt call Uninstall-Distributor' {
                    Assert-MockCalled -CommandName Uninstall-Distributor -Times 0 
                }
                It 'Get method returns Ensure = Present' {
                    $result.Ensure | Should Be 'Present'
                }
                It "Get method returns InstanceName = $($testParameters.InstanceName)" {
                    $result.InstanceName | Should Be $testParameters.InstanceName
                }
                It "Get method returns DistributorMode = $($testParameters.DistributorMode)" {
                    $result.DistributorMode | Should Be $testParameters.DistributorMode
                }
                It 'Get method returns DistributionDBName = distribution' {
                    $result.DistributionDBName | Should Be 'distribution'
                }
                It 'Get method returns RemoteDistributor is empty' {
                    $result.RemoteDistributor | Should Be 'SERVERNAME'
                }
                It 'Get method returns WorkingDirectory = C:\temp' {
                    $result.WorkingDirectory | Should Be 'C:\temp'
                }
            }

            Context 'Test method' {
                It 'Test method returns false' {
                    Test-TargetResource @testParameters | Should be $false
                }
            }

            Context 'Set method' {
                Set-TargetResource @testParameters

                It 'Set method calls Get-SqlServerMajorVersion with $InstanceName = MSSQLSERVER' {
                    Assert-MockCalled -CommandName Get-SqlServerMajorVersion -Times 1 `
                        -ParameterFilter { $InstanceName -eq 'MSSQLSERVER' }
                }
                It 'Set method calls Get-SqlLocalServerName with $InstanceName = MSSQLSERVER' {
                    Assert-MockCalled -CommandName Get-SqlLocalServerName -Times 1 `
                        -ParameterFilter { $InstanceName -eq 'MSSQLSERVER' }
                }
                It 'Set method calls New-ServerConnection with $SqlServerName = SERVERNAME' {
                    Assert-MockCalled -CommandName New-ServerConnection -Times 1 `
                        -ParameterFilter { $SqlServerName -eq 'SERVERNAME' }
                }
                It 'Set method calls New-ReplicationServer with $ServerConnection.ServerInstance = SERVERNAME' {
                    Assert-MockCalled -CommandName New-ReplicationServer -Times 1 `
                        -ParameterFilter { $ServerConnection.ServerInstance -eq 'SERVERNAME' }
                }
                It 'Set method calls Uninstall-Distributor with $ReplicationServer.DistributionServer = SERVERNAME' {
                    Assert-MockCalled -CommandName Uninstall-Distributor -Times 1 `
                        -ParameterFilter { $ReplicationServer.DistributionServer -eq 'SERVERNAME' }
                }
                It 'Set method doesnt call New-DistributionDatabase' {
                    Assert-MockCalled -CommandName New-DistributionDatabase -Times 0
                }
                It 'Set method doesnt call Install-LocalDistributor' {
                    Assert-MockCalled -CommandName Install-LocalDistributor -Times 0
                }
                It 'Set method doesnt call Install-RemoteDistributor' {
                    Assert-MockCalled -CommandName Install-RemoteDistributor -Times 0 
                }
                It 'Set method doesnt call Register-DistributorPublisher' {
                    Assert-MockCalled -CommandName Register-DistributorPublisher -Times 0
                }
            }
        }

        Describe 'The system is not in desired state given Remote distribution, but should be Absent' {

            $testParameters = @{
                InstanceName = 'INSTANCENAME'
                AdminLinkCredentials = $credentials
                DistributorMode = 'Remote'
                RemoteDistributor = 'REMOTESERVER'
                WorkingDirectory = 'C:\temp'
                Ensure = 'Absent'
            }

            Mock -CommandName Get-SqlServerMajorVersion -MockWith { return '99' }
            Mock -CommandName Get-SqlLocalServerName -MockWith { return 'SERVERNAME\INSTANCENAME' }
            Mock -CommandName New-ServerConnection -MockWith { 
                return [pscustomobject]@{
                    ServerInstance = $SqlServerName
                } 
            }
            Mock -CommandName New-ReplicationServer -MockWith {
                return [pscustomobject]@{
                    IsDistributor = $false
                    IsPublisher = $true
                    DistributionDatabase = 'distribution'
                    DistributionServer = 'REMOTESERVER'
                    WorkingDirectory = 'C:\temp'
                }
            }
            Mock -CommandName New-DistributionDatabase -MockWith { return [pscustomobject]@{} } 
            Mock -CommandName Install-LocalDistributor -MockWith { }
            Mock -CommandName Install-RemoteDistributor -MockWith { }
            Mock -CommandName Register-DistributorPublisher -MockWith { }
            Mock -CommandName Uninstall-Distributor -MockWith {}

            Context 'Get methot' {
                $result = Get-TargetResource @testParameters
                It 'Get method calls Get-SqlServerMajorVersion with $InstanceName = INSTANCENAME' {
                    Assert-MockCalled -CommandName Get-SqlServerMajorVersion -Times 1 `
                        -ParameterFilter { $InstanceName -eq 'INSTANCENAME' }
                }
                It 'Get method calls Get-SqlLocalServerName with $InstanceName = INSTANCENAME' {
                    Assert-MockCalled -CommandName Get-SqlLocalServerName -Times 1 `
                        -ParameterFilter { $InstanceName -eq 'INSTANCENAME' }
                }
                It 'Get method calls New-ServerConnection with $SqlServerName = SERVERNAME\INSTANCENAME' {
                    Assert-MockCalled -CommandName New-ServerConnection -Times 1 `
                        -ParameterFilter { $SqlServerName -eq 'SERVERNAME\INSTANCENAME' }
                }
                It 'Get method calls New-ReplicationServer with $ServerConnection.ServerInstance = SERVERNAME\INSTANCENAME' {
                    Assert-MockCalled -CommandName New-ReplicationServer -Times 1 `
                        -ParameterFilter { $ServerConnection.ServerInstance -eq 'SERVERNAME\INSTANCENAME' }
                }
                It 'Get method doesnt call New-DistributionDatabase' {
                    Assert-MockCalled -CommandName New-DistributionDatabase -Times 0 
                }
                It 'Get method doesnt call Install-LocalDistributor' {
                    Assert-MockCalled -CommandName Install-LocalDistributor -Times 0 
                }
                It 'Get method doesnt call Install-RemoteDistributor' {
                    Assert-MockCalled -CommandName Install-RemoteDistributor -Times 0 
                }
                It 'Ger method doesnt call Register-DistributorPublisher' {
                    Assert-MockCalled -CommandName Register-DistributorPublisher -Times 0 
                }
                It 'Ger method doesnt call Uninstall-Distributor' {
                    Assert-MockCalled -CommandName Uninstall-Distributor -Times 0 
                }
                It 'Get method returns Ensure = Present' {
                    $result.Ensure | Should Be 'Present'
                }
                It "Get method returns InstanceName = $($testParameters.InstanceName)" {
                    $result.InstanceName | Should Be $testParameters.InstanceName
                }
                It "Get method returns DistributorMode = $($testParameters.DistributorMode)" {
                    $result.DistributorMode | Should Be $testParameters.DistributorMode
                }
                It 'Get method returns DistributionDBName = distribution' {
                    $result.DistributionDBName | Should Be 'distribution'
                }
                It "Get method returns RemoteDistributor = $($testParameters.RemoteDistributor)" {
                    $result.RemoteDistributor | Should Be $testParameters.RemoteDistributor
                }
                It 'Get method returns WorkingDirectory = C:\temp' {
                    $result.WorkingDirectory | Should Be 'C:\temp'
                }
            }

            Context 'Test method' {
                It 'Test method returns false' {
                    Test-TargetResource @testParameters | Should be $false
                }
            }

            Context 'Set method' {
                Set-TargetResource @testParameters
                It 'Set method calls Get-SqlServerMajorVersion with $InstanceName = INSTANCENAME' {
                    Assert-MockCalled -CommandName Get-SqlServerMajorVersion -Times 1 `
                        -ParameterFilter { $InstanceName -eq 'INSTANCENAME' }
                }
                It 'Set method calls Get-SqlLocalServerName with $InstanceName = INSTANCENAME' {
                    Assert-MockCalled -CommandName Get-SqlLocalServerName -Times 1 `
                        -ParameterFilter { $InstanceName -eq 'INSTANCENAME' }
                }
                It 'Set method calls New-ServerConnection with $SqlServerName = SERVERNAME\INSTANCENAME' {
                    Assert-MockCalled -CommandName New-ServerConnection -Times 1 `
                        -ParameterFilter { $SqlServerName -eq 'SERVERNAME\INSTANCENAME' }
                }
                It 'Set method calls New-ReplicationServer with $ServerConnection.ServerInstance = SERVERNAME\INSTANCENAME' {
                    Assert-MockCalled -CommandName New-ReplicationServer -Times 1 `
                        -ParameterFilter { $ServerConnection.ServerInstance -eq 'SERVERNAME\INSTANCENAME' }
                }
                It 'Set method calls Uninstall-Distributor with $ReplicationServer.DistributionServer = REMOTESERVER' {
                    Assert-MockCalled -CommandName Uninstall-Distributor -Times 1 `
                        -ParameterFilter { $ReplicationServer.DistributionServer -eq 'REMOTESERVER' }
                }
                It 'Set method doesnt call New-DistributionDatabase' {
                    Assert-MockCalled -CommandName New-DistributionDatabase -Times 0
                }
                It 'Set method doesnt call Install-LocalDistributor' {
                    Assert-MockCalled -CommandName Install-LocalDistributor -Times 0
                }
                It 'Set method doesnt call Install-RemoteDistributor' {
                    Assert-MockCalled -CommandName Install-RemoteDistributor -Times 0 
                }
                It 'Set method doesnt call Register-DistributorPublisher' {
                    Assert-MockCalled -CommandName Register-DistributorPublisher -Times 0
                }
            }
        }

        Describe 'The system is in sync when Absent' {

            $testParameters = @{
                InstanceName = 'MSSQLSERVER'
                AdminLinkCredentials = $credentials
                DistributorMode = 'Local'
                WorkingDirectory = 'C:\temp'
                Ensure = 'Absent'
            }

            Mock -CommandName Get-SqlServerMajorVersion -MockWith { return '99' }
            Mock -CommandName Get-SqlLocalServerName -MockWith { return 'SERVERNAME' }
            Mock -CommandName New-ServerConnection -MockWith { 
                return [pscustomobject]@{
                    ServerInstance = $SqlServerName
                } 
            }
            Mock -CommandName New-ReplicationServer -MockWith {
                return [pscustomobject]@{
                    IsDistributor = $false
                    IsPublisher = $false
                    DistributionDatabase = ''
                    DistributionServer = ''
                    WorkingDirectory = ''
                }
            }
            Mock -CommandName New-DistributionDatabase -MockWith { return [pscustomobject]@{} } 
            Mock -CommandName Install-LocalDistributor -MockWith { }
            Mock -CommandName Install-RemoteDistributor -MockWith { }
            Mock -CommandName Register-DistributorPublisher -MockWith { }
            Mock -CommandName Uninstall-Distributor -MockWith {}

            Context 'Get method' {
                $result = Get-TargetResource @testParameters
                It 'Get method calls Get-SqlServerMajorVersion with InstanceName = MSSQLSERVER' {
                    Assert-MockCalled -CommandName Get-SqlServerMajorVersion -Times 1 `
                        -ParameterFilter { $InstanceName -eq 'MSSQLSERVER' }
                }
                It 'Get method calls Get-SqlLocalServerName with $InstanceName = MSSQLSERVER' {
                    Assert-MockCalled -CommandName Get-SqlLocalServerName -Times 1 `
                        -ParameterFilter { $InstanceName -eq 'MSSQLSERVER' }
                }
                It 'Get method calls New-ServerConnection with $SqlServerName = SERVERNAME' {
                    Assert-MockCalled -CommandName New-ServerConnection -Times 1 `
                        -ParameterFilter { $SqlServerName -eq 'SERVERNAME' }
                }
                It 'Get method calls New-ReplicationServer with $ServerConnection.ServerInstance = SERVERNAME' {
                    Assert-MockCalled -CommandName New-ReplicationServer -Times 1 `
                        -ParameterFilter { $ServerConnection.ServerInstance -eq 'SERVERNAME' }
                }
                It 'Get method doesnt call New-DistributionDatabase' {
                    Assert-MockCalled -CommandName New-DistributionDatabase -Times 0 
                }
                It 'Get method doesnt call Install-LocalDistributor' {
                    Assert-MockCalled -CommandName Install-LocalDistributor -Times 0 
                }
                It 'Get method doesnt call Install-RemoteDistributor' {
                    Assert-MockCalled -CommandName Install-RemoteDistributor -Times 0 
                }
                It 'Ger method doesnt call Register-DistributorPublisher' {
                    Assert-MockCalled -CommandName Register-DistributorPublisher -Times 0 
                }
                It 'Ger method doesnt call Uninstall-Distributor' {
                    Assert-MockCalled -CommandName Uninstall-Distributor -Times 0 
                }
                It 'Get method returns Ensure = Absent' {
                    $result.Ensure | Should Be 'Absent'
                }
                It "Get method returns InstanceName = $($testParameters.InstanceName)" {
                    $result.InstanceName | Should Be $testParameters.InstanceName
                }
                It "Get method returns DistributorMode = $($testParameters.DistributorMode)" {
                    $result.DistributorMode | Should Be $testParameters.DistributorMode
                }
                It 'Get method returns DistributionDBName = distribution' {
                    $result.DistributionDBName | Should Be 'distribution'
                }
                It 'Get method returns RemoteDistributor is empty' {
                    $result.RemoteDistributor | Should Be ''
                }
                It "Get method returns WorkingDirectory = $($testParameters.WorkingDirectory)" {
                    $result.WorkingDirectory | Should Be $testParameters.WorkingDirectory
                }
            }
            
            Context 'Test method' {
                It 'Test method returns true' {
                    Test-TargetResource @testParameters | Should be $true
                }
            }
            
            Context 'Set method' {
                Set-TargetResource @testParameters
                It 'Set method calls Get-SqlServerMajorVersion with $InstanceName = MSSQLSERVER' {
                    Assert-MockCalled -CommandName Get-SqlServerMajorVersion -Times 1 `
                        -ParameterFilter { $InstanceName -eq 'MSSQLSERVER' }
                }
                It 'Set method calls Get-SqlLocalServerName with $InstanceName = MSSQLSERVER' {
                    Assert-MockCalled -CommandName Get-SqlLocalServerName -Times 1 `
                        -ParameterFilter { $InstanceName -eq 'MSSQLSERVER' }
                }
                It 'Set method calls New-ServerConnection with $SqlServerName = SERVERNAME' {
                    Assert-MockCalled -CommandName New-ServerConnection -Times 1 `
                        -ParameterFilter { $SqlServerName -eq 'SERVERNAME' }
                }
                It 'Set method calls New-ReplicationServer with $ServerConnection.ServerInstance = SERVERNAME' {
                    Assert-MockCalled -CommandName New-ReplicationServer -Times 1 `
                        -ParameterFilter { $ServerConnection.ServerInstance -eq 'SERVERNAME' }
                }
                It 'Set method doesnt call New-DistributionDatabase with $DistributionDBName = distribution' {
                    Assert-MockCalled -CommandName New-DistributionDatabase -Times 0 
                }
                It 'Set method doesnt call Install-LocalDistributor' {
                    Assert-MockCalled -CommandName Install-LocalDistributor -Times 0
                }
                It 'Set method doesnt call Install-RemoteDistributor' {
                    Assert-MockCalled -CommandName Install-RemoteDistributor -Times 0
                }
                It 'Set method doesnt call Register-DistributorPublisher' {
                    Assert-MockCalled -CommandName Register-DistributorPublisher -Times 0 
                }
                It 'Set method doesnt call Uninstall-Distributor' {
                    Assert-MockCalled -CommandName Uninstall-Distributor -Times 0 
                }
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
