$script:DSCModuleName      = 'xSQLServer' 
$script:DSCResourceName    = 'MSFT_xSQLAlias' 

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
    $registryPath = 'HKLM:\SOFTWARE\Microsoft\MSSQLServer\Client\ConnectTo'
    $registryPathWow6432Node = 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\MSSQLServer\Client\ConnectTo'

    $name = 'MyAlias'
    $serverNameTcp = 'sqlnode.company.local'
    $tcpPort = 1433
    $serverNameNamedPipes = 'sqlnode'
    $pipeName = "\\$serverNameNamedPipes\PIPE\sql\query"

    $unknownName = 'UnknownAlias'
    $unknownServerName = 'unknownserver'

    $nameDifferentTcpPort = 'DifferentTcpPort'
    $nameDifferentServerNameTcp = 'DifferentServerNameTcp'
    $nameDifferentPipeName = 'DifferentPipeName'
    $differentTcpPort = 1500
    $differentServerNameTcp = "$unknownServerName.company.local"
    $differentPipeName = "\\$unknownServerName\PIPE\sql\query"

    $nameWow6432NodeDifferFrom64BitOS = 'Wow6432NodeDifferFrom64BitOS'
    #endregion Pester Test Initialization

    #region Get-TargetResource
    Describe "$($script:DSCResourceName)\Get-TargetResource" {
        # Mocking for protocol TCP
        Mock -CommandName Get-ItemProperty -ParameterFilter { $Path -eq $registryPath -and $Name -eq $name } -MockWith {
            return @{
                'MyAlias' = 'DBMSSOCN,sqlnode.company.local,1433'
            }
        } -ModuleName $script:DSCResourceName -Verifiable

        Mock -CommandName Get-ItemProperty -ParameterFilter { $Path -eq $registryPathWow6432Node -and $Name -eq $name } -MockWith {
            return @{
                'MyAlias' = 'DBMSSOCN,sqlnode.company.local,1433'
            }
        } -ModuleName $script:DSCResourceName -Verifiable

        Mock -CommandName Get-ItemProperty -ParameterFilter { $Path -eq $registryPath -and $Name -eq $nameDifferentTcpPort } -MockWith {
            return @{
                'DifferentTcpPort' = 'DBMSSOCN,sqlnode.company.local,1500'
            }
        } -ModuleName $script:DSCResourceName -Verifiable

        Mock -CommandName Get-ItemProperty -ParameterFilter { $Path -eq $registryPathWow6432Node -and $Name -eq $nameDifferentTcpPort } -MockWith {
            return @{
                'DifferentTcpPort' = 'DBMSSOCN,sqlnode.company.local,1500'
            }
        } -ModuleName $script:DSCResourceName -Verifiable

        Mock -CommandName Get-ItemProperty -ParameterFilter { $Path -eq $registryPath -and $Name -eq $nameDifferentServerNameTcp } -MockWith {
            return @{
                'DifferentServerNameTcp' = 'DBMSSOCN,unknownserver.company.local,1433'
            }
        } -ModuleName $script:DSCResourceName -Verifiable

        Mock -CommandName Get-ItemProperty -ParameterFilter { $Path -eq $registryPathWow6432Node -and $Name -eq $nameDifferentServerNameTcp } -MockWith {
            return @{
                'DifferentServerNameTcp' = 'DBMSSOCN,unknownserver.company.local,1433'
            }
        } -ModuleName $script:DSCResourceName -Verifiable

        Mock -CommandName Get-ItemProperty -ParameterFilter { $Path -eq $registryPath -and $Name -eq $unknownName } -MockWith {
            return $null
        } -ModuleName $script:DSCResourceName -Verifiable

        # Mocking 64-bit OS
        Mock -CommandName Get-WmiObject -MockWith {
            return New-Object Object | 
                Add-Member -MemberType NoteProperty -Name OSArchitecture -Value '64-bit' -PassThru -Force
        } -ParameterFilter { $Class -eq 'win32_OperatingSystem' } -ModuleName $script:DSCResourceName -Verifiable

        Context 'When the system is in the desired present state for 64-bit OS using TCP' {
            $testParameters = @{
                Name = $name
                ServerName = $serverNameTcp
            }

            $result = Get-TargetResource @testParameters

            It 'Should return the state as present' {
                $result.Ensure | Should Be 'Present'
            }

            It 'Should return the same values as passed as parameters' {
                $result.Name | Should Be $testParameters.Name
                $result.ServerName | Should Be $testParameters.ServerName
            }

            It 'Should return TCP as the protocol used' {
                $result.Protocol | Should Be 'TCP'
            }
            
            It "Should return $tcpPort as the port number used" {
                $result.TcpPort | Should Be $tcpPort
            }

            It 'Should not return any pipe name' {
                $result.PipeName | Should Be ''
            }

            It 'Should call the mocked functions exactly 1 time each' {
                Assert-MockCalled Get-WmiObject -ParameterFilter { $Class -eq 'win32_OperatingSystem' } `
                    -Exactly -Times 1 -ModuleName $script:DSCResourceName -Scope Context

                Assert-MockCalled Get-ItemProperty -ParameterFilter { $Path -eq $registryPath } `
                    -Exactly -Times 1 -ModuleName $script:DSCResourceName -Scope Context
                
                Assert-MockCalled Get-ItemProperty -ParameterFilter { $Path -eq $registryPathWow6432Node } `
                    -Exactly -Times 1 -ModuleName $script:DSCResourceName -Scope Context
            }
        }

        Context 'When the system is in the desired absent state for 64-bit OS' {
            $testParameters = @{
                Name = $unknownName
                ServerName = $unknownServerName
            }

            $result = Get-TargetResource @testParameters

            It 'Should return the state as absent' {
                $result.Ensure | Should Be 'Absent'
            }

            It 'Should return the same values as passed as parameters' {
                $result.Name | Should Be $testParameters.Name
            }

            It 'Should not return the value passed in the ServerName parameter' {
                $result.ServerName | Should Be ''
            }

            It 'Should not return any protocol' {
                $result.Protocol | Should Be ''
            }
            
            It 'Should not return a port number' {
                $result.TcpPort | Should Be 0
            }

            It 'Should not return any pipe name' {
                $result.PipeName | Should Be ''
            }

            It 'Should call the mocked functions exactly 1 time each' {
                Assert-MockCalled Get-WmiObject -ParameterFilter { $Class -eq 'win32_OperatingSystem' } `
                    -Exactly -Times 1 -ModuleName $script:DSCResourceName -Scope Context

                Assert-MockCalled Get-ItemProperty -ParameterFilter { $Path -eq $registryPath } `
                    -Exactly -Times 1 -ModuleName $script:DSCResourceName -Scope Context
                
                Assert-MockCalled Get-ItemProperty -ParameterFilter { $Path -eq $registryPathWow6432Node } `
                    -Exactly -Times 1 -ModuleName $script:DSCResourceName -Scope Context
            }
        }

        Context 'When the system is not in the desired state because TcpPort is different when desired protocol is TCP' {
            $testParameters = @{
                Name = $nameDifferentTcpPort
                ServerName = $serverNameTcp
            }

            $result = Get-TargetResource @testParameters

            It 'Should return the state as present' {
                $result.Ensure | Should Be 'Present'
            }

            It 'Should return the same values as passed as parameters' {
                $result.Name | Should Be $testParameters.Name
                $result.ServerName | Should Be $testParameters.ServerName
            }

            It 'Should return TCP as the protocol used' {
                $result.Protocol | Should Be 'TCP'
            }
            
            It "Should return $differentTcpPort as the port number used" {
                $result.TcpPort | Should Be $differentTcpPort
            }

            It 'Should not return any pipe name' {
                $result.PipeName | Should Be ''
            }

            It 'Should call the mocked functions exactly 1 time each' {
                Assert-MockCalled Get-WmiObject -ParameterFilter { $Class -eq 'win32_OperatingSystem' } `
                    -Exactly -Times 1 -ModuleName $script:DSCResourceName -Scope Context

                Assert-MockCalled Get-ItemProperty -ParameterFilter { $Path -eq $registryPath } `
                    -Exactly -Times 1 -ModuleName $script:DSCResourceName -Scope Context
                
                Assert-MockCalled Get-ItemProperty -ParameterFilter { $Path -eq $registryPathWow6432Node } `
                    -Exactly -Times 1 -ModuleName $script:DSCResourceName -Scope Context
            }
        }

        Context 'When the system is not in the desired state because ServerName is different when desired protocol is TCP' {
            $testParameters = @{
                Name = $nameDifferentServerNameTcp
                ServerName = $serverNameTcp
            }

            $result = Get-TargetResource @testParameters

            It 'Should return the state as present' {
                $result.Ensure | Should Be 'Present'
            }

            It 'Should return the same values as passed as parameters' {
                $result.Name | Should Be $testParameters.Name
            }

            It 'Should return different server name than the one passed as parameter' {
                $result.ServerName | Should Be $differentServerNameTcp
            }

            It 'Should return TCP as the protocol used' {
                $result.Protocol | Should Be 'TCP'
            }
            
            It "Should return $tcpPort as the port number used" {
                $result.TcpPort | Should Be $tcpPort
            }

            It 'Should not return any pipe name' {
                $result.PipeName | Should Be ''
            }

            It 'Should call the mocked functions exactly 1 time each' {
                Assert-MockCalled Get-WmiObject -ParameterFilter { $Class -eq 'win32_OperatingSystem' } `
                    -Exactly -Times 1 -ModuleName $script:DSCResourceName -Scope Context

                Assert-MockCalled Get-ItemProperty -ParameterFilter { $Path -eq $registryPath } `
                    -Exactly -Times 1 -ModuleName $script:DSCResourceName -Scope Context
                
                Assert-MockCalled Get-ItemProperty -ParameterFilter { $Path -eq $registryPathWow6432Node } `
                    -Exactly -Times 1 -ModuleName $script:DSCResourceName -Scope Context
            }
        }

        # Mocking 32-bit OS
        Mock -CommandName Get-WmiObject -MockWith {
            return New-Object Object | 
                Add-Member -MemberType NoteProperty -Name OSArchitecture -Value '32-bit' -PassThru -Force
        } -ParameterFilter { $Class -eq 'win32_OperatingSystem' } -ModuleName $script:DSCResourceName -Verifiable

        Context 'When the system is in the desired present state for 32-bit OS using TCP' {
            $testParameters = @{
                Name = $name
                ServerName = $serverNameTcp
            }

            $result = Get-TargetResource @testParameters

            It 'Should return the state as present' {
                $result.Ensure | Should Be 'Present'
            }

            It 'Should return the same values as passed as parameters' {
                $result.Name | Should Be $testParameters.Name
                $result.ServerName | Should Be $testParameters.ServerName
            }

            It 'Should return TCP as the protocol used' {
                $result.Protocol | Should Be 'TCP'
            }
            
            It "Should return $tcpPort as the port number used" {
                $result.TcpPort | Should Be $tcpPort
            }

            It 'Should not return any pipe name' {
                $result.PipeName | Should Be ''
            }

            It 'Should call the mocked functions exactly 1 time each' {
                Assert-MockCalled Get-WmiObject -ParameterFilter { $Class -eq 'win32_OperatingSystem' } `
                    -Exactly -Times 1 -ModuleName $script:DSCResourceName -Scope Context

                Assert-MockCalled Get-ItemProperty -ParameterFilter { $Path -eq $registryPath } `
                    -Exactly -Times 1 -ModuleName $script:DSCResourceName -Scope Context
            }

            It 'Should not call the Get-ItemProperty for the Wow6432Node-path' {
                Assert-MockCalled Get-ItemProperty -ParameterFilter { $Path -eq $registryPathWow6432Node } `
                    -Exactly -Times 0 -ModuleName $script:DSCResourceName -Scope Context
            }
        }

        Context 'When the system is in the desired absent state for 32-bit OS' {
            $testParameters = @{
                Name = $unknownName
                ServerName = $unknownServerName
            }

            $result = Get-TargetResource @testParameters

            It 'Should return the state as absent' {
                $result.Ensure | Should Be 'Absent'
            }

            It 'Should return the same values as passed as parameters' {
                $result.Name | Should Be $testParameters.Name
            }

            It 'Should not return the value passed in the ServerName parameter' {
                $result.ServerName | Should Be ''
            }

            It 'Should not return any protocol' {
                $result.Protocol | Should Be ''
            }
            
            It 'Should not return a port number' {
                $result.TcpPort | Should Be 0
            }

            It 'Should not return any pipe name' {
                $result.PipeName | Should Be ''
            }

            It 'Should call the mocked functions exactly 1 time each' {
                Assert-MockCalled Get-WmiObject -ParameterFilter { $Class -eq 'win32_OperatingSystem' } `
                    -Exactly -Times 1 -ModuleName $script:DSCResourceName -Scope Context

                Assert-MockCalled Get-ItemProperty -ParameterFilter { $Path -eq $registryPath } `
                    -Exactly -Times 1 -ModuleName $script:DSCResourceName -Scope Context
            }

            It 'Should not call the Get-ItemProperty for the Wow6432Node-path' {
                Assert-MockCalled Get-ItemProperty -ParameterFilter { $Path -eq $registryPathWow6432Node } `
                    -Exactly -Times 0 -ModuleName $script:DSCResourceName -Scope Context
            }
        }

        # Testing protocol NP (Named Pipes)
        Mock -CommandName Get-ItemProperty -ParameterFilter { $Path -eq $registryPath -and $Name -eq $name } -MockWith {
            return @{
                'MyAlias' = 'DBNMPNTW,\\sqlnode\PIPE\sql\query'
            }
        } -ModuleName $script:DSCResourceName -Verifiable

        Mock -CommandName Get-ItemProperty -ParameterFilter { $Path -eq $registryPathWow6432Node -and $Name -eq $name } -MockWith {
            return @{
                'MyAlias' = 'DBNMPNTW,\\sqlnode\PIPE\sql\query'
            }
        } -ModuleName $script:DSCResourceName -Verifiable

        Mock -CommandName Get-ItemProperty -ParameterFilter { $Path -eq $registryPath -and $Name -eq $nameDifferentPipeName } -MockWith {
            return @{
                'DifferentPipeName' = 'DBNMPNTW,\\unknownserver\PIPE\sql\query'
            }
        } -ModuleName $script:DSCResourceName -Verifiable

        Mock -CommandName Get-ItemProperty -ParameterFilter { $Path -eq $registryPathWow6432Node -and $Name -eq $nameDifferentPipeName } -MockWith {
            return @{
                'DifferentPipeName' = 'DBNMPNTW,\\unknownserver\PIPE\sql\query'
            }
        } -ModuleName $script:DSCResourceName -Verifiable

        Mock -CommandName Get-ItemProperty -ParameterFilter { $Path -eq $registryPath -and $Name -eq $nameWow6432NodeDifferFrom64BitOS } -MockWith {
            return @{
                'Wow6432NodeDifferFrom64BitOS' = 'DBNMPNTW,\\firstserver\PIPE\sql\query'
            }
        } -ModuleName $script:DSCResourceName -Verifiable

        Mock -CommandName Get-ItemProperty -ParameterFilter { $Path -eq $registryPathWow6432Node -and $Name -eq $nameWow6432NodeDifferFrom64BitOS } -MockWith {
            return @{
                'Wow6432NodeDifferFrom64BitOS' = 'DBNMPNTW,\\secondserver\PIPE\sql\query'
            }
        } -ModuleName $script:DSCResourceName -Verifiable

        # Mocking 64-bit OS
        Mock -CommandName Get-WmiObject -MockWith {
            return New-Object Object | 
                Add-Member -MemberType NoteProperty -Name OSArchitecture -Value '64-bit' -PassThru -Force
        } -ParameterFilter { $Class -eq 'win32_OperatingSystem' } -ModuleName $script:DSCResourceName -Verifiable

        Context 'When the system is in the desired present state for 64-bit OS using Named Pipes' {
            $testParameters = @{
                Name = $name
                ServerName = $serverNameNamedPipes
            }

            $result = Get-TargetResource @testParameters

            It 'Should return the state as present' {
                $result.Ensure | Should Be 'Present'
            }

            It 'Should return the same value as passed in the Name parameter' {
                $result.Name | Should Be $testParameters.Name
            }

            It 'Should not return the value passed in the ServerName parameter' {
                $result.ServerName | Should Be ''
            }

            It 'Should return NP as the protocol used' {
                $result.Protocol | Should Be 'NP'
            }
            
            It 'Should not return a port number' {
                $result.TcpPort | Should Be 0
            }

            It 'Should return the correct pipe name based on the passed ServerName parameter' {
                $result.PipeName | Should Be "\\$serverNameNamedPipes\PIPE\sql\query"
            }

            It 'Should call the mocked functions exactly 1 time each' {
                Assert-MockCalled Get-WmiObject -ParameterFilter { $Class -eq 'win32_OperatingSystem' } `
                    -Exactly -Times 1 -ModuleName $script:DSCResourceName -Scope Context

                Assert-MockCalled Get-ItemProperty -ParameterFilter { $Path -eq $registryPath } `
                    -Exactly -Times 1 -ModuleName $script:DSCResourceName -Scope Context
                
                Assert-MockCalled Get-ItemProperty -ParameterFilter { $Path -eq $registryPathWow6432Node } `
                    -Exactly -Times 1 -ModuleName $script:DSCResourceName -Scope Context
            }
        }

        Context 'When the system is not in the desired state because ServerName is different when desired protocol is Named Pipes' {
            $testParameters = @{
                Name = $nameDifferentPipeName
                ServerName = $serverNameNamedPipes
            }

            $result = Get-TargetResource @testParameters

            It 'Should return the state as present' {
                $result.Ensure | Should Be 'Present'
            }

            It 'Should return the same values as passed as parameters' {
                $result.Name | Should Be $testParameters.Name
            }

            It 'Should not return the value passed in the ServerName parameter' {
                $result.ServerName | Should Be ''
            }

            It 'Should return NP as the protocol used' {
                $result.Protocol | Should Be 'NP'
            }
            
            It 'Should not return a port number' {
                $result.TcpPort | Should Be 0
            }

            It 'Should return the correct pipe name based on the passed ServerName parameter' {
                $result.PipeName | Should Be $differentPipeName
            }

            It 'Should call the mocked functions exactly 1 time each' {
                Assert-MockCalled Get-WmiObject -ParameterFilter { $Class -eq 'win32_OperatingSystem' } `
                    -Exactly -Times 1 -ModuleName $script:DSCResourceName -Scope Context

                Assert-MockCalled Get-ItemProperty -ParameterFilter { $Path -eq $registryPath } `
                    -Exactly -Times 1 -ModuleName $script:DSCResourceName -Scope Context
                
                Assert-MockCalled Get-ItemProperty -ParameterFilter { $Path -eq $registryPathWow6432Node } `
                    -Exactly -Times 1 -ModuleName $script:DSCResourceName -Scope Context
            }
        }

        Context 'When the state differ between 32-bit OS and 64-bit OS registry keys' {
            $testParameters = @{
                Name = $nameWow6432NodeDifferFrom64BitOS
                ServerName = $serverNameNamedPipes
            }

            $result = Get-TargetResource @testParameters

            It 'Should return the state as absent' {
                $result.Ensure | Should Be 'Absent'
            }

            It 'Should return the same values as passed as parameters' {
                $result.Name | Should Be $testParameters.Name
            }

            It 'Should not return the value passed in the ServerName parameter' {
                $result.ServerName | Should Be ''
            }

            It 'Should not return any protocol' {
                $result.Protocol | Should Be ''
            }
            
            It 'Should not return a port number' {
                $result.TcpPort | Should Be 0
            }

            It 'Should not return any pipe name' {
                $result.PipeName | Should Be ''
            }

            It 'Should call the mocked functions exactly 1 time each' {
                Assert-MockCalled Get-WmiObject -ParameterFilter { $Class -eq 'win32_OperatingSystem' } `
                    -Exactly -Times 1 -ModuleName $script:DSCResourceName -Scope Context

                Assert-MockCalled Get-ItemProperty -ParameterFilter { $Path -eq $registryPath } `
                    -Exactly -Times 1 -ModuleName $script:DSCResourceName -Scope Context
                
                Assert-MockCalled Get-ItemProperty -ParameterFilter { $Path -eq $registryPathWow6432Node } `
                    -Exactly -Times 1 -ModuleName $script:DSCResourceName -Scope Context
            }
        }

        # Mocking 32-bit OS
        Mock -CommandName Get-WmiObject -MockWith {
            return New-Object Object | 
                Add-Member -MemberType NoteProperty -Name OSArchitecture -Value '32-bit' -PassThru -Force
        } -ParameterFilter { $Class -eq 'win32_OperatingSystem' } -ModuleName $script:DSCResourceName -Verifiable

        Context 'When the system is in the desired present state for 32-bit OS using Named Pipes' {
            $testParameters = @{
                Name = $name
                ServerName = $serverNameNamedPipes
            }

            $result = Get-TargetResource @testParameters

            It 'Should return the state as present' {
                $result.Ensure | Should Be 'Present'
            }

            It 'Should return the same value as passed in the Name parameter' {
                $result.Name | Should Be $testParameters.Name
            }

            It 'Should not return the value passed in the ServerName parameter' {
                $result.ServerName | Should Be ''
            }

            It 'Should return NP as the protocol used' {
                $result.Protocol | Should Be 'NP'
            }
            
            It 'Should not return a port number' {
                $result.TcpPort | Should Be 0
            }

            It 'Should return the correct pipe name based on the passed ServerName parameter' {
                $result.PipeName | Should Be $pipeName
            }

            It 'Should call the mocked functions exactly 1 time each' {
                Assert-MockCalled Get-WmiObject -ParameterFilter { $Class -eq 'win32_OperatingSystem' } `
                    -Exactly -Times 1 -ModuleName $script:DSCResourceName -Scope Context

                Assert-MockCalled Get-ItemProperty -ParameterFilter { $Path -eq $registryPath } `
                    -Exactly -Times 1 -ModuleName $script:DSCResourceName -Scope Context
            }

            It 'Should not call the Get-ItemProperty for the Wow6432Node-path' {
                Assert-MockCalled Get-ItemProperty -ParameterFilter { $Path -eq $registryPathWow6432Node } `
                    -Exactly -Times 0 -ModuleName $script:DSCResourceName -Scope Context
            }
        }

        Assert-VerifiableMocks
    }
    #endregion Get-TargetResource

    #region Set-TargetResource
    Describe "$($script:DSCResourceName)\Set-TargetResource" {
        Mock -CommandName New-Item -MockWith {} -ModuleName $script:DSCResourceName -Verifiable
        Mock -CommandName Set-ItemProperty -MockWith {} -ModuleName $script:DSCResourceName -Verifiable
        Mock -CommandName Remove-ItemProperty -MockWith {} -ModuleName $script:DSCResourceName -Verifiable
        Mock -CommandName Test-Path -MockWith {
            return $false
        } -ModuleName $script:DSCResourceName -Verifiable

        # Mocking 64-bit OS
        Mock -CommandName Get-WmiObject -MockWith {
            return New-Object Object | 
                Add-Member -MemberType NoteProperty -Name OSArchitecture -Value '64-bit' -PassThru -Force
        } -ParameterFilter { $Class -eq 'win32_OperatingSystem' } -ModuleName $script:DSCResourceName -Verifiable
        
        Context 'When the system is not in the desired state for 64-bit OS using TCP' {
            It 'Should call mocked functions Test-Path, New-Item and Set-ItemProperty twice each when desired state should be present for protocol TCP' {
                $testParameters = @{
                    Name = $name
                    Protocol = 'TCP'
                    ServerName = $serverNameTcp
                    TcpPort = $tcpPort
                }

                Set-TargetResource @testParameters

                Assert-MockCalled -ModuleName $script:DSCResourceName -CommandName Test-Path -Exactly 2 -Scope It
                Assert-MockCalled -ModuleName $script:DSCResourceName -CommandName New-Item -Exactly 2 -Scope It
                Assert-MockCalled -ModuleName $script:DSCResourceName -CommandName Set-ItemProperty -Exactly 2 -Scope It
            }

            It 'Should call mocked functions Test-Path, New-Item and Set-ItemProperty twice each when desired state should be present for protocol Named Pipes' {
                $testParameters = @{
                    Name = $name
                    Protocol = 'NP'
                    ServerName = $serverNameNamedPipes
                }

                Set-TargetResource @testParameters

                Assert-MockCalled -ModuleName $script:DSCResourceName -CommandName Test-Path -Exactly 2 -Scope It
                Assert-MockCalled -ModuleName $script:DSCResourceName -CommandName New-Item -Exactly 2 -Scope It
                Assert-MockCalled -ModuleName $script:DSCResourceName -CommandName Set-ItemProperty -Exactly 2 -Scope It
            }

            It 'Should call mocked functions Test-Path and Remove-ItemProperty twice each when desired state should be absent for 64-bit OS' {
                Mock -CommandName Test-Path -MockWith {
                    return $true
                } -ModuleName $script:DSCResourceName -Verifiable

                $testParameters = @{
                    Ensure = 'Absent'
                    Name = $name
                    ServerName = $serverNameTcp
                }

                Set-TargetResource @testParameters

                Assert-MockCalled -ModuleName $script:DSCResourceName -CommandName Test-Path -Exactly 2 -Scope It
                Assert-MockCalled -ModuleName $script:DSCResourceName -CommandName Remove-ItemProperty -Exactly 2 -Scope It
            }

        }

        # Mocking 32-bit OS
        Mock -CommandName Get-WmiObject -MockWith {
            return New-Object Object | 
                Add-Member -MemberType NoteProperty -Name OSArchitecture -Value '32-bit' -PassThru -Force
        } -ParameterFilter { $Class -eq 'win32_OperatingSystem' } -ModuleName $script:DSCResourceName -Verifiable

        Context 'When the system is not in the desired state for 32-bit OS using TCP' {
            It 'Should call mocked functions Test-Path, New-Item and Set-ItemProperty once each when desired state should be present for protocol TCP' {
                $testParameters = @{
                    Name = $name
                    Protocol = 'TCP'
                    ServerName = $serverNameTcp
                    TcpPort = $tcpPort
                }

                Set-TargetResource @testParameters

                Assert-MockCalled -ModuleName $script:DSCResourceName -CommandName Test-Path -Exactly 1 -Scope It
                Assert-MockCalled -ModuleName $script:DSCResourceName -CommandName New-Item -Exactly 1 -Scope It
                Assert-MockCalled -ModuleName $script:DSCResourceName -CommandName Set-ItemProperty -Exactly 1 -Scope It
            }

            It 'Should call mocked functions Test-Path, New-Item and Set-ItemProperty once each when desired state should be present for protocol Named Pipes' {
                $testParameters = @{
                    Name = $name
                    Protocol = 'NP'
                    ServerName = $serverNameNamedPipes
                }

                Set-TargetResource @testParameters

                Assert-MockCalled -ModuleName $script:DSCResourceName -CommandName Test-Path -Exactly 1 -Scope It
                Assert-MockCalled -ModuleName $script:DSCResourceName -CommandName New-Item -Exactly 1 -Scope It
                Assert-MockCalled -ModuleName $script:DSCResourceName -CommandName Set-ItemProperty -Exactly 1 -Scope It
            }

            It 'Should call mocked functions Test-Path and Remove-ItemProperty once each when desired state should be absent for 32-bit OS' {
                Mock -CommandName Test-Path -MockWith {
                    return $true
                } -ModuleName $script:DSCResourceName -Verifiable

                $testParameters = @{
                    Ensure = 'Absent'
                    Name = $name
                    ServerName = $serverNameNamedPipes
                }

                Set-TargetResource @testParameters

                Assert-MockCalled -ModuleName $script:DSCResourceName -CommandName Test-Path -Exactly 1 -Scope It
                Assert-MockCalled -ModuleName $script:DSCResourceName -CommandName Remove-ItemProperty -Exactly 1 -Scope It
            }
        }
    }
    #endregion Set-TargetResource

    #region Test-TargetResource
    Describe "$($script:DSCResourceName)\Test-TargetResource" {
        Mock -CommandName Get-ItemProperty -ParameterFilter { $Path -eq $registryPath -and $Name -eq $name } -MockWith {
            return @{
                'MyAlias' = 'DBMSSOCN,sqlnode.company.local,1433'
            }
        } -ModuleName $script:DSCResourceName -Verifiable

        Mock -CommandName Get-ItemProperty -ParameterFilter { $Path -eq $registryPathWow6432Node -and $Name -eq $name } -MockWith {
            return @{
                'MyAlias' = 'DBMSSOCN,sqlnode.company.local,1433'
            }
        } -ModuleName $script:DSCResourceName -Verifiable

        Mock -CommandName Get-ItemProperty -ParameterFilter { $Path -eq $registryPath -and $Name -eq $unknownName } -MockWith {
            return $null
        } -ModuleName $script:DSCResourceName -Verifiable

        # Mocking 64-bit OS
        Mock -CommandName Get-WmiObject -MockWith {
            return New-Object Object | 
                Add-Member -MemberType NoteProperty -Name OSArchitecture -Value '64-bit' -PassThru -Force
        } -ParameterFilter { $Class -eq 'win32_OperatingSystem' } -ModuleName $script:DSCResourceName -Verifiable

        Context 'When the system is in the desired state (when using TCP)' {
            It 'Should return state as present ($true)' {
                $testParameters = @{
                    Name = $name
                    Protocol = 'TCP'
                    ServerName = $serverNameTcp
                    TcpPort = $tcpPort
                }

                Test-TargetResource @testParameters | Should Be $true
            }
        }

        Context 'When the system is not in the desired state (when using TCP)' {
            It 'Should return state as absent ($false)' {
                $testParameters = @{
                    Name = $unknownName
                    Protocol = 'TCP'
                    ServerName = $serverNameTcp
                    TcpPort = $tcpPort
                }

                Test-TargetResource @testParameters | Should Be $false
            }
        }

        Mock -CommandName Get-ItemProperty -ParameterFilter { $Path -eq $registryPath -and $Name -eq $name } -MockWith {
            return @{
                'MyAlias' = 'DBNMPNTW,\\sqlnode\PIPE\sql\query'
            }
        } -ModuleName $script:DSCResourceName -Verifiable

        Mock -CommandName Get-ItemProperty -ParameterFilter { $Path -eq $registryPathWow6432Node -and $Name -eq $name } -MockWith {
            return @{
                'MyAlias' = 'DBNMPNTW,\\sqlnode\PIPE\sql\query'
            }
        } -ModuleName $script:DSCResourceName -Verifiable

        Mock -CommandName Get-ItemProperty -ParameterFilter { $Path -eq $registryPath -and $Name -eq $unknownName } -MockWith {
            return $null
        } -ModuleName $script:DSCResourceName -Verifiable

        Context 'When the system is in the desired state (when using Named Pipes)' {
            It 'Should return state as present ($true)' {
                $testParameters = @{
                    Name = $name
                    Protocol = 'NP'
                    ServerName = $serverNameNamedPipes
                }

                Test-TargetResource @testParameters | Should Be $true
            }
        }

        Context 'When the system is not in the desired state (when using Named Pipes)' {
            It 'Should return state as absent ($false)' {
                $testParameters = @{
                    Name = $unknownName
                    Protocol = 'NP'
                    ServerName = $serverNameNamedPipes
                }

                Test-TargetResource @testParameters | Should Be $false
            }
        }
    }
    #endregion Test-TargetResource
}
finally
{
    #region FOOTER

    Restore-TestEnvironment -TestEnvironment $TestEnvironment 

    #endregion
}
