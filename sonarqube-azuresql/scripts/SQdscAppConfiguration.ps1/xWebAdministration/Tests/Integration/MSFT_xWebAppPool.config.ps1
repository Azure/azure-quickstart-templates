#requires -Version 4.0

[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingConvertToSecureStringWithPlainText', '')]
[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssigments', '')]
param ()

$ConfigData = @{
    AllNodes = @(
        @{
            NodeName = '*'
            PSDscAllowPlainTextPassword = $true
        }
        @{
            NodeName = 'localhost'
        }
    )
}

$TestCredential = New-Object -TypeName PSCredential -ArgumentList (
    'CONTOSO\JDoe',
    ('5t6y7u8i' | ConvertTo-SecureString -AsPlainText -Force)
)

$TestParameters = [Ordered]@{
    Name                           = 'TestAppPool'
    Ensure                         = 'Present'
    State                          = 'Stopped'
    autoStart                      = $false
    CLRConfigFile                  = 'C:\inetpub\temp\aspnet.config'
    enable32BitAppOnWin64          = $true
    enableConfigurationOverride    = $false
    managedPipelineMode            = 'Classic'
    managedRuntimeLoader           = ''
    managedRuntimeVersion          = 'v2.0'
    passAnonymousToken             = $false
    startMode                      = 'AlwaysRunning'
    queueLength                    = 2000
    cpuAction                      = 'KillW3wp'
    cpuLimit                       = 90000
    cpuResetInterval               = '00:10:00'
    cpuSmpAffinitized              = $true
    cpuSmpProcessorAffinityMask    = 1
    cpuSmpProcessorAffinityMask2   = 1
    identityType                   = 'SpecificUser'
    Credential                     = $TestCredential
    idleTimeout                    = '00:15:00'
    idleTimeoutAction              = 'Suspend'
    loadUserProfile                = $false
    logEventOnProcessModel         = ''
    logonType                      = 'LogonService'
    manualGroupMembership          = $true
    maxProcesses                   = 2
    pingingEnabled                 = $false
    pingInterval                   = '00:01:00'
    pingResponseTime               = '00:02:00'
    setProfileEnvironment          = $true
    shutdownTimeLimit              = '00:02:00'
    startupTimeLimit               = '00:02:00'
    orphanActionExe                = 'C:\inetpub\temp\orphanAction.exe'
    orphanActionParams             = '/orphanActionParam1'
    orphanWorkerProcess            = $true
    loadBalancerCapabilities       = 'TcpLevel'
    rapidFailProtection            = $false
    rapidFailProtectionInterval    = '00:10:00'
    rapidFailProtectionMaxCrashes  = 10
    autoShutdownExe                = 'C:\inetpub\temp\autoShutdown.exe'
    autoShutdownParams             = '/autoShutdownParam1'
    disallowOverlappingRotation    = $true
    disallowRotationOnConfigChange = $true
    logEventOnRecycle              = 'Time,Memory,PrivateMemory'
    restartMemoryLimit             = 1048576
    restartPrivateMemoryLimit      = 1048576
    restartRequestsLimit           = 1000
    restartTimeLimit               = '2.10:00:00'
    restartSchedule                = @('06:00:00', '08:00:00')
}

Configuration MSFT_xWebAppPool_Config
{
    Import-DscResource -ModuleName xWebAdministration

    Node $AllNodes.NodeName
    {
        xWebAppPool TestAppPool
        {
            Name                           = $TestParameters.Name
            Ensure                         = $TestParameters.Ensure
            State                          = $TestParameters.State
            autoStart                      = $TestParameters.autoStart
            CLRConfigFile                  = $TestParameters.CLRConfigFile
            enable32BitAppOnWin64          = $TestParameters.enable32BitAppOnWin64
            enableConfigurationOverride    = $TestParameters.enableConfigurationOverride
            managedPipelineMode            = $TestParameters.managedPipelineMode
            managedRuntimeLoader           = $TestParameters.managedRuntimeLoader
            managedRuntimeVersion          = $TestParameters.managedRuntimeVersion
            passAnonymousToken             = $TestParameters.passAnonymousToken
            startMode                      = $TestParameters.startMode
            queueLength                    = $TestParameters.queueLength
            cpuAction                      = $TestParameters.cpuAction
            cpuLimit                       = $TestParameters.cpuLimit
            cpuResetInterval               = $TestParameters.cpuResetInterval
            cpuSmpAffinitized              = $TestParameters.cpuSmpAffinitized
            cpuSmpProcessorAffinityMask    = $TestParameters.cpuSmpProcessorAffinityMask
            cpuSmpProcessorAffinityMask2   = $TestParameters.cpuSmpProcessorAffinityMask2
            identityType                   = $TestParameters.identityType
            Credential                     = $TestParameters.Credential
            idleTimeout                    = $TestParameters.idleTimeout
            idleTimeoutAction              = $TestParameters.idleTimeoutAction
            loadUserProfile                = $TestParameters.loadUserProfile
            logEventOnProcessModel         = $TestParameters.logEventOnProcessModel
            logonType                      = $TestParameters.logonType
            manualGroupMembership          = $TestParameters.manualGroupMembership
            maxProcesses                   = $TestParameters.maxProcesses
            pingingEnabled                 = $TestParameters.pingingEnabled
            pingInterval                   = $TestParameters.pingInterval
            pingResponseTime               = $TestParameters.pingResponseTime
            setProfileEnvironment          = $TestParameters.setProfileEnvironment
            shutdownTimeLimit              = $TestParameters.shutdownTimeLimit
            startupTimeLimit               = $TestParameters.startupTimeLimit
            orphanActionExe                = $TestParameters.orphanActionExe
            orphanActionParams             = $TestParameters.orphanActionParams
            orphanWorkerProcess            = $TestParameters.orphanWorkerProcess
            loadBalancerCapabilities       = $TestParameters.loadBalancerCapabilities
            rapidFailProtection            = $TestParameters.rapidFailProtection
            rapidFailProtectionInterval    = $TestParameters.rapidFailProtectionInterval
            rapidFailProtectionMaxCrashes  = $TestParameters.rapidFailProtectionMaxCrashes
            autoShutdownExe                = $TestParameters.autoShutdownExe
            autoShutdownParams             = $TestParameters.autoShutdownParams
            disallowOverlappingRotation    = $TestParameters.disallowOverlappingRotation
            disallowRotationOnConfigChange = $TestParameters.disallowRotationOnConfigChange
            logEventOnRecycle              = $TestParameters.logEventOnRecycle
            restartMemoryLimit             = $TestParameters.restartMemoryLimit
            restartPrivateMemoryLimit      = $TestParameters.restartPrivateMemoryLimit
            restartRequestsLimit           = $TestParameters.restartRequestsLimit
            restartTimeLimit               = $TestParameters.restartTimeLimit
            restartSchedule                = $TestParameters.restartSchedule
        }
    }
}
