#requires -Version 4.0

# Suppressing this rule because IIS requires PlainText for one of the functions used in this test
[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingConvertToSecureStringWithPlainText', '')]
param ()

$script:DSCModuleName   = 'xWebAdministration'
$script:DSCResourceName = 'MSFT_xWebAppPool'

#region HEADER
$script:moduleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
if ( (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests'))) -or `
     (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1'))) )
{
    & git @('clone','https://github.com/PowerShell/DscResource.Tests.git',(Join-Path -Path $script:moduleRoot -ChildPath '\DSCResource.Tests\'))
}

Import-Module (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1') -Force

Import-Module (Join-Path -Path $script:moduleRoot -ChildPath 'Tests\MockWebAdministrationWindowsFeature.psm1')

$TestEnvironment = Initialize-TestEnvironment `
    -DSCModuleName $script:DSCModuleName `
    -DSCResourceName $script:DSCResourceName `
    -TestType Unit
#endregion

# Begin Testing
try
{
    #region Pester Tests

    InModuleScope $script:DSCResourceName {

        Describe "$($script:DSCResourceName)\Get-TargetResource" {

            Mock Assert-Module

            Context 'Application pool does not exist' {

                Mock Get-WebConfiguration

                $result = Get-TargetResource -Name 'NonExistent'

                It 'Should return the Ensure property set to Absent' {
                    $result.Ensure | Should Be 'Absent'
                }

            }

            Context 'Application pool exists' {

                $mockAppPool = @{
                    name = 'MockAppPool'
                    state = 'Started'
                    autoStart = $true
                    CLRConfigFile = ''
                    enable32BitAppOnWin64 = $false
                    enableConfigurationOverride = $true
                    managedPipelineMode = 'Integrated'
                    managedRuntimeLoader = 'webengine4.dll'
                    managedRuntimeVersion = 'v4.0'
                    passAnonymousToken = $true
                    startMode = 'OnDemand'
                    queueLength = 1000
                    cpu = @{
                        action = 'NoAction'
                        limit = 0
                        resetInterval = '00:05:00'
                        smpAffinitized = $false
                        smpProcessorAffinityMask = 4294967295
                        smpProcessorAffinityMask2 = 4294967295
                    }
                    processModel = @{
                        identityType = 'SpecificUser'
                        idleTimeout = '00:20:00'
                        idleTimeoutAction = 'Terminate'
                        loadUserProfile = $true
                        logEventOnProcessModel = 'IdleTimeout'
                        logonType = 'LogonBatch'
                        manualGroupMembership = $false
                        maxProcesses = 1
                        password = 'P@$$w0rd'
                        pingingEnabled = $true
                        pingInterval = '00:00:30'
                        pingResponseTime = '00:01:30'
                        setProfileEnvironment = $false
                        shutdownTimeLimit = '00:01:30'
                        startupTimeLimit = '00:01:30'
                        userName = 'CONTOSO\JDoe'
                    }
                    failure = @{
                        orphanActionExe = ''
                        orphanActionParams = ''
                        orphanWorkerProcess = $false
                        loadBalancerCapabilities = 'HttpLevel'
                        rapidFailProtection = $true
                        rapidFailProtectionInterval = '00:05:00'
                        rapidFailProtectionMaxCrashes = 5
                        autoShutdownExe = ''
                        autoShutdownParams = ''
                    }
                    recycling = @{
                        disallowOverlappingRotation = $false
                        disallowRotationOnConfigChange = $false
                        logEventOnRecycle = 'Time,Requests,Schedule,Memory,IsapiUnhealthy,OnDemand,ConfigChange,PrivateMemory'
                        periodicRestart = @{
                            memory = 0
                            privateMemory = 0
                            requests = 0
                            time = '1.05:00:00'
                            schedule = @{
                                Collection = @(
                                    @{value = '04:00:00'}
                                    @{value = '08:00:00'}
                                )
                            }
                        }
                    }
                }

                Mock Get-WebConfiguration -MockWith {$mockAppPool}

                $result = Get-TargetResource -Name $mockAppPool.Name

                It 'Should return the Ensure property set to Present' {
                    $result.Ensure | Should Be 'Present'
                }

                It 'Should return the Name property' {
                    $result.Name | Should Be $mockAppPool.name
                }

                It 'Should return the State property' {
                    $result.State | Should Be $mockAppPool.state
                }

                It 'Should return the autoStart property' {
                    $result.autoStart | Should Be $mockAppPool.autoStart
                }

                It 'Should return the CLRConfigFile property' {
                    $result.CLRConfigFile | Should Be $mockAppPool.CLRConfigFile
                }

                It 'Should return the enable32BitAppOnWin64 property' {
                    $result.enable32BitAppOnWin64 | Should Be $mockAppPool.enable32BitAppOnWin64
                }

                It 'Should return the enableConfigurationOverride property' {
                    $result.enableConfigurationOverride | Should Be $mockAppPool.enableConfigurationOverride
                }

                It 'Should return the managedPipelineMode property' {
                    $result.managedPipelineMode | Should Be $mockAppPool.managedPipelineMode
                }

                It 'Should return the managedRuntimeLoader property' {
                    $result.managedRuntimeLoader | Should Be $mockAppPool.managedRuntimeLoader
                }

                It 'Should return the managedRuntimeVersion property' {
                    $result.managedRuntimeVersion | Should Be $mockAppPool.managedRuntimeVersion
                }

                It 'Should return the passAnonymousToken property' {
                    $result.passAnonymousToken | Should Be $mockAppPool.passAnonymousToken
                }

                It 'Should return the startMode property' {
                    $result.startMode | Should Be $mockAppPool.startMode
                }

                It 'Should return the queueLength property' {
                    $result.queueLength | Should Be $mockAppPool.queueLength
                }

                It 'Should return the cpuAction property' {
                    $result.cpuAction | Should Be $mockAppPool.cpu.action
                }

                It 'Should return the cpuLimit property' {
                    $result.cpuLimit | Should Be $mockAppPool.cpu.limit
                }

                It 'Should return the cpuResetInterval property' {
                    $result.cpuResetInterval | Should Be $mockAppPool.cpu.resetInterval
                }

                It 'Should return the cpuSmpAffinitized property' {
                    $result.cpuSmpAffinitized | Should Be $mockAppPool.cpu.smpAffinitized
                }

                It 'Should return the cpuSmpProcessorAffinityMask property' {
                    $result.cpuSmpProcessorAffinityMask | Should Be $mockAppPool.cpu.smpProcessorAffinityMask
                }

                It 'Should return the cpuSmpProcessorAffinityMask2 property' {
                    $result.cpuSmpProcessorAffinityMask2 | Should Be $mockAppPool.cpu.smpProcessorAffinityMask2
                }

                It 'Should return the identityType property' {
                    $result.identityType | Should Be $mockAppPool.processModel.identityType
                }

                It 'Should return the Credential (userName) property' {
                    # Get-DscConfiguration returns MSFT_Credential with empty UserName
                    $result.Credential.userName | Should Be $mockAppPool.processModel.userName
                }

                It 'Should return the Credential (password) property' {
                    # Get-DscConfiguration returns MSFT_Credential with empty Password
                    $result.Credential.Password | Should Be $mockAppPool.processModel.password
                }

                It 'Should return the idleTimeout property' {
                    $result.idleTimeout | Should Be $mockAppPool.processModel.idleTimeout
                }

                It 'Should return the idleTimeoutAction property' {
                    $result.idleTimeoutAction | Should Be $mockAppPool.processModel.idleTimeoutAction
                }

                It 'Should return the loadUserProfile property' {
                    $result.loadUserProfile | Should Be $mockAppPool.processModel.loadUserProfile
                }

                It 'Should return the logonType property' {
                    $result.logonType | Should Be $mockAppPool.processModel.logonType
                }

                It 'Should return the logEventOnProcessModel property' {
                    $result.logEventOnProcessModel | Should Be $mockAppPool.processModel.logEventOnProcessModel
                }

                It 'Should return the manualGroupMembership property' {
                    $result.manualGroupMembership | Should Be $mockAppPool.processModel.manualGroupMembership
                }

                It 'Should return the maxProcesses property' {
                    $result.maxProcesses | Should Be $mockAppPool.processModel.maxProcesses
                }

                It 'Should return the pingingEnabled property' {
                    $result.pingingEnabled | Should Be $mockAppPool.processModel.pingingEnabled
                }

                It 'Should return the pingInterval property' {
                    $result.pingInterval | Should Be $mockAppPool.processModel.pingInterval
                }

                It 'Should return the pingResponseTime property' {
                    $result.pingResponseTime | Should Be $mockAppPool.processModel.pingResponseTime
                }

                It 'Should return the setProfileEnvironment property' {
                    $result.setProfileEnvironment | Should Be $mockAppPool.processModel.setProfileEnvironment
                }

                It 'Should return the shutdownTimeLimit property' {
                    $result.shutdownTimeLimit | Should Be $mockAppPool.processModel.shutdownTimeLimit
                }

                It 'Should return the startupTimeLimit property' {
                    $result.startupTimeLimit | Should Be $mockAppPool.processModel.startupTimeLimit
                }

                It 'Should return the orphanActionExe property' {
                    $result.orphanActionExe | Should Be $mockAppPool.failure.orphanActionExe
                }

                It 'Should return the orphanActionParams property' {
                    $result.orphanActionParams | Should Be $mockAppPool.failure.orphanActionParams
                }

                It 'Should return the orphanWorkerProcess property' {
                    $result.orphanWorkerProcess | Should Be $mockAppPool.failure.orphanWorkerProcess
                }

                It 'Should return the loadBalancerCapabilities property' {
                    $result.loadBalancerCapabilities | Should Be $mockAppPool.failure.loadBalancerCapabilities
                }

                It 'Should return the rapidFailProtection property' {
                    $result.rapidFailProtection | Should Be $mockAppPool.failure.rapidFailProtection
                }

                It 'Should return the rapidFailProtectionInterval property' {
                    $result.rapidFailProtectionInterval | Should Be $mockAppPool.failure.rapidFailProtectionInterval
                }

                It 'Should return the rapidFailProtectionMaxCrashes property' {
                    $result.rapidFailProtectionMaxCrashes | Should Be $mockAppPool.failure.rapidFailProtectionMaxCrashes
                }

                It 'Should return the autoShutdownExe property' {
                    $result.autoShutdownExe | Should Be $mockAppPool.failure.autoShutdownExe
                }

                It 'Should return the autoShutdownParams property' {
                    $result.autoShutdownParams | Should Be $mockAppPool.failure.autoShutdownParams
                }

                It 'Should return the disallowOverlappingRotation property' {
                    $result.disallowOverlappingRotation | Should Be $mockAppPool.recycling.disallowOverlappingRotation
                }

                It 'Should return the disallowRotationOnConfigChange property' {
                    $result.disallowRotationOnConfigChange | Should Be $mockAppPool.recycling.disallowRotationOnConfigChange
                }

                It 'Should return the logEventOnRecycle property' {
                    $result.logEventOnRecycle | Should Be $mockAppPool.recycling.logEventOnRecycle
                }

                It 'Should return the restartMemoryLimit property' {
                    $result.restartMemoryLimit | Should Be $mockAppPool.recycling.periodicRestart.memory
                }

                It 'Should return the restartPrivateMemoryLimit property' {
                    $result.restartPrivateMemoryLimit | Should Be $mockAppPool.recycling.periodicRestart.privateMemory
                }

                It 'Should return the restartRequestsLimit property' {
                    $result.restartRequestsLimit | Should Be $mockAppPool.recycling.periodicRestart.requests
                }

                It 'Should return the restartTimeLimit property' {
                    $result.restartTimeLimit | Should Be $mockAppPool.recycling.periodicRestart.time
                }

                It 'Should return the restartSchedule property' {

                    $restartScheduleValues = [String[]]@(
                        @($mockAppPool.recycling.periodicRestart.schedule.Collection).ForEach('value')
                    )

                    $compareSplat = @{
                        ReferenceObject = [String[]]@($result.restartSchedule)
                        DifferenceObject = $restartScheduleValues
                        ExcludeDifferent = $true
                        IncludeEqual = $true
                    }

                    $compareResult = Compare-Object @compareSplat

                    $compareResult.Count -eq $restartScheduleValues.Count | Should Be $true

                }

            }

        }

        Describe "how '$($script:DSCResourceName)\Test-TargetResource' responds to Ensure = 'Absent'" {

            Mock Assert-Module

            Context 'Application pool does not exist' {

                Mock Get-WebConfiguration

                It 'Should return True' {
                    Test-TargetResource -Ensure 'Absent' -Name 'NonExistent' |
                    Should Be $true
                }

            }

            Context 'Application pool exists' {

                $mockAppPool = @{
                    name = 'MockAppPool'
                }

                Mock Get-WebConfiguration -MockWith {$mockAppPool}

                It 'Should return False' {
                    Test-TargetResource -Ensure 'Absent' -Name $mockAppPool.name |
                    Should Be $false
                }

            }

        }

        Describe "how '$($script:DSCResourceName)\Test-TargetResource' responds to Ensure = 'Present'" {

            Mock Assert-Module

            Context 'Application pool does not exist' {

                Mock Get-WebConfiguration

                It 'Should return False' {
                    Test-TargetResource -Ensure 'Present' -Name 'NonExistent' |
                    Should Be $false
                }

            }

            Context 'Application pool exists' {

                $mockAppPool = @{
                    name = 'MockAppPool'
                }

                Mock Get-WebConfiguration -MockWith {$mockAppPool}

                It 'Should return True' {
                    Test-TargetResource -Ensure 'Present' -Name $mockAppPool.name |
                    Should Be $true
                }

            }

            Context 'All the properties match the desired state' {

                $mockAppPool = @{
                    name = 'MockAppPool'
                    state = 'Started'
                    autoStart = $true
                    CLRConfigFile = ''
                    enable32BitAppOnWin64 = $false
                    enableConfigurationOverride = $true
                    managedPipelineMode = 'Integrated'
                    managedRuntimeLoader = 'webengine4.dll'
                    managedRuntimeVersion = 'v4.0'
                    passAnonymousToken = $true
                    startMode = 'OnDemand'
                    queueLength = 1000
                    cpu = @{
                        action = 'NoAction'
                        limit = 0
                        resetInterval = '00:05:00'
                        smpAffinitized = $false
                        smpProcessorAffinityMask = 4294967295
                        smpProcessorAffinityMask2 = 4294967295
                    }
                    processModel = @{
                        identityType = 'SpecificUser'
                        idleTimeout = '00:20:00'
                        idleTimeoutAction = 'Terminate'
                        loadUserProfile = $true
                        logEventOnProcessModel = 'IdleTimeout'
                        logonType = 'LogonBatch'
                        manualGroupMembership = $false
                        maxProcesses = 1
                        password = 'P@$$w0rD'
                        pingingEnabled = $true
                        pingInterval = '00:00:30'
                        pingResponseTime = '00:01:30'
                        setProfileEnvironment = $false
                        shutdownTimeLimit = '00:01:30'
                        startupTimeLimit = '00:01:30'
                        userName = 'CONTOSO\JDoe'
                    }
                    failure = @{
                        orphanActionExe = ''
                        orphanActionParams = ''
                        orphanWorkerProcess = $false
                        loadBalancerCapabilities = 'HttpLevel'
                        rapidFailProtection = $true
                        rapidFailProtectionInterval = '00:05:00'
                        rapidFailProtectionMaxCrashes = 5
                        autoShutdownExe = ''
                        autoShutdownParams = ''
                    }
                    recycling = @{
                        disallowOverlappingRotation = $false
                        disallowRotationOnConfigChange = $false
                        logEventOnRecycle = 'Time,Requests,Schedule,Memory,IsapiUnhealthy,OnDemand,ConfigChange,PrivateMemory'
                        periodicRestart = @{
                            memory = 0
                            privateMemory = 0
                            requests = 0
                            time = '1.05:00:00'
                            schedule = @{
                                Collection = @(
                                    @{value = '04:00:00'}
                                    @{value = '08:00:00'}
                                )
                            }
                        }
                    }
                }

                Mock Get-WebConfiguration -MockWith {$mockAppPool}

                $mockUserName = $mockAppPool.processModel.userName
                $mockPassword = $mockAppPool.processModel.password | ConvertTo-SecureString -AsPlainText -Force
                $mockCredential = New-Object -TypeName PSCredential -ArgumentList $mockUserName, $mockPassword

                $mockRestartSchedule = [String[]]@(
                    @($mockAppPool.recycling.periodicRestart.schedule.Collection).ForEach('value')
                )

                $testParamsSplat = @{
                    Name = $mockAppPool.Name
                    State = $mockAppPool.state
                    autoStart = $mockAppPool.autoStart
                    CLRConfigFile = $mockAppPool.CLRConfigFile
                    enable32BitAppOnWin64 = $mockAppPool.enable32BitAppOnWin64
                    enableConfigurationOverride = $mockAppPool.enableConfigurationOverride
                    managedPipelineMode = $mockAppPool.managedPipelineMode
                    managedRuntimeLoader = $mockAppPool.managedRuntimeLoader
                    managedRuntimeVersion = $mockAppPool.managedRuntimeVersion
                    passAnonymousToken = $mockAppPool.passAnonymousToken
                    startMode = $mockAppPool.startMode
                    queueLength = $mockAppPool.queueLength
                    cpuAction = $mockAppPool.cpu.action
                    cpuLimit = $mockAppPool.cpu.limit
                    cpuResetInterval = $mockAppPool.cpu.resetInterval
                    cpuSmpAffinitized = $mockAppPool.cpu.smpAffinitized
                    cpuSmpProcessorAffinityMask = $mockAppPool.cpu.smpProcessorAffinityMask
                    cpuSmpProcessorAffinityMask2 = $mockAppPool.cpu.smpProcessorAffinityMask2
                    identityType = $mockAppPool.processModel.identityType
                    Credential = $mockCredential
                    idleTimeout = $mockAppPool.processModel.idleTimeout
                    idleTimeoutAction = $mockAppPool.processModel.idleTimeoutAction
                    loadUserProfile = $mockAppPool.processModel.loadUserProfile
                    logEventOnProcessModel = $mockAppPool.processModel.logEventOnProcessModel
                    logonType = $mockAppPool.processModel.logonType
                    manualGroupMembership = $mockAppPool.processModel.manualGroupMembership
                    maxProcesses = $mockAppPool.processModel.maxProcesses
                    pingingEnabled = $mockAppPool.processModel.pingingEnabled
                    pingInterval = $mockAppPool.processModel.pingInterval
                    pingResponseTime = $mockAppPool.processModel.pingResponseTime
                    setProfileEnvironment = $mockAppPool.processModel.setProfileEnvironment
                    shutdownTimeLimit = $mockAppPool.processModel.shutdownTimeLimit
                    startupTimeLimit = $mockAppPool.processModel.startupTimeLimit
                    orphanActionExe = $mockAppPool.failure.orphanActionExe
                    orphanActionParams = $mockAppPool.failure.orphanActionParams
                    orphanWorkerProcess = $mockAppPool.failure.orphanWorkerProcess
                    loadBalancerCapabilities = $mockAppPool.failure.loadBalancerCapabilities
                    rapidFailProtection = $mockAppPool.failure.rapidFailProtection
                    rapidFailProtectionInterval = $mockAppPool.failure.rapidFailProtectionInterval
                    rapidFailProtectionMaxCrashes = $mockAppPool.failure.rapidFailProtectionMaxCrashes
                    autoShutdownExe = $mockAppPool.failure.autoShutdownExe
                    autoShutdownParams = $mockAppPool.failure.autoShutdownParams
                    disallowOverlappingRotation = $mockAppPool.recycling.disallowOverlappingRotation
                    disallowRotationOnConfigChange = $mockAppPool.recycling.disallowRotationOnConfigChange
                    logEventOnRecycle = $mockAppPool.recycling.logEventOnRecycle
                    restartMemoryLimit = $mockAppPool.recycling.periodicRestart.memory
                    restartPrivateMemoryLimit = $mockAppPool.recycling.periodicRestart.privateMemory
                    restartRequestsLimit = $mockAppPool.recycling.periodicRestart.requests
                    restartTimeLimit = $mockAppPool.recycling.periodicRestart.time
                    restartSchedule = $mockRestartSchedule
                }

                It 'Should return True' {
                    Test-TargetResource -Ensure 'Present' @testParamsSplat |
                    Should Be $true
                }

            }

            Context 'Test the State property' {

                $mockAppPool = @{
                    name = 'MockAppPool'
                    State = 'Started'
                }

                Mock Get-WebConfiguration -MockWith {$mockAppPool}

                It 'Should return True when the property matches the desired state' {
                    Test-TargetResource -Ensure 'Present' -Name $mockAppPool.name -State 'Started' |
                    Should Be $true
                }

                It 'Should return False when the property does not match the desired state' {
                    Test-TargetResource -Ensure 'Present' -Name $mockAppPool.name -State 'Stopped' |
                    Should Be $false
                }

            }

            Context 'Test the autoStart property' {

                $mockAppPool = @{
                    name = 'MockAppPool'
                    autoStart = $true
                }

                Mock Get-WebConfiguration -MockWith {$mockAppPool}

                It 'Should return True when the property matches the desired state' {
                    Test-TargetResource -Ensure 'Present' -Name $mockAppPool.name -autoStart $true |
                    Should Be $true
                }

                It 'Should return False when the property does not match the desired state' {
                    Test-TargetResource -Ensure 'Present' -Name $mockAppPool.name -autoStart $false |
                    Should Be $false
                }

            }

            Context 'Test the CLRConfigFile property' {

                $mockAppPool = @{
                    name = 'MockAppPool'
                    CLRConfigFile = ''
                }

                Mock Get-WebConfiguration -MockWith {$mockAppPool}

                It 'Should return True when the property matches the desired state' {
                    Test-TargetResource -Ensure 'Present' -Name $mockAppPool.name -CLRConfigFile '' |
                    Should Be $true
                }

                It 'Should return False when the property does not match the desired state' {
                    Test-TargetResource -Ensure 'Present' -Name $mockAppPool.name -CLRConfigFile 'C:\inetpub\temp\aspnet.config' |
                    Should Be $false
                }

            }

            Context 'Test the enable32BitAppOnWin64 property' {

                $mockAppPool = @{
                    name = 'MockAppPool'
                    enable32BitAppOnWin64 = $false
                }

                Mock Get-WebConfiguration -MockWith {$mockAppPool}

                It 'Should return True when the property matches the desired state' {
                    Test-TargetResource -Ensure 'Present' -Name $mockAppPool.name -enable32BitAppOnWin64 $false |
                    Should Be $true
                }

                It 'Should return False when the property does not match the desired state' {
                    Test-TargetResource -Ensure 'Present' -Name $mockAppPool.name -enable32BitAppOnWin64 $true |
                    Should Be $false
                }

            }

            Context 'Test the enableConfigurationOverride property' {

                $mockAppPool = @{
                    name = 'MockAppPool'
                    enableConfigurationOverride = $true
                }

                Mock Get-WebConfiguration -MockWith {$mockAppPool}

                It 'Should return True when the property matches the desired state' {
                    Test-TargetResource -Ensure 'Present' -Name $mockAppPool.name -enableConfigurationOverride $true |
                    Should Be $true
                }

                It 'Should return False when the property does not match the desired state' {
                    Test-TargetResource -Ensure 'Present' -Name $mockAppPool.name -enableConfigurationOverride $false |
                    Should Be $false
                }

            }

            Context 'Test the managedPipelineMode property' {

                $mockAppPool = @{
                    name = 'MockAppPool'
                    managedPipelineMode = 'Integrated'
                }

                Mock Get-WebConfiguration -MockWith {$mockAppPool}

                It 'Should return True when the property matches the desired state' {
                    Test-TargetResource -Ensure 'Present' -Name $mockAppPool.name -managedPipelineMode 'Integrated' |
                    Should Be $true
                }

                It 'Should return False when the property does not match the desired state' {
                    Test-TargetResource -Ensure 'Present' -Name $mockAppPool.name -managedPipelineMode 'Classic' |
                    Should Be $false
                }

            }

            Context 'Test the managedRuntimeLoader property' {

                $mockAppPool = @{
                    name = 'MockAppPool'
                    managedRuntimeLoader = 'webengine4.dll'
                }

                Mock Get-WebConfiguration -MockWith {$mockAppPool}

                It 'Should return True when the property matches the desired state' {
                    Test-TargetResource -Ensure 'Present' -Name $mockAppPool.name -managedRuntimeLoader 'webengine4.dll' |
                    Should Be $true
                }

                It 'Should return False when the property does not match the desired state' {
                    Test-TargetResource -Ensure 'Present' -Name $mockAppPool.name -managedRuntimeLoader '' |
                    Should Be $false
                }

            }

            Context 'Test the managedRuntimeVersion property' {

                $mockAppPool = @{
                    name = 'MockAppPool'
                    managedRuntimeVersion = 'v4.0'
                }

                Mock Get-WebConfiguration -MockWith {$mockAppPool}

                It 'Should return True when the property matches the desired state' {
                    Test-TargetResource -Ensure 'Present' -Name $mockAppPool.name -managedRuntimeVersion 'v4.0' |
                    Should Be $true
                }

                It 'Should return False when the property does not match the desired state' {
                    Test-TargetResource -Ensure 'Present' -Name $mockAppPool.name -managedRuntimeVersion 'v2.0' |
                    Should Be $false
                }

            }

            Context 'Test the passAnonymousToken property' {

                $mockAppPool = @{
                    name = 'MockAppPool'
                    passAnonymousToken = $true
                }

                Mock Get-WebConfiguration -MockWith {$mockAppPool}

                It 'Should return True when the property matches the desired state' {
                    Test-TargetResource -Ensure 'Present' -Name $mockAppPool.name -passAnonymousToken $true |
                    Should Be $true
                }

                It 'Should return False when the property does not match the desired state' {
                    Test-TargetResource -Ensure 'Present' -Name $mockAppPool.name -passAnonymousToken $false |
                    Should Be $false
                }

            }

            Context 'Test the startMode property' {

                $mockAppPool = @{
                    name = 'MockAppPool'
                    startMode = 'OnDemand'
                }

                Mock Get-WebConfiguration -MockWith {$mockAppPool}

                It 'Should return True when the property matches the desired state' {
                    Test-TargetResource -Ensure 'Present' -Name $mockAppPool.name -startMode 'OnDemand' |
                    Should Be $true
                }

                It 'Should return False when the property does not match the desired state' {
                    Test-TargetResource -Ensure 'Present' -Name $mockAppPool.name -startMode 'AlwaysRunning' |
                    Should Be $false
                }

            }

            Context 'Test the queueLength property' {

                $mockAppPool = @{
                    name = 'MockAppPool'
                    queueLength = 1000
                }

                Mock Get-WebConfiguration -MockWith {$mockAppPool}

                It 'Should return True when the property matches the desired state' {
                    Test-TargetResource -Ensure 'Present' -Name $mockAppPool.name -queueLength 1000 |
                    Should Be $true
                }

                It 'Should return False when the property does not match the desired state' {
                    Test-TargetResource -Ensure 'Present' -Name $mockAppPool.name -queueLength 2000 |
                    Should Be $false
                }

            }

            Context 'Test the cpuAction property' {

                $mockAppPool = @{
                    name = 'MockAppPool'
                    cpu = @{
                        action = 'NoAction'
                    }
                }

                Mock Get-WebConfiguration -MockWith {$mockAppPool}

                It 'Should return True when the property matches the desired state' {
                    Test-TargetResource -Ensure 'Present' -Name $mockAppPool.name -cpuAction 'NoAction' |
                    Should Be $true
                }

                It 'Should return False when the property does not match the desired state' {
                    Test-TargetResource -Ensure 'Present' -Name $mockAppPool.name -cpuAction 'KillW3wp' |
                    Should Be $false
                }

            }

            Context 'Test the cpuLimit property' {

                $mockAppPool = @{
                    name = 'MockAppPool'
                    cpu = @{
                        limit = 0
                    }
                }

                Mock Get-WebConfiguration -MockWith {$mockAppPool}

                It 'Should return True when the property matches the desired state' {
                    Test-TargetResource -Ensure 'Present' -Name $mockAppPool.name -cpuLimit 0 |
                    Should Be $true
                }

                It 'Should return False when the property does not match the desired state' {
                    Test-TargetResource -Ensure 'Present' -Name $mockAppPool.name -cpuLimit 90000 |
                    Should Be $false
                }

            }

            Context 'Test the cpuResetInterval property' {

                $mockAppPool = @{
                    name = 'MockAppPool'
                    cpu = @{
                        resetInterval = '00:05:00'
                    }
                }

                Mock Get-WebConfiguration -MockWith {$mockAppPool}

                It 'Should return True when the property matches the desired state' {
                    Test-TargetResource -Ensure 'Present' -Name $mockAppPool.name -cpuResetInterval '00:05:00' |
                    Should Be $true
                }

                It 'Should return False when the property does not match the desired state' {
                    Test-TargetResource -Ensure 'Present' -Name $mockAppPool.name -cpuResetInterval '00:10:00' |
                    Should Be $false
                }

            }

            Context 'Test the cpuSmpAffinitized property' {

                $mockAppPool = @{
                    name = 'MockAppPool'
                    cpu = @{
                        smpAffinitized = $false
                    }
                }

                Mock Get-WebConfiguration -MockWith {$mockAppPool}

                It 'Should return True when the property matches the desired state' {
                    Test-TargetResource -Ensure 'Present' -Name $mockAppPool.name -cpuSmpAffinitized $false |
                    Should Be $true
                }

                It 'Should return False when the property does not match the desired state' {
                    Test-TargetResource -Ensure 'Present' -Name $mockAppPool.name -cpuSmpAffinitized $true |
                    Should Be $false
                }

            }

            Context 'Test the cpuSmpProcessorAffinityMask property' {

                $mockAppPool = @{
                    name = 'MockAppPool'
                    cpu = @{
                        smpProcessorAffinityMask = 4294967295
                    }
                }

                Mock Get-WebConfiguration -MockWith {$mockAppPool}

                It 'Should return True when the property matches the desired state' {
                    Test-TargetResource -Ensure 'Present' -Name $mockAppPool.name -cpuSmpProcessorAffinityMask 4294967295 |
                    Should Be $true
                }

                It 'Should return False when the property does not match the desired state' {
                    Test-TargetResource -Ensure 'Present' -Name $mockAppPool.name -cpuSmpProcessorAffinityMask 1 |
                    Should Be $false
                }

            }

            Context 'Test the cpuSmpProcessorAffinityMask2 property' {

                $mockAppPool = @{
                    name = 'MockAppPool'
                    cpu = @{
                        smpProcessorAffinityMask2 = 4294967295
                    }
                }

                Mock Get-WebConfiguration -MockWith {$mockAppPool}

                It 'Should return True when the property matches the desired state' {
                    Test-TargetResource -Ensure 'Present' -Name $mockAppPool.name -cpuSmpProcessorAffinityMask2 4294967295 |
                    Should Be $true
                }

                It 'Should return False when the property does not match the desired state' {
                    Test-TargetResource -Ensure 'Present' -Name $mockAppPool.name -cpuSmpProcessorAffinityMask2 1 |
                    Should Be $false
                }

            }

            Context 'Test the identityType property' {

                $mockAppPool = @{
                    name = 'MockAppPool'
                    processModel = @{
                        identityType = 'ApplicationPoolIdentity'
                    }
                }

                Mock Get-WebConfiguration -MockWith {$mockAppPool}

                It 'Should return True when the property matches the desired state' {
                    Test-TargetResource -Ensure 'Present' -Name $mockAppPool.name -identityType 'ApplicationPoolIdentity' |
                    Should Be $true
                }

                It 'Should return False when the property does not match the desired state' {
                    Test-TargetResource -Ensure 'Present' -Name $mockAppPool.name -identityType 'NetworkService' |
                    Should Be $false
                }

            }

            Context 'Test the Credential property' {

                $mockAppPool = @{
                    name = 'MockAppPool'
                    processModel = @{
                        identityType = 'SpecificUser'
                        password = '1q2w3e4r'
                        userName = 'CONTOSO\JDoe'
                    }
                }

                Mock Get-WebConfiguration -MockWith {$mockAppPool}

                It 'Should return True when both the userName and the password properties match the desired state' {

                    $mockUserName = $mockAppPool.processModel.userName
                    $mockPassword = $mockAppPool.processModel.password | ConvertTo-SecureString -AsPlainText -Force
                    $mockCredential = New-Object -TypeName PSCredential -ArgumentList $mockUserName, $mockPassword

                    Test-TargetResource -Ensure 'Present' -Name $mockAppPool.name -identityType 'SpecificUser' -Credential $mockCredential |
                    Should Be $true

                }

                It 'Should return False when the userName property does not match the desired state' {

                    $mockUserName = 'CONTOSO\GFawkes'
                    $mockPassword = $mockAppPool.processModel.password | ConvertTo-SecureString -AsPlainText -Force
                    $mockCredential = New-Object -TypeName PSCredential -ArgumentList $mockUserName, $mockPassword

                    Test-TargetResource -Ensure 'Present' -Name $mockAppPool.name -identityType 'SpecificUser' -Credential $mockCredential |
                    Should Be $false

                }

                It 'Should return False when the password property does not match the desired state' {

                    $mockUserName = $mockAppPool.processModel.userName
                    $mockPassword = '5t6y7u8i' | ConvertTo-SecureString -AsPlainText -Force
                    $mockCredential = New-Object -TypeName PSCredential -ArgumentList $mockUserName, $mockPassword

                    Test-TargetResource -Ensure 'Present' -Name $mockAppPool.name -identityType 'SpecificUser' -Credential $mockCredential |
                    Should Be $false

                }

            }

            Context 'Test the idleTimeout property' {

                $mockAppPool = @{
                    name = 'MockAppPool'
                    processModel = @{
                        idleTimeout = '00:20:00'
                    }
                }

                Mock Get-WebConfiguration -MockWith {$mockAppPool}

                It 'Should return True when the property matches the desired state' {
                    Test-TargetResource -Ensure 'Present' -Name $mockAppPool.name -idleTimeout '00:20:00' |
                    Should Be $true
                }

                It 'Should return False when the property does not match the desired state' {
                    Test-TargetResource -Ensure 'Present' -Name $mockAppPool.name -idleTimeout '00:15:00' |
                    Should Be $false
                }

            }

            Context 'Test the idleTimeoutAction property' {

                $mockAppPool = @{
                    name = 'MockAppPool'
                    processModel = @{
                        idleTimeoutAction = 'Terminate'
                    }
                }

                Mock Get-WebConfiguration -MockWith {$mockAppPool}

                It 'Should return True when the property matches the desired state' {
                    Test-TargetResource -Ensure 'Present' -Name $mockAppPool.name -idleTimeoutAction 'Terminate' |
                    Should Be $true
                }

                It 'Should return False when the property does not match the desired state' {
                    Test-TargetResource -Ensure 'Present' -Name $mockAppPool.name -idleTimeoutAction 'Suspend' |
                    Should Be $false
                }

            }

            Context 'Test the loadUserProfile property' {

                $mockAppPool = @{
                    name = 'MockAppPool'
                    processModel = @{
                        loadUserProfile = $true
                    }
                }

                Mock Get-WebConfiguration -MockWith {$mockAppPool}

                It 'Should return True when the property matches the desired state' {
                    Test-TargetResource -Ensure 'Present' -Name $mockAppPool.name -loadUserProfile $true |
                    Should Be $true
                }

                It 'Should return False when the property does not match the desired state' {
                    Test-TargetResource -Ensure 'Present' -Name $mockAppPool.name -loadUserProfile $false |
                    Should Be $false
                }

            }

            Context 'Test the logEventOnProcessModel property' {

                $mockAppPool = @{
                    name = 'MockAppPool'
                    processModel = @{
                        logEventOnProcessModel = 'IdleTimeout'
                    }
                }

                Mock Get-WebConfiguration -MockWith {$mockAppPool}

                It 'Should return True when the property matches the desired state' {
                    Test-TargetResource -Ensure 'Present' -Name $mockAppPool.name -logEventOnProcessModel 'IdleTimeout' |
                    Should Be $true
                }

                It 'Should return False when the property does not match the desired state' {
                    Test-TargetResource -Ensure 'Present' -Name $mockAppPool.name -logEventOnProcessModel '' |
                    Should Be $false
                }

            }

            Context 'Test the logonType property' {

                $mockAppPool = @{
                    name = 'MockAppPool'
                    processModel = @{
                        logonType = 'LogonBatch'
                    }
                }

                Mock Get-WebConfiguration -MockWith {$mockAppPool}

                It 'Should return True when the property matches the desired state' {
                    Test-TargetResource -Ensure 'Present' -Name $mockAppPool.name -logonType 'LogonBatch' |
                    Should Be $true
                }

                It 'Should return False when the property does not match the desired state' {
                    Test-TargetResource -Ensure 'Present' -Name $mockAppPool.name -logonType 'LogonService' |
                    Should Be $false
                }

            }

            Context 'Test the manualGroupMembership property' {

                $mockAppPool = @{
                    name = 'MockAppPool'
                    processModel = @{
                        manualGroupMembership = $false
                    }
                }

                Mock Get-WebConfiguration -MockWith {$mockAppPool}

                It 'Should return True when the property matches the desired state' {
                    Test-TargetResource -Ensure 'Present' -Name $mockAppPool.name -manualGroupMembership $false |
                    Should Be $true
                }

                It 'Should return False when the property does not match the desired state' {
                    Test-TargetResource -Ensure 'Present' -Name $mockAppPool.name -manualGroupMembership $true |
                    Should Be $false
                }

            }

            Context 'Test the maxProcesses property' {

                $mockAppPool = @{
                    name = 'MockAppPool'
                    processModel = @{
                        maxProcesses = 1
                    }
                }

                Mock Get-WebConfiguration -MockWith {$mockAppPool}

                It 'Should return True when the property matches the desired state' {
                    Test-TargetResource -Ensure 'Present' -Name $mockAppPool.name -maxProcesses 1 |
                    Should Be $true
                }

                It 'Should return False when the property does not match the desired state' {
                    Test-TargetResource -Ensure 'Present' -Name $mockAppPool.name -maxProcesses 2 |
                    Should Be $false
                }

            }

            Context 'Test the pingingEnabled property' {

                $mockAppPool = @{
                    name = 'MockAppPool'
                    processModel = @{
                        pingingEnabled = $true
                    }
                }

                Mock Get-WebConfiguration -MockWith {$mockAppPool}

                It 'Should return True when the property matches the desired state' {
                    Test-TargetResource -Ensure 'Present' -Name $mockAppPool.name -pingingEnabled $true |
                    Should Be $true
                }

                It 'Should return False when the property does not match the desired state' {
                    Test-TargetResource -Ensure 'Present' -Name $mockAppPool.name -pingingEnabled $false |
                    Should Be $false
                }

            }

            Context 'Test the pingInterval property' {

                $mockAppPool = @{
                    name = 'MockAppPool'
                    processModel = @{
                        pingInterval = '00:00:30'
                    }
                }

                Mock Get-WebConfiguration -MockWith {$mockAppPool}

                It 'Should return True when the property matches the desired state' {
                    Test-TargetResource -Ensure 'Present' -Name $mockAppPool.name -pingInterval '00:00:30' |
                    Should Be $true
                }

                It 'Should return False when the property does not match the desired state' {
                    Test-TargetResource -Ensure 'Present' -Name $mockAppPool.name -pingInterval '00:01:00' |
                    Should Be $false
                }

            }

            Context 'Test the pingResponseTime property' {

                $mockAppPool = @{
                    name = 'MockAppPool'
                    processModel = @{
                        pingResponseTime = '00:01:30'
                    }
                }

                Mock Get-WebConfiguration -MockWith {$mockAppPool}

                It 'Should return True when the property matches the desired state' {
                    Test-TargetResource -Ensure 'Present' -Name $mockAppPool.name -pingResponseTime '00:01:30' |
                    Should Be $true
                }

                It 'Should return False when the property does not match the desired state' {
                    Test-TargetResource -Ensure 'Present' -Name $mockAppPool.name -pingResponseTime '00:02:00' |
                    Should Be $false
                }

            }

            Context 'Test the setProfileEnvironment property' {

                $mockAppPool = @{
                    name = 'MockAppPool'
                    processModel = @{
                        setProfileEnvironment = $false
                    }
                }

                Mock Get-WebConfiguration -MockWith {$mockAppPool}

                It 'Should return True when the property matches the desired state' {
                    Test-TargetResource -Ensure 'Present' -Name $mockAppPool.name -setProfileEnvironment $false |
                    Should Be $true
                }

                It 'Should return False when the property does not match the desired state' {
                    Test-TargetResource -Ensure 'Present' -Name $mockAppPool.name -setProfileEnvironment $true |
                    Should Be $false
                }

            }

            Context 'Test the shutdownTimeLimit property' {

                $mockAppPool = @{
                    name = 'MockAppPool'
                    processModel = @{
                        shutdownTimeLimit = '00:01:30'
                    }
                }

                Mock Get-WebConfiguration -MockWith {$mockAppPool}

                It 'Should return True when the property matches the desired state' {
                    Test-TargetResource -Ensure 'Present' -Name $mockAppPool.name -shutdownTimeLimit '00:01:30' |
                    Should Be $true
                }

                It 'Should return False when the property does not match the desired state' {
                    Test-TargetResource -Ensure 'Present' -Name $mockAppPool.name -shutdownTimeLimit '00:02:00' |
                    Should Be $false
                }

            }

            Context 'Test the startupTimeLimit property' {

                $mockAppPool = @{
                    name = 'MockAppPool'
                    processModel = @{
                        startupTimeLimit = '00:01:30'
                    }
                }

                Mock Get-WebConfiguration -MockWith {$mockAppPool}

                It 'Should return True when the property matches the desired state' {
                    Test-TargetResource -Ensure 'Present' -Name $mockAppPool.name -startupTimeLimit '00:01:30' |
                    Should Be $true
                }

                It 'Should return False when the property does not match the desired state' {
                    Test-TargetResource -Ensure 'Present' -Name $mockAppPool.name -startupTimeLimit '00:02:00' |
                    Should Be $false
                }

            }

            Context 'Test the orphanActionExe property' {

                $mockAppPool = @{
                    name = 'MockAppPool'
                    failure = @{
                        orphanActionExe = ''
                    }
                }

                Mock Get-WebConfiguration -MockWith {$mockAppPool}

                It 'Should return True when the property matches the desired state' {
                    Test-TargetResource -Ensure 'Present' -Name $mockAppPool.name -orphanActionExe '' |
                    Should Be $true
                }

                It 'Should return False when the property does not match the desired state' {
                    Test-TargetResource -Ensure 'Present' -Name $mockAppPool.name -orphanActionExe 'C:\inetpub\temp\orphanAction.exe' |
                    Should Be $false
                }

            }

            Context 'Test the orphanActionParams property' {

                $mockAppPool = @{
                    name = 'MockAppPool'
                    failure = @{
                        orphanActionParams = ''
                    }
                }

                Mock Get-WebConfiguration -MockWith {$mockAppPool}

                It 'Should return True when the property matches the desired state' {
                    Test-TargetResource -Ensure 'Present' -Name $mockAppPool.name -orphanActionParams '' |
                    Should Be $true
                }

                It 'Should return False when the property does not match the desired state' {
                    Test-TargetResource -Ensure 'Present' -Name $mockAppPool.name -orphanActionParams '/orphanActionParam1' |
                    Should Be $false
                }

            }

            Context 'Test the orphanWorkerProcess property' {

                $mockAppPool = @{
                    name = 'MockAppPool'
                    failure = @{
                        orphanWorkerProcess = $false
                    }
                }

                Mock Get-WebConfiguration -MockWith {$mockAppPool}

                It 'Should return True when the property matches the desired state' {
                    Test-TargetResource -Ensure 'Present' -Name $mockAppPool.name -orphanWorkerProcess $false |
                    Should Be $true
                }

                It 'Should return False when the property does not match the desired state' {
                    Test-TargetResource -Ensure 'Present' -Name $mockAppPool.name -orphanWorkerProcess $true |
                    Should Be $false
                }

            }

            Context 'Test the loadBalancerCapabilities property' {

                $mockAppPool = @{
                    name = 'MockAppPool'
                    failure = @{
                        loadBalancerCapabilities = 'HttpLevel'
                    }
                }

                Mock Get-WebConfiguration -MockWith {$mockAppPool}

                It 'Should return True when the property matches the desired state' {
                    Test-TargetResource -Ensure 'Present' -Name $mockAppPool.name -loadBalancerCapabilities 'HttpLevel' |
                    Should Be $true
                }

                It 'Should return False when the property does not match the desired state' {
                    Test-TargetResource -Ensure 'Present' -Name $mockAppPool.name -loadBalancerCapabilities 'TcpLevel' |
                    Should Be $false
                }

            }

            Context 'Test the rapidFailProtection property' {

                $mockAppPool = @{
                    name = 'MockAppPool'
                    failure = @{
                        rapidFailProtection = $true
                    }
                }

                Mock Get-WebConfiguration -MockWith {$mockAppPool}

                It 'Should return True when the property matches the desired state' {
                    Test-TargetResource -Ensure 'Present' -Name $mockAppPool.name -rapidFailProtection $true |
                    Should Be $true
                }

                It 'Should return False when the property does not match the desired state' {
                    Test-TargetResource -Ensure 'Present' -Name $mockAppPool.name -rapidFailProtection $false |
                    Should Be $false
                }

            }

            Context 'Test the rapidFailProtectionInterval property' {

                $mockAppPool = @{
                    name = 'MockAppPool'
                    failure = @{
                        rapidFailProtectionInterval = '00:05:00'
                    }
                }

                Mock Get-WebConfiguration -MockWith {$mockAppPool}

                It 'Should return True when the property matches the desired state' {
                    Test-TargetResource -Ensure 'Present' -Name $mockAppPool.name -rapidFailProtectionInterval '00:05:00' |
                    Should Be $true
                }

                It 'Should return False when the property does not match the desired state' {
                    Test-TargetResource -Ensure 'Present' -Name $mockAppPool.name -rapidFailProtectionInterval '00:10:00' |
                    Should Be $false
                }

            }

            Context 'Test the rapidFailProtectionMaxCrashes property' {

                $mockAppPool = @{
                    name = 'MockAppPool'
                    failure = @{
                        rapidFailProtectionMaxCrashes = 5
                    }
                }

                Mock Get-WebConfiguration -MockWith {$mockAppPool}

                It 'Should return True when the property matches the desired state' {
                    Test-TargetResource -Ensure 'Present' -Name $mockAppPool.name -rapidFailProtectionMaxCrashes 5 |
                    Should Be $true
                }

                It 'Should return False when the property does not match the desired state' {
                    Test-TargetResource -Ensure 'Present' -Name $mockAppPool.name -rapidFailProtectionMaxCrashes 10 |
                    Should Be $false
                }

            }

            Context 'Test the autoShutdownExe property' {

                $mockAppPool = @{
                    name = 'MockAppPool'
                    failure = @{
                        autoShutdownExe = ''
                    }
                }

                Mock Get-WebConfiguration -MockWith {$mockAppPool}

                It 'Should return True when the property matches the desired state' {
                    Test-TargetResource -Ensure 'Present' -Name $mockAppPool.name -autoShutdownExe '' |
                    Should Be $true
                }

                It 'Should return False when the property does not match the desired state' {
                    Test-TargetResource -Ensure 'Present' -Name $mockAppPool.name -autoShutdownExe 'C:\inetpub\temp\autoShutdown.exe' |
                    Should Be $false
                }

            }

            Context 'Test the autoShutdownParams property' {

                $mockAppPool = @{
                    name = 'MockAppPool'
                    failure = @{
                        autoShutdownParams = ''
                    }
                }

                Mock Get-WebConfiguration -MockWith {$mockAppPool}

                It 'Should return True when the property matches the desired state' {
                    Test-TargetResource -Ensure 'Present' -Name $mockAppPool.name -autoShutdownParams '' |
                    Should Be $true
                }

                It 'Should return False when the property does not match the desired state' {
                    Test-TargetResource -Ensure 'Present' -Name $mockAppPool.name -autoShutdownParams '/autoShutdownParam1' |
                    Should Be $false
                }

            }

            Context 'Test the disallowOverlappingRotation property' {

                $mockAppPool = @{
                    name = 'MockAppPool'
                    recycling = @{
                        disallowOverlappingRotation = $false
                    }
                }

                Mock Get-WebConfiguration -MockWith {$mockAppPool}

                It 'Should return True when the property matches the desired state' {
                    Test-TargetResource -Ensure 'Present' -Name $mockAppPool.name -disallowOverlappingRotation $false |
                    Should Be $true
                }

                It 'Should return False when the property does not match the desired state' {
                    Test-TargetResource -Ensure 'Present' -Name $mockAppPool.name -disallowOverlappingRotation $true |
                    Should Be $false
                }

            }

            Context 'Test the disallowRotationOnConfigChange property' {

                $mockAppPool = @{
                    name = 'MockAppPool'
                    recycling = @{
                        disallowRotationOnConfigChange = $false
                    }
                }

                Mock Get-WebConfiguration -MockWith {$mockAppPool}

                It 'Should return True when the property matches the desired state' {
                    Test-TargetResource -Ensure 'Present' -Name $mockAppPool.name -disallowRotationOnConfigChange $false |
                    Should Be $true
                }

                It 'Should return False when the property does not match the desired state' {
                    Test-TargetResource -Ensure 'Present' -Name $mockAppPool.name -disallowRotationOnConfigChange $true |
                    Should Be $false
                }

            }

            Context 'Test the logEventOnRecycle property' {

                $mockAppPool = @{
                    name = 'MockAppPool'
                    recycling = @{
                        logEventOnRecycle = 'Time,Requests,Schedule,Memory,IsapiUnhealthy,OnDemand,ConfigChange,PrivateMemory'
                    }
                }

                Mock Get-WebConfiguration -MockWith {$mockAppPool}

                It 'Should return True when the property matches the desired state' {
                    Test-TargetResource -Ensure 'Present' -Name $mockAppPool.name -logEventOnRecycle 'Time,Requests,Schedule,Memory,IsapiUnhealthy,OnDemand,ConfigChange,PrivateMemory' |
                    Should Be $true
                }

                It 'Should return False when the property does not match the desired state' {
                    Test-TargetResource -Ensure 'Present' -Name $mockAppPool.name -logEventOnRecycle 'Time,Memory,PrivateMemory' |
                    Should Be $false
                }

            }

            Context 'Test the restartMemoryLimit property' {

                $mockAppPool = @{
                    name = 'MockAppPool'
                    recycling = @{
                        periodicRestart = @{
                            memory = 0
                        }
                    }
                }

                Mock Get-WebConfiguration -MockWith {$mockAppPool}

                It 'Should return True when the property matches the desired state' {
                    Test-TargetResource -Ensure 'Present' -Name $mockAppPool.name -restartMemoryLimit 0 |
                    Should Be $true
                }

                It 'Should return False when the property does not match the desired state' {
                    Test-TargetResource -Ensure 'Present' -Name $mockAppPool.name -restartMemoryLimit 1048576 |
                    Should Be $false
                }

            }

            Context 'Test the restartPrivateMemoryLimit property' {

                $mockAppPool = @{
                    name = 'MockAppPool'
                    recycling = @{
                        periodicRestart = @{
                            privateMemory = 0
                        }
                    }
                }

                Mock Get-WebConfiguration -MockWith {$mockAppPool}

                It 'Should return True when the property matches the desired state' {
                    Test-TargetResource -Ensure 'Present' -Name $mockAppPool.name -restartPrivateMemoryLimit 0 |
                    Should Be $true
                }

                It 'Should return False when the property does not match the desired state' {
                    Test-TargetResource -Ensure 'Present' -Name $mockAppPool.name -restartPrivateMemoryLimit 1048576 |
                    Should Be $false
                }

            }

            Context 'Test the restartRequestsLimit property' {

                $mockAppPool = @{
                    name = 'MockAppPool'
                    recycling = @{
                        periodicRestart = @{
                            requests = 0
                        }
                    }
                }

                Mock Get-WebConfiguration -MockWith {$mockAppPool}

                It 'Should return True when the property matches the desired state' {
                    Test-TargetResource -Ensure 'Present' -Name $mockAppPool.name -restartRequestsLimit 0 |
                    Should Be $true
                }

                It 'Should return False when the property does not match the desired state' {
                    Test-TargetResource -Ensure 'Present' -Name $mockAppPool.name -restartRequestsLimit 1000 |
                    Should Be $false
                }

            }

            Context 'Test the restartTimeLimit property' {

                $mockAppPool = @{
                    name = 'MockAppPool'
                    recycling = @{
                        periodicRestart = @{
                            time = '1.05:00:00'
                        }
                    }
                }

                Mock Get-WebConfiguration -MockWith {$mockAppPool}

                It 'Should return True when the property matches the desired state' {
                    Test-TargetResource -Ensure 'Present' -Name $mockAppPool.name -restartTimeLimit '1.05:00:00' |
                    Should Be $true
                }

                It 'Should return False when the property does not match the desired state' {
                    Test-TargetResource -Ensure 'Present' -Name $mockAppPool.name -restartTimeLimit '2.10:00:00' |
                    Should Be $false
                }

            }

            Context 'Test the restartSchedule property' {

                $mockAppPool = @{
                    name = 'MockAppPool'
                    recycling = @{
                        periodicRestart = @{
                            schedule = @{
                                Collection = @(
                                    @{value = '04:00:00'}
                                    @{value = '08:00:00'}
                                )
                            }
                        }
                    }
                }

                Mock Get-WebConfiguration -MockWith {$mockAppPool}

                It 'Should return True when the property matches the desired state' {
                    Test-TargetResource -Ensure 'Present' -Name $mockAppPool.name -restartSchedule @('04:00:00', '08:00:00') |
                    Should Be $true
                }

                It 'Should return False when the property does not match the desired state' {
                    Test-TargetResource -Ensure 'Present' -Name $mockAppPool.name -restartSchedule @('') |
                    Should Be $false
                }

            }

        }

        Describe "how '$($script:DSCResourceName)\Set-TargetResource' responds to Ensure = 'Absent'" {

            Mock -CommandName Assert-Module -MockWith {}

            Context 'Application pool exists and is started' {

                $mockAppPool = @{
                    name = 'MockAppPool'
                    state = 'Started'
                }

                Mock Get-WebConfiguration -MockWith {$mockAppPool}
                Mock Stop-WebAppPool
                Mock Remove-WebAppPool

                Set-TargetResource -Ensure 'Absent' -Name $mockAppPool.name

                It 'Should call Stop-WebAppPool' {
                    Assert-MockCalled Stop-WebAppPool -Exactly 1
                }

                It 'Should call Remove-WebAppPool' {
                    Assert-MockCalled Remove-WebAppPool -Exactly 1
                }

                It 'Should throw if Stop-WebAppPool fails' {

                    Mock Stop-WebAppPool -MockWith {throw}

                    {Set-TargetResource -Ensure 'Absent' -Name $mockAppPool.name} |
                    Should Throw

                }

                It 'Should throw if Remove-WebAppPool fails' {

                    Mock Stop-WebAppPool
                    Mock Remove-WebAppPool -MockWith {throw}

                    {Set-TargetResource -Ensure 'Absent' -Name $mockAppPool.name} |
                    Should Throw

                }

            }

            Context 'Application pool exists and is stopped' {

                $mockAppPool = @{
                    name = 'MockAppPool'
                    state = 'Stopped'
                }

                Mock Get-WebConfiguration -MockWith {$mockAppPool}
                Mock Stop-WebAppPool
                Mock Remove-WebAppPool

                Set-TargetResource -Ensure 'Absent' -Name $mockAppPool.name

                It 'Should not call Stop-WebAppPool' {
                    Assert-MockCalled Stop-WebAppPool -Exactly 0
                }

                It 'Should call Remove-WebAppPool' {
                    Assert-MockCalled Remove-WebAppPool -Exactly 1
                }

                It 'Should throw if Remove-WebAppPool fails' {

                    Mock Remove-WebAppPool -MockWith {throw}

                    {Set-TargetResource -Ensure 'Absent' -Name $mockAppPool.name} |
                    Should Throw

                }

            }

        }

        Describe "how '$($script:DSCResourceName)\Set-TargetResource' responds to Ensure = 'Present'" {

            Mock -CommandName Assert-Module -MockWith {}

            Context 'Application pool does not exist' {

                $mockAppPool = @{
                    name = 'MockAppPool'
                }

                Mock Get-WebConfiguration
                Mock New-WebAppPool -MockWith {$mockAppPool}
                Mock Start-Sleep

                It 'Should call New-WebAppPool' {
                    Set-TargetResource -Ensure 'Present' -Name $mockAppPool.Name
                    Assert-MockCalled New-WebAppPool -Exactly 1
                }

                It 'Should throw if New-WebAppPool fails' {

                    Mock New-WebAppPool -MockWith {throw}

                    {Set-TargetResource -Ensure 'Present' -Name $mockAppPool.Name} |
                    Should Throw

                }

            }

            Context 'All the properties need to be set' {

                $mockAppPool = @{
                    name = 'MockAppPool'
                    state = 'Started'
                    autoStart = $true
                    CLRConfigFile = ''
                    enable32BitAppOnWin64 = $false
                    enableConfigurationOverride = $true
                    managedPipelineMode = 'Integrated'
                    managedRuntimeLoader = 'webengine4.dll'
                    managedRuntimeVersion = 'v4.0'
                    passAnonymousToken = $true
                    startMode = 'OnDemand'
                    queueLength = 1000
                    cpu = @{
                        action = 'NoAction'
                        limit = 0
                        resetInterval = '00:05:00'
                        smpAffinitized = $false
                        smpProcessorAffinityMask = 4294967295
                        smpProcessorAffinityMask2 = 4294967295
                    }
                    processModel = @{
                        identityType = 'ApplicationPoolIdentity'
                        idleTimeout = '00:20:00'
                        idleTimeoutAction = 'Terminate'
                        loadUserProfile = $true
                        logEventOnProcessModel = 'IdleTimeout'
                        logonType = 'LogonBatch'
                        manualGroupMembership = $false
                        maxProcesses = 1
                        password = ''
                        pingingEnabled = $true
                        pingInterval = '00:00:30'
                        pingResponseTime = '00:01:30'
                        setProfileEnvironment = $false
                        shutdownTimeLimit = '00:01:30'
                        startupTimeLimit = '00:01:30'
                        userName = ''
                    }
                    failure = @{
                        orphanActionExe = ''
                        orphanActionParams = ''
                        orphanWorkerProcess = $false
                        loadBalancerCapabilities = 'HttpLevel'
                        rapidFailProtection = $true
                        rapidFailProtectionInterval = '00:05:00'
                        rapidFailProtectionMaxCrashes = 5
                        autoShutdownExe = ''
                        autoShutdownParams = ''
                    }
                    recycling = @{
                        disallowOverlappingRotation = $false
                        disallowRotationOnConfigChange = $false
                        logEventOnRecycle = 'Time,Requests,Schedule,Memory,IsapiUnhealthy,OnDemand,ConfigChange,PrivateMemory'
                        periodicRestart = @{
                            memory = 0
                            privateMemory = 0
                            requests = 0
                            time = '1.05:00:00'
                            schedule = @{
                                Collection = @(
                                    @{value = '02:00:00'}
                                    @{value = '04:00:00'}
                                )
                            }
                        }
                    }
                }

                Mock Get-WebConfiguration -MockWith {$mockAppPool}

                $mockUserName = 'CONTOSO\GFawkes'
                $mockPassword = '5t6y7u8i' | ConvertTo-SecureString -AsPlainText -Force
                $mockCredential = New-Object -TypeName PSCredential -ArgumentList $mockUserName, $mockPassword

                $setParamsSplat = @{
                    Name = $mockAppPool.name
                    State = 'Stopped'
                    autoStart = $false
                    CLRConfigFile = 'C:\inetpub\temp\aspnet.config'
                    enable32BitAppOnWin64 = $true
                    enableConfigurationOverride = $false
                    managedPipelineMode = 'Classic'
                    managedRuntimeLoader = ''
                    managedRuntimeVersion = 'v2.0'
                    passAnonymousToken = $false
                    startMode = 'AlwaysRunning'
                    queueLength = 2000
                    cpuAction = 'KillW3wp'
                    cpuLimit = 90000
                    cpuResetInterval = '00:10:00'
                    cpuSmpAffinitized = $true
                    cpuSmpProcessorAffinityMask = 1
                    cpuSmpProcessorAffinityMask2 = 1
                    identityType = 'SpecificUser'
                    Credential = $mockCredential
                    idleTimeout = '00:15:00'
                    idleTimeoutAction = 'Suspend'
                    loadUserProfile = $false
                    logEventOnProcessModel = ''
                    logonType = 'LogonService'
                    manualGroupMembership = $true
                    maxProcesses = 2
                    pingingEnabled = $false
                    pingInterval = '00:01:00'
                    pingResponseTime = '00:02:00'
                    setProfileEnvironment = $true
                    shutdownTimeLimit = '00:02:00'
                    startupTimeLimit = '00:02:00'
                    orphanActionExe = 'C:\inetpub\temp\orphanAction.exe'
                    orphanActionParams = '/orphanActionParam1'
                    orphanWorkerProcess = $true
                    loadBalancerCapabilities = 'TcpLevel'
                    rapidFailProtection = $false
                    rapidFailProtectionInterval = '00:10:00'
                    rapidFailProtectionMaxCrashes = 10
                    autoShutdownExe = 'C:\inetpub\temp\autoShutdown.exe'
                    autoShutdownParams = '/autoShutdownParam1'
                    disallowOverlappingRotation = $true
                    disallowRotationOnConfigChange = $true
                    logEventOnRecycle = 'Time,Memory,PrivateMemory'
                    restartMemoryLimit = 1048576
                    restartPrivateMemoryLimit = 1048576
                    restartRequestsLimit = 1000
                    restartTimeLimit = '2.10:00:00'
                    restartSchedule = @('06:00:00', '08:00:00')
                }

                Mock Stop-WebAppPool
                Mock Invoke-AppCmd

                Set-TargetResource -Ensure 'Present' @setParamsSplat

                It 'Should call all the mocks' {
                    Assert-MockCalled Stop-WebAppPool -Exactly 1
                    Assert-MockCalled Invoke-AppCmd -Exactly 52
                }

            }

            Context 'The State property needs to be set to Started' {

                $mockAppPool = @{
                    name = 'MockAppPool'
                    state = 'Stopped'
                }

                Mock Get-WebConfiguration -MockWith {$mockAppPool}

                It 'Should call Start-WebAppPool' {
                    Mock Start-WebAppPool
                    Set-TargetResource -Ensure 'Present' -Name $mockAppPool.name -State 'Started'
                    Assert-MockCalled Start-WebAppPool -Exactly 1
                }

                It 'Should throw if Start-WebAppPool fails' {

                    Mock Start-WebAppPool -MockWith {throw}

                    {Set-TargetResource -Ensure 'Present' -Name $mockAppPool.name -State 'Started'} |
                    Should Throw

                }

            }

            Context 'The State property needs to be set to Stopped' {

                $mockAppPool = @{
                    name = 'MockAppPool'
                    state = 'Started'
                }

                Mock Get-WebConfiguration -MockWith {$mockAppPool}

                It 'Should call Stop-WebAppPool' {
                    Mock Stop-WebAppPool
                    Set-TargetResource -Ensure 'Present' -Name $mockAppPool.name -State 'Stopped'
                    Assert-MockCalled Stop-WebAppPool -Exactly 1
                }

                It 'Should throw if Stop-WebAppPool fails' {

                    Mock Stop-WebAppPool -MockWith {throw}

                    {Set-TargetResource -Ensure 'Present' -Name $mockAppPool.name -State 'Stopped'} |
                    Should Throw

                }

            }

            Context 'The autoStart property needs to be set' {

                $mockAppPool = @{
                    name = 'MockAppPool'
                    autoStart = $true
                }

                Mock Get-WebConfiguration -MockWith {$mockAppPool}

                $setParamsSplat = @{
                    Ensure = 'Present'
                    Name = $mockAppPool.name
                    autoStart = $false
                }

                Mock Invoke-AppCmd -ParameterFilter {$ArgumentList[-1] -eq '/autoStart:False'}

                Set-TargetResource @setParamsSplat

                It 'Should call Invoke-AppCmd' {
                    Assert-MockCalled Invoke-AppCmd -Exactly 1
                }

            }

            Context 'The CLRConfigFile property needs to be set' {

                $mockAppPool = @{
                    name = 'MockAppPool'
                    CLRConfigFile = ''
                }

                Mock Get-WebConfiguration -MockWith {$mockAppPool}

                $setParamsSplat = @{
                    Ensure = 'Present'
                    Name = $mockAppPool.name
                    CLRConfigFile = 'C:\inetpub\temp\aspnet.config'
                }

                Mock Invoke-AppCmd -ParameterFilter {$ArgumentList[-1] -eq '/CLRConfigFile:C:\inetpub\temp\aspnet.config'}

                Set-TargetResource @setParamsSplat

                It 'Should call Invoke-AppCmd' {
                    Assert-MockCalled Invoke-AppCmd -Exactly 1
                }

            }

            Context 'The enable32BitAppOnWin64 property needs to be set' {

                $mockAppPool = @{
                    name = 'MockAppPool'
                    enable32BitAppOnWin64 = $false
                }

                Mock Get-WebConfiguration -MockWith {$mockAppPool}

                $setParamsSplat = @{
                    Ensure = 'Present'
                    Name = $mockAppPool.name
                    enable32BitAppOnWin64 = $true
                }

                Mock Invoke-AppCmd -ParameterFilter {$ArgumentList[-1] -eq '/enable32BitAppOnWin64:True'}

                Set-TargetResource @setParamsSplat

                It 'Should call Invoke-AppCmd' {
                    Assert-MockCalled Invoke-AppCmd -Exactly 1
                }

            }

            Context 'The enableConfigurationOverride property needs to be set' {

                $mockAppPool = @{
                    name = 'MockAppPool'
                    enableConfigurationOverride = $true
                }

                Mock Get-WebConfiguration -MockWith {$mockAppPool}

                $setParamsSplat = @{
                    Ensure = 'Present'
                    Name = $mockAppPool.name
                    enableConfigurationOverride = $false
                }

                Mock Invoke-AppCmd -ParameterFilter {$ArgumentList[-1] -eq '/enableConfigurationOverride:False'}

                Set-TargetResource @setParamsSplat

                It 'Should call Invoke-AppCmd' {
                    Assert-MockCalled Invoke-AppCmd -Exactly 1
                }

            }

            Context 'The managedPipelineMode property needs to be set' {

                $mockAppPool = @{
                    name = 'MockAppPool'
                    managedPipelineMode = 'Integrated'
                }

                Mock Get-WebConfiguration -MockWith {$mockAppPool}

                $setParamsSplat = @{
                    Ensure = 'Present'
                    Name = $mockAppPool.name
                    managedPipelineMode = 'Classic'
                }

                Mock Invoke-AppCmd -ParameterFilter {$ArgumentList[-1] -eq '/managedPipelineMode:Classic'}

                Set-TargetResource @setParamsSplat

                It 'Should call Invoke-AppCmd' {
                    Assert-MockCalled Invoke-AppCmd -Exactly 1
                }

            }

            Context 'The managedRuntimeLoader property needs to be set' {

                $mockAppPool = @{
                    name = 'MockAppPool'
                    managedRuntimeLoader = 'webengine4.dll'
                }

                Mock Get-WebConfiguration -MockWith {$mockAppPool}

                $setParamsSplat = @{
                    Ensure = 'Present'
                    Name = $mockAppPool.name
                    managedRuntimeLoader = ''
                }

                Mock Invoke-AppCmd -ParameterFilter {$ArgumentList[-1] -eq '/managedRuntimeLoader:'}

                Set-TargetResource @setParamsSplat

                It 'Should call Invoke-AppCmd' {
                    Assert-MockCalled Invoke-AppCmd -Exactly 1
                }

            }

            Context 'The managedRuntimeVersion property needs to be set' {

                $mockAppPool = @{
                    name = 'MockAppPool'
                    managedRuntimeVersion = 'v4.0'
                }

                Mock Get-WebConfiguration -MockWith {$mockAppPool}

                $setParamsSplat = @{
                    Ensure = 'Present'
                    Name = $mockAppPool.name
                    managedRuntimeVersion = 'v2.0'
                }

                Mock Invoke-AppCmd -ParameterFilter {$ArgumentList[-1] -eq '/managedRuntimeVersion:v2.0'}

                Set-TargetResource @setParamsSplat

                It 'Should call Invoke-AppCmd' {
                    Assert-MockCalled Invoke-AppCmd -Exactly 1
                }

            }

            Context 'The passAnonymousToken property needs to be set' {

                $mockAppPool = @{
                    name = 'MockAppPool'
                    passAnonymousToken = $true
                }

                Mock Get-WebConfiguration -MockWith {$mockAppPool}

                $setParamsSplat = @{
                    Ensure = 'Present'
                    Name = $mockAppPool.name
                    passAnonymousToken = $false
                }

                Mock Invoke-AppCmd -ParameterFilter {$ArgumentList[-1] -eq '/passAnonymousToken:False'}

                Set-TargetResource @setParamsSplat

                It 'Should call Invoke-AppCmd' {
                    Assert-MockCalled Invoke-AppCmd -Exactly 1
                }

            }

            Context 'The startMode property needs to be set' {

                $mockAppPool = @{
                    name = 'MockAppPool'
                    startMode = 'OnDemand'
                }

                Mock Get-WebConfiguration -MockWith {$mockAppPool}

                $setParamsSplat = @{
                    Ensure = 'Present'
                    Name = $mockAppPool.name
                    startMode = 'AlwaysRunning'
                }

                Mock Invoke-AppCmd -ParameterFilter {$ArgumentList[-1] -eq '/startMode:AlwaysRunning'}

                Set-TargetResource @setParamsSplat

                It 'Should call Invoke-AppCmd' {
                    Assert-MockCalled Invoke-AppCmd -Exactly 1
                }

            }

            Context 'The queueLength property needs to be set' {

                $mockAppPool = @{
                    name = 'MockAppPool'
                    queueLength = 1000
                }

                Mock Get-WebConfiguration -MockWith {$mockAppPool}

                $setParamsSplat = @{
                    Ensure = 'Present'
                    Name = $mockAppPool.name
                    queueLength = 2000
                }

                Mock Invoke-AppCmd -ParameterFilter {$ArgumentList[-1] -eq '/queueLength:2000'}

                Set-TargetResource @setParamsSplat

                It 'Should call Invoke-AppCmd' {
                    Assert-MockCalled Invoke-AppCmd -Exactly 1
                }

            }

            Context 'The cpuAction property needs to be set' {

                $mockAppPool = @{
                    name = 'MockAppPool'
                    cpu = @{
                        action = 'NoAction'
                    }
                }

                Mock Get-WebConfiguration -MockWith {$mockAppPool}

                $setParamsSplat = @{
                    Ensure = 'Present'
                    Name = $mockAppPool.name
                    cpuAction = 'KillW3wp'
                }

                Mock Invoke-AppCmd -ParameterFilter {$ArgumentList[-1] -eq '/cpu.action:KillW3wp'}

                Set-TargetResource @setParamsSplat

                It 'Should call Invoke-AppCmd' {
                    Assert-MockCalled Invoke-AppCmd -Exactly 1
                }

            }

            Context 'The cpuLimit property needs to be set' {

                $mockAppPool = @{
                    name = 'MockAppPool'
                    cpu = @{
                        limit = 0
                    }
                }

                Mock Get-WebConfiguration -MockWith {$mockAppPool}

                $setParamsSplat = @{
                    Ensure = 'Present'
                    Name = $mockAppPool.name
                    cpuLimit = 90000
                }

                Mock Invoke-AppCmd -ParameterFilter {$ArgumentList[-1] -eq '/cpu.limit:90000'}

                Set-TargetResource @setParamsSplat

                It 'Should call Invoke-AppCmd' {
                    Assert-MockCalled Invoke-AppCmd -Exactly 1
                }

            }

            Context 'The cpuResetInterval property needs to be set' {

                $mockAppPool = @{
                    name = 'MockAppPool'
                    cpu = @{
                        resetInterval = '00:05:00'
                    }
                }

                Mock Get-WebConfiguration -MockWith {$mockAppPool}

                $setParamsSplat = @{
                    Ensure = 'Present'
                    Name = $mockAppPool.name
                    cpuResetInterval = '00:10:00'
                }

                Mock Invoke-AppCmd -ParameterFilter {$ArgumentList[-1] -eq '/cpu.resetInterval:00:10:00'}

                Set-TargetResource @setParamsSplat

                It 'Should call Invoke-AppCmd' {
                    Assert-MockCalled Invoke-AppCmd -Exactly 1
                }

            }

            Context 'The cpuSmpAffinitized property needs to be set' {

                $mockAppPool = @{
                    name = 'MockAppPool'
                    cpu = @{
                        smpAffinitized = $false
                    }
                }

                Mock Get-WebConfiguration -MockWith {$mockAppPool}

                $setParamsSplat = @{
                    Ensure = 'Present'
                    Name = $mockAppPool.name
                    cpuSmpAffinitized = $true
                }

                Mock Invoke-AppCmd -ParameterFilter {$ArgumentList[-1] -eq '/cpu.smpAffinitized:True'}

                Set-TargetResource @setParamsSplat

                It 'Should call Invoke-AppCmd' {
                    Assert-MockCalled Invoke-AppCmd -Exactly 1
                }

            }

            Context 'The cpuSmpProcessorAffinityMask property needs to be set' {

                $mockAppPool = @{
                    name = 'MockAppPool'
                    cpu = @{
                        smpProcessorAffinityMask = 4294967295
                    }
                }

                Mock Get-WebConfiguration -MockWith {$mockAppPool}

                $setParamsSplat = @{
                    Ensure = 'Present'
                    Name = $mockAppPool.name
                    cpuSmpProcessorAffinityMask = 1
                }

                Mock Invoke-AppCmd -ParameterFilter {$ArgumentList[-1] -eq '/cpu.smpProcessorAffinityMask:1'}

                Set-TargetResource @setParamsSplat

                It 'Should call Invoke-AppCmd' {
                    Assert-MockCalled Invoke-AppCmd -Exactly 1
                }

            }

            Context 'The cpuSmpProcessorAffinityMask2 property needs to be set' {

                $mockAppPool = @{
                    name = 'MockAppPool'
                    cpu = @{
                        smpProcessorAffinityMask2 = 4294967295
                    }
                }

                Mock Get-WebConfiguration -MockWith {$mockAppPool}

                $setParamsSplat = @{
                    Ensure = 'Present'
                    Name = $mockAppPool.name
                    cpuSmpProcessorAffinityMask2 = 1
                }

                Mock Invoke-AppCmd -ParameterFilter {$ArgumentList[-1] -eq '/cpu.smpProcessorAffinityMask2:1'}

                Set-TargetResource @setParamsSplat

                It 'Should call Invoke-AppCmd' {
                    Assert-MockCalled Invoke-AppCmd -Exactly 1
                }

            }

            Context 'The identityType property needs to be set' {

                $mockAppPool = @{
                    name = 'MockAppPool'
                    processModel = @{
                        identityType = 'ApplicationPoolIdentity'
                    }
                }

                Mock Get-WebConfiguration -MockWith {$mockAppPool}

                $setParamsSplat = @{
                    Ensure = 'Present'
                    Name = $mockAppPool.name
                    identityType = 'SpecificUser'
                }

                Mock Invoke-AppCmd -ParameterFilter {$ArgumentList[-1] -eq '/processModel.identityType:SpecificUser'}

                Set-TargetResource @setParamsSplat

                It 'Should call Invoke-AppCmd' {
                    Assert-MockCalled Invoke-AppCmd -Exactly 1
                }

            }

            Context 'The idleTimeout property needs to be set' {

                $mockAppPool = @{
                    name = 'MockAppPool'
                    processModel = @{
                        idleTimeout = '00:20:00'
                    }
                }

                Mock Get-WebConfiguration -MockWith {$mockAppPool}

                $setParamsSplat = @{
                    Ensure = 'Present'
                    Name = $mockAppPool.name
                    idleTimeout = '00:15:00'
                }

                Mock Invoke-AppCmd -ParameterFilter {$ArgumentList[-1] -eq '/processModel.idleTimeout:00:15:00'}

                Set-TargetResource @setParamsSplat

                It 'Should call Invoke-AppCmd' {
                    Assert-MockCalled Invoke-AppCmd -Exactly 1
                }

            }

            Context 'The idleTimeoutAction property needs to be set' {

                $mockAppPool = @{
                    name = 'MockAppPool'
                    processModel = @{
                        idleTimeoutAction = 'Terminate'
                    }
                }

                Mock Get-WebConfiguration -MockWith {$mockAppPool}

                $setParamsSplat = @{
                    Ensure = 'Present'
                    Name = $mockAppPool.name
                    idleTimeoutAction = 'Suspend'
                }

                Mock Invoke-AppCmd -ParameterFilter {$ArgumentList[-1] -eq '/processModel.idleTimeoutAction:Suspend'}

                Set-TargetResource @setParamsSplat

                It 'Should call Invoke-AppCmd' {
                    Assert-MockCalled Invoke-AppCmd -Exactly 1
                }

            }

            Context 'The loadUserProfile property needs to be set' {

                $mockAppPool = @{
                    name = 'MockAppPool'
                    processModel = @{
                        loadUserProfile = $true
                    }
                }

                Mock Get-WebConfiguration -MockWith {$mockAppPool}

                $setParamsSplat = @{
                    Ensure = 'Present'
                    Name = $mockAppPool.name
                    loadUserProfile = $false
                }

                Mock Invoke-AppCmd -ParameterFilter {$ArgumentList[-1] -eq '/processModel.loadUserProfile:False'}

                Set-TargetResource @setParamsSplat

                It 'Should call Invoke-AppCmd' {
                    Assert-MockCalled Invoke-AppCmd -Exactly 1
                }

            }

            Context 'The logEventOnProcessModel property needs to be set' {

                $mockAppPool = @{
                    name = 'MockAppPool'
                    processModel = @{
                        logEventOnProcessModel = 'IdleTimeout'
                    }
                }

                Mock Get-WebConfiguration -MockWith {$mockAppPool}

                $setParamsSplat = @{
                    Ensure = 'Present'
                    Name = $mockAppPool.name
                    logEventOnProcessModel = ''
                }

                Mock Invoke-AppCmd -ParameterFilter {$ArgumentList[-1] -eq '/processModel.logEventOnProcessModel:'}

                Set-TargetResource @setParamsSplat

                It 'Should call Invoke-AppCmd' {
                    Assert-MockCalled Invoke-AppCmd -Exactly 1
                }

            }

            Context 'The logonType property needs to be set' {

                $mockAppPool = @{
                    name = 'MockAppPool'
                    processModel = @{
                        logonType = 'LogonBatch'
                    }
                }

                Mock Get-WebConfiguration -MockWith {$mockAppPool}

                $setParamsSplat = @{
                    Ensure = 'Present'
                    Name = $mockAppPool.name
                    logonType = 'LogonService'
                }

                Mock Invoke-AppCmd -ParameterFilter {$ArgumentList[-1] -eq '/processModel.logonType:LogonService'}

                Set-TargetResource @setParamsSplat

                It 'Should call Invoke-AppCmd' {
                    Assert-MockCalled Invoke-AppCmd -Exactly 1
                }

            }

            Context 'The manualGroupMembership property needs to be set' {

                $mockAppPool = @{
                    name = 'MockAppPool'
                    processModel = @{
                        manualGroupMembership = $false
                    }
                }

                Mock Get-WebConfiguration -MockWith {$mockAppPool}

                $setParamsSplat = @{
                    Ensure = 'Present'
                    Name = $mockAppPool.name
                    manualGroupMembership = $true
                }

                Mock Invoke-AppCmd -ParameterFilter {$ArgumentList[-1] -eq '/processModel.manualGroupMembership:True'}

                Set-TargetResource @setParamsSplat

                It 'Should call Invoke-AppCmd' {
                    Assert-MockCalled Invoke-AppCmd -Exactly 1
                }

            }

            Context 'The maxProcesses property needs to be set' {

                $mockAppPool = @{
                    name = 'MockAppPool'
                    processModel = @{
                        maxProcesses = 1
                    }
                }

                Mock Get-WebConfiguration -MockWith {$mockAppPool}

                $setParamsSplat = @{
                    Ensure = 'Present'
                    Name = $mockAppPool.name
                    maxProcesses = 2
                }

                Mock Invoke-AppCmd -ParameterFilter {$ArgumentList[-1] -eq '/processModel.maxProcesses:2'}

                Set-TargetResource @setParamsSplat

                It 'Should call Invoke-AppCmd' {
                    Assert-MockCalled Invoke-AppCmd -Exactly 1
                }

            }

            Context 'The pingingEnabled property needs to be set' {

                $mockAppPool = @{
                    name = 'MockAppPool'
                    processModel = @{
                        pingingEnabled = $true
                    }
                }

                Mock Get-WebConfiguration -MockWith {$mockAppPool}

                $setParamsSplat = @{
                    Ensure = 'Present'
                    Name = $mockAppPool.name
                    pingingEnabled = $false
                }

                Mock Invoke-AppCmd -ParameterFilter {$ArgumentList[-1] -eq '/processModel.pingingEnabled:False'}

                Set-TargetResource @setParamsSplat

                It 'Should call Invoke-AppCmd' {
                    Assert-MockCalled Invoke-AppCmd -Exactly 1
                }

            }

            Context 'The pingInterval property needs to be set' {

                $mockAppPool = @{
                    name = 'MockAppPool'
                    processModel = @{
                        pingInterval = '00:00:30'
                    }
                }

                Mock Get-WebConfiguration -MockWith {$mockAppPool}

                $setParamsSplat = @{
                    Ensure = 'Present'
                    Name = $mockAppPool.name
                    pingInterval = '00:01:00'
                }

                Mock Invoke-AppCmd -ParameterFilter {$ArgumentList[-1] -eq '/processModel.pingInterval:00:01:00'}

                Set-TargetResource @setParamsSplat

                It 'Should call Invoke-AppCmd' {
                    Assert-MockCalled Invoke-AppCmd -Exactly 1
                }

            }

            Context 'The pingResponseTime property needs to be set' {

                $mockAppPool = @{
                    name = 'MockAppPool'
                    processModel = @{
                        pingResponseTime = '00:01:30'
                    }
                }

                Mock Get-WebConfiguration -MockWith {$mockAppPool}

                $setParamsSplat = @{
                    Ensure = 'Present'
                    Name = $mockAppPool.name
                    pingResponseTime = '00:02:00'
                }

                Mock Invoke-AppCmd -ParameterFilter {$ArgumentList[-1] -eq '/processModel.pingResponseTime:00:02:00'}

                Set-TargetResource @setParamsSplat

                It 'Should call Invoke-AppCmd' {
                    Assert-MockCalled Invoke-AppCmd -Exactly 1
                }

            }

            Context 'The setProfileEnvironment property needs to be set' {

                $mockAppPool = @{
                    name = 'MockAppPool'
                    processModel = @{
                        setProfileEnvironment = $false
                    }
                }

                Mock Get-WebConfiguration -MockWith {$mockAppPool}

                $setParamsSplat = @{
                    Ensure = 'Present'
                    Name = $mockAppPool.name
                    setProfileEnvironment = $true
                }

                Mock Invoke-AppCmd -ParameterFilter {$ArgumentList[-1] -eq '/processModel.setProfileEnvironment:True'}

                Set-TargetResource @setParamsSplat

                It 'Should call Invoke-AppCmd' {
                    Assert-MockCalled Invoke-AppCmd -Exactly 1
                }

            }

            Context 'The shutdownTimeLimit property needs to be set' {

                $mockAppPool = @{
                    name = 'MockAppPool'
                    processModel = @{
                        shutdownTimeLimit = '00:01:30'
                    }
                }

                Mock Get-WebConfiguration -MockWith {$mockAppPool}

                $setParamsSplat = @{
                    Ensure = 'Present'
                    Name = $mockAppPool.name
                    shutdownTimeLimit = '00:02:00'
                }

                Mock Invoke-AppCmd -ParameterFilter {$ArgumentList[-1] -eq '/processModel.shutdownTimeLimit:00:02:00'}

                Set-TargetResource @setParamsSplat

                It 'Should call Invoke-AppCmd' {
                    Assert-MockCalled Invoke-AppCmd -Exactly 1
                }

            }

            Context 'The startupTimeLimit property needs to be set' {

                $mockAppPool = @{
                    name = 'MockAppPool'
                    processModel = @{
                        startupTimeLimit = '00:01:30'
                    }
                }

                Mock Get-WebConfiguration -MockWith {$mockAppPool}

                $setParamsSplat = @{
                    Ensure = 'Present'
                    Name = $mockAppPool.name
                    startupTimeLimit = '00:02:00'
                }

                Mock Invoke-AppCmd -ParameterFilter {$ArgumentList[-1] -eq '/processModel.startupTimeLimit:00:02:00'}

                Set-TargetResource @setParamsSplat

                It 'Should call Invoke-AppCmd' {
                    Assert-MockCalled Invoke-AppCmd -Exactly 1
                }

            }

            Context 'The orphanActionExe property needs to be set' {

                $mockAppPool = @{
                    name = 'MockAppPool'
                    failure = @{
                        orphanActionExe = ''
                    }
                }

                Mock Get-WebConfiguration -MockWith {$mockAppPool}

                $setParamsSplat = @{
                    Ensure = 'Present'
                    Name = $mockAppPool.name
                    orphanActionExe = 'C:\inetpub\temp\orphanAction.exe'
                }

                Mock Invoke-AppCmd -ParameterFilter {$ArgumentList[-1] -eq '/failure.orphanActionExe:C:\inetpub\temp\orphanAction.exe'}

                Set-TargetResource @setParamsSplat

                It 'Should call Invoke-AppCmd' {
                    Assert-MockCalled Invoke-AppCmd -Exactly 1
                }

            }

            Context 'The orphanActionParams property needs to be set' {

                $mockAppPool = @{
                    name = 'MockAppPool'
                    failure = @{
                        orphanActionParams = ''
                    }
                }

                Mock Get-WebConfiguration -MockWith {$mockAppPool}

                $setParamsSplat = @{
                    Ensure = 'Present'
                    Name = $mockAppPool.name
                    orphanActionParams = '/orphanActionParam1'
                }

                Mock Invoke-AppCmd -ParameterFilter {$ArgumentList[-1] -eq '/failure.orphanActionParams:/orphanActionParam1'}

                Set-TargetResource @setParamsSplat

                It 'Should call Invoke-AppCmd' {
                    Assert-MockCalled Invoke-AppCmd -Exactly 1
                }

            }

            Context 'The orphanWorkerProcess property needs to be set' {

                $mockAppPool = @{
                    name = 'MockAppPool'
                    failure = @{
                        orphanWorkerProcess = $false
                    }
                }

                Mock Get-WebConfiguration -MockWith {$mockAppPool}

                $setParamsSplat = @{
                    Ensure = 'Present'
                    Name = $mockAppPool.name
                    orphanWorkerProcess = $true
                }

                Mock Invoke-AppCmd -ParameterFilter {$ArgumentList[-1] -eq '/failure.orphanWorkerProcess:True'}

                Set-TargetResource @setParamsSplat

                It 'Should call Invoke-AppCmd' {
                    Assert-MockCalled Invoke-AppCmd -Exactly 1
                }

            }

            Context 'The loadBalancerCapabilities property needs to be set' {

                $mockAppPool = @{
                    name = 'MockAppPool'
                    failure = @{
                        loadBalancerCapabilities = 'HttpLevel'
                    }
                }

                Mock Get-WebConfiguration -MockWith {$mockAppPool}

                $setParamsSplat = @{
                    Ensure = 'Present'
                    Name = $mockAppPool.name
                    loadBalancerCapabilities = 'TcpLevel'
                }

                Mock Invoke-AppCmd -ParameterFilter {$ArgumentList[-1] -eq '/failure.loadBalancerCapabilities:TcpLevel'}

                Set-TargetResource @setParamsSplat

                It 'Should call Invoke-AppCmd' {
                    Assert-MockCalled Invoke-AppCmd -Exactly 1
                }

            }

            Context 'The rapidFailProtection property needs to be set' {

                $mockAppPool = @{
                    name = 'MockAppPool'
                    failure = @{
                        rapidFailProtection = $true
                    }
                }

                Mock Get-WebConfiguration -MockWith {$mockAppPool}

                $setParamsSplat = @{
                    Ensure = 'Present'
                    Name = $mockAppPool.name
                    rapidFailProtection = $false
                }

                Mock Invoke-AppCmd -ParameterFilter {$ArgumentList[-1] -eq '/failure.rapidFailProtection:False'}

                Set-TargetResource @setParamsSplat

                It 'Should call Invoke-AppCmd' {
                    Assert-MockCalled Invoke-AppCmd -Exactly 1
                }

            }

            Context 'The rapidFailProtectionInterval property needs to be set' {

                $mockAppPool = @{
                    name = 'MockAppPool'
                    failure = @{
                        rapidFailProtectionInterval = '00:05:00'
                    }
                }

                Mock Get-WebConfiguration -MockWith {$mockAppPool}

                $setParamsSplat = @{
                    Ensure = 'Present'
                    Name = $mockAppPool.name
                    rapidFailProtectionInterval = '00:10:00'
                }

                Mock Invoke-AppCmd -ParameterFilter {$ArgumentList[-1] -eq '/failure.rapidFailProtectionInterval:00:10:00'}

                Set-TargetResource @setParamsSplat

                It 'Should call Invoke-AppCmd' {
                    Assert-MockCalled Invoke-AppCmd -Exactly 1
                }

            }

            Context 'The rapidFailProtectionMaxCrashes property needs to be set' {

                $mockAppPool = @{
                    name = 'MockAppPool'
                    failure = @{
                        rapidFailProtectionMaxCrashes = 5
                    }
                }

                Mock Get-WebConfiguration -MockWith {$mockAppPool}

                $setParamsSplat = @{
                    Ensure = 'Present'
                    Name = $mockAppPool.name
                    rapidFailProtectionMaxCrashes = 10
                }

                Mock Invoke-AppCmd -ParameterFilter {$ArgumentList[-1] -eq '/failure.rapidFailProtectionMaxCrashes:10'}

                Set-TargetResource @setParamsSplat

                It 'Should call Invoke-AppCmd' {
                    Assert-MockCalled Invoke-AppCmd -Exactly 1
                }

            }

            Context 'The autoShutdownExe property needs to be set' {

                $mockAppPool = @{
                    name = 'MockAppPool'
                    failure = @{
                        autoShutdownExe = ''
                    }
                }

                Mock Get-WebConfiguration -MockWith {$mockAppPool}

                $setParamsSplat = @{
                    Ensure = 'Present'
                    Name = $mockAppPool.name
                    autoShutdownExe = 'C:\inetpub\temp\autoShutdown.exe'
                }

                Mock Invoke-AppCmd -ParameterFilter {$ArgumentList[-1] -eq '/failure.autoShutdownExe:C:\inetpub\temp\autoShutdown.exe'}

                Set-TargetResource @setParamsSplat

                It 'Should call Invoke-AppCmd' {
                    Assert-MockCalled Invoke-AppCmd -Exactly 1
                }

            }

            Context 'The autoShutdownParams property needs to be set' {

                $mockAppPool = @{
                    name = 'MockAppPool'
                    failure = @{
                        autoShutdownParams = ''
                    }

                }

                Mock Get-WebConfiguration -MockWith {$mockAppPool}

                $setParamsSplat = @{
                    Ensure = 'Present'
                    Name = $mockAppPool.name
                    autoShutdownParams = '/autoShutdownParam1'
                }

                Mock Invoke-AppCmd -ParameterFilter {$ArgumentList[-1] -eq '/failure.autoShutdownParams:/autoShutdownParam1'}

                Set-TargetResource @setParamsSplat

                It 'Should call Invoke-AppCmd' {
                    Assert-MockCalled Invoke-AppCmd -Exactly 1
                }

            }

            Context 'The disallowOverlappingRotation property needs to be set' {

                $mockAppPool = @{
                    name = 'MockAppPool'
                    recycling = @{
                        disallowOverlappingRotation = $false
                    }
                }

                Mock Get-WebConfiguration -MockWith {$mockAppPool}

                $setParamsSplat = @{
                    Ensure = 'Present'
                    Name = $mockAppPool.name
                    disallowOverlappingRotation = $true
                }

                Mock Invoke-AppCmd -ParameterFilter {$ArgumentList[-1] -eq '/recycling.disallowOverlappingRotation:True'}

                Set-TargetResource @setParamsSplat

                It 'Should call Invoke-AppCmd' {
                    Assert-MockCalled Invoke-AppCmd -Exactly 1
                }

            }

            Context 'The disallowRotationOnConfigChange property needs to be set' {

                $mockAppPool = @{
                    name = 'MockAppPool'
                    recycling = @{
                        disallowRotationOnConfigChange = $false
                    }
                }

                Mock Get-WebConfiguration -MockWith {$mockAppPool}

                $setParamsSplat = @{
                    Ensure = 'Present'
                    Name = $mockAppPool.name
                    disallowRotationOnConfigChange = $true
                }

                Mock Invoke-AppCmd -ParameterFilter {$ArgumentList[-1] -eq '/recycling.disallowRotationOnConfigChange:True'}

                Set-TargetResource @setParamsSplat

                It 'Should call Invoke-AppCmd' {
                    Assert-MockCalled Invoke-AppCmd -Exactly 1
                }

            }

            Context 'The logEventOnRecycle property needs to be set' {

                $mockAppPool = @{
                    name = 'MockAppPool'
                    recycling = @{
                        logEventOnRecycle = 'Time,Requests,Schedule,Memory,IsapiUnhealthy,OnDemand,ConfigChange,PrivateMemory'
                    }
                }

                Mock Get-WebConfiguration -MockWith {$mockAppPool}

                $setParamsSplat = @{
                    Ensure = 'Present'
                    Name = $mockAppPool.name
                    logEventOnRecycle = 'Time,Memory,PrivateMemory'
                }

                Mock Invoke-AppCmd -ParameterFilter {$ArgumentList[-1] -eq '/recycling.logEventOnRecycle:Time,Memory,PrivateMemory'}

                Set-TargetResource @setParamsSplat

                It 'Should call Invoke-AppCmd' {
                    Assert-MockCalled Invoke-AppCmd -Exactly 1
                }

            }

            Context 'The restartMemoryLimit property needs to be set' {

                $mockAppPool = @{
                    name = 'MockAppPool'
                    recycling = @{
                        periodicRestart = @{
                            memory = 0
                        }
                    }
                }

                Mock Get-WebConfiguration -MockWith {$mockAppPool}

                $setParamsSplat = @{
                    Ensure = 'Present'
                    Name = $mockAppPool.name
                    restartMemoryLimit = 1048576
                }

                Mock Invoke-AppCmd -ParameterFilter {$ArgumentList[-1] -eq '/recycling.periodicRestart.memory:1048576'}

                Set-TargetResource @setParamsSplat

                It 'Should call Invoke-AppCmd' {
                    Assert-MockCalled Invoke-AppCmd -Exactly 1
                }

            }

            Context 'The restartPrivateMemoryLimit property needs to be set' {

                $mockAppPool = @{
                    name = 'MockAppPool'
                    recycling = @{
                        periodicRestart = @{
                            privateMemory = 0
                        }
                    }
                }

                Mock Get-WebConfiguration -MockWith {$mockAppPool}

                $setParamsSplat = @{
                    Ensure = 'Present'
                    Name = $mockAppPool.name
                    restartPrivateMemoryLimit = 1048576
                }

                Mock Invoke-AppCmd -ParameterFilter {$ArgumentList[-1] -eq '/recycling.periodicRestart.privateMemory:1048576'}

                Set-TargetResource @setParamsSplat

                It 'Should call Invoke-AppCmd' {
                    Assert-MockCalled Invoke-AppCmd -Exactly 1
                }

            }

            Context 'The restartRequestsLimit property needs to be set' {

                $mockAppPool = @{
                    name = 'MockAppPool'
                    recycling = @{
                        periodicRestart = @{
                            requests = 0
                        }
                    }
                }

                Mock Get-WebConfiguration -MockWith {$mockAppPool}

                $setParamsSplat = @{
                    Ensure = 'Present'
                    Name = $mockAppPool.name
                    restartRequestsLimit = 1000
                }

                Mock Invoke-AppCmd -ParameterFilter {$ArgumentList[-1] -eq '/recycling.periodicRestart.requests:1000'}

                Set-TargetResource @setParamsSplat

                It 'Should call Invoke-AppCmd' {
                    Assert-MockCalled Invoke-AppCmd -Exactly 1
                }

            }

            Context 'The restartTimeLimit property needs to be set' {

                $mockAppPool = @{
                    name = 'MockAppPool'
                    recycling = @{
                        periodicRestart = @{
                            time = '1.05:00:00'
                        }
                    }
                }

                Mock Get-WebConfiguration -MockWith {$mockAppPool}

                $setParamsSplat = @{
                    Ensure = 'Present'
                    Name = $mockAppPool.name
                    restartTimeLimit = '2.10:00:00'
                }

                Mock Invoke-AppCmd -ParameterFilter {$ArgumentList[-1] -eq '/recycling.periodicRestart.time:2.10:00:00'}

                Set-TargetResource @setParamsSplat

                It 'Should call Invoke-AppCmd' {
                    Assert-MockCalled Invoke-AppCmd -Exactly 1
                }

            }

            Context 'The restartSchedule property needs to be set' {

                $mockAppPool = @{
                    name = 'MockAppPool'
                    recycling = @{
                        periodicRestart = @{
                            schedule = @{
                                Collection = @(
                                    @{value = '04:00:00'}
                                )
                            }
                        }
                    }
                }

                Mock Get-WebConfiguration -MockWith {$mockAppPool}

                $setParamsSplat = @{
                    Ensure = 'Present'
                    Name = $mockAppPool.name
                    restartSchedule = @('08:00:00')
                }

                Mock Invoke-AppCmd -ParameterFilter {$ArgumentList[-1] -eq "/-recycling.periodicRestart.schedule.[value='04:00:00']"}
                Mock Invoke-AppCmd -ParameterFilter {$ArgumentList[-1] -eq "/+recycling.periodicRestart.schedule.[value='08:00:00']"}

                Set-TargetResource @setParamsSplat

                It 'Should call Invoke-AppCmd' {
                    Assert-MockCalled Invoke-AppCmd -ParameterFilter {$ArgumentList[-1] -eq "/-recycling.periodicRestart.schedule.[value='04:00:00']"} -Exactly 1
                    Assert-MockCalled Invoke-AppCmd -ParameterFilter {$ArgumentList[-1] -eq "/+recycling.periodicRestart.schedule.[value='08:00:00']"} -Exactly 1
                }

            }

        }

        Describe "MSFT_xWebAppPool\Get-Property" {

            It 'Should return the value of $appPool.property1' {
                $appPool = @{ property1 = 'result' }
                $path = 'property1'
                Get-Property -Object $appPool -PropertyName $path |
                Should Be 'result'

            }

            It 'Should return the value of $appPool.property1.property2' {
                $appPool = @{ property1 = @{ property2 = 'result' } }
                $path = 'property1.property2'
                Get-Property -Object $appPool -PropertyName $path |
                Should Be 'result'

            }

            It 'Should return the value of $appPool.property1.property2.property3' {
                $appPool = @{ property1 = @{ property2 = @{ property3 ='result' } } }
                $path = 'property1.property2.property3'
                Get-Property -Object $appPool -PropertyName $path |
                Should Be 'result'

            }

        }

    }

    #endregion
}
finally
{
    Restore-TestEnvironment -TestEnvironment $TestEnvironment
}
