# Need to be able to create a password from plain text to create test credentials
[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingConvertToSecureStringWithPlainText', '')]
param ()

$errorActionPreference = 'Stop'
Set-StrictMode -Version 'Latest'

# Import CommonTestHelper for Enter-DscResourceTestEnvironment, Exit-DscResourceTestEnvironment
$script:testsFolderFilePath = Split-Path $PSScriptRoot -Parent
$script:commonTestHelperFilePath = Join-Path -Path $testsFolderFilePath -ChildPath 'CommonTestHelper.psm1'
Import-Module -Name $commonTestHelperFilePath

$script:testEnvironment = Enter-DscResourceTestEnvironment `
    -DSCResourceModuleName 'xPSDesiredStateConfiguration' `
    -DSCResourceName 'MSFT_xServiceResource' `
    -TestType 'Unit'

try
{
    # This is needed so that the ServiceControllerStatus enum is recognized as a valid type
    Add-Type -AssemblyName 'System.ServiceProcess'

    InModuleScope 'MSFT_xServiceResource' {
        $script:testServiceName = 'DscTestService'
        
        $script:testUsername1 = 'TestUser1'
        $script:testUsername2 = 'TestUser2'

        $script:testPassword = 'DummyPassword'
        $secureTestPassword = ConvertTo-SecureString $script:testPassword -AsPlainText -Force

        $script:testCredential1 = New-Object -TypeName 'System.Management.Automation.PSCredential' -ArgumentList ($script:testUsername1, $secureTestPassword)
        $script:testCredential2 = New-Object -TypeName 'System.Management.Automation.PSCredential' -ArgumentList ($script:testUsername2, $secureTestPassword)

        Describe 'xService\Get-TargetResource' {
            Mock -CommandName 'Get-Service' -MockWith { }
            Mock -CommandName 'Get-ServiceCimInstance' -MockWith { }
            Mock -CommandName 'ConvertTo-StartupTypeString' -MockWith { }

            $getTargetResourceParameters = @{
                Name = 'TestServiceName'
            }

            Context 'Service does not exist' {
                It 'Should not throw' {
                    { $null = Get-TargetResource @getTargetResourceParameters } | Should Not Throw
                }

                It 'Should retrieve service' {
                    Assert-MockCalled -CommandName 'Get-Service' -ParameterFilter { $Name -eq $getTargetResourceParameters.Name } -Times 1 -Scope 'Context'
                }

                It 'Should not attempt to retrieve the service CIM instance' {
                    Assert-MockCalled 'Get-ServiceCimInstance' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to convert the service start mode to a startup type string' {
                    Assert-MockCalled -CommandName 'ConvertTo-StartupTypeString' -Times 0 -Scope 'Context'
                }

                $getTargetResourceResult = Get-TargetResource @getTargetResourceParameters

                It 'Should return a hashtable' {
                    $getTargetResourceResult -is [Hashtable] | Should Be $true
                }

                It 'Should return the service name' {
                    $getTargetResourceResult.Name | Should Be $getTargetResourceParameters.Name
                }

                It 'Should return the service Ensure state as Absent' {
                    $getTargetResourceResult.Ensure | Should Be 'Absent'
                }
            }

            Context 'Service exists with all properties defined and custom startup account name' {
                $testService = @{
                    Name = 'TestServiceName'
                    DisplayName = 'TestDisplayName'
                    Status = 'TestServiceStatus'
                    StartType = 'TestServiceStartType'
                    ServicesDependedOn = @(
                        @{
                            Name = 'ServiceDependency1'
                        },
                        @{
                            Name = 'ServiceDependency2'
                        }
                    )
                }

                $testServiceCimInstance = @{
                    Name = $testService.Name
                    PathName = 'TestServicePath'
                    Description = 'Test service description'
                    StartName = 'CustomStartName'
                    StartMode = 'Auto'
                    DesktopInteract = $true
                }

                $convertToStartupTypeStringResult = 'TestStartupTypeString'
                
                Mock -CommandName 'Get-Service' -MockWith { return $testService }
                Mock -CommandName 'Get-ServiceCimInstance' -MockWith { return $testServiceCimInstance }
                Mock -CommandName 'ConvertTo-StartupTypeString' -MockWith { return $convertToStartupTypeStringResult }

                It 'Should not throw' {
                    { $null = Get-TargetResource @getTargetResourceParameters } | Should Not Throw
                }

                It 'Should retrieve service' {
                    Assert-MockCalled -CommandName 'Get-Service' -ParameterFilter { $Name -eq $getTargetResourceParameters.Name } -Times 1 -Scope 'Context'
                }

                It 'Should retrieve the service CIM instance' {
                    Assert-MockCalled 'Get-ServiceCimInstance' -ParameterFilter { $ServiceName -eq $getTargetResourceParameters.Name } -Times 1 -Scope 'Context'
                }

                It 'Should convert the service start mode to a startup type string' {
                    Assert-MockCalled -CommandName 'ConvertTo-StartupTypeString' -ParameterFilter { $StartMode -eq $testServiceCimInstance.StartMode } -Times 1 -Scope 'Context'
                }

                $getTargetResourceResult = Get-TargetResource @getTargetResourceParameters

                It 'Should return a hashtable' {
                    $getTargetResourceResult -is [Hashtable] | Should Be $true
                }

                It 'Should return the service name' {
                    $getTargetResourceResult.Name | Should Be $getTargetResourceParameters.Name
                }

                It 'Should return the service Ensure state as Present' {
                    $getTargetResourceResult.Ensure | Should Be 'Present'
                }

                It 'Should return the service path' {
                    $getTargetResourceResult.Path | Should Be $testServiceCimInstance.PathName
                }

                It 'Should return the service startup type' {
                    $getTargetResourceResult.StartupType | Should Be $convertToStartupTypeStringResult
                }

                It 'Should return the service startup account name' {
                    $getTargetResourceResult.BuiltInAccount | Should Be $testServiceCimInstance.StartName
                }

                It 'Should return the service state' {
                    $getTargetResourceResult.State | Should Be $testService.Status
                }

                It 'Should return the service display name' {
                    $getTargetResourceResult.DisplayName | Should Be $testService.DisplayName
                }

                It 'Should return the service description' {
                    $getTargetResourceResult.Description | Should Be $testServiceCimInstance.Description
                }

                It 'Should return the service desktop interation setting' {
                    $getTargetResourceResult.DesktopInteract | Should Be $testServiceCimInstance.DesktopInteract
                }

                It 'Should return the service dependencies' {
                    $getTargetResourceResult.Dependencies | Should Be $testService.ServicesDependedOn.Name
                }
            }

            Context 'Service exists with no dependencies and startup account name as NT Authority\LocalService' {
                $testService = @{
                    Name = 'TestServiceName'
                    DisplayName = 'TestDisplayName'
                    Status = 'TestServiceStatus'
                    StartType = 'TestServiceStartType'
                    ServicesDependedOn = $null
                }

                $expectedBuiltInAccountValue = 'LocalService'

                $testServiceCimInstance = @{
                    Name = $testService.Name
                    PathName = 'TestServicePath'
                    Description = 'Test service description'
                    StartName = "NT Authority\$expectedBuiltInAccountValue"
                    StartMode = 'Manual'
                    DesktopInteract = $false
                }

                $convertToStartupTypeStringResult = 'TestStartupTypeString'
                
                Mock -CommandName 'Get-Service' -MockWith { return $testService }
                Mock -CommandName 'Get-ServiceCimInstance' -MockWith { return $testServiceCimInstance }
                Mock -CommandName 'ConvertTo-StartupTypeString' -MockWith { return $convertToStartupTypeStringResult }

                It 'Should not throw' {
                    { $null = Get-TargetResource @getTargetResourceParameters } | Should Not Throw
                }

                It 'Should retrieve service' {
                    Assert-MockCalled -CommandName 'Get-Service' -ParameterFilter { $Name -eq $getTargetResourceParameters.Name } -Times 1 -Scope 'Context'
                }

                It 'Should retrieve the service CIM instance' {
                    Assert-MockCalled 'Get-ServiceCimInstance' -ParameterFilter { $ServiceName -eq $getTargetResourceParameters.Name } -Times 1 -Scope 'Context'
                }

                It 'Should convert the service start mode to a startup type string' {
                    Assert-MockCalled -CommandName 'ConvertTo-StartupTypeString' -ParameterFilter { $StartMode -eq $testServiceCimInstance.StartMode } -Times 1 -Scope 'Context'
                }

                $getTargetResourceResult = Get-TargetResource @getTargetResourceParameters

                It 'Should return a hashtable' {
                    $getTargetResourceResult -is [Hashtable] | Should Be $true
                }

                It 'Should return the service name' {
                    $getTargetResourceResult.Name | Should Be $getTargetResourceParameters.Name
                }

                It 'Should return the service Ensure state as Present' {
                    $getTargetResourceResult.Ensure | Should Be 'Present'
                }

                It 'Should return the service path' {
                    $getTargetResourceResult.Path | Should Be $testServiceCimInstance.PathName
                }

                It 'Should return the service startup type' {
                    $getTargetResourceResult.StartupType | Should Be $convertToStartupTypeStringResult
                }

                It 'Should return the service startup account name' {
                    $getTargetResourceResult.BuiltInAccount | Should Be $expectedBuiltInAccountValue
                }

                It 'Should return the service state' {
                    $getTargetResourceResult.State | Should Be $testService.Status
                }

                It 'Should return the service display name' {
                    $getTargetResourceResult.DisplayName | Should Be $testService.DisplayName
                }

                It 'Should return the service description' {
                    $getTargetResourceResult.Description | Should Be $testServiceCimInstance.Description
                }

                It 'Should return the service desktop interation setting' {
                    $getTargetResourceResult.DesktopInteract | Should Be $testServiceCimInstance.DesktopInteract
                }

                It 'Should return the service dependencies as null' {
                    $getTargetResourceResult.Dependencies | Should Be $null
                }
            }

            Context 'Service exists with no description or display name and startup account name as NT Authority\NetworkService' {
                $testService = @{
                    Name = 'TestServiceName'
                    DisplayName = $null
                    Status = 'TestServiceStatus'
                    StartType = 'TestServiceStartType'
                    ServicesDependedOn = @(
                        @{
                            Name = 'ServiceDependency1'
                        },
                        @{
                            Name = 'ServiceDependency2'
                        }
                    )
                }

                $expectedBuiltInAccountValue = 'NetworkService'

                $testServiceCimInstance = @{
                    Name = $testService.Name
                    PathName = 'TestServicePath'
                    Description = $null
                    StartName = "NT Authority\$expectedBuiltInAccountValue"
                    StartMode = 'Disabled'
                    DesktopInteract = $false
                }

                $convertToStartupTypeStringResult = 'TestStartupTypeString'
                
                Mock -CommandName 'Get-Service' -MockWith { return $testService }
                Mock -CommandName 'Get-ServiceCimInstance' -MockWith { return $testServiceCimInstance }
                Mock -CommandName 'ConvertTo-StartupTypeString' -MockWith { return $convertToStartupTypeStringResult }

                It 'Should not throw' {
                    { $null = Get-TargetResource @getTargetResourceParameters } | Should Not Throw
                }

                It 'Should retrieve service' {
                    Assert-MockCalled -CommandName 'Get-Service' -ParameterFilter { $Name -eq $getTargetResourceParameters.Name } -Times 1 -Scope 'Context'
                }

                It 'Should retrieve the service CIM instance' {
                    Assert-MockCalled 'Get-ServiceCimInstance' -ParameterFilter { $ServiceName -eq $getTargetResourceParameters.Name } -Times 1 -Scope 'Context'
                }

                It 'Should convert the service start mode to a startup type string' {
                    Assert-MockCalled -CommandName 'ConvertTo-StartupTypeString' -ParameterFilter { $StartMode -eq $testServiceCimInstance.StartMode } -Times 1 -Scope 'Context'
                }

                $getTargetResourceResult = Get-TargetResource @getTargetResourceParameters

                It 'Should return a hashtable' {
                    $getTargetResourceResult -is [Hashtable] | Should Be $true
                }

                It 'Should return the service name' {
                    $getTargetResourceResult.Name | Should Be $getTargetResourceParameters.Name
                }

                It 'Should return the service Ensure state as Present' {
                    $getTargetResourceResult.Ensure | Should Be 'Present'
                }

                It 'Should return the service path' {
                    $getTargetResourceResult.Path | Should Be $testServiceCimInstance.PathName
                }

                It 'Should return the service startup type' {
                    $getTargetResourceResult.StartupType | Should Be $convertToStartupTypeStringResult
                }

                It 'Should return the service startup account name' {
                    $getTargetResourceResult.BuiltInAccount | Should Be $expectedBuiltInAccountValue
                }

                It 'Should return the service state' {
                    $getTargetResourceResult.State | Should Be $testService.Status
                }

                It 'Should return the service display name as null' {
                    $getTargetResourceResult.DisplayName | Should Be $null
                }

                It 'Should return the service description as null' {
                    $getTargetResourceResult.Description | Should Be $null
                }

                It 'Should return the service desktop interation setting' {
                    $getTargetResourceResult.DesktopInteract | Should Be $testServiceCimInstance.DesktopInteract
                }

                It 'Should return the service dependencies' {
                    $getTargetResourceResult.Dependencies | Should Be $testService.ServicesDependedOn.Name
                }
            }
        }

        Describe 'xService\Set-TargetResource' {
            Mock -CommandName 'Assert-NoStartupTypeStateConflict' -MockWith { }

            Mock -CommandName 'Get-Service' -MockWith { }
            Mock -CommandName 'New-Service' -MockWith { }
            Mock -CommandName 'Remove-ServiceWithTimeout' -MockWith { }

            Mock -CommandName 'Set-ServicePath' -MockWith { return $true }
            Mock -CommandName 'Set-ServiceProperty' -MockWith { }

            Mock -CommandName 'Start-ServiceWithTimeout' -MockWith { }
            Mock -CommandName 'Stop-ServiceWithTimeout' -MockWith { }

            Context 'Both BuiltInAccount and Credential specified' {
                $setTargetResourceParameters = @{
                    Name = $script:testServiceName
                    BuiltInAccount = 'LocalSystem'
                    Credential = $script:testCredential1
                }

                It 'Should throw an error for BuiltInAccount and Credential conflict' {
                    $expectedErrorMessage = $script:localizedData.BuiltInAccountAndCredentialSpecified -f $setTargetResourceParameters.Name
                    { Set-TargetResource @setTargetResourceParameters } | Should Throw $expectedErrorMessage
                }
            }

            Context 'Service does not exist and Ensure set to Absent' {
                $setTargetResourceParameters = @{
                    Name = $script:testServiceName
                    Ensure = 'Absent'
                }

                It 'Should not throw' {
                    { Set-TargetResource @setTargetResourceParameters } | Should Not Throw
                }

                It 'Should not check for a startup type and state conflict' {
                    Assert-MockCalled -CommandName 'Assert-NoStartupTypeStateConflict' -Times 0 -Scope 'Context'
                }

                It 'Should retrieve the service' {
                    Assert-MockCalled -CommandName 'Get-Service' -ParameterFilter { $Name -eq $setTargetResourceParameters.Name } -Times 1 -Scope 'Context'
                }

                It 'Should not attempt to create the service' {
                    Assert-MockCalled -CommandName 'New-Service' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to remove the service' {
                    Assert-MockCalled -CommandName 'Remove-ServiceWithTimeout' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to change the service path' {
                    Assert-MockCalled -CommandName 'Set-ServicePath' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to change the service properties' {
                    Assert-MockCalled -CommandName 'Set-ServiceProperty' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to start the service' {
                    Assert-MockCalled -CommandName 'Start-ServiceWithTimeout' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to stop or restart the service' {
                    Assert-MockCalled -CommandName 'Stop-ServiceWithTimeout' -Times 0 -Scope 'Context'
                }
            }

            Context 'Service does not exist, Ensure set to Present, and Path not specified' {
                $setTargetResourceParameters = @{
                    Name = $script:testServiceName
                    Ensure = 'Present'
                }

                It 'Should throw an error for the missing path' {
                    $expectedErrorMessage = $script:localizedData.ServiceDoesNotExistPathMissingError -f $script:testServiceName
                    { Set-TargetResource @setTargetResourceParameters } | Should Throw $expectedErrorMessage
                }
            }

            Context 'Service does not exist, Ensure set to Present, and Path specified' {
                $setTargetResourceParameters = @{
                    Name = $script:testServiceName
                    Ensure = 'Present'
                    Path = 'FakePath'
                }

                It 'Should not throw' {
                    { Set-TargetResource @setTargetResourceParameters } | Should Not Throw
                }

                It 'Should not check for a startup type and state conflict' {
                    Assert-MockCalled -CommandName 'Assert-NoStartupTypeStateConflict' -Times 0 -Scope 'Context'
                }

                It 'Should retrieve the service' {
                    Assert-MockCalled -CommandName 'Get-Service' -ParameterFilter { $Name -eq $setTargetResourceParameters.Name } -Times 1 -Scope 'Context'
                }

                It 'Should create the service' {
                    Assert-MockCalled -CommandName 'New-Service' -ParameterFilter { $Name -eq $setTargetResourceParameters.Name -and $BinaryPathName -eq $setTargetResourceParameters.Path } -Times 1 -Scope 'Context'
                }

                It 'Should not attempt to remove the service' {
                    Assert-MockCalled -CommandName 'Remove-ServiceWithTimeout' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to change the service path' {
                    Assert-MockCalled -CommandName 'Set-ServicePath' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to change the service properties' {
                    Assert-MockCalled -CommandName 'Set-ServiceProperty' -Times 0 -Scope 'Context'
                }

                It 'Should start the service' {
                    Assert-MockCalled -CommandName 'Start-ServiceWithTimeout' -ParameterFilter { $ServiceName -eq $setTargetResourceParameters.Name } -Times 1 -Scope 'Context'
                }

                It 'Should not attempt to stop or restart the service' {
                    Assert-MockCalled -CommandName 'Stop-ServiceWithTimeout' -Times 0 -Scope 'Context'
                }
            }

            Context 'Service does not exist, Ensure set to Present, State set to Running, and all parameters except Credential specified' {
                $setTargetResourceParameters = @{
                    Name = $script:testServiceName
                    Ensure = 'Present'
                    Path = 'FakePath'
                    StartupType = 'Automatic'
                    BuiltInAccount = 'LocalSystem'
                    DesktopInteract = $true
                    State = 'Running'
                    DisplayName = 'TestDisplayName'
                    Description = 'Test device description'
                    Dependencies = @( 'TestServiceDependency1', 'TestServiceDependency2' )
                }

                It 'Should not throw' {
                    { Set-TargetResource @setTargetResourceParameters } | Should Not Throw
                }

                It 'Should check for a startup type and state conflict' {
                    Assert-MockCalled -CommandName 'Assert-NoStartupTypeStateConflict' -ParameterFilter { $ServiceName -eq $setTargetResourceParameters.Name -and $StartupType -eq $setTargetResourceParameters.StartupType -and $State -eq $setTargetResourceParameters.State } -Times 1 -Scope 'Context'
                }

                It 'Should retrieve the service' {
                    Assert-MockCalled -CommandName 'Get-Service' -ParameterFilter { $Name -eq $setTargetResourceParameters.Name } -Times 1 -Scope 'Context'
                }

                It 'Should create the service' {
                    Assert-MockCalled -CommandName 'New-Service' -ParameterFilter { $Name -eq $setTargetResourceParameters.Name -and $BinaryPathName -eq $setTargetResourceParameters.Path } -Times 1 -Scope 'Context'
                }

                It 'Should not attempt to remove the service' {
                    Assert-MockCalled -CommandName 'Remove-ServiceWithTimeout' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to change the service path' {
                    Assert-MockCalled -CommandName 'Set-ServicePath' -Times 0 -Scope 'Context'
                }

                It 'Should change all service properties except Credential' {
                    Assert-MockCalled -CommandName 'Set-ServiceProperty' -ParameterFilter { $ServiceName -eq $setTargetResourceParameters.Name -and $StartupType -eq $setTargetResourceParameters.StartupType -and $BuiltInAccount -eq $setTargetResourceParameters.BuiltInAccount -and $DesktopInteract -eq $setTargetResourceParameters.DesktopInteract -and $DisplayName -eq $setTargetResourceParameters.DisplayName -and $Description -eq $setTargetResourceParameters.Description -and $null -eq (Compare-Object -ReferenceObject $setTargetResourceParameters.Dependencies -DifferenceObject $Dependencies) } -Times 1 -Scope 'Context'
                }

                It 'Should start the service' {
                    Assert-MockCalled -CommandName 'Start-ServiceWithTimeout' -ParameterFilter { $ServiceName -eq $setTargetResourceParameters.Name } -Times 1 -Scope 'Context'
                }

                It 'Should not attempt to stop or restart the service' {
                    Assert-MockCalled -CommandName 'Stop-ServiceWithTimeout' -Times 0 -Scope 'Context'
                }
            }

            Context 'Service does not exist, Ensure set to Present, State set to Stopped, and all parameters except BuiltInAccount specified' {
                $setTargetResourceParameters = @{
                    Name = $script:testServiceName
                    Ensure = 'Present'
                    Path = 'FakePath'
                    StartupType = 'Disabled'
                    Credential = $script:testCredential1
                    DesktopInteract = $true
                    State = 'Stopped'
                    DisplayName = 'TestDisplayName'
                    Description = 'Test device description'
                    Dependencies = @( 'TestServiceDependency1', 'TestServiceDependency2' )
                }

                It 'Should not throw' {
                    { Set-TargetResource @setTargetResourceParameters } | Should Not Throw
                }

                It 'Should check for a startup type and state conflict' {
                    Assert-MockCalled -CommandName 'Assert-NoStartupTypeStateConflict' -ParameterFilter { $ServiceName -eq $setTargetResourceParameters.Name -and $StartupType -eq $setTargetResourceParameters.StartupType -and $State -eq $setTargetResourceParameters.State } -Times 1 -Scope 'Context'
                }

                It 'Should retrieve the service' {
                    Assert-MockCalled -CommandName 'Get-Service' -ParameterFilter { $Name -eq $setTargetResourceParameters.Name } -Times 1 -Scope 'Context'
                }

                It 'Should create the service' {
                    Assert-MockCalled -CommandName 'New-Service' -ParameterFilter { $Name -eq $setTargetResourceParameters.Name -and $BinaryPathName -eq $setTargetResourceParameters.Path } -Times 1 -Scope 'Context'
                }

                It 'Should not attempt to remove the service' {
                    Assert-MockCalled -CommandName 'Remove-ServiceWithTimeout' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to change the service path' {
                    Assert-MockCalled -CommandName 'Set-ServicePath' -Times 0 -Scope 'Context'
                }

                It 'Should change all service properties except BuiltInAccount' {
                    Assert-MockCalled -CommandName 'Set-ServiceProperty' -ParameterFilter { $ServiceName -eq $setTargetResourceParameters.Name -and $StartupType -eq $setTargetResourceParameters.StartupType -and $null -eq (Compare-Object -ReferenceObject $setTargetResourceParameters.Credential -DifferenceObject $Credential) -and $DesktopInteract -eq $setTargetResourceParameters.DesktopInteract -and $DisplayName -eq $setTargetResourceParameters.DisplayName -and $Description -eq $setTargetResourceParameters.Description -and $null -eq (Compare-Object -ReferenceObject $setTargetResourceParameters.Dependencies -DifferenceObject $Dependencies) } -Times 1 -Scope 'Context'
                }

                It 'Should not attempt to start the service' {
                    Assert-MockCalled -CommandName 'Start-ServiceWithTimeout' -Times 0 -Scope 'Context'
                }

                It 'Should stop the service' {
                    Assert-MockCalled -CommandName 'Stop-ServiceWithTimeout' -ParameterFilter { $ServiceName -eq $setTargetResourceParameters.Name } -Times 1 -Scope 'Context'
                }
            }

            $testService = @{
                Name = 'TestServiceName'
                DisplayName = 'TestDisplayName'
                Status = 'TestServiceStatus'
                StartType = 'TestServiceStartType'
                ServicesDependedOn = @(
                    @{
                        Name = 'TestServiceDependency1'
                    },
                    @{
                        Name = 'TestServiceDependency2'
                    }
                )
            }

            Mock -CommandName 'Get-Service' -MockWith { return $testService }

            Context 'Service exists and Ensure set to Absent' {
                $setTargetResourceParameters = @{
                    Name = $script:testServiceName
                    Ensure = 'Absent'
                }

                It 'Should not throw' {
                    { Set-TargetResource @setTargetResourceParameters } | Should Not Throw
                }

                It 'Should not check for a startup type and state conflict' {
                    Assert-MockCalled -CommandName 'Assert-NoStartupTypeStateConflict' -Times 0 -Scope 'Context'
                }

                It 'Should retrieve the service' {
                    Assert-MockCalled -CommandName 'Get-Service' -ParameterFilter { $Name -eq $setTargetResourceParameters.Name } -Times 1 -Scope 'Context'
                }

                It 'Should not attempt to create the service' {
                    Assert-MockCalled -CommandName 'New-Service' -Times 0 -Scope 'Context'
                }

                It 'Should stop the service' {
                    Assert-MockCalled -CommandName 'Stop-ServiceWithTimeout' -ParameterFilter { $ServiceName -eq $setTargetResourceParameters.Name } -Times 1 -Scope 'Context'
                }

                It 'Should remove the service' {
                    Assert-MockCalled -CommandName 'Remove-ServiceWithTimeout' -ParameterFilter { $Name -eq $setTargetResourceParameters.Name } -Times 1 -Scope 'Context'
                }

                It 'Should not attempt to change the service path' {
                    Assert-MockCalled -CommandName 'Set-ServicePath' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to change the service properties' {
                    Assert-MockCalled -CommandName 'Set-ServiceProperty' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to start the service' {
                    Assert-MockCalled -CommandName 'Start-ServiceWithTimeout' -Times 0 -Scope 'Context'
                }
            }

            Context 'Service exists and Ensure set to Present' {
                $setTargetResourceParameters = @{
                    Name = $script:testServiceName
                    Ensure = 'Present'
                }

                It 'Should not throw' {
                    { Set-TargetResource @setTargetResourceParameters } | Should Not Throw
                }

                It 'Should not check for a startup type and state conflict' {
                    Assert-MockCalled -CommandName 'Assert-NoStartupTypeStateConflict' -Times 0 -Scope 'Context'
                }

                It 'Should retrieve the service' {
                    Assert-MockCalled -CommandName 'Get-Service' -ParameterFilter { $Name -eq $setTargetResourceParameters.Name } -Times 1 -Scope 'Context'
                }

                It 'Should not attempt to create the service' {
                    Assert-MockCalled -CommandName 'New-Service' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to remove the service' {
                    Assert-MockCalled -CommandName 'Remove-ServiceWithTimeout' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to change the service path' {
                    Assert-MockCalled -CommandName 'Set-ServicePath' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to change the service properties' {
                    Assert-MockCalled -CommandName 'Set-ServiceProperty' -Times 0 -Scope 'Context'
                }

                It 'Should start the service' {
                    Assert-MockCalled -CommandName 'Start-ServiceWithTimeout' -ParameterFilter { $ServiceName -eq $setTargetResourceParameters.Name } -Times 1 -Scope 'Context'
                }
 
                It 'Should not attempt to stop or restart the service' {
                    Assert-MockCalled -CommandName 'Stop-ServiceWithTimeout' -Times 0 -Scope 'Context'
                }
            }

            Context 'Service exists, Ensure set to Present, and Path specified' {
                $setTargetResourceParameters = @{
                    Name = $script:testServiceName
                    Ensure = 'Present'
                    Path = 'TestPath'
                }

                It 'Should not throw' {
                    { Set-TargetResource @setTargetResourceParameters } | Should Not Throw
                }

                It 'Should not check for a startup type and state conflict' {
                    Assert-MockCalled -CommandName 'Assert-NoStartupTypeStateConflict' -Times 0 -Scope 'Context'
                }

                It 'Should retrieve the service' {
                    Assert-MockCalled -CommandName 'Get-Service' -ParameterFilter { $Name -eq $setTargetResourceParameters.Name } -Times 1 -Scope 'Context'
                }

                It 'Should not attempt to create the service' {
                    Assert-MockCalled -CommandName 'New-Service' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to remove the service' {
                    Assert-MockCalled -CommandName 'Remove-ServiceWithTimeout' -Times 0 -Scope 'Context'
                }

                It 'Should change the service path' {
                    Assert-MockCalled -CommandName 'Set-ServicePath' -ParameterFilter { $ServiceName -eq $setTargetResourceParameters.Name -and $Path -eq $setTargetResourceParameters.Path } -Times 1 -Scope 'Context'
                }

                It 'Should not attempt to change the service properties' {
                    Assert-MockCalled -CommandName 'Set-ServiceProperty' -Times 0 -Scope 'Context'
                }

                It 'Should stop the service to restart it' {
                    Assert-MockCalled -CommandName 'Stop-ServiceWithTimeout' -ParameterFilter { $ServiceName -eq $setTargetResourceParameters.Name } -Times 1 -Scope 'Context'
                }

                It 'Should start the service' {
                    Assert-MockCalled -CommandName 'Start-ServiceWithTimeout' -ParameterFilter { $ServiceName -eq $setTargetResourceParameters.Name } -Times 1 -Scope 'Context'
                }
            }

            Context 'Service exists, Ensure set to Present, State set to Stopped, and all parameters except Credential specified' {
                $setTargetResourceParameters = @{
                    Name = $script:testServiceName
                    Ensure = 'Present'
                    Path = 'FakePath'
                    StartupType = 'Automatic'
                    BuiltInAccount = 'LocalSystem'
                    DesktopInteract = $true
                    State = 'Stopped'
                    DisplayName = 'TestDisplayName'
                    Description = 'Test device description'
                    Dependencies = @( 'TestServiceDependency1', 'TestServiceDependency2' )
                }

                It 'Should not throw' {
                    { Set-TargetResource @setTargetResourceParameters } | Should Not Throw
                }

                It 'Should check for a startup type and state conflict' {
                    Assert-MockCalled -CommandName 'Assert-NoStartupTypeStateConflict' -ParameterFilter { $ServiceName -eq $setTargetResourceParameters.Name -and $StartupType -eq $setTargetResourceParameters.StartupType -and $State -eq $setTargetResourceParameters.State } -Times 1 -Scope 'Context'
                }

                It 'Should retrieve the service' {
                    Assert-MockCalled -CommandName 'Get-Service' -ParameterFilter { $Name -eq $setTargetResourceParameters.Name } -Times 1 -Scope 'Context'
                }

                It 'Should not attempt to create the service' {
                    Assert-MockCalled -CommandName 'New-Service' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to remove the service' {
                    Assert-MockCalled -CommandName 'Remove-ServiceWithTimeout' -Times 0 -Scope 'Context'
                }

                It 'Should change the service path' {
                    Assert-MockCalled -CommandName 'Set-ServicePath' -ParameterFilter { $ServiceName -eq $setTargetResourceParameters.Name -and $Path -eq $setTargetResourceParameters.Path } -Times 1 -Scope 'Context'
                }

                It 'Should change all service properties except Credential' {
                    Assert-MockCalled -CommandName 'Set-ServiceProperty' -ParameterFilter { $ServiceName -eq $setTargetResourceParameters.Name -and $StartupType -eq $setTargetResourceParameters.StartupType -and $BuiltInAccount -eq $setTargetResourceParameters.BuiltInAccount -and $DesktopInteract -eq $setTargetResourceParameters.DesktopInteract -and $DisplayName -eq $setTargetResourceParameters.DisplayName -and $Description -eq $setTargetResourceParameters.Description -and $null -eq (Compare-Object -ReferenceObject $setTargetResourceParameters.Dependencies -DifferenceObject $Dependencies) } -Times 1 -Scope 'Context'
                }

                It 'Should not attempt to start the service' {
                    Assert-MockCalled -CommandName 'Start-ServiceWithTimeout' -Times 0 -Scope 'Context'
                }

                It 'Should stop the service' {
                    Assert-MockCalled -CommandName 'Stop-ServiceWithTimeout' -ParameterFilter { $ServiceName -eq $setTargetResourceParameters.Name } -Times 1 -Scope 'Context'
                }
            }

            Context 'Service exists, Ensure set to Present, State set to Ignore, and all parameters except Path and BuiltInAccount specified' {
                $setTargetResourceParameters = @{
                    Name = $script:testServiceName
                    Ensure = 'Present'
                    StartupType = 'Manual'
                    Credential = $script:testCredential1
                    DesktopInteract = $true
                    State = 'Ignore'
                    DisplayName = 'TestDisplayName'
                    Description = 'Test device description'
                    Dependencies = @( 'TestServiceDependency1', 'TestServiceDependency2' )
                }

                It 'Should not throw' {
                    { Set-TargetResource @setTargetResourceParameters } | Should Not Throw
                }

                It 'Should check for a startup type and state conflict' {
                    Assert-MockCalled -CommandName 'Assert-NoStartupTypeStateConflict' -ParameterFilter { $ServiceName -eq $setTargetResourceParameters.Name -and $StartupType -eq $setTargetResourceParameters.StartupType -and $State -eq $setTargetResourceParameters.State } -Times 1 -Scope 'Context'
                }

                It 'Should retrieve the service' {
                    Assert-MockCalled -CommandName 'Get-Service' -ParameterFilter { $Name -eq $setTargetResourceParameters.Name } -Times 1 -Scope 'Context'
                }

                It 'Should not attempt to create the service' {
                    Assert-MockCalled -CommandName 'New-Service' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to remove the service' {
                    Assert-MockCalled -CommandName 'Remove-ServiceWithTimeout' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to change the service path' {
                    Assert-MockCalled -CommandName 'Set-ServicePath' -Times 0 -Scope 'Context'
                }

                It 'Should change all service properties except BuiltInAccount' {
                    Assert-MockCalled -CommandName 'Set-ServiceProperty' -ParameterFilter { $ServiceName -eq $setTargetResourceParameters.Name -and $StartupType -eq $setTargetResourceParameters.StartupType -and $BuiltInAccount -eq $setTargetResourceParameters.BuiltInAccount -and $DesktopInteract -eq $setTargetResourceParameters.DesktopInteract -and $DisplayName -eq $setTargetResourceParameters.DisplayName -and $Description -eq $setTargetResourceParameters.Description -and $null -eq (Compare-Object -ReferenceObject $setTargetResourceParameters.Dependencies -DifferenceObject $Dependencies) } -Times 1 -Scope 'Context'
                }

                It 'Should not attempt to start the service' {
                    Assert-MockCalled -CommandName 'Start-ServiceWithTimeout' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to stop the service' {
                    Assert-MockCalled -CommandName 'Stop-ServiceWithTimeout' -Times 0 -Scope 'Context'
                }
            }

            Context 'Service exists, Ensure set to Present, and DesktopInteract specified' {
                $setTargetResourceParameters = @{
                    Name = $script:testServiceName
                    Ensure = 'Present'
                    DesktopInteract = $true
                }

                It 'Should not throw' {
                    { Set-TargetResource @setTargetResourceParameters } | Should Not Throw
                }

                It 'Should not check for a startup type and state conflict' {
                    Assert-MockCalled -CommandName 'Assert-NoStartupTypeStateConflict' -Times 0 -Scope 'Context'
                }

                It 'Should retrieve the service' {
                    Assert-MockCalled -CommandName 'Get-Service' -ParameterFilter { $Name -eq $setTargetResourceParameters.Name } -Times 1 -Scope 'Context'
                }

                It 'Should not attempt to create the service' {
                    Assert-MockCalled -CommandName 'New-Service' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to remove the service' {
                    Assert-MockCalled -CommandName 'Remove-ServiceWithTimeout' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to change the service path' {
                    Assert-MockCalled -CommandName 'Set-ServicePath' -Times 0 -Scope 'Context'
                }

                It 'Should change only DesktopInteract service property' {
                    Assert-MockCalled -CommandName 'Set-ServiceProperty' -ParameterFilter { $ServiceName -eq $setTargetResourceParameters.Name -and $DesktopInteract -eq $setTargetResourceParameters.DesktopInteract } -Times 1 -Scope 'Context'
                }

                It 'Should start the service' {
                    Assert-MockCalled -CommandName 'Start-ServiceWithTimeout' -ParameterFilter { $ServiceName -eq $setTargetResourceParameters.Name } -Times 1 -Scope 'Context'
                }

                It 'Should not attempt to stop the service' {
                    Assert-MockCalled -CommandName 'Stop-ServiceWithTimeout' -Times 0 -Scope 'Context'
                }
            }

            Mock -CommandName 'Set-ServicePath' -MockWith { return $false }
            
            Context 'Service exists, Ensure set to Present, and matching Path to service path specified' {
                $setTargetResourceParameters = @{
                    Name = $script:testServiceName
                    Ensure = 'Present'
                    Path = 'TestPath'
                }

                It 'Should not throw' {
                    { Set-TargetResource @setTargetResourceParameters } | Should Not Throw
                }

                It 'Should not check for a startup type and state conflict' {
                    Assert-MockCalled -CommandName 'Assert-NoStartupTypeStateConflict' -Times 0 -Scope 'Context'
                }

                It 'Should retrieve the service' {
                    Assert-MockCalled -CommandName 'Get-Service' -ParameterFilter { $Name -eq $setTargetResourceParameters.Name } -Times 1 -Scope 'Context'
                }

                It 'Should not attempt to create the service' {
                    Assert-MockCalled -CommandName 'New-Service' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to remove the service' {
                    Assert-MockCalled -CommandName 'Remove-ServiceWithTimeout' -Times 0 -Scope 'Context'
                }

                It 'Should attempt to change the service path' {
                    Assert-MockCalled -CommandName 'Set-ServicePath' -ParameterFilter { $ServiceName -eq $setTargetResourceParameters.Name -and $Path -eq $setTargetResourceParameters.Path } -Times 1 -Scope 'Context'
                }

                It 'Should not attempt to change the service properties' {
                    Assert-MockCalled -CommandName 'Set-ServiceProperty' -Times 0 -Scope 'Context'
                }

                It 'Should not stop the service to restart it' {
                    Assert-MockCalled -CommandName 'Stop-ServiceWithTimeout' -Times 0 -Scope 'Context'
                }

                It 'Should start the service' {
                    Assert-MockCalled -CommandName 'Start-ServiceWithTimeout' -ParameterFilter { $ServiceName -eq $setTargetResourceParameters.Name } -Times 1 -Scope 'Context'
                }
            }
        }

        Describe 'xService\Test-TargetResource' {
            Mock -CommandName 'Assert-NoStartupTypeStateConflict' -MockWith { }
            Mock -CommandName 'Get-TargetResource' -MockWith {
                return @{
                    Name = $script:testServiceName
                    Ensure = 'Absent'
                }
            }
            Mock -CommandName 'Test-PathsMatch' -MockWith { return $true }
            Mock -CommandName 'ConvertTo-StartName' -MockWith { return $Username }

            Context 'Both BuiltInAccount and Credential specified' {
                $testTargetResourceParameters = @{
                    Name = $script:testServiceName
                    BuiltInAccount = 'LocalSystem'
                    Credential = $script:testCredential1
                }

                It 'Should throw an error for BuiltInAccount and Credential conflict' {
                    $expectedErrorMessage = $script:localizedData.BuiltInAccountAndCredentialSpecified -f $testTargetResourceParameters.Name
                    { Test-TargetResource @testTargetResourceParameters } | Should Throw $expectedErrorMessage
                }
            }

            Context 'Service does not exist and Ensure set to Absent' {
                $testTargetResourceParameters = @{
                    Name = $script:testServiceName
                    Ensure = 'Absent'
                }
                
                It 'Should not throw' {
                    { Test-TargetResource @testTargetResourceParameters } | Should Not Throw
                }

                It 'Should not check for a startup type and state conflict' {
                    Assert-MockCalled -CommandName 'Assert-NoStartupTypeStateConflict' -Times 0 -Scope 'Context'
                }

                It 'Should retrieve the service' {
                    Assert-MockCalled -CommandName 'Get-TargetResource' -ParameterFilter { $Name -eq $testTargetResourceParameters.Name } -Times 1 -Scope 'Context'
                }

                It 'Should not attempt to test if the service path matches the specified path' {
                    Assert-MockCalled -CommandName 'Test-PathsMatch' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to convert a credential username to a service start name' {
                    Assert-MockCalled -CommandName 'ConvertTo-StartName' -Times 0 -Scope 'Context'
                }

                It 'Should return true' {
                    Test-TargetResource @testTargetResourceParameters | Should Be $true
                }
            }

            Context 'Service does not exist and Ensure set to Present' {
                $testTargetResourceParameters = @{
                    Name = $script:testServiceName
                    Ensure = 'Present'
                }
                
                It 'Should not throw' {
                    { Test-TargetResource @testTargetResourceParameters } | Should Not Throw
                }

                It 'Should not check for a startup type and state conflict' {
                    Assert-MockCalled -CommandName 'Assert-NoStartupTypeStateConflict' -Times 0 -Scope 'Context'
                }

                It 'Should retrieve the service' {
                    Assert-MockCalled -CommandName 'Get-TargetResource' -ParameterFilter { $Name -eq $testTargetResourceParameters.Name } -Times 1 -Scope 'Context'
                }

                It 'Should not attempt to test if the service path matches the specified path' {
                    Assert-MockCalled -CommandName 'Test-PathsMatch' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to convert a credential username to a service start name' {
                    Assert-MockCalled -CommandName 'ConvertTo-StartName' -Times 0 -Scope 'Context'
                }

                It 'Should return false' {
                    Test-TargetResource @testTargetResourceParameters | Should Be $false
                }
            }

            $serviceResourceWithAllProperties = @{
                Name            = $script:testServiceName
                Ensure          = 'Present'
                StartupType     = 'Automatic'
                BuiltInAccount  = 'LocalSystem'
                DesktopInteract = $false
                State           = 'Running'
                Path            = 'TestPath'
                DisplayName     = 'TestDisplayName'
                Description     = 'Test service description'
                Dependencies    = @( 'TestServiceDependency1', 'TestServiceDependency2' )
            }

            Mock -CommandName 'Get-TargetResource' -MockWith { return $serviceResourceWithAllProperties }

            Context 'Service exists and Ensure set to Absent' {
                $testTargetResourceParameters = @{
                    Name = $script:testServiceName
                    Ensure = 'Absent'
                }
                
                It 'Should not throw' {
                    { Test-TargetResource @testTargetResourceParameters } | Should Not Throw
                }

                It 'Should not check for a startup type and state conflict' {
                    Assert-MockCalled -CommandName 'Assert-NoStartupTypeStateConflict' -Times 0 -Scope 'Context'
                }

                It 'Should retrieve the service' {
                    Assert-MockCalled -CommandName 'Get-TargetResource' -ParameterFilter { $Name -eq $testTargetResourceParameters.Name } -Times 1 -Scope 'Context'
                }

                It 'Should not attempt to test if the service path matches the specified path' {
                    Assert-MockCalled -CommandName 'Test-PathsMatch' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to convert a credential username to a service start name' {
                    Assert-MockCalled -CommandName 'ConvertTo-StartName' -Times 0 -Scope 'Context'
                }

                It 'Should return false' {
                    Test-TargetResource @testTargetResourceParameters | Should Be $false
                }
            }

            Context 'Service exists and Ensure set to Present' {
                $testTargetResourceParameters = @{
                    Name = $script:testServiceName
                    Ensure = 'Present'
                }
                
                It 'Should not throw' {
                    { Test-TargetResource @testTargetResourceParameters } | Should Not Throw
                }

                It 'Should not check for a startup type and state conflict' {
                    Assert-MockCalled -CommandName 'Assert-NoStartupTypeStateConflict' -Times 0 -Scope 'Context'
                }

                It 'Should retrieve the service' {
                    Assert-MockCalled -CommandName 'Get-TargetResource' -ParameterFilter { $Name -eq $testTargetResourceParameters.Name } -Times 1 -Scope 'Context'
                }

                It 'Should not attempt to test if the service path matches the specified path' {
                    Assert-MockCalled -CommandName 'Test-PathsMatch' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to convert a credential username to a service start name' {
                    Assert-MockCalled -CommandName 'ConvertTo-StartName' -Times 0 -Scope 'Context'
                }

                It 'Should return true' {
                    Test-TargetResource @testTargetResourceParameters | Should Be $true
                }
            }

            Context 'Service exists, Ensure set to Present, and all matching parameters specified except Credential' {
                $testTargetResourceParameters = $serviceResourceWithAllProperties
                
                It 'Should not throw' {
                    { Test-TargetResource @testTargetResourceParameters } | Should Not Throw
                }

                It 'Should check for a startup type and state conflict' {
                    Assert-MockCalled -CommandName 'Assert-NoStartupTypeStateConflict' -ParameterFilter { $ServiceName -eq $testTargetResourceParameters.Name -and $StartupType -eq $testTargetResourceParameters.StartupType -and $State -eq $testTargetResourceParameters.State } -Times 1 -Scope 'Context'
                }

                It 'Should retrieve the service' {
                    Assert-MockCalled -CommandName 'Get-TargetResource' -ParameterFilter { $Name -eq $testTargetResourceParameters.Name } -Times 1 -Scope 'Context'
                }

                It 'Should test if the service path matches the specified path' {
                    Assert-MockCalled -CommandName 'Test-PathsMatch' -ParameterFilter { $ExpectedPath -eq $testTargetResourceParameters.Path -and $ActualPath -eq $serviceResourceWithAllProperties.Path } -Times 1 -Scope 'Context'
                }

                It 'Should not attempt to convert a credential username to a service start name' {
                    Assert-MockCalled -CommandName 'ConvertTo-StartName' -Times 0 -Scope 'Context'
                }

                It 'Should return true' {
                    Test-TargetResource @testTargetResourceParameters | Should Be $true
                }
            }

            $mismatchingParameters = @{
                StartupType = 'Manual'
                BuiltInAccount = 'NetworkService'
                DesktopInteract = $true
                State = 'Stopped'
                DisplayName = 'MismatchingDisplayName'
                Description = 'Mismatching service description'
                Dependencies    = @( 'TestServiceDependency3', 'TestServiceDependency4' )
            }

            foreach ($mismatchingParameterName in $mismatchingParameters.Keys)
            {
                Context "Service exists, Ensure set to Present, and mismatching $mismatchingParameterName specified" {
                    $testTargetResourceParameters = @{
                        Name = $serviceResourceWithAllProperties.Name
                        Ensure = 'Present'
                        $mismatchingParameterName = $mismatchingParameters[$mismatchingParameterName]
                    }
                
                    It 'Should not throw' {
                        { Test-TargetResource @testTargetResourceParameters } | Should Not Throw
                    }

                    

                    if ($mismatchingParameterName -eq 'StartupType')
                    {
                        It 'Should check for a startup type and state conflict' {
                            Assert-MockCalled -CommandName 'Assert-NoStartupTypeStateConflict' -ParameterFilter { $ServiceName -eq $testTargetResourceParameters.Name -and $StartupType -eq $testTargetResourceParameters.StartupType -and $State -eq 'Running' } -Times 1 -Scope 'Context'
                        }
                    }
                    else
                    {
                        It 'Should not check for a startup type and state conflict' {
                            Assert-MockCalled -CommandName 'Assert-NoStartupTypeStateConflict' -Times 0 -Scope 'Context'
                        }
                    }

                    It 'Should retrieve the service' {
                        Assert-MockCalled -CommandName 'Get-TargetResource' -ParameterFilter { $Name -eq $testTargetResourceParameters.Name } -Times 1 -Scope 'Context'
                    }

                    It 'Should not test if the service path matches the specified path' {
                        Assert-MockCalled -CommandName 'Test-PathsMatch' -Times 0 -Scope 'Context'
                    }

                    It 'Should not attempt to convert a credential username to a service start name' {
                        Assert-MockCalled -CommandName 'ConvertTo-StartName' -Times 0 -Scope 'Context'
                    }

                    It 'Should return false' {
                        Test-TargetResource @testTargetResourceParameters | Should Be $false
                    }
                }
            }

            Context 'Service exists, Ensure set to Present, and State is set to Ignore' {
                $testTargetResourceParameters = @{
                    Name = $serviceResourceWithAllProperties.Name
                    Ensure = 'Present'
                    State = 'Ignore'
                }
                
                It 'Should not throw' {
                    { Test-TargetResource @testTargetResourceParameters } | Should Not Throw
                }

                It 'Should not check for a startup type and state conflict' {
                    Assert-MockCalled -CommandName 'Assert-NoStartupTypeStateConflict' -Times 0 -Scope 'Context'
                }

                It 'Should retrieve the service' {
                    Assert-MockCalled -CommandName 'Get-TargetResource' -ParameterFilter { $Name -eq $testTargetResourceParameters.Name } -Times 1 -Scope 'Context'
                }

                It 'Should not test if the service path matches the specified path' {
                    Assert-MockCalled -CommandName 'Test-PathsMatch' -Times 0 -Scope 'Context'
                }

                It 'Should not attempt to convert a credential username to a service start name' {
                    Assert-MockCalled -CommandName 'ConvertTo-StartName' -Times 0 -Scope 'Context'
                }

                It 'Should return true' {
                    Test-TargetResource @testTargetResourceParameters | Should Be $true
                }
            }

            $serviceResourceWithCustomBuiltInAccount = @{
                Name            = $script:testServiceName
                Ensure          = 'Present'
                State           = 'Running'
                BuiltInAccount  = $script:testCredential1.UserName
                DisplayName     = 'TestDisplayName'
                Description     = 'Test service description'
                Dependencies    = @( 'TestServiceDependency1', 'TestServiceDependency2' )
            }

            Mock -CommandName 'Get-TargetResource' -MockWith { return $serviceResourceWithCustomBuiltInAccount }

            Context 'Service exists, Ensure set to Present, and matching Credential specified' {
                $testTargetResourceParameters = @{
                    Name = $serviceResourceWithCustomBuiltInAccount.Name
                    Ensure = 'Present'
                    Credential = $script:testCredential1
                }
                
                It 'Should not throw' {
                    { Test-TargetResource @testTargetResourceParameters } | Should Not Throw
                }

                It 'Should not check for a startup type and state conflict' {
                    Assert-MockCalled -CommandName 'Assert-NoStartupTypeStateConflict' -Times 0 -Scope 'Context'
                }

                It 'Should retrieve the service' {
                    Assert-MockCalled -CommandName 'Get-TargetResource' -ParameterFilter { $Name -eq $testTargetResourceParameters.Name } -Times 1 -Scope 'Context'
                }

                It 'Should not test if the service path matches the specified path' {
                    Assert-MockCalled -CommandName 'Test-PathsMatch' -Times 0 -Scope 'Context'
                }

                It 'Should convert the credential username to a service start name' {
                    Assert-MockCalled -CommandName 'ConvertTo-StartName' -ParameterFilter { $Username -eq $script:testCredential1.UserName } -Times 1 -Scope 'Context'
                }

                It 'Should return true' {
                    Test-TargetResource @testTargetResourceParameters | Should Be $true
                }
            }

            Context 'Service exists, Ensure set to Present, and mismatching Credential specified' {
                $testTargetResourceParameters = @{
                    Name = $serviceResourceWithCustomBuiltInAccount.Name
                    Ensure = 'Present'
                    Credential = $script:testCredential2
                }
                
                It 'Should not throw' {
                    { Test-TargetResource @testTargetResourceParameters } | Should Not Throw
                }

                It 'Should not check for a startup type and state conflict' {
                    Assert-MockCalled -CommandName 'Assert-NoStartupTypeStateConflict' -Times 0 -Scope 'Context'
                }

                It 'Should retrieve the service' {
                    Assert-MockCalled -CommandName 'Get-TargetResource' -ParameterFilter { $Name -eq $testTargetResourceParameters.Name } -Times 1 -Scope 'Context'
                }

                It 'Should not test if the service path matches the specified path' {
                    Assert-MockCalled -CommandName 'Test-PathsMatch' -Times 0 -Scope 'Context'
                }

                It 'Should convert the credential username to a service start name' {
                    Assert-MockCalled -CommandName 'ConvertTo-StartName' -ParameterFilter { $Username -eq $script:testCredential2.UserName } -Times 1 -Scope 'Context'
                }

                It 'Should return false' {
                    Test-TargetResource @testTargetResourceParameters | Should Be $false
                }
            }

            $allowedEmptyPropertyNames = @( 'DisplayName', 'Description', 'Dependencies' )

            foreach ($allowedEmptyPropertyName in $allowedEmptyPropertyNames)
            {
                Context "Service exists, Ensure set to Present, $allowedEmptyPropertyName specified as empty" {
                    $testTargetResourceParameters = @{
                        Name = $serviceResourceWithCustomBuiltInAccount.Name
                        Ensure = 'Present'
                    }

                    if ($allowedEmptyPropertyName -eq 'Dependencies')
                    {
                        $testTargetResourceParameters[$allowedEmptyPropertyName] = @()
                    }
                    else
                    {
                        $testTargetResourceParameters[$allowedEmptyPropertyName] = ''
                    }
                
                    It 'Should not throw' {
                        { Test-TargetResource @testTargetResourceParameters } | Should Not Throw
                    }

                    It 'Should not check for a startup type and state conflict' {
                        Assert-MockCalled -CommandName 'Assert-NoStartupTypeStateConflict' -Times 0 -Scope 'Context'
                    }

                    It 'Should retrieve the service' {
                        Assert-MockCalled -CommandName 'Get-TargetResource' -ParameterFilter { $Name -eq $testTargetResourceParameters.Name } -Times 1 -Scope 'Context'
                    }

                    It 'Should not test if the service path matches the specified path' {
                        Assert-MockCalled -CommandName 'Test-PathsMatch' -Times 0 -Scope 'Context'
                    }

                    It 'Should not attempt to convert a credential username to a service start name' {
                        Assert-MockCalled -CommandName 'ConvertTo-StartName' -Times 0 -Scope 'Context'
                    }

                    It 'Should return false' {
                        Test-TargetResource @testTargetResourceParameters | Should Be $false
                    }
                }
            }

            $serviceResourceWithNullProperties = @{
                Name   = $script:testServiceName
                Ensure = 'Present'
                Path   = 'TestPath'
                State  = 'Running'
            }

            foreach ($nullPropertyName in $allowedEmptyPropertyNames)
            {
                $serviceResourceWithNullProperties[$nullPropertyName] = $null
            }
                
            Mock -CommandName 'Get-TargetResource' -MockWith { return $serviceResourceWithNullProperties }

            foreach ($nullPropertyName in $allowedEmptyPropertyNames)
            {
                Context "Service exists but DisplayName, Description, and Dependencies are null, Ensure set to Present, $nullPropertyName specified" {
                    $testTargetResourceParameters = @{
                        Name = $serviceResourceWithNullProperties.Name
                        Ensure = 'Present'
                        $nullPropertyName = 'Something'
                    }
                
                    It 'Should not throw' {
                        { Test-TargetResource @testTargetResourceParameters } | Should Not Throw
                    }

                    It 'Should not check for a startup type and state conflict' {
                        Assert-MockCalled -CommandName 'Assert-NoStartupTypeStateConflict' -Times 0 -Scope 'Context'
                    }

                    It 'Should retrieve the service' {
                        Assert-MockCalled -CommandName 'Get-TargetResource' -ParameterFilter { $Name -eq $testTargetResourceParameters.Name } -Times 1 -Scope 'Context'
                    }

                    It 'Should not test if the service path matches the specified path' {
                        Assert-MockCalled -CommandName 'Test-PathsMatch' -Times 0 -Scope 'Context'
                    }

                    It 'Should not attempt to convert a credential username to a service start name' {
                        Assert-MockCalled -CommandName 'ConvertTo-StartName' -Times 0 -Scope 'Context'
                    }

                    It 'Should return false' {
                        Test-TargetResource @testTargetResourceParameters | Should Be $false
                    }
                }

                Context "Service exists but DisplayName, Description, and Dependencies are null, Ensure set to Present, $nullPropertyName not specified" {
                    $testTargetResourceParameters = @{
                        Name = $serviceResourceWithNullProperties.Name
                        Ensure = 'Present'
                    }
                
                    It 'Should not throw' {
                        { Test-TargetResource @testTargetResourceParameters } | Should Not Throw
                    }

                    It 'Should not check for a startup type and state conflict' {
                        Assert-MockCalled -CommandName 'Assert-NoStartupTypeStateConflict' -Times 0 -Scope 'Context'
                    }

                    It 'Should retrieve the service' {
                        Assert-MockCalled -CommandName 'Get-TargetResource' -ParameterFilter { $Name -eq $testTargetResourceParameters.Name } -Times 1 -Scope 'Context'
                    }

                    It 'Should not test if the service path matches the specified path' {
                        Assert-MockCalled -CommandName 'Test-PathsMatch' -Times 0 -Scope 'Context'
                    }

                    It 'Should not attempt to convert a credential username to a service start name' {
                        Assert-MockCalled -CommandName 'ConvertTo-StartName' -Times 0 -Scope 'Context'
                    }

                    It 'Should return true' {
                        Test-TargetResource @testTargetResourceParameters | Should Be $true
                    }
                }
            }

            Mock -CommandName 'Test-PathsMatch' -MockWith { return $false }

            Context 'Service exists, Ensure set to Present, and mismatching Path specified' {
                $testTargetResourceParameters = @{
                    Name = $serviceResourceWithCustomBuiltInAccount.Name
                    Ensure = 'Present'
                    Path = 'Mismatching path'
                }
                
                It 'Should not throw' {
                    { Test-TargetResource @testTargetResourceParameters } | Should Not Throw
                }

                It 'Should not check for a startup type and state conflict' {
                    Assert-MockCalled -CommandName 'Assert-NoStartupTypeStateConflict' -Times 0 -Scope 'Context'
                }

                It 'Should retrieve the service' {
                    Assert-MockCalled -CommandName 'Get-TargetResource' -ParameterFilter { $Name -eq $testTargetResourceParameters.Name } -Times 1 -Scope 'Context'
                }

                It 'Should test if the service path matches the specified path' {
                    Assert-MockCalled -CommandName 'Test-PathsMatch' -ParameterFilter { $ExpectedPath -eq $testTargetResourceParameters.Path -and $ActualPath -eq $serviceResourceWithNullProperties.Path } -Times 1 -Scope 'Context'
                }

                It 'Should not attempt to convert a credential username to a service start name' {
                    Assert-MockCalled -CommandName 'ConvertTo-StartName' -Times 0 -Scope 'Context'
                }

                It 'Should return false' {
                    Test-TargetResource @testTargetResourceParameters | Should Be $false
                }
            }
        }

        Describe 'xService\Get-ServiceCimInstance' {
            Mock -CommandName 'Get-CimInstance' -MockWith { }

            Context 'Service does not exist' {
                It 'Should not throw' {
                    { Get-ServiceCimInstance -ServiceName $script:testServiceName } | Should Not Throw
                }

                It 'Should retrieve the CIM instance of the service with the given name' {
                    Assert-MockCalled -CommandName 'Get-CimInstance' -ParameterFilter {$ClassName -ieq 'Win32_Service' -and $Filter.Contains($script:testServiceName)} -Times 1 -Scope 'Context'
                }

                It 'Should return null' {
                    Get-ServiceCimInstance -ServiceName $script:testServiceName | Should Be $null
                }
            }

            $testCimInstance = 'TestCimInstance'

            Mock -CommandName 'Get-CimInstance' -MockWith { return $testCimInstance }

            Context 'Service exists' {
                It 'Should not throw' {
                    { Get-ServiceCimInstance -ServiceName $script:testServiceName } | Should Not Throw
                }

                It 'Should retrieve the CIM instance of the service with the given name' {
                    Assert-MockCalled -CommandName 'Get-CimInstance' -ParameterFilter {$ClassName -ieq 'Win32_Service' -and $Filter.Contains($script:testServiceName)} -Times 1 -Scope 'Context'
                }

                It 'Should return the retrieved CIM instance' {
                    Get-ServiceCimInstance -ServiceName $script:testServiceName | Should Be $testCimInstance
                }
            }
        }

        Describe 'xService\ConvertTo-StartupTypeString' {
            Context 'StartupType specifed as Auto' {
                It 'Should return Automatic' {
                    ConvertTo-StartupTypeString -StartMode 'Auto' | Should Be 'Automatic'
                }
            }

            Context 'StartupType specifed as Manual' {
                It 'Should return Manual' {
                    ConvertTo-StartupTypeString -StartMode 'Manual' | Should Be 'Manual'
                }
            }

            Context 'StartupType specifed as Disabled' {
                It 'Should return Disabled' {
                    ConvertTo-StartupTypeString -StartMode 'Disabled' | Should Be 'Disabled'
                }
            }
        }

        Describe 'xService\Assert-NoStartupTypeStateConflict' {
            $stateValues = @( 'Running', 'Stopped', 'Ignore' )
            $startupTypeValues = @( 'Manual', 'Automatic', 'Disabled' )

            foreach ($startupTypeValue in $startupTypeValues)
            {
                foreach ($stateValue in $stateValues)
                {
                    Context "StartupType specified as $startupTypeValue and State specified as $stateValue" {
                        $assertNoStartupTypeStateConflictParameters = @{
                            ServiceName = $script:testServiceName
                            StartupType = $startupTypeValue
                            State = $stateValue
                        }

                        if ($stateValue -eq 'Running' -and $startupTypeValue -eq 'Disabled')
                        {
                            It 'Should throw error for conflicting state and startup type' {
                                $errorMessage = $script:localizedData.StartupTypeStateConflict -f $assertNoStartupTypeStateConflictParameters.ServiceName, $startupTypeValue, $stateValue
                                { Assert-NoStartupTypeStateConflict @assertNoStartupTypeStateConflictParameters } | Should Throw $errorMessage
                            }                    
                        }
                        elseif ($stateValue -eq 'Stopped' -and $startupTypeValue -eq 'Automatic')
                        {
                            It 'Should throw error for conflicting state and startup type' {
                                $errorMessage = $script:localizedData.StartupTypeStateConflict -f $assertNoStartupTypeStateConflictParameters.ServiceName, $startupTypeValue, $stateValue
                                { Assert-NoStartupTypeStateConflict @assertNoStartupTypeStateConflictParameters } | Should Throw $errorMessage
                            }
                        }
                        else
                        {
                            It 'Should not throw' {
                                { Assert-NoStartupTypeStateConflict @assertNoStartupTypeStateConflictParameters } | Should Not Throw
                            }
                        }
                    }
                }
            }
        }

        Describe 'xService\Test-PathsMatch' {
            Context 'Specified paths match' {
                It 'Should return true' {
                    $matchingPath = 'MatchingPath'
                    Test-PathsMatch -ExpectedPath $matchingPath -ActualPath $matchingPath | Should Be $true
                }
            }

            Context 'Specified paths do not match' {
                It 'Should return false' {
                    Test-PathsMatch -ExpectedPath 'Path1' -ActualPath 'Path2' | Should Be $false
                }
            }
        }

        Describe 'xService\ConvertTo-StartName' {
            Context 'Username specified as LocalSystem' {
                It 'Should return .\LocalSystem' {
                    ConvertTo-StartName -Username 'LocalSystem' | Should Be '.\LocalSystem'
                }
            }

            Context 'Username specified as LocalService' {
                It 'Should return NT Authority\LocalService' {
                    ConvertTo-StartName -Username 'LocalService' | Should Be 'NT Authority\LocalService'
                }
            }

            Context 'Username specified as NetworkService' {
                It 'Should return NT Authority\NetworkService' {
                    ConvertTo-StartName -Username 'NetworkService' | Should Be 'NT Authority\NetworkService'
                }
            }

            Context 'Custom username specified without any \ or @ characters' {
                It 'Should return custom username prefixed with .\' {
                    $customUsername = 'TestUsername'
                    ConvertTo-StartName -Username $customUsername | Should Be ".\$customUsername"
                }
            }

            Context 'Custom username specified that starts with the local computer name followed by a \ character' {
                It 'Should return custom username prefixed with .\ instead of the local computer name' {
                    $customUsername = 'TestUsername'
                    $customUsernameWithComputerNamePrefix = "$env:computerName\$customUsername"
                    ConvertTo-StartName -Username $customUsernameWithComputerNamePrefix | Should Be ".\$customUsername"
                }
            }

            Context 'Custom username specified with a \ character and a custom domain' {
                It 'Should return the custom username with no changes' {
                    $customUsername = 'TestDomain\TestUsername'
                    ConvertTo-StartName -Username $customUsername | Should Be $customUsername
                }
            }

            Context 'Custom username specified with an @ character' {
                It 'Should return the custom username with no changes' {
                    $customUsername = 'TestUsername@TestDomain'
                    ConvertTo-StartName -Username $customUsername | Should Be $customUsername
                }
            }
        }

        Describe 'xService\Set-ServicePath' {
            $testServiceCimInstance = New-CimInstance -ClassName 'Win32_Service' -Property @{ PathName = 'TestPath' } -ClientOnly

            try
            {
                Mock -CommandName 'Get-ServiceCimInstance' -MockWith { return $testServiceCimInstance }
                Mock -CommandName 'Test-PathsMatch' -MockWith { return $true }

                $invokeCimMethodSuccessResult = @{
                    ReturnValue = 0
                }

                Mock -CommandName 'Invoke-CimMethod' -MockWith { return $invokeCimMethodSuccessResult }

                Context 'Specified path matches the service path' {
                    $setServicePathParameters = @{
                        ServiceName = $script:testServiceName
                        Path = $testServiceCimInstance.PathName
                    }

                    It 'Should not throw' {
                        { Set-ServicePath @setServicePathParameters } | Should Not Throw
                    }

                    It 'Should retrieve the service CIM instance' {
                        Assert-MockCalled -CommandName 'Get-ServiceCimInstance' -ParameterFilter { $ServiceName -eq $setServicePathParameters.ServiceName } -Times 1 -Scope 'Context'
                    }

                    It 'Should test if the specfied path matches the service path' {
                        Assert-MockCalled -CommandName 'Test-PathsMatch' -ParameterFilter { $ExpectedPath -eq $setServicePathParameters.Path -and $ActualPath -eq $testServiceCimInstance.PathName } -Times 1 -Scope 'Context'
                    }

                    It 'Should not change the service' {
                        Assert-MockCalled -CommandName 'Invoke-CimMethod' -Times 0 -Scope 'Context'
                    }

                    It 'Should return false' {
                        Set-ServicePath @setServicePathParameters | Should Be $false
                    }
                }

                Mock -CommandName 'Test-PathsMatch' -MockWith { return $false }

                Context 'Specified path does not match the service path and the path change succeeds' {
                    $setServicePathParameters = @{
                        ServiceName = $script:testServiceName
                        Path = 'NewTestPath'
                    }

                    It 'Should not throw' {
                        { Set-ServicePath @setServicePathParameters } | Should Not Throw
                    }

                    It 'Should retrieve the service CIM instance' {
                        Assert-MockCalled -CommandName 'Get-ServiceCimInstance' -ParameterFilter { $ServiceName -eq $setServicePathParameters.ServiceName } -Times 1 -Scope 'Context'
                    }

                    It 'Should test if the specfied path matches the service path' {
                        Assert-MockCalled -CommandName 'Test-PathsMatch' -ParameterFilter { $ExpectedPath -eq $setServicePathParameters.Path -and $ActualPath -eq $testServiceCimInstance.PathName } -Times 1 -Scope 'Context'
                    }

                    It 'Should change the service' {
                        Assert-MockCalled -CommandName 'Invoke-CimMethod' -ParameterFilter { $InputObject -eq $testServiceCimInstance -and $MethodName -eq 'Change' -and $Arguments.PathName -eq $setServicePathParameters.Path} -Times 1 -Scope 'Context'
                    }

                    It 'Should return true' {
                        Set-ServicePath @setServicePathParameters | Should Be $true
                    }
                }
    
                $invokeCimMethodFailResult = @{
                    ReturnValue = 1
                }

                Mock -CommandName 'Invoke-CimMethod' -MockWith { return $invokeCimMethodFailResult }

                Context 'Specified path does not match the service path and the path change fails' {
                    $setServicePathParameters = @{
                        ServiceName = $script:testServiceName
                        Path = 'NewTestPath'
                    }

                    It 'Should throw error for failed service path change' {
                        $errorMessage = $script:localizedData.InvokeCimMethodFailed -f 'Change', $setServicePathParameters.ServiceName, 'PathName', $invokeCimMethodFailResult.ReturnValue

                        { Set-ServicePath @setServicePathParameters } | Should Throw $errorMessage
                    }
                }
            }
            finally
            {
                $testServiceCimInstance.Dispose()

                # Release the reference so the garbage collector can clean up
                $testServiceCimInstance = $null
            }
        }

        Describe 'xService\Set-ServiceDependencies' {
            $testServiceCimInstance = New-CimInstance -ClassName 'Win32_Service' -ClientOnly

            try {
                $testService = @{
                    ServicesDependedOn = @( @{ Name = 'TestDependency1' }, @{ Name = 'TestDependency2'} )
                }

                Mock -CommandName 'Get-Service' -MockWith { return $testService }
                Mock -CommandName 'Get-ServiceCimInstance' -MockWith { return $testServiceCimInstance }

                $invokeCimMethodSuccessResult = @{
                    ReturnValue = 0
                }

                Mock -CommandName 'Invoke-CimMethod' -MockWith { return $invokeCimMethodSuccessResult }

                Context 'Specified dependencies match the service dependencies' {
                    $setServiceDependenciesParameters = @{
                        ServiceName = $script:testServiceName
                        Dependencies = $testService.ServicesDependedOn.Name
                    }

                    It 'Should not throw' {
                        { Set-ServiceDependencies @setServiceDependenciesParameters } | Should Not Throw
                    }

                    It 'Should retrieve the service' {
                        Assert-MockCalled -CommandName 'Get-Service' -ParameterFilter { $Name -eq $setServiceDependenciesParameters.ServiceName } -Times 1 -Scope 'Context'                        
                    }

                    It 'Should not retrieve the service CIM instance' {
                        Assert-MockCalled -CommandName 'Get-ServiceCimInstance' -Times 0 -Scope 'Context'
                    }

                    It 'Should not change the service' {
                        Assert-MockCalled -CommandName 'Invoke-CimMethod' -Times 0 -Scope 'Context'
                    }
                }

                Context 'Specified dependencies do not match the populated service dependencies and the dependency change succeeds' {
                    $setServiceDependenciesParameters = @{
                        ServiceName = $script:testServiceName
                        Dependencies = @( 'TestDependency3', 'TestDependency4' )
                    }

                    It 'Should not throw' {
                        { Set-ServiceDependencies @setServiceDependenciesParameters } | Should Not Throw
                    }

                    It 'Should retrieve the service' {
                        Assert-MockCalled -CommandName 'Get-Service' -ParameterFilter { $Name -eq $setServiceDependenciesParameters.ServiceName } -Times 1 -Scope 'Context'                        
                    }

                    It 'Should retrieve the service CIM instance' {
                        Assert-MockCalled -CommandName 'Get-ServiceCimInstance' -ParameterFilter { $ServiceName -eq $setServiceDependenciesParameters.ServiceName } -Times 1 -Scope 'Context'
                    }

                    It 'Should change the service' {
                        Assert-MockCalled -CommandName 'Invoke-CimMethod' -ParameterFilter { $InputObject -eq $testServiceCimInstance -and $MethodName -eq 'Change' -and $null -eq (Compare-Object -ReferenceObject $setServiceDependenciesParameters.Dependencies -DifferenceObject $Arguments.ServiceDependencies) } -Times 1 -Scope 'Context'
                    }
                }

                Context 'Specified empty dependencies do not match the populated service dependencies and the dependency change succeeds' {
                    $setServiceDependenciesParameters = @{
                        ServiceName = $script:testServiceName
                        Dependencies = @()
                    }

                    It 'Should not throw' {
                        { Set-ServiceDependencies @setServiceDependenciesParameters } | Should Not Throw
                    }

                    It 'Should retrieve the service' {
                        Assert-MockCalled -CommandName 'Get-Service' -ParameterFilter { $Name -eq $setServiceDependenciesParameters.ServiceName } -Times 1 -Scope 'Context'                        
                    }

                    It 'Should retrieve the service CIM instance' {
                        Assert-MockCalled -CommandName 'Get-ServiceCimInstance' -ParameterFilter { $ServiceName -eq $setServiceDependenciesParameters.ServiceName } -Times 1 -Scope 'Context'
                    }

                    It 'Should change the service' {
                        Assert-MockCalled -CommandName 'Invoke-CimMethod' -ParameterFilter { $InputObject -eq $testServiceCimInstance -and $MethodName -eq 'Change' -and $null -eq (Compare-Object -ReferenceObject $setServiceDependenciesParameters.Dependencies -DifferenceObject $Arguments.ServiceDependencies) } -Times 1 -Scope 'Context'
                    }
                }

                $testServiceWithNoDependencies = @{
                    ServicesDependedOn = $null
                }

                Mock -CommandName 'Get-Service' -MockWith { return $testServiceWithNoDependencies }

                Context 'Specified empty dependencies match the null service dependencies' {
                    $setServiceDependenciesParameters = @{
                        ServiceName = $script:testServiceName
                        Dependencies = @()
                    }

                    It 'Should not throw' {
                        { Set-ServiceDependencies @setServiceDependenciesParameters } | Should Not Throw
                    }

                    It 'Should retrieve the service' {
                        Assert-MockCalled -CommandName 'Get-Service' -ParameterFilter { $Name -eq $setServiceDependenciesParameters.ServiceName } -Times 1 -Scope 'Context'                        
                    }

                    It 'Should not retrieve the service CIM instance' {
                        Assert-MockCalled -CommandName 'Get-ServiceCimInstance' -Times 0 -Scope 'Context'
                    }

                    It 'Should not change the service' {
                        Assert-MockCalled -CommandName 'Invoke-CimMethod' -Times 0 -Scope 'Context'
                    }
                }

                Context 'Specified dependencies do not match the null service dependencies and the dependency change succeeds' {
                    $setServiceDependenciesParameters = @{
                        ServiceName = $script:testServiceName
                        Dependencies = @( 'TestDependency3', 'TestDependency4' )
                    }

                    It 'Should not throw' {
                        { Set-ServiceDependencies @setServiceDependenciesParameters } | Should Not Throw
                    }

                    It 'Should retrieve the service' {
                        Assert-MockCalled -CommandName 'Get-Service' -ParameterFilter { $Name -eq $setServiceDependenciesParameters.ServiceName } -Times 1 -Scope 'Context'                        
                    }

                    It 'Should retrieve the service CIM instance' {
                        Assert-MockCalled -CommandName 'Get-ServiceCimInstance' -ParameterFilter { $ServiceName -eq $setServiceDependenciesParameters.ServiceName } -Times 1 -Scope 'Context'
                    }

                    It 'Should change the service' {
                        Assert-MockCalled -CommandName 'Invoke-CimMethod' -ParameterFilter { $InputObject -eq $testServiceCimInstance -and $MethodName -eq 'Change' -and $null -eq (Compare-Object -ReferenceObject $setServiceDependenciesParameters.Dependencies -DifferenceObject $Arguments.ServiceDependencies) } -Times 1 -Scope 'Context'
                    }                    
                }
    
                $invokeCimMethodFailResult = @{
                    ReturnValue = 1
                }

                Mock -CommandName 'Invoke-CimMethod' -MockWith { return $invokeCimMethodFailResult }

                Context 'Specified dependencies do not match the service dependencies and the dependency change fails' {
                    $setServiceDependenciesParameters = @{
                        ServiceName = $script:testServiceName
                        Dependencies = @( 'TestDependency3', 'TestDependency4' )
                    }

                    It 'Should throw error for failed service path change' {
                        $errorMessage = $script:localizedData.InvokeCimMethodFailed -f 'Change', $setServiceDependenciesParameters.ServiceName, 'ServiceDependencies', $invokeCimMethodFailResult.ReturnValue

                        { Set-ServiceDependencies @setServiceDependenciesParameters } | Should Throw $errorMessage
                    }
                }
            }
            finally
            {
                $testServiceCimInstance.Dispose()
            }
        }

        Describe 'xService\Set-ServiceAccountProperty' {
            $testServiceCimInstance = New-CimInstance -ClassName 'Win32_Service' -Property @{ StartName = 'LocalSystem'; DesktopInteract = $true } -ClientOnly

            try {
                Mock -CommandName 'Get-ServiceCimInstance' -MockWith { return $testServiceCimInstance }
                Mock -CommandName 'Grant-LogOnAsServiceRight' -MockWith { }
                Mock -CommandName 'ConvertTo-StartName' -MockWith { return $Username }
                
                $invokeCimMethodSuccessResult = @{
                    ReturnValue = 0
                }

                Mock -CommandName 'Invoke-CimMethod' -MockWith { return $invokeCimMethodSuccessResult }

                Context 'No parameters specified' {
                    $setServiceAccountPropertyParameters = @{
                        ServiceName = $script:testServiceName
                    }

                    It 'Should not throw' {
                        { Set-ServiceAccountProperty @setServiceAccountPropertyParameters } | Should Not Throw
                    }

                    It 'Should retrieve service CIM instance' {
                        Assert-MockCalled -CommandName 'Get-ServiceCimInstance' -ParameterFilter { $ServiceName -eq $setServiceAccountPropertyParameters.ServiceName } -Times 1 -Scope 'Context'
                    }

                    It 'Should not attempt to convert the built-in account or credential username to a service start name' {
                        Assert-MockCalled -CommandName 'ConvertTo-StartName' -Times 0 -Scope 'Context'
                    }

                    It 'Should not attempt to grant Log on As a Service right' {
                        Assert-MockCalled -CommandName 'Grant-LogOnAsServiceRight' -Times 0 -Scope 'Context'
                    }

                    It 'Should not attempt to change service' {
                        Assert-MockCalled -CommandName 'Invoke-CimMethod' -Times 0 -Scope 'Context'
                    }
                }

                Context 'Matching DesktopInteract specified' {
                    $setServiceAccountPropertyParameters = @{
                        ServiceName = $script:testServiceName
                        DesktopInteract = $testServiceCimInstance.DesktopInteract
                    }

                    It 'Should not throw' {
                        { Set-ServiceAccountProperty @setServiceAccountPropertyParameters } | Should Not Throw
                    }

                    It 'Should retrieve service CIM instance' {
                        Assert-MockCalled -CommandName 'Get-ServiceCimInstance' -ParameterFilter { $ServiceName -eq $setServiceAccountPropertyParameters.ServiceName } -Times 1 -Scope 'Context'
                    }

                    It 'Should not attempt to convert the built-in account or credential username to a service start name' {
                        Assert-MockCalled -CommandName 'ConvertTo-StartName' -Times 0 -Scope 'Context'
                    }

                    It 'Should not attempt to grant Log on As a Service right' {
                        Assert-MockCalled -CommandName 'Grant-LogOnAsServiceRight' -Times 0 -Scope 'Context'
                    }

                    It 'Should not attempt to change service' {
                        Assert-MockCalled -CommandName 'Invoke-CimMethod' -Times 0 -Scope 'Context'
                    }
                }

                Context 'Mismatching DesktopInteract specified and service change succeeds' {
                    $setServiceAccountPropertyParameters = @{
                        ServiceName = $script:testServiceName
                        DesktopInteract = -not $testServiceCimInstance.DesktopInteract
                    }

                    It 'Should not throw' {
                        { Set-ServiceAccountProperty @setServiceAccountPropertyParameters } | Should Not Throw
                    }

                    It 'Should retrieve service CIM instance' {
                        Assert-MockCalled -CommandName 'Get-ServiceCimInstance' -ParameterFilter { $ServiceName -eq $setServiceAccountPropertyParameters.ServiceName } -Times 1 -Scope 'Context'
                    }

                    It 'Should not attempt to convert the built-in account or credential username to a service start name' {
                        Assert-MockCalled -CommandName 'ConvertTo-StartName' -Times 0 -Scope 'Context'
                    }

                    It 'Should not attempt to grant Log on As a Service right' {
                        Assert-MockCalled -CommandName 'Grant-LogOnAsServiceRight' -Times 0 -Scope 'Context'
                    }

                    It 'Should change service' {
                        Assert-MockCalled -CommandName 'Invoke-CimMethod' -ParameterFilter { $InputObject -eq $testServiceCimInstance -and $MethodName -eq 'Change' -and $Arguments.DesktopInteract -eq $setServiceAccountPropertyParameters.DesktopInteract} -Times 1 -Scope 'Context'
                    }
                }

                Context 'Credential with matching username specified' {
                    $secureTestPassword = ConvertTo-SecureString -String 'TestPassword' -AsPlainText -Force
                    $testCredentialWithMatchingUsername = New-Object -TypeName 'PSCredential' -ArgumentList @( $testServiceCimInstance.StartName, $secureTestPassword )

                    $setServiceAccountPropertyParameters = @{
                        ServiceName = $script:testServiceName
                        Credential = $testCredentialWithMatchingUsername
                    }

                    It 'Should not throw' {
                        { Set-ServiceAccountProperty @setServiceAccountPropertyParameters } | Should Not Throw
                    }

                    It 'Should retrieve service CIM instance' {
                        Assert-MockCalled -CommandName 'Get-ServiceCimInstance' -ParameterFilter { $ServiceName -eq $setServiceAccountPropertyParameters.ServiceName } -Times 1 -Scope 'Context'
                    }

                    It 'Should convert the credential username to a service start name' {
                        Assert-MockCalled -CommandName 'ConvertTo-StartName' -ParameterFilter { $Username -eq $setServiceAccountPropertyParameters.Credential.UserName } -Times 1 -Scope 'Context'
                    }

                    It 'Should not attempt to grant Log on As a Service right' {
                        Assert-MockCalled -CommandName 'Grant-LogOnAsServiceRight' -Times 0 -Scope 'Context'
                    }

                    It 'Should not attempt to change service' {
                        Assert-MockCalled -CommandName 'Invoke-CimMethod' -Times 0 -Scope 'Context'
                    }
                }

                Context 'Credential with mismatching username specified and service change succeeds' {
                    $setServiceAccountPropertyParameters = @{
                        ServiceName = $script:testServiceName
                        Credential = $script:testCredential1
                    }

                    It 'Should not throw' {
                        { Set-ServiceAccountProperty @setServiceAccountPropertyParameters } | Should Not Throw
                    }

                    It 'Should retrieve service CIM instance' {
                        Assert-MockCalled -CommandName 'Get-ServiceCimInstance' -ParameterFilter { $ServiceName -eq $setServiceAccountPropertyParameters.ServiceName } -Times 1 -Scope 'Context'
                    }

                    It 'Should convert the credential username to a service start name' {
                        Assert-MockCalled -CommandName 'ConvertTo-StartName' -ParameterFilter { $Username -eq $setServiceAccountPropertyParameters.Credential.UserName } -Times 1 -Scope 'Context'
                    }

                    It 'Should grant Log on As a Service right' {
                        Assert-MockCalled -CommandName 'Grant-LogOnAsServiceRight' -ParameterFilter { $Username -eq $setServiceAccountPropertyParameters.Credential.UserName } -Times 1 -Scope 'Context'
                    }

                    It 'Should change service' {
                        Assert-MockCalled -CommandName 'Invoke-CimMethod' -ParameterFilter { $InputObject -eq $testServiceCimInstance -and $MethodName -eq 'Change' -and $Arguments.StartName -eq $setServiceAccountPropertyParameters.Credential.UserName -and $Arguments.StartPassword -eq $setServiceAccountPropertyParameters.Credential.GetNetworkCredential().Password } -Times 1 -Scope 'Context'
                    }
                }

                Context 'Matching BuiltInAccount specified' {
                    $setServiceAccountPropertyParameters = @{
                        ServiceName = $script:testServiceName
                        BuiltInAccount = $testServiceCimInstance.StartName
                    }

                    It 'Should not throw' {
                        { Set-ServiceAccountProperty @setServiceAccountPropertyParameters } | Should Not Throw
                    }

                    It 'Should retrieve service CIM instance' {
                        Assert-MockCalled -CommandName 'Get-ServiceCimInstance' -ParameterFilter { $ServiceName -eq $setServiceAccountPropertyParameters.ServiceName } -Times 1 -Scope 'Context'
                    }

                    It 'Should convert the built-in account to a service start name' {
                        Assert-MockCalled -CommandName 'ConvertTo-StartName' -ParameterFilter { $Username -eq $setServiceAccountPropertyParameters.BuiltInAccount } -Times 1 -Scope 'Context'
                    }

                    It 'Should not attempt to grant Log on As a Service right' {
                        Assert-MockCalled -CommandName 'Grant-LogOnAsServiceRight' -Times 0 -Scope 'Context'
                    }

                    It 'Should not attempt to change service' {
                        Assert-MockCalled -CommandName 'Invoke-CimMethod' -Times 0 -Scope 'Context'
                    }
                }

                Context 'Mismatching BuiltInAccount specified and service change succeeds' {
                    $setServiceAccountPropertyParameters = @{
                        ServiceName = $script:testServiceName
                        BuiltInAccount = 'NetworkService'
                    }

                    It 'Should not throw' {
                        { Set-ServiceAccountProperty @setServiceAccountPropertyParameters } | Should Not Throw
                    }

                    It 'Should retrieve service CIM instance' {
                        Assert-MockCalled -CommandName 'Get-ServiceCimInstance' -ParameterFilter { $ServiceName -eq $setServiceAccountPropertyParameters.ServiceName } -Times 1 -Scope 'Context'
                    }

                    It 'Should convert the built-in account to a service start name' {
                        Assert-MockCalled -CommandName 'ConvertTo-StartName' -ParameterFilter { $Username -eq $setServiceAccountPropertyParameters.BuiltInAccount } -Times 1 -Scope 'Context'
                    }

                    It 'Should not attempt to grant Log on As a Service right' {
                        Assert-MockCalled -CommandName 'Grant-LogOnAsServiceRight' -Times 0 -Scope 'Context'
                    }

                    It 'Should change service' {
                        Assert-MockCalled -CommandName 'Invoke-CimMethod' -ParameterFilter { $InputObject -eq $testServiceCimInstance -and $MethodName -eq 'Change' -and $Arguments.StartName -eq $setServiceAccountPropertyParameters.BuiltInAccount -and $Arguments.StartPassword -eq [String]::Empty } -Times 1 -Scope 'Context'
                    }
                }

                $invokeCimMethodFailResult = @{
                    ReturnValue = 1
                }

                Mock -CommandName 'Invoke-CimMethod' -MockWith { return $invokeCimMethodFailResult }

                Context 'Mismatching DesktopInteract specified and service change fails' {
                    $setServiceAccountPropertyParameters = @{
                        ServiceName = $script:testServiceName
                        DesktopInteract = -not $testServiceCimInstance.DesktopInteract
                    }

                    It 'Should throw an error for service change failure' {
                        $errorMessage = $script:localizedData.InvokeCimMethodFailed -f 'Change', $setServiceAccountPropertyParameters.ServiceName, 'DesktopInteract', $invokeCimMethodFailResult.ReturnValue

                        { Set-ServiceAccountProperty @setServiceAccountPropertyParameters } | Should Throw $errorMessage
                    }
                }

                Context 'Credential with mismatching username specified and service change fails' {
                    $setServiceAccountPropertyParameters = @{
                        ServiceName = $script:testServiceName
                        Credential = $script:testCredential1
                    }

                    It 'Should throw an error for service change failure' {
                        $errorMessage = $script:localizedData.InvokeCimMethodFailed -f 'Change', $setServiceAccountPropertyParameters.ServiceName, 'StartName, StartPassword', $invokeCimMethodFailResult.ReturnValue

                        { Set-ServiceAccountProperty @setServiceAccountPropertyParameters } | Should Throw $errorMessage
                    }
                }

                Context 'Mismatching BuiltInAccount specified and service change fails' {
                    $setServiceAccountPropertyParameters = @{
                        ServiceName = $script:testServiceName
                        BuiltInAccount = 'NetworkService'
                    }

                    It 'Should throw an error for service change failure' {
                        $errorMessage = $script:localizedData.InvokeCimMethodFailed -f 'Change', $setServiceAccountPropertyParameters.ServiceName, 'StartName, StartPassword', $invokeCimMethodFailResult.ReturnValue

                        { Set-ServiceAccountProperty @setServiceAccountPropertyParameters } | Should Throw $errorMessage
                    }
                }
            }
            finally
            {
                $testServiceCimInstance.Dispose()

                # Release the reference so the garbage collector can clean up
                $testServiceCimInstance = $null
            }
        }

        Describe 'xService\Set-ServiceStartupType' {
            $testServiceCimInstance = New-CimInstance -ClassName 'Win32_Service' -Property @{ StartMode = 'Manual' } -ClientOnly

            try {
                Mock -CommandName 'Get-ServiceCimInstance' -MockWith { return $testServiceCimInstance }
                Mock -CommandName 'ConvertTo-StartupTypeString' -MockWith { return $testServiceCimInstance.StartMode }

                $invokeCimMethodSuccessResult = @{
                    ReturnValue = 0
                }

                Mock -CommandName 'Invoke-CimMethod' -MockWith { return $invokeCimMethodSuccessResult }

                Context 'Specified startup type matches the service startup type' {
                    $setServiceStartupTypeParameters = @{
                        ServiceName = $script:testServiceName
                        StartupType = $testServiceCimInstance.StartMode
                    }

                    It 'Should not throw' {
                        { Set-ServiceStartupType @setServiceStartupTypeParameters } | Should Not Throw
                    }

                    It 'Should retrieve the service CIM instance' {
                        Assert-MockCalled -CommandName 'Get-ServiceCimInstance' -ParameterFilter { $ServiceName -eq $setServiceStartupTypeParameters.ServiceName } -Times 1 -Scope 'Context'
                    }

                    It 'Should not attempt to change the service' {
                        Assert-MockCalled -CommandName 'Invoke-CimMethod' -Times 0 -Scope 'Context'
                    }
                }

                Context 'Specified startup type does not match the service startup type and service change succeeds' {
                    $setServiceStartupTypeParameters = @{
                        ServiceName = $script:testServiceName
                        StartupType = 'Automatic'
                    }

                    It 'Should not throw' {
                        { Set-ServiceStartupType @setServiceStartupTypeParameters } | Should Not Throw
                    }

                    It 'Should retrieve the service CIM instance' {
                        Assert-MockCalled -CommandName 'Get-ServiceCimInstance' -ParameterFilter { $ServiceName -eq $setServiceStartupTypeParameters.ServiceName } -Times 1 -Scope 'Context'
                    }

                    It 'Should change the service' {
                        Assert-MockCalled -CommandName 'Invoke-CimMethod' -ParameterFilter { $InputObject -eq $testServiceCimInstance -and $MethodName -eq 'Change' -and $Arguments.StartMode -eq $setServiceStartupTypeParameters.StartupType } -Times 1 -Scope 'Context'
                    }
                }

                $invokeCimMethodFailResult = @{
                    ReturnValue = 1
                }

                Mock -CommandName 'Invoke-CimMethod' -MockWith { return $invokeCimMethodFailResult }

                Context 'Specified startup type does not match the service startup type and service change fails' {
                    $setServiceStartupTypeParameters = @{
                        ServiceName = $script:testServiceName
                        StartupType = 'Automatic'
                    }

                    It 'Should throw error for failed service change' {
                        $errorMessage = $script:localizedData.InvokeCimMethodFailed -f 'Change', $setServiceStartupTypeParameters.ServiceName, 'StartMode', $invokeCimMethodFailResult.ReturnValue

                        { Set-ServiceStartupType @setServiceStartupTypeParameters } | Should Throw $errorMessage
                    }
                }
            }
            finally
            {
                $testServiceCimInstance.Dispose()

                # Release the reference so the garbage collector can clean up
                $testServiceCimInstance = $null
            }
        }

        Describe 'xService\Set-ServiceProperty' {
            $testServiceCimInstance = @{
                Description = 'Test service description'
                DisplayName = 'TestDisplayName'
            }

            Mock -CommandName 'Get-ServiceCimInstance' -MockWith { return $testServiceCimInstance }
            Mock -CommandName 'Set-Service' -MockWith { }
            Mock -CommandName 'Set-ServiceDependencies' -MockWith { }
            Mock -CommandName 'Set-ServiceAccountProperty' -MockWith { }
            Mock -CommandName 'Set-ServiceStartupType' -MockWith { }

            Context 'No parameters specified' {
                $setServicePropertyParameters = @{
                    ServiceName = $script:testServiceName
                }

                It 'Should not throw' {
                    { Set-ServiceProperty @setServicePropertyParameters } | Should Not Throw
                }

                It 'Should retrieve service CIM instance' {
                    Assert-MockCalled -CommandName 'Get-ServiceCimInstance' -ParameterFilter { $ServiceName -eq $setServicePropertyParameters.ServiceName } -Times 1 -Scope 'Context'
                }

                It 'Should not set service description or display name' {
                    Assert-MockCalled -CommandName 'Set-Service' -Times 0 -Scope 'Context'
                }

                It 'Should not set service dependencies' {
                    Assert-MockCalled -CommandName 'Set-ServiceDependencies' -Times 0 -Scope 'Context'
                }

                It 'Should not set service account properties' {
                    Assert-MockCalled -CommandName 'Set-ServiceAccountProperty' -Times 0 -Scope 'Context'
                }

                It 'Should not set service startup type' {
                    Assert-MockCalled -CommandName 'Set-ServiceStartupType' -Times 0 -Scope 'Context'
                }
            }

            Context 'Mismatching DisplayName specified' {
                $setServicePropertyParameters = @{
                    ServiceName = $script:testServiceName
                    DisplayName = 'NewDisplayName'
                }

                It 'Should not throw' {
                    { Set-ServiceProperty @setServicePropertyParameters } | Should Not Throw
                }

                It 'Should retrieve service CIM instance' {
                    Assert-MockCalled -CommandName 'Get-ServiceCimInstance' -ParameterFilter { $ServiceName -eq $setServicePropertyParameters.ServiceName } -Times 1 -Scope 'Context'
                }

                It 'Should set service display name' {
                    Assert-MockCalled -CommandName 'Set-Service' -ParameterFilter { $Name -eq $setServicePropertyParameters.ServiceName -and $DisplayName -eq $setServicePropertyParameters.DisplayName } -Times 1 -Scope 'Context'
                }

                It 'Should not set service dependencies' {
                    Assert-MockCalled -CommandName 'Set-ServiceDependencies' -Times 0 -Scope 'Context'
                }

                It 'Should not set service account properties' {
                    Assert-MockCalled -CommandName 'Set-ServiceAccountProperty' -Times 0 -Scope 'Context'
                }

                It 'Should not set service startup type' {
                    Assert-MockCalled -CommandName 'Set-ServiceStartupType' -Times 0 -Scope 'Context'
                }
            }

            Context 'Mismatching Description specified' {
                $setServicePropertyParameters = @{
                    ServiceName = $script:testServiceName
                    Description = 'New service description'
                }

                It 'Should not throw' {
                    { Set-ServiceProperty @setServicePropertyParameters } | Should Not Throw
                }

                It 'Should retrieve service CIM instance' {
                    Assert-MockCalled -CommandName 'Get-ServiceCimInstance' -ParameterFilter { $ServiceName -eq $setServicePropertyParameters.ServiceName } -Times 1 -Scope 'Context'
                }

                It 'Should set service description' {
                    Assert-MockCalled -CommandName 'Set-Service' -ParameterFilter { $Name -eq $setServicePropertyParameters.ServiceName -and $Description -eq $setServicePropertyParameters.Description } -Times 1 -Scope 'Context'
                }

                It 'Should not set service dependencies' {
                    Assert-MockCalled -CommandName 'Set-ServiceDependencies' -Times 0 -Scope 'Context'
                }

                It 'Should not set service account properties' {
                    Assert-MockCalled -CommandName 'Set-ServiceAccountProperty' -Times 0 -Scope 'Context'
                }

                It 'Should not set service startup type' {
                    Assert-MockCalled -CommandName 'Set-ServiceStartupType' -Times 0 -Scope 'Context'
                }
            }

            Context 'Matching Description and DisplayName specified' {
                $setServicePropertyParameters = @{
                    ServiceName = $script:testServiceName
                    DisplayName = $testServiceCimInstance.DisplayName
                    Description = $testServiceCimInstance.Description
                }

                It 'Should not throw' {
                    { Set-ServiceProperty @setServicePropertyParameters } | Should Not Throw
                }

                It 'Should retrieve service CIM instance' {
                    Assert-MockCalled -CommandName 'Get-ServiceCimInstance' -ParameterFilter { $ServiceName -eq $setServicePropertyParameters.ServiceName } -Times 1 -Scope 'Context'
                }

                It 'Should not set service description or display name' {
                    Assert-MockCalled -CommandName 'Set-Service' -Times 0 -Scope 'Context'
                }

                It 'Should not set service dependencies' {
                    Assert-MockCalled -CommandName 'Set-ServiceDependencies' -Times 0 -Scope 'Context'
                }

                It 'Should not set service account properties' {
                    Assert-MockCalled -CommandName 'Set-ServiceAccountProperty' -Times 0 -Scope 'Context'
                }

                It 'Should not set service startup type' {
                    Assert-MockCalled -CommandName 'Set-ServiceStartupType' -Times 0 -Scope 'Context'
                }
            }

            Context 'Dependencies specified' {
                $setServicePropertyParameters = @{
                    ServiceName = $script:testServiceName
                    Dependencies = @( 'TestDependency1' )
                }

                It 'Should not throw' {
                    { Set-ServiceProperty @setServicePropertyParameters } | Should Not Throw
                }

                It 'Should retrieve service CIM instance' {
                    Assert-MockCalled -CommandName 'Get-ServiceCimInstance' -ParameterFilter { $ServiceName -eq $setServicePropertyParameters.ServiceName } -Times 1 -Scope 'Context'
                }

                It 'Should not set service description or display name' {
                    Assert-MockCalled -CommandName 'Set-Service' -Times 0 -Scope 'Context'
                }

                It 'Should set service dependencies' {
                    Assert-MockCalled -CommandName 'Set-ServiceDependencies' -ParameterFilter { $ServiceName -eq $setServicePropertyParameters.ServiceName -and $null -eq (Compare-Object -ReferenceObject $setServicePropertyParameters.Dependencies -DifferenceObject $Dependencies) } -Times 1 -Scope 'Context'
                }

                It 'Should not set service account properties' {
                    Assert-MockCalled -CommandName 'Set-ServiceAccountProperty' -Times 0 -Scope 'Context'
                }

                It 'Should not set service startup type' {
                    Assert-MockCalled -CommandName 'Set-ServiceStartupType' -Times 0 -Scope 'Context'
                }
            }

            Context 'Credential specified' {
                $setServicePropertyParameters = @{
                    ServiceName = $script:testServiceName
                    Credential = $script:testCredential1
                }

                It 'Should not throw' {
                    { Set-ServiceProperty @setServicePropertyParameters } | Should Not Throw
                }

                It 'Should retrieve service CIM instance' {
                    Assert-MockCalled -CommandName 'Get-ServiceCimInstance' -ParameterFilter { $ServiceName -eq $setServicePropertyParameters.ServiceName } -Times 1 -Scope 'Context'
                }

                It 'Should not set service description or display name' {
                    Assert-MockCalled -CommandName 'Set-Service' -Times 0 -Scope 'Context'
                }

                It 'Should not set service dependencies' {
                    Assert-MockCalled -CommandName 'Set-ServiceDependencies' -Times 0 -Scope 'Context'
                }

                It 'Should set service account properties' {
                    Assert-MockCalled -CommandName 'Set-ServiceAccountProperty' -ParameterFilter { $ServiceName -eq $setServicePropertyParameters.ServiceName -and [PSCredential]::Equals($setServicePropertyParameters.Credential, $Credential) } -Times 1 -Scope 'Context'
                }

                It 'Should not set service startup type' {
                    Assert-MockCalled -CommandName 'Set-ServiceStartupType' -Times 0 -Scope 'Context'
                }
            }

            Context 'BuiltInAccount specified' {
                $setServicePropertyParameters = @{
                    ServiceName = $script:testServiceName
                    BuiltInAccount = 'LocalService'
                }

                It 'Should not throw' {
                    { Set-ServiceProperty @setServicePropertyParameters } | Should Not Throw
                }

                It 'Should retrieve service CIM instance' {
                    Assert-MockCalled -CommandName 'Get-ServiceCimInstance' -ParameterFilter { $ServiceName -eq $setServicePropertyParameters.ServiceName } -Times 1 -Scope 'Context'
                }

                It 'Should not set service description or display name' {
                    Assert-MockCalled -CommandName 'Set-Service' -Times 0 -Scope 'Context'
                }

                It 'Should not set service dependencies' {
                    Assert-MockCalled -CommandName 'Set-ServiceDependencies' -Times 0 -Scope 'Context'
                }

                It 'Should set service account properties' {
                    Assert-MockCalled -CommandName 'Set-ServiceAccountProperty' -ParameterFilter { $ServiceName -eq $setServicePropertyParameters.ServiceName -and $BuiltInAccount -eq $setServicePropertyParameters.BuiltInAccount } -Times 1 -Scope 'Context'
                }

                It 'Should not set service startup type' {
                    Assert-MockCalled -CommandName 'Set-ServiceStartupType' -Times 0 -Scope 'Context'
                }
            }

            Context 'DesktopInteract specified' {
                $setServicePropertyParameters = @{
                    ServiceName = $script:testServiceName
                    DesktopInteract = $true
                }

                It 'Should not throw' {
                    { Set-ServiceProperty @setServicePropertyParameters } | Should Not Throw
                }

                It 'Should retrieve service CIM instance' {
                    Assert-MockCalled -CommandName 'Get-ServiceCimInstance' -ParameterFilter { $ServiceName -eq $setServicePropertyParameters.ServiceName } -Times 1 -Scope 'Context'
                }

                It 'Should not set service description or display name' {
                    Assert-MockCalled -CommandName 'Set-Service' -Times 0 -Scope 'Context'
                }

                It 'Should not set service dependencies' {
                    Assert-MockCalled -CommandName 'Set-ServiceDependencies' -Times 0 -Scope 'Context'
                }

                It 'Should set service account properties' {
                    Assert-MockCalled -CommandName 'Set-ServiceAccountProperty' -ParameterFilter { $ServiceName -eq $setServicePropertyParameters.ServiceName -and $DesktopInteract -eq $setServicePropertyParameters.DesktopInteract } -Times 1 -Scope 'Context'
                }

                It 'Should not set service startup type' {
                    Assert-MockCalled -CommandName 'Set-ServiceStartupType' -Times 0 -Scope 'Context'
                }
            }

            Context 'StartupType specified' {
                $setServicePropertyParameters = @{
                    ServiceName = $script:testServiceName
                    StartupType = 'Manual'
                }

                It 'Should not throw' {
                    { Set-ServiceProperty @setServicePropertyParameters } | Should Not Throw
                }

                It 'Should retrieve service CIM instance' {
                    Assert-MockCalled -CommandName 'Get-ServiceCimInstance' -ParameterFilter { $ServiceName -eq $setServicePropertyParameters.ServiceName } -Times 1 -Scope 'Context'
                }

                It 'Should not set service description or display name' {
                    Assert-MockCalled -CommandName 'Set-Service' -Times 0 -Scope 'Context'
                }

                It 'Should not set service dependencies' {
                    Assert-MockCalled -CommandName 'Set-ServiceDependencies' -Times 0 -Scope 'Context'
                }

                It 'Should not set service account properties' {
                    Assert-MockCalled -CommandName 'Set-ServiceAccountProperty' -Times 0 -Scope 'Context'
                }

                It 'Should set service startup type' {
                    Assert-MockCalled -CommandName 'Set-ServiceStartupType' -ParameterFilter { $ServiceName -eq $setServicePropertyParameters.ServiceName -and $StartupType -eq $setServicePropertyParameters.StartupType } -Times 1 -Scope 'Context'
                }
            }
        }

        Describe 'xService\Remove-ServiceWithTimeout' {
            Mock -CommandName 'Remove-Service' -MockWith { }
            Mock -CommandName 'Get-Service' -MockWith { }

            Context 'Service removal succeeds' {
                $removeServiceWithTimeoutParameters = @{
                    Name = $script:testServiceName
                    TerminateTimeout = 500
                }

                It 'Should not throw' {
                    { Remove-ServiceWithTimeout @removeServiceWithTimeoutParameters } | Should Not Throw
                }

                It 'Should remove service' {
                    Assert-MockCalled -CommandName 'Remove-Service' -ParameterFilter { $Name -eq $removeServiceWithTimeoutParameters.Name } -Times 1 -Scope 'Context'
                }

                It 'Should retrieve service to check for removal once' {
                    Assert-MockCalled -CommandName 'Get-Service' -ParameterFilter { $Name -eq $removeServiceWithTimeoutParameters.Name } -Times 1 -Scope 'Context'
                }
            }

            Mock -CommandName 'Get-Service' -MockWith { return 'Not null' }

            Context 'Service removal fails' {
                $removeServiceWithTimeoutParameters = @{
                    Name = $script:testServiceName
                    TerminateTimeout = 500
                }

                It 'Should throw error for service removal timeout' {
                    $errorMessage = $script:localizedData.ServiceDeletionFailed -f $removeServiceWithTimeoutParameters.Name
                    { Remove-ServiceWithTimeout @removeServiceWithTimeoutParameters } | Should Throw $errorMessage
                }
            }
        }

        Describe 'xService\Start-ServiceWithTimeout' {
            Mock -CommandName 'Start-Service' -MockWith { }
            Mock -CommandName 'Wait-ServiceStateWithTimeout' -MockWith { }

            $startServiceWithTimeoutParameters = @{
                ServiceName = $script:testServiceName
                StartupTimeout = 500
            }

            $expectedTimeSpan = [TimeSpan]::FromMilliseconds($startServiceWithTimeoutParameters.StartupTimeout)
                    
            It 'Should not throw' {
                { Start-ServiceWithTimeout @startServiceWithTimeoutParameters } | Should Not Throw
            }

            It 'Should start service' {
                Assert-MockCalled -CommandName 'Start-Service' -ParameterFilter { $Name -eq $startServiceWithTimeoutParameters.ServiceName } -Times 1 -Scope 'Describe'
            }

            It 'Should wait for service to start' {
                Assert-MockCalled -CommandName 'Wait-ServiceStateWithTimeout' -ParameterFilter { $ServiceName -eq $startServiceWithTimeoutParameters.ServiceName -and $State -eq [System.ServiceProcess.ServiceControllerStatus]::Running -and [TimeSpan]::Equals($expectedTimeSpan, $WaitTimeSpan) } -Times 1 -Scope 'Describe'
            }
        }

        Describe 'xService\Stop-ServiceWithTimeout' {
            Mock -CommandName 'Stop-Service' -MockWith { }
            Mock -CommandName 'Wait-ServiceStateWithTimeout' -MockWith { }

            $stopServiceWithTimeoutParameters = @{
                ServiceName = $script:testServiceName
                TerminateTimeout = 500
            }

            $expectedTimeSpan = [TimeSpan]::FromMilliseconds($stopServiceWithTimeoutParameters.TerminateTimeout)
                    
            It 'Should not throw' {
                { Stop-ServiceWithTimeout @stopServiceWithTimeoutParameters } | Should Not Throw
            }

            It 'Should stop service' {
                Assert-MockCalled -CommandName 'Stop-Service' -ParameterFilter { $Name -eq $stopServiceWithTimeoutParameters.ServiceName } -Times 1 -Scope 'Describe'
            }

            It 'Should wait for service to stop' {
                Assert-MockCalled -CommandName 'Wait-ServiceStateWithTimeout' -ParameterFilter { $ServiceName -eq $stopServiceWithTimeoutParameters.ServiceName -and $State -eq [System.ServiceProcess.ServiceControllerStatus]::Stopped -and [TimeSpan]::Equals($expectedTimeSpan, $WaitTimeSpan) } -Times 1 -Scope 'Describe'
            }
        }
    }
}
finally
{
    Exit-DscResourceTestEnvironment -TestEnvironment $script:testEnvironment
}
