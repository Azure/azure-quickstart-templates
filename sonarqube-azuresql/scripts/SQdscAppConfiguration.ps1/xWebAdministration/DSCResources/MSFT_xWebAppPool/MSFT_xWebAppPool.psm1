#requires -Version 4.0 -Modules CimCmdlets

# Load the Helper Module
Import-Module -Name "$PSScriptRoot\..\Helper.psm1"

# Localized messages
data LocalizedData
{
    # culture="en-US"
    ConvertFrom-StringData -StringData @'
        ErrorAppCmdNonZeroExitCode        = AppCmd.exe has exited with error code "{0}".
        VerboseAppPoolFound               = Application pool "{0}" was found.
        VerboseAppPoolNotFound            = Application pool "{0}" was not found.
        VerboseEnsureNotInDesiredState    = The "Ensure" state of application pool "{0}" does not match the desired state.
        VerbosePropertyNotInDesiredState  = The "{0}" property of application pool "{1}" does not match the desired state.
        VerboseCredentialToBeCleared      = Custom account credentials of application pool "{0}" need to be cleared because the "identityType" property is not set to "SpecificUser".
        VerboseCredentialToBeIgnored      = The "Credential" property is only valid when the "identityType" property is set to "SpecificUser".
        VerboseResourceInDesiredState     = The target resource is already in the desired state. No action is required.
        VerboseResourceNotInDesiredState  = The target resource is not in the desired state.
        VerboseNewAppPool                 = Creating application pool "{0}".
        VerboseRemoveAppPool              = Removing application pool "{0}".
        VerboseStartAppPool               = Starting application pool "{0}".
        VerboseStopAppPool                = Stopping application pool "{0}".
        VerboseSetProperty                = Setting the "{0}" property of application pool "{1}".
        VerboseClearCredential            = Clearing custom account credentials of application pool "{0}" because the "identityType" property is not set to "SpecificUser".
        VerboseRestartScheduleValueAdd    = Adding value "{0}" to the "restartSchedule" collection of application pool "{1}".
        VerboseRestartScheduleValueRemove = Removing value "{0}" from the "restartSchedule" collection of application pool "{1}".
'@
}

# Writable properties except Ensure and Credential.
data PropertyData
{
    @(
        # General
        @{Name = 'State';                          Path = 'state'}
        @{Name = 'autoStart';                      Path = 'autoStart'}
        @{Name = 'CLRConfigFile';                  Path = 'CLRConfigFile'}
        @{Name = 'enable32BitAppOnWin64';          Path = 'enable32BitAppOnWin64'}
        @{Name = 'enableConfigurationOverride';    Path = 'enableConfigurationOverride'}
        @{Name = 'managedPipelineMode';            Path = 'managedPipelineMode'}
        @{Name = 'managedRuntimeLoader';           Path = 'managedRuntimeLoader'}
        @{Name = 'managedRuntimeVersion';          Path = 'managedRuntimeVersion'}
        @{Name = 'passAnonymousToken';             Path = 'passAnonymousToken'}
        @{Name = 'startMode';                      Path = 'startMode'}
        @{Name = 'queueLength';                    Path = 'queueLength'}

        # CPU
        @{Name = 'cpuAction';                      Path = 'cpu.action'}
        @{Name = 'cpuLimit';                       Path = 'cpu.limit'}
        @{Name = 'cpuResetInterval';               Path = 'cpu.resetInterval'}
        @{Name = 'cpuSmpAffinitized';              Path = 'cpu.smpAffinitized'}
        @{Name = 'cpuSmpProcessorAffinityMask';    Path = 'cpu.smpProcessorAffinityMask'}
        @{Name = 'cpuSmpProcessorAffinityMask2';   Path = 'cpu.smpProcessorAffinityMask2'}

        # Process Model
        @{Name = 'identityType';                   Path = 'processModel.identityType'}
        @{Name = 'idleTimeout';                    Path = 'processModel.idleTimeout'}
        @{Name = 'idleTimeoutAction';              Path = 'processModel.idleTimeoutAction'}
        @{Name = 'loadUserProfile';                Path = 'processModel.loadUserProfile'}
        @{Name = 'logEventOnProcessModel';         Path = 'processModel.logEventOnProcessModel'}
        @{Name = 'logonType';                      Path = 'processModel.logonType'}
        @{Name = 'manualGroupMembership';          Path = 'processModel.manualGroupMembership'}
        @{Name = 'maxProcesses';                   Path = 'processModel.maxProcesses'}
        @{Name = 'pingingEnabled';                 Path = 'processModel.pingingEnabled'}
        @{Name = 'pingInterval';                   Path = 'processModel.pingInterval'}
        @{Name = 'pingResponseTime';               Path = 'processModel.pingResponseTime'}
        @{Name = 'setProfileEnvironment';          Path = 'processModel.setProfileEnvironment'}
        @{Name = 'shutdownTimeLimit';              Path = 'processModel.shutdownTimeLimit'}
        @{Name = 'startupTimeLimit';               Path = 'processModel.startupTimeLimit'}

        # Process Orphaning
        @{Name = 'orphanActionExe';                Path = 'failure.orphanActionExe'}
        @{Name = 'orphanActionParams';             Path = 'failure.orphanActionParams'}
        @{Name = 'orphanWorkerProcess';            Path = 'failure.orphanWorkerProcess'}

        # Rapid-Fail Protection
        @{Name = 'loadBalancerCapabilities';       Path = 'failure.loadBalancerCapabilities'}
        @{Name = 'rapidFailProtection';            Path = 'failure.rapidFailProtection'}
        @{Name = 'rapidFailProtectionInterval';    Path = 'failure.rapidFailProtectionInterval'}
        @{Name = 'rapidFailProtectionMaxCrashes';  Path = 'failure.rapidFailProtectionMaxCrashes'}
        @{Name = 'autoShutdownExe';                Path = 'failure.autoShutdownExe'}
        @{Name = 'autoShutdownParams';             Path = 'failure.autoShutdownParams'}

        # Recycling
        @{Name = 'disallowOverlappingRotation';    Path = 'recycling.disallowOverlappingRotation'}
        @{Name = 'disallowRotationOnConfigChange'; Path = 'recycling.disallowRotationOnConfigChange'}
        @{Name = 'logEventOnRecycle';              Path = 'recycling.logEventOnRecycle'}
        @{Name = 'restartMemoryLimit';             Path = 'recycling.periodicRestart.memory'}
        @{Name = 'restartPrivateMemoryLimit';      Path = 'recycling.periodicRestart.privateMemory'}
        @{Name = 'restartRequestsLimit';           Path = 'recycling.periodicRestart.requests'}
        @{Name = 'restartTimeLimit';               Path = 'recycling.periodicRestart.time'}
        @{Name = 'restartSchedule';                Path = 'recycling.periodicRestart.schedule'}
    )
}

function Get-TargetResource
{
    <#
    .SYNOPSIS
        This will return a hashtable of results 
    #>

    [CmdletBinding()]
    [OutputType([Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateLength(1, 64)]
        [String] $Name
    )

    Assert-Module

    # XPath -Filter is case-sensitive. Use Where-Object to get the target application pool by name.
    $appPool = Get-WebConfiguration -Filter '/system.applicationHost/applicationPools/add' |
        Where-Object -FilterScript {$_.name -eq $Name}

    $cimCredential = $null

    if ($null -eq $appPool)
    {
        Write-Verbose -Message ($LocalizedData['VerboseAppPoolNotFound'] -f $Name)

        $ensureResult = 'Absent'
    }
    else
    {
        Write-Verbose -Message ($LocalizedData['VerboseAppPoolFound'] -f $Name)

        $ensureResult = 'Present'

        if ($appPool.processModel.identityType -eq 'SpecificUser')
        {
            $cimCredential = New-CimInstance -ClientOnly `
                -ClassName MSFT_Credential `
                -Namespace root/microsoft/windows/DesiredStateConfiguration `
                -Property @{
                    UserName = [String]$appPool.processModel.userName
                    Password = [String]$appPool.processModel.password
                }
        }
    }

    $returnValue = @{
        Name = $Name
        Ensure = $ensureResult
        Credential = $cimCredential
    }

    $PropertyData.Where(
        {
            $_.Name -ne 'restartSchedule'
        }
    ).ForEach(
        {
            $property = Get-Property -Object $appPool -PropertyName $_.Path
            $returnValue.Add($_.Name, $property)
        }
    )

    $restartScheduleCurrent = [String[]]@(
        @($appPool.recycling.periodicRestart.schedule.Collection).ForEach('value')
    )

    $returnValue.Add('restartSchedule', $restartScheduleCurrent)

    return $returnValue
}

function Set-TargetResource
{
    <#
    .SYNOPSIS
        This will set the desired state
    #>
    
    [CmdletBinding(SupportsShouldProcess = $true)]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateLength(1, 64)]
        [String] $Name,

        [ValidateSet('Present', 'Absent')]
        [String] $Ensure = 'Present',

        [ValidateSet('Started', 'Stopped')]
        [String] $State,

        [Boolean] $autoStart,

        [String] $CLRConfigFile,

        [Boolean] $enable32BitAppOnWin64,

        [Boolean] $enableConfigurationOverride,

        [ValidateSet('Integrated', 'Classic')]
        [String] $managedPipelineMode,

        [String] $managedRuntimeLoader,

        [ValidateSet('v4.0', 'v2.0', '')]
        [String] $managedRuntimeVersion,

        [Boolean] $passAnonymousToken,

        [ValidateSet('OnDemand', 'AlwaysRunning')]
        [String] $startMode,

        [ValidateRange(10, 65535)]
        [UInt32] $queueLength,

        [ValidateSet('NoAction', 'KillW3wp', 'Throttle', 'ThrottleUnderLoad')]
        [String] $cpuAction,

        [ValidateRange(0, 100000)]
        [UInt32] $cpuLimit,

        [ValidateScript({
            ([ValidateRange(0, 1440)]$valueInMinutes = [TimeSpan]::Parse($_).TotalMinutes); $?
        })]
        [String] $cpuResetInterval,

        [Boolean] $cpuSmpAffinitized,

        [UInt32] $cpuSmpProcessorAffinityMask,

        [UInt32] $cpuSmpProcessorAffinityMask2,

        [ValidateSet(
                'ApplicationPoolIdentity', 'LocalService', 'LocalSystem',
                'NetworkService', 'SpecificUser'
        )]
        [String] $identityType,

        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()] 
        $Credential,

        [ValidateScript({
            ([ValidateRange(0, 43200)]$valueInMinutes = [TimeSpan]::Parse($_).TotalMinutes); $?
        })]
        [String] $idleTimeout,

        [ValidateSet('Terminate', 'Suspend')]
        [String] $idleTimeoutAction,

        [Boolean] $loadUserProfile,

        [String] $logEventOnProcessModel,

        [ValidateSet('LogonBatch', 'LogonService')]
        [String] $logonType,

        [Boolean] $manualGroupMembership,

        [ValidateRange(0, 2147483647)]
        [UInt32] $maxProcesses,

        [Boolean] $pingingEnabled,

        [ValidateScript({
            ([ValidateRange(1, 4294967)]$valueInSeconds = [TimeSpan]::Parse($_).TotalSeconds); $?
        })]
        [String] $pingInterval,

        [ValidateScript({
            ([ValidateRange(1, 4294967)]$valueInSeconds = [TimeSpan]::Parse($_).TotalSeconds); $?
        })]
        [String] $pingResponseTime,

        [Boolean] $setProfileEnvironment,

        [ValidateScript({
            ([ValidateRange(1, 4294967)]$valueInSeconds = [TimeSpan]::Parse($_).TotalSeconds); $?
        })]
        [String] $shutdownTimeLimit,

        [ValidateScript({
            ([ValidateRange(1, 4294967)]$valueInSeconds = [TimeSpan]::Parse($_).TotalSeconds); $?
        })]
        [String] $startupTimeLimit,

        [String] $orphanActionExe,

        [String] $orphanActionParams,

        [Boolean] $orphanWorkerProcess,

        [ValidateSet('HttpLevel', 'TcpLevel')]
        [String] $loadBalancerCapabilities,

        [Boolean] $rapidFailProtection,

        [ValidateScript({
            ([ValidateRange(1, 144000)]$valueInMinutes = [TimeSpan]::Parse($_).TotalMinutes); $?
        })]
        [String] $rapidFailProtectionInterval,

        [ValidateRange(0, 2147483647)]
        [UInt32] $rapidFailProtectionMaxCrashes,

        [String] $autoShutdownExe,

        [String] $autoShutdownParams,

        [Boolean] $disallowOverlappingRotation,

        [Boolean] $disallowRotationOnConfigChange,

        [String] $logEventOnRecycle,

        [UInt32] $restartMemoryLimit,

        [UInt32] $restartPrivateMemoryLimit,

        [UInt32] $restartRequestsLimit,

        [ValidateScript({
            ([ValidateRange(0, 432000)]$valueInMinutes = [TimeSpan]::Parse($_).TotalMinutes); $?
        })]
        [String] $restartTimeLimit,

        [ValidateScript({
            ($_ -eq '') -or
            (& {
                ([ValidateRange(0, 86399)]$valueInSeconds = [TimeSpan]::Parse($_).TotalSeconds); $?
            })
        })]
        [String[]] $restartSchedule
    )

    if (-not $PSCmdlet.ShouldProcess($Name))
    {
        return
    }

    Assert-Module

    $appPool = Get-WebConfiguration -Filter '/system.applicationHost/applicationPools/add' |
        Where-Object -FilterScript {$_.name -eq $Name}

    if ($Ensure -eq 'Present')
    {
        # Create Application Pool
        if ($null -eq $appPool)
        {
            Write-Verbose -Message ($LocalizedData['VerboseAppPoolNotFound'] -f $Name)
            Write-Verbose -Message ($LocalizedData['VerboseNewAppPool'] -f $Name)

            $appPool = New-WebAppPool -Name $Name -ErrorAction Stop
        }

        # Set Application Pool Properties
        if ($null -ne $appPool)
        {
            Write-Verbose -Message ($LocalizedData['VerboseAppPoolFound'] -f $Name)

            $PropertyData.Where(
                {
                    ($_.Name -in $PSBoundParameters.Keys) -and
                    ($_.Name -notin @('State', 'restartSchedule'))
                }
            ).ForEach(
                {
                    $propertyName = $_.Name
                    $propertyPath = $_.Path
                    $property = Get-Property -Object $appPool -PropertyName $propertyPath

                    if ( 
                        $PSBoundParameters[$propertyName] -ne $property
                    )
                    {
                        Write-Verbose -Message (
                            $LocalizedData['VerboseSetProperty'] -f $propertyName, $Name
                        )

                        Invoke-AppCmd -ArgumentList 'set', 'apppool', $Name, (
                            '/{0}:{1}' -f $propertyPath, $PSBoundParameters[$propertyName]
                        )
                    }
                }
            )

            if ($PSBoundParameters.ContainsKey('Credential'))
            {
                if ($PSBoundParameters['identityType'] -eq 'SpecificUser')
                {
                    if ($appPool.processModel.userName -ne $Credential.UserName)
                    {
                        Write-Verbose -Message (
                            $LocalizedData['VerboseSetProperty'] -f 'Credential (userName)', $Name
                        )

                        Invoke-AppCmd -ArgumentList 'set', 'apppool', $Name, (
                            '/processModel.userName:{0}' -f $Credential.UserName
                        )
                    }

                    $clearTextPassword = $Credential.GetNetworkCredential().Password

                    if ($appPool.processModel.password -cne $clearTextPassword)
                    {
                        Write-Verbose -Message (
                            $LocalizedData['VerboseSetProperty'] -f 'Credential (password)', $Name
                        )

                        Invoke-AppCmd -ArgumentList 'set', 'apppool', $Name, (
                            '/processModel.password:{0}' -f $clearTextPassword
                        )
                    }
                }
                else
                {
                    Write-Verbose -Message ($LocalizedData['VerboseCredentialToBeIgnored'])
                }
            }

            # Ensure userName and password are cleared if identityType isn't set to SpecificUser.
            if (
                (
                    (
                        ($PSBoundParameters.ContainsKey('identityType') -eq $true) -and
                        ($PSBoundParameters['identityType'] -ne 'SpecificUser')
                    ) -or
                    (
                        ($PSBoundParameters.ContainsKey('identityType') -eq $false) -and
                        ($appPool.processModel.identityType -ne 'SpecificUser')
                    )
                ) -and
                (
                    ([String]::IsNullOrEmpty($appPool.processModel.userName) -eq $false) -or
                    ([String]::IsNullOrEmpty($appPool.processModel.password) -eq $false)
                )
            )
            {
                Write-Verbose -Message ($LocalizedData['VerboseClearCredential'] -f $Name)

                Invoke-AppCmd -ArgumentList 'set', 'apppool', $Name, '/processModel.userName:'
                Invoke-AppCmd -ArgumentList 'set', 'apppool', $Name, '/processModel.password:'
            }

            if ($PSBoundParameters.ContainsKey('restartSchedule'))
            {
                # Normalize the restartSchedule array values.
                $restartScheduleDesired = [String[]]@(
                    $restartSchedule.Where(
                        {
                            $_ -ne ''
                        }
                    ).ForEach(
                        {
                            [TimeSpan]::Parse($_).ToString('hh\:mm\:ss')
                        }
                    ) |
                    Select-Object -Unique
                )

                $restartScheduleCurrent = [String[]]@(
                    @($appPool.recycling.periodicRestart.schedule.Collection).ForEach('value')
                )

                Compare-Object -ReferenceObject $restartScheduleDesired `
                    -DifferenceObject $restartScheduleCurrent |
                        ForEach-Object -Process {

                            # Add value
                            if ($_.SideIndicator -eq '<=')
                            {
                                Write-Verbose -Message (
                                    $LocalizedData['VerboseRestartScheduleValueAdd'] -f
                                        $_.InputObject, $Name
                                )

                                Invoke-AppCmd -ArgumentList 'set', 'apppool', $Name, (
                                    "/+recycling.periodicRestart.schedule.[value='{0}']" -f $_.InputObject
                                )
                            }
                            # Remove value
                            else
                            {
                                Write-Verbose -Message (
                                    $LocalizedData['VerboseRestartScheduleValueRemove'] -f
                                        $_.InputObject, $Name
                                )

                                Invoke-AppCmd -ArgumentList 'set', 'apppool', $Name, (
                                    "/-recycling.periodicRestart.schedule.[value='{0}']" -f $_.InputObject
                                )
                            }

                        }
            }

            if ($PSBoundParameters.ContainsKey('State') -and $appPool.state -ne $State)
            {
                if ($State -eq 'Started')
                {
                    Write-Verbose -Message ($LocalizedData['VerboseStartAppPool'] -f $Name)

                    Start-WebAppPool -Name $Name -ErrorAction Stop
                }
                else
                {
                    Write-Verbose -Message ($LocalizedData['VerboseStopAppPool'] -f $Name)

                    Stop-WebAppPool -Name $Name -ErrorAction Stop
                }
            }
        }
    }
    else
    {
        # Remove Application Pool
        if ($null -ne $appPool)
        {
            Write-Verbose -Message ($LocalizedData['VerboseAppPoolFound'] -f $Name)

            if ($appPool.state -eq 'Started')
            {
                Write-Verbose -Message ($LocalizedData['VerboseStopAppPool'] -f $Name)

                Stop-WebAppPool -Name $Name -ErrorAction Stop
            }

            Write-Verbose -Message ($LocalizedData['VerboseRemoveAppPool'] -f $Name)

            Remove-WebAppPool -Name $Name -ErrorAction Stop
        }
        else
        {
            Write-Verbose -Message ($LocalizedData['VerboseAppPoolNotFound'] -f $Name)
        }
    }
}

function Test-TargetResource
{
    <#
    .SYNOPSIS
        This tests the desired state. If the state is not correct it will return $false.
        If the state is correct it will return $true
    #>

    [OutputType([Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateLength(1, 64)]
        [String] $Name,

        [ValidateSet('Present', 'Absent')]
        [String] $Ensure = 'Present',

        [ValidateSet('Started', 'Stopped')]
        [String] $State,

        [Boolean] $autoStart,

        [String] $CLRConfigFile,

        [Boolean] $enable32BitAppOnWin64,

        [Boolean] $enableConfigurationOverride,

        [ValidateSet('Integrated', 'Classic')]
        [String] $managedPipelineMode,

        [String] $managedRuntimeLoader,

        [ValidateSet('v4.0', 'v2.0', '')]
        [String] $managedRuntimeVersion,

        [Boolean] $passAnonymousToken,

        [ValidateSet('OnDemand', 'AlwaysRunning')]
        [String] $startMode,

        [ValidateRange(10, 65535)]
        [UInt32] $queueLength,

        [ValidateSet('NoAction', 'KillW3wp', 'Throttle', 'ThrottleUnderLoad')]
        [String] $cpuAction,

        [ValidateRange(0, 100000)]
        [UInt32] $cpuLimit,

        [ValidateScript({
            ([ValidateRange(0, 1440)]$valueInMinutes = [TimeSpan]::Parse($_).TotalMinutes); $?
        })]
        [String] $cpuResetInterval,

        [Boolean] $cpuSmpAffinitized,

        [UInt32] $cpuSmpProcessorAffinityMask,

        [UInt32] $cpuSmpProcessorAffinityMask2,

        [ValidateSet(
                'ApplicationPoolIdentity', 'LocalService', 'LocalSystem',
                'NetworkService', 'SpecificUser'
        )]
        [String] $identityType,

        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        [ValidateScript({
            ([ValidateRange(0, 43200)]$valueInMinutes = [TimeSpan]::Parse($_).TotalMinutes); $?
        })]
        [String] $idleTimeout,

        [ValidateSet('Terminate', 'Suspend')]
        [String] $idleTimeoutAction,

        [Boolean] $loadUserProfile,

        [String] $logEventOnProcessModel,

        [ValidateSet('LogonBatch', 'LogonService')]
        [String] $logonType,

        [Boolean] $manualGroupMembership,

        [ValidateRange(0, 2147483647)]
        [UInt32] $maxProcesses,

        [Boolean] $pingingEnabled,

        [ValidateScript({
            ([ValidateRange(1, 4294967)]$valueInSeconds = [TimeSpan]::Parse($_).TotalSeconds); $?
        })]
        [String] $pingInterval,

        [ValidateScript({
            ([ValidateRange(1, 4294967)]$valueInSeconds = [TimeSpan]::Parse($_).TotalSeconds); $?
        })]
        [String] $pingResponseTime,

        [Boolean] $setProfileEnvironment,

        [ValidateScript({
            ([ValidateRange(1, 4294967)]$valueInSeconds = [TimeSpan]::Parse($_).TotalSeconds); $?
        })]
        [String] $shutdownTimeLimit,

        [ValidateScript({
            ([ValidateRange(1, 4294967)]$valueInSeconds = [TimeSpan]::Parse($_).TotalSeconds); $?
        })]
        [String] $startupTimeLimit,

        [String] $orphanActionExe,

        [String] $orphanActionParams,

        [Boolean] $orphanWorkerProcess,

        [ValidateSet('HttpLevel', 'TcpLevel')]
        [String] $loadBalancerCapabilities,

        [Boolean] $rapidFailProtection,

        [ValidateScript({
            ([ValidateRange(1, 144000)]$valueInMinutes = [TimeSpan]::Parse($_).TotalMinutes); $?
        })]
        [String] $rapidFailProtectionInterval,

        [ValidateRange(0, 2147483647)]
        [UInt32] $rapidFailProtectionMaxCrashes,

        [String] $autoShutdownExe,

        [String] $autoShutdownParams,

        [Boolean] $disallowOverlappingRotation,

        [Boolean] $disallowRotationOnConfigChange,

        [String] $logEventOnRecycle,

        [UInt32] $restartMemoryLimit,

        [UInt32] $restartPrivateMemoryLimit,

        [UInt32] $restartRequestsLimit,

        [ValidateScript({
            ([ValidateRange(0, 432000)]$valueInMinutes = [TimeSpan]::Parse($_).TotalMinutes); $?
        })]
        [String] $restartTimeLimit,

        [ValidateScript({
            ($_ -eq '') -or
            (& {
                ([ValidateRange(0, 86399)]$valueInSeconds = [TimeSpan]::Parse($_).TotalSeconds); $?
            })
        })]
        [String[]] $restartSchedule
    )

    Assert-Module

    $inDesiredState = $true

    $appPool = Get-WebConfiguration -Filter '/system.applicationHost/applicationPools/add' |
        Where-Object -FilterScript {$_.name -eq $Name}

    if (
        ($Ensure -eq 'Absent' -and $null -ne $appPool) -or
        ($Ensure -eq 'Present' -and $null -eq $appPool)
    )
    {
        $inDesiredState = $false

        if ($null -ne $appPool)
        {
            Write-Verbose -Message ($LocalizedData['VerboseAppPoolFound'] -f $Name)
        }
        else
        {
            Write-Verbose -Message ($LocalizedData['VerboseAppPoolNotFound'] -f $Name)
        }

        Write-Verbose -Message ($LocalizedData['VerboseEnsureNotInDesiredState'] -f $Name)
    }

    if ($Ensure -eq 'Present' -and $null -ne $appPool)
    {
        Write-Verbose -Message ($LocalizedData['VerboseAppPoolFound'] -f $Name)

        $PropertyData.Where(
            {
                ($_.Name -in $PSBoundParameters.Keys) -and
                ($_.Name -ne 'restartSchedule')
            }
        ).ForEach(
            {
                $propertyName = $_.Name
                $propertyPath = $_.Path
                $property = Get-Property -Object $appPool -PropertyName $propertyPath

                if (
                    $PSBoundParameters[$propertyName] -ne $property
                )
                {
                    Write-Verbose -Message (
                        $LocalizedData['VerbosePropertyNotInDesiredState'] -f $propertyName, $Name
                    )

                    $inDesiredState = $false
                }
            }
        )

        if ($PSBoundParameters.ContainsKey('Credential'))
        {
            if ($PSBoundParameters['identityType'] -eq 'SpecificUser')
            {
                if ($appPool.processModel.userName -ne $Credential.UserName)
                {
                    Write-Verbose -Message (
                        $LocalizedData['VerbosePropertyNotInDesiredState'] -f
                            'Credential (userName)', $Name
                    )

                    $inDesiredState = $false
                }

                $clearTextPassword = $Credential.GetNetworkCredential().Password

                if ($appPool.processModel.password -cne $clearTextPassword)
                {
                    Write-Verbose -Message (
                        $LocalizedData['VerbosePropertyNotInDesiredState'] -f
                            'Credential (password)', $Name
                    )

                    $inDesiredState = $false
                }
            }
            else
            {
                Write-Verbose -Message ($LocalizedData['VerboseCredentialToBeIgnored'])
            }
        }

        # Ensure userName and password are cleared if identityType isn't set to SpecificUser.
        if (
            (
                (
                    ($PSBoundParameters.ContainsKey('identityType') -eq $true) -and
                    ($PSBoundParameters['identityType'] -ne 'SpecificUser')
                ) -or
                (
                    ($PSBoundParameters.ContainsKey('identityType') -eq $false) -and
                    ($appPool.processModel.identityType -ne 'SpecificUser')
                )
            ) -and
            (
                ([String]::IsNullOrEmpty($appPool.processModel.userName) -eq $false) -or
                ([String]::IsNullOrEmpty($appPool.processModel.password) -eq $false)
            )
        )
        {
            Write-Verbose -Message ($LocalizedData['VerboseCredentialToBeCleared'] -f $Name)

            $inDesiredState = $false
        }

        if ($PSBoundParameters.ContainsKey('restartSchedule'))
        {
            # Normalize the restartSchedule array values.
            $restartScheduleDesired = [String[]]@(
                $restartSchedule.Where(
                    {
                        $_ -ne ''
                    }
                ).ForEach(
                    {
                        [TimeSpan]::Parse($_).ToString('hh\:mm\:ss')
                    }
                ) |
                Select-Object -Unique
            )

            $restartScheduleCurrent = [String[]]@(
                @($appPool.recycling.periodicRestart.schedule.Collection).ForEach('value')
            )

            if (
                Compare-Object -ReferenceObject $restartScheduleDesired `
                    -DifferenceObject $restartScheduleCurrent
            )
            {
                Write-Verbose -Message (
                    $LocalizedData['VerbosePropertyNotInDesiredState'] -f 'restartSchedule', $Name
                )

                $inDesiredState = $false
            }
        }
    }

    if ($inDesiredState -eq $true)
    {
        Write-Verbose -Message ($LocalizedData['VerboseResourceInDesiredState'])
    }
    else
    {
        Write-Verbose -Message ($LocalizedData['VerboseResourceNotInDesiredState'])
    }

    return $inDesiredState
}

#region Helper Functions

function Get-Property 
{
    param 
    (
        [object] $Object,
        [string] $PropertyName)

    $parts = $PropertyName.Split('.')
    $firstPart = $parts[0]

    $value = $Object.$firstPart
    if($parts.Count -gt 1)
    {
        $newParts = @()
        1..($parts.Count -1) | ForEach-Object{
            $newParts += $parts[$_]
        }

        $newName = ($newParts -join '.')
        return Get-Property -Object $value -PropertyName $newName
    }
    else
    {
        return $value
    }
} 

<#
    .SYNOPSIS
        Runs appcmd.exe - if there's an error then the application will terminate
        
    .PARAMETER ArgumentList
        Optional list of string arguments to be passed into appcmd.exe    

#>
function Invoke-AppCmd
{
    [CmdletBinding()]
    param
    (
        [String[]] $ArgumentList
    )

    <# 
            This is a local preference for the function which will terminate
            the program if there's an error invoking appcmd.exe
    #>
    $ErrorActionPreference = 'Stop'

    $appcmdFilePath = "$env:SystemRoot\System32\inetsrv\appcmd.exe"
    
    $appcmdResult = $(& $appcmdFilePath $ArgumentList)
    Write-Verbose -Message $appcmdResult

    if ($LASTEXITCODE -ne 0)
    {
        $errorMessage = $LocalizedData['ErrorAppCmdNonZeroExitCode'] -f $LASTEXITCODE

        New-TerminatingError -ErrorId 'ErrorAppCmdNonZeroExitCode' `
            -ErrorMessage $errorMessage `
            -ErrorCategory 'InvalidResult'
    }
}

#endregion Helper Functions

Export-ModuleMember -Function *-TargetResource
