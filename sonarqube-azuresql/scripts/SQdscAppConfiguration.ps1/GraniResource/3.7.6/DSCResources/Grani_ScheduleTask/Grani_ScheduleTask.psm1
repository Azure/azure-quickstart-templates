#region Initialize

function Initialize
{
    # Enum for Ensure
    Add-Type -TypeDefinition @"
        public enum EnsureType
        {
            Present,
            Absent
        }
"@ -ErrorAction SilentlyContinue

    #-- PublicEnum Enum for ScheduledTaskTest --#
    Add-Type -TypeDefinition @"
        public enum ScheduledParameterType
        {
            Root,
            Actions,
            Principal,
            Settings,
            Triggers
        }
"@ -ErrorAction SilentlyContinue

    #-- PublicEnum Enum for ScheduledTaskTest Property --#
    Add-Type -TypeDefinition @"
        public enum ScheduledTaskPropertyType
        {
            TaskName,
            Description,
            Execute,
            Argument,
            WorkingDirectory,
            Credential,
            RunLevel,
            Compatibility,
            ExecutionTimeLimit,
            Hidden,
            Disable,
            ScheduledAt,
            RepetitionIntervalTimeSpanString,
            RepetitionDurationTimeSpanString,
            Daily,
            Once,
            AtSartup,
            AtLogOn,
            AtLogOnUserId
        }
"@ -ErrorAction SilentlyContinue
}

Initialize

#endregion

#region Message Definition

$verboseMessages = Data {
    ConvertFrom-StringData -StringData @"
        EnsureDetectAbsent = Ensure detected as Absent. Removing existing ScheduledTask for TaskPath '{0}', TaskName '{1}'.
        EnsureDetectPresent = Ensure detected as Present. Setting ScheduledTask for TaskPath '{0}', TaskName '{1}'.
        DisableDetected = Disabled detected as $true. Disabling task and exit configuration.
"@
}

$debugMessages = Data {
    ConvertFrom-StringData -StringData @"
        CheckSchedulerAtLogOn = Checking Trigger is : AtLogOn
        CheckSchedulerAtStartup = Checking Trigger is : AtStartup
        CheckSchedulerDaily = Checking Trigger is : Daily
        CheckSchedulerOnce = Checking Trigger is : Once
        CheckScheduleTaskExist = Checking {0} is exists with : {1}
        CheckScheduleTaskParameter = Checking {0} is match with : {1}
        CheckScheduleTaskParameterTimeSpan = Checking {0} is match with : {1}min
        CheckSchedulerUserId = Checking UserId is exists with : {0}
        CreateTask = Creating Task Scheduler Name '{0}', Path '{1}'
        ScheduleTaskResult = {0} : {1} ({2})
        ScheduleTaskTimeSpanResult = {0} : {1} ({2}min)
        SetAction = Setting Action Execute : '{0}', Argument : '{1}', WorkingDirectory : '{2}'.
        SetDescription = Setting Description : '{0}'.
        SetDisable = Setting ScheduledTask Disable : '{0}'.
        SetTrigger = Setting Trigger RepetitionIntervalTimeSpanString : '{0}', RepetitionDurationTimeSpanString : '{1}', ScheduledAt : '{2}', Daily : '{3}', Once : '{4}'.
        SkipNoneUseParameter = Skipping {0} as value not passed to function.
        SkipNullPassedParameter = Skipping {0} as passed value is null.
        SkipPrincipal = Skip Credential. Using System for Principal.
        UsePrincipal = Using principal with Credential. Execution will be fail if not elevated.
        ValidateTaskPathChar = Validated Task Path for {0} char expected to be '\\' but was not. Add '\\'. TaskPath : {1}, NewTaskPath : {2}
"@
}

$errorMessages = Data {
    ConvertFrom-StringData -StringData @"
        InvalidTrigger = Invalid Operation detected, you can't set same or greater timespan for RepetitionInterval '{0}' than RepetitionDuration '{1}'.
        ExecuteBrank = Invalid Operation detected, Execute detected as blank. You must set executable string.
        ScheduleAtArgumentLength = Argument length not match with current ScheduledAt {0} and passed ScheduledAt {1}.
        ScheduleRepetitionArgumentLength = Argument length not match with current Scheduled Repetition {0} and passed ScheduledAt {1}.
        ScheduleAtNullException = ScheduledAt detected as null. You must set at least 1 ScheduledAt to set ScheduledTask as Present.
        ScheduleTriggerNullException = None of Schedule trigger detected. Please set one of trigger from : RepetitionIntervalTimeSpanString, RepetitionDurationTimeSpanString, Daily, Once, AtSartup, AtLogOn
"@
}

#endregion

#region *-TargetResource

function Get-TargetResource
{
    [OutputType([HashTable])]
    [CmdletBinding(DefaultParameterSetName = "Repetition")]
    param
    (
        [parameter(Mandatory = $true)]
        [ValidateSet("Present","Absent")]
        [System.String]$Ensure,

        [parameter(Mandatory = $true)]
        [System.String]$TaskName,

        [parameter(Mandatory = $false)]
        [System.String]$TaskPath = "\",

        [parameter(Mandatory = $false)]
        [System.String]$Description,

        [parameter(Mandatory = $false)]
        [System.String]$Execute,

        [parameter(Mandatory = $false)]
        [System.String]$Argument,

        [parameter(Mandatory = $false)]
        [System.String]$WorkingDirectory,

        [parameter(Mandatory = $false)]
        [System.Management.Automation.PSCredential]$Credential = [PSCredential]::Empty,

        [parameter(Mandatory = $false)]
        [ValidateSet("Highest","Limited")]
        [System.String]$Runlevel,

        [parameter(Mandatory = $false)]
        [ValidateSet("At","Win8","Win7","Vista","V1")]
        [System.String]$Compatibility,

        [parameter(Mandatory = $false)]
        [System.Int64]$ExecuteTimeLimitTicks = [TimeSpan]::FromDays(3).Ticks,

        [parameter(Mandatory = $false)]
        [System.Boolean]$Hidden,

        [parameter(Mandatory = $false)]
        [System.Boolean]$Disable = $true,

        [parameter(Mandatory = $false)]
        [System.DateTime[]]$ScheduledAt,

        [parameter(Mandatory = $false, parameterSetName = "Repetition")]
        [string[]]$RepetitionIntervalTimeSpanString = @([TimeSpan]::FromHours(1).ToString()),

        [parameter(Mandatory = $false, parameterSetName = "Repetition")]
        [string[]]$RepetitionDurationTimeSpanString = @([TimeSpan]::MaxValue.ToString()),

        [parameter(Mandatory = $false, parameterSetName = "Daily")]
        [System.Boolean]$Daily,

        [parameter(Mandatory = $false, parameterSetName = "Once")]
        [System.Boolean]$Once,

        [parameter(Mandatory = $false, parameterSetName = "AtStartup")]
        [System.Boolean]$AtStartup,

        [parameter(Mandatory = $false, parameterSetName = "AtLogOn")]
        [System.Boolean]$AtLogOn,

        [parameter(Mandatory = $false, parameterSetName = "AtLogOn")]
        [System.String]$AtLogOnUserId = ""
    )

    $param = @{}

    # Task Path validation
    $validatedTaskPath = ValidateTaskPathLastChar -taskPath $taskPath
    $param.TaskPath = ValidateTaskPathFirstChar -taskPath $validatedTaskPath

    if ($Disable)
    {
        Write-Debug "Disable"
        @(
            'TaskName',
            'Disable'
        ) `
        | where {$PSBoundParameters.ContainsKey($_)} `
        | %{ $param.$_ = Get-Variable -Name $_ -ValueOnly }
    }
    else
    {
        # Credential param
        if (($PSBoundParameters.ContainsKey("Credential")) -or ([PSCredential]::Empty -ne $Credential))
        {
            $param.Credential = $Credential
        }

        # Trigger param
        if ($PSBoundParameters.ContainsKey("Once"))
        {
            $param.Once = $Once
        }
        elseif ($PSBoundParameters.ContainsKey("Daily"))
        {
            $param.Daily = $Daily
        }
        elseif ($PSBoundParameters.ContainsKey("AtStartup"))
        {
            $param.AtStartup = $AtStartup
        }
        elseif ($PSBoundParameters.ContainsKey("AtLogOn"))
        {
            $param.AtLogOn = $AtLogOn
            $param.AtLogOnUserId = $AtLogOnUserId
        }
        else
        {
            if ($PSBoundParameters.ContainsKey('RepetitionIntervalTimeSpanString') -and (-not $RepetitionIntervalTimeSpanString.Contains("")))
            {
                $param.RepetitionInterval = ConvertToTimeSpan -TimeSpanString $RepetitionIntervalTimeSpanString
            }

            if ($PSBoundParameters.ContainsKey('RepetitionDurationTimeSpanString') -and (-not $RepetitionDurationTimeSpanString.Contains("")))
            {
                $param.RepetitionDuration = ConvertToTimeSpan -TimeSpanString $RepetitionDurationTimeSpanString
            }
        }

        # ExecutionTimelimit param
        Write-Verbose $PSBoundParameters.ContainsKey("ExecuteTimeLimitTicks")
        if ($PSBoundParameters.ContainsKey("ExecuteTimeLimitTicks")){ $param.ExecutionTimeLimit = [TimeSpan]::FromTicks($ExecuteTimeLimitTicks) }

        # obtain other param
        @(
            'TaskName',
            'Description', 
            'Execute', 
            'Argument', 
            'WorkingDirectory', 
            'Runlevel',
            'Compatibility',
            'Hidden',
            'Disable', 
            'ScheduledAt'
        ) `
        | where {$PSBoundParameters.ContainsKey($_)} `
        | %{ $param.$_ = Get-Variable -Name $_ -ValueOnly }
    }

    # Test current ScheduledTask
    $taskResult = TestScheduledTaskStatus @param

    # ensure check
    $ensureResult = if (($taskResult.GetEnumerator() | %{$_.Value.result}) -contains $false)
    {
        [EnsureType]::Absent
    }
    else
    {
        [EnsureType]::Present
    }

    # return hashtable    
    $returnHash = [ordered]@{}
    $returnHash.Ensure = $ensureResult
    @(
        # root
        'TaskName',
        'TaskPath',
        'Description', 

        # Action
        'Execute', 
        'Argument', 
        'WorkingDirectory', 

        # Principal
        'Runlevel',

        # settings
        'Compatibility',
        'Hidden',
        'Disable',

        # Trigger
        'ScheduledAt',
        'Daily',
        'Once',
        'AtStartup',
        'AtLogOn',
        'AtLogOnUserId'
    ) `
    | where {$taskResult."$_".target -ne $null} `
    | %{$returnHash.$_ = $taskResult."$_".target}

    # convert credential to CIM Instance
    if (($PSBoundParameters.ContainsKey("Credential")))
    {
        $returnHash.Credential = New-CimInstance -ClassName MSFT_Credential -Property @{Username=[string]$Credential.UserName; Password=[string]$null} -Namespace root/microsoft/windows/desiredstateconfiguration -ClientOnly
    }

    # convert timespan to string
    if (($PSBoundParameters.ContainsKey("ExecuteTimeLimitTicks")) -and ($taskResult.ExecutionTimeLimit.target.Ticks -ne $null))
    {
        $returnHash.ExecuteTimeLimitTicks = [System.Int64]$taskResult.ExecutionTimeLimit.target.Ticks
    }
    if ($PSBoundParameters.ContainsKey("RepetitionIntervalTimeSpanString"))
    {
        $returnHash.RepetitionIntervalTimeSpanString = $taskResult.RepetitionInterval.target | where {$_} | %{$_.ToString()}
    }
    if ($PSBoundParameters.ContainsKey("RepetitionDurationTimeSpanString"))
    {
        $returnHash.RepetitionDurationTimeSpanString = $taskResult.RepetitionDuration.target | where {$_} | %{$_.ToString()}
    }

    return $returnHash
}

function Set-TargetResource
{
    [OutputType([Void])]
    [CmdletBinding(DefaultParameterSetName = "Repetition")]
    param
    (
        [parameter(Mandatory = $true)]
        [ValidateSet("Present","Absent")]
        [System.String]$Ensure,

        [parameter(Mandatory = $true)]
        [System.String]$TaskName,

        [parameter(Mandatory = $false)]
        [System.String]$TaskPath = "\",

        [parameter(Mandatory = $false)]
        [System.String]$Description,

        [parameter(Mandatory = $false)]
        [System.String]$Execute = [string]::Empty,

        [parameter(Mandatory = $false)]
        [System.String]$Argument = [string]::Empty,

        [parameter(Mandatory = $false)]
        [System.String]$WorkingDirectory = [string]::Empty,

        [parameter(Mandatory = $false)]
        [System.Management.Automation.PSCredential]$Credential = [PSCredential]::Empty,

        [parameter(Mandatory = $false)]
        [ValidateSet("Highest","Limited")]
        [System.String]$Runlevel = "Limited",

        [parameter(Mandatory = $false)]
        [ValidateSet("At","Win8","Win7","Vista","V1")]
        [System.String]$Compatibility = "Win8",

        [parameter(Mandatory = $false)]
        [System.Int64]$ExecuteTimeLimitTicks = [TimeSpan]::FromDays(3).Ticks,

        [parameter(Mandatory = $false)]
        [System.Boolean]$Hidden = $true,

        [parameter(Mandatory = $false)]
        [System.Boolean]$Disable = $true,

        [parameter(Mandatory = $false)]
        [System.DateTime[]]$ScheduledAt,

        [parameter(Mandatory = $false, parameterSetName = "Repetition")]
        [string[]]$RepetitionIntervalTimeSpanString = @([TimeSpan]::FromHours(1).ToString()),

        [parameter(Mandatory = $false, parameterSetName = "Repetition")]
        [string[]]$RepetitionDurationTimeSpanString = @([TimeSpan]::MaxValue.ToString()),

        [parameter(Mandatory = $false, parameterSetName = "Daily")]
        [System.Boolean]$Daily = $false,

        [parameter(Mandatory = $false, parameterSetName = "Once")]
        [System.Boolean]$Once,

        [parameter(Mandatory = $false, parameterSetName = "AtStartup")]
        [System.Boolean]$AtStartup,

        [parameter(Mandatory = $false, parameterSetName = "AtLogOn")]
        [System.Boolean]$AtLogOn,

        [parameter(Mandatory = $false, parameterSetName = "AtLogOn")]
        [System.String]$AtLogOnUserId = ""
    )
    
    # Task Path validation
    $validatedTaskPath = ValidateTaskPathLastChar -taskPath $TaskPath
    $newTaskPath = ValidateTaskPathFirstChar -taskPath $validatedTaskPath

    # Get Existing Schedule Task
    $existingTaskParam = 
    @{
        TaskName = $taskName
        TaskPath = $newTaskPath
    }
    $existingTask = GetExistingTaskScheduler @existingTaskParam

    #region Absent

    if ($Ensure -eq "Absent")
    {
        Write-Verbose ($verboseMessages.EnsureDetectAbsent -f $newTaskPath, $TaskName)
        $existingTask | Unregister-ScheduledTask -Confirm:$false > $null;
        RemoveScheduledTaskEmptyDirectoryPath
        return;
    }

    #endregion

    #region Present

    Write-Verbose ($verboseMessages.EnsureDetectPresent -f $newTaskPath, $TaskName)
    
    # Enable/Disable
    if (($existingTask | measure).Count -ne 0)
    {
        Write-Debug ($debugMessages.SetDisable -f $Disable)
        switch ($Disable)
        {
            $true {
                Write-Verbose ($verboseMessages.DisableDetected -f $newTaskPath, $TaskName)
                $existingTask | Disable-ScheduledTask
                return
            }
            $false {
                $existingTask | Enable-ScheduledTask
            }
        }
    }

    # validation
    ValidateSameFolderNotExist @existingTaskParam

    $scheduleTaskParam = @{}

    # description
    if (-not [string]::IsNullOrWhiteSpace($Description))
    {
        Write-Debug ($debugMessages.SetDescription -f $Description)
        $scheduleTaskParam.description = $Description
    }

    # action
    Write-Debug ($debugMessages.SetAction -f $Execute, $Argument, $WorkingDirectory)
    $actionParam = 
    @{
        Execute = $Execute
        Argument = $Argument
        WorkingDirectory = $WorkingDirectory
    }
    $scheduleTaskParam.action = CreateTaskSchedulerAction @actionParam

    # trigger
    if ($ScheduledAt -ne $null)
    {
        if ($Daily -or $Once)
        {
            $interval = $duration = $null
        }
        elseif (($null -eq $RepetitionIntervalTimeSpanString) -and ($null -eq $RepetitionDurationTimeSpanString))
        {
            $interval = $duration = $null
        }
        elseif ((-not $RepetitionIntervalTimeSpanString.Contains("")) -and (-not $RepetitionDurationTimeSpanString.Contains("")))
        {
            $interval = ConvertToTimeSpan -TimeSpanString $RepetitionIntervalTimeSpanString
            $duration = ConvertToTimeSpan -TimeSpanString $RepetitionDurationTimeSpanString
        }
        else
        {
            $interval = $duration = $null
        }
    }
    elseif ($AtStartup -or $AtLogOn)
    {
        # Both AtStartup and $AtLogOn cannot use with $ScheduledAt
        $interval = $duration = $ScheduledAt = $null
    }

    Write-Debug ($debugMessages.SetTrigger -f $interval, $duration, $ScheduledAt, $Daily, $Once, $AtStartup, $AtLogOn)
    $triggerParam =
    @{
        RepetitionInterval = $interval
        RepetitionDuration = $duration
        ScheduledAt = $ScheduledAt
        Daily = $Daily
        Once = $Once
        AtStartup = $AtStartup
        AtLogOn = $AtLogOn
        LogOnUserId = $AtLogOnUserId
    }
    $scheduleTaskParam.trigger = CreateTaskSchedulerTrigger @triggerParam

    # settings
    $scheduleTaskParam.settings = if ($PSBoundParameters.ContainsKey('ExecuteTimeLimitTicks'))
    {
        New-ScheduledTaskSettingsSet -Disable:$Disable -Hidden:$Hidden -Compatibility $Compatibility -ExecutionTimeLimit (TicksToTimeSpan -Ticks $ExecuteTimeLimitTicks)
    }
    else
    {
        New-ScheduledTaskSettingsSet -Disable:$Disable -Hidden:$Hidden -Compatibility $Compatibility
    }

    # Register ScheduledTask
    $registerParam = GetRegisterParam -Credential $Credential -Runlevel $Runlevel -TaskName $TaskName -TaskPath $newTaskPath -scheduleTaskParam $scheduleTaskParam
    Register-ScheduledTask @registerParam -Force | select * | Out-String | Write-Debug

    #endregion
}

function Test-TargetResource
{
    [OutputType([Bool])]
    [CmdletBinding(DefaultParameterSetName = "Repetition")]
    param
    (
        [parameter(Mandatory = $true)]
        [ValidateSet("Present","Absent")]
        [System.String]$Ensure,

        [parameter(Mandatory = $true)]
        [System.String]$TaskName,

        [parameter(Mandatory = $false)]
        [System.String]$TaskPath = "\",

        [parameter(Mandatory = $false)]
        [System.String]$Description,

        [parameter(Mandatory = $false)]
        [System.String]$Execute,

        [parameter(Mandatory = $false)]
        [System.String]$Argument,

        [parameter(Mandatory = $false)]
        [System.String]$WorkingDirectory,

        [parameter(Mandatory = $false)]
        [System.Management.Automation.PSCredential]$Credential = [PSCredential]::Empty,

        [parameter(Mandatory = $false)]
        [ValidateSet("Highest","Limited")]
        [System.String]$Runlevel,

        [parameter(Mandatory = $false)]
        [ValidateSet("At","Win8","Win7","Vista","V1")]
        [System.String]$Compatibility,

        [parameter(Mandatory = $false)]
        [System.Int64]$ExecuteTimeLimitTicks = [TimeSpan]::FromDays(3).Ticks,

        [parameter(Mandatory = $false)]
        [System.Boolean]$Hidden,

        [parameter(Mandatory = $false)]
        [System.Boolean]$Disable = $true,

        [parameter(Mandatory = $false)]
        [System.DateTime[]]$ScheduledAt,

        [parameter(Mandatory = $false, parameterSetName = "Repetition")]
        [string[]]$RepetitionIntervalTimeSpanString = @([TimeSpan]::FromHours(1).ToString()),

        [parameter(Mandatory = $false, parameterSetName = "Repetition")]
        [string[]]$RepetitionDurationTimeSpanString = @([TimeSpan]::MaxValue.ToString()),

        [parameter(Mandatory = $false, parameterSetName = "Daily")]
        [System.Boolean]$Daily,

        [parameter(Mandatory = $false, parameterSetName = "Once")]
        [System.Boolean]$Once,

        [parameter(Mandatory = $false, parameterSetName = "AtStartup")]
        [System.Boolean]$AtStartup,

        [parameter(Mandatory = $false, parameterSetName = "AtLogOn")]
        [System.Boolean]$AtLogOn,

        [parameter(Mandatory = $false, parameterSetName = "AtLogOn")]
        [System.String]$AtLogOnUserId = ""
    )

    $param = @{}

    # obtain other param
    @(
        'Ensure',
        'TaskName',
        'TaskPath'
        'Description', 
        'Execute', 
        'Argument', 
        'WorkingDirectory', 
        'Credential', 
        'Runlevel',
        'Compatibility',
        'ExecuteTimeLimitTicks',
        'Hidden',
        'Disable', 
        'ScheduledAt',
        'RepetitionIntervalTimeSpanString',
        'RepetitionDurationTimeSpanString',
        'Daily',
        'Once',
        'AtStartup',
        'AtLogOn',
        'AtLogOnUserId'
    ) `
    | where {$PSBoundParameters.ContainsKey($_)} `
    | %{ $param.$_ = Get-Variable -Name $_ -ValueOnly }
    return (Get-TargetResource @param).Ensure -eq $Ensure
}

#endregion

#region Validate Helper

function ValidateTaskPathLastChar
{
    [OutputType([Void])]
    [CmdletBinding()]
    param
    (
        [string]$TaskPath
    )

    $newTaskPath = $TaskPath;
    $lastChar = [System.Linq.Enumerable]::ToArray($TaskPath) | select -Last 1
    if ($lastChar -ne "\")
    {
        $newTaskPath = $TaskPath + "\";
        Write-Debug ($debugMessages.ValidateTaskPathChar -f "Last", $TaskPath, $newTaskPath);
    }
    return $newTaskPath
}

function ValidateTaskPathFirstChar
{
    [OutputType([Void])]
    [CmdletBinding()]
    param
    (
        [string]$TaskPath
    )
    
    $newTaskPath = $TaskPath;
    $firstChar = [System.Linq.Enumerable]::ToArray($TaskPath) | select -First 1;
    if ($firstChar -ne "\")
    {
        $newTaskPath = "\" + $TaskPath;
        Write-Debug ($debugMessages.ValidateTaskPathChar -f "First", $TaskPath, $newTaskPath);
    }
    return $newTaskPath
}

function ValidateSameFolderNotExist
{
    [OutputType([Void])]
    [CmdletBinding()]
    param
    (
        [string]$TaskName,
        [string]$TaskPath
    )

    if (TestExistingTaskSchedulerWithPath -TaskName $TaskName -TaskPath $TaskPath){ throw New-Object System.InvalidOperationException ($errorMessages.SameNameFolderFound -f $taskName) }
}

#endregion

#region Create Helper

function CreateTaskSchedulerAction 
{
    [CmdletBinding()]
    param
    (
        [string]$Argument,
        [string]$Execute,
        [string]$WorkingDirectory
    )
    if ($Execute -eq [string]::Empty){ throw New-Object System.InvalidOperationException ($errorMessages.ExecuteBrank) }

    $param = @{}
    $param.Execute = $Execute
    if ($Argument -ne [string]::Empty){ $param.Argument = $Argument }
    if ($WorkingDirectory -ne [string]::Empty){ $param.WorkingDirectory = $WorkingDirectory }
    return New-ScheduledTaskAction @param
}

function ConvertToTimeSpan
{
    [OutputType([TimeSpan[]])]
    [CmdletBinding()]
    param(
        [parameter(Mandatory = $false, Position  = 0)]
        [ValidateNotNullOrEmpty()]
        [string[]]$TimeSpanString
    )

    foreach ($x in $TimeSpanString)
    {
        if (-not [string]::IsNullOrWhiteSpace($TimeSpanString))
        {
            [TimeSpan]$result = New-Object System.TimeSpan;
            if (![TimeSpan]::TryParse($x, [ref]$result))
            {
                [TimeSpan]::MaxValue
            }
            else
            {
                $result
            }
        }
    }
}

function CreateTaskSchedulerTrigger
{
    [CmdletBinding()]
    param
    (
        [TimeSpan[]]$RepetitionInterval,
        [TimeSpan[]]$RepetitionDuration,
        [DateTime[]]$ScheduledAt,
        [bool]$Daily,
        [bool]$Once,
        [bool]$AtStartup,
        [bool]$AtLogOn,
        [string]$LogOnUserId
    )

    $trigger = if (($false -eq $Daily) -and ($false -eq $Once) -and ($false -eq $AtStartup) -and ($false -eq $AtLogOn))
    {
        $repetitionPair = New-ZipPairs -first $RepetitionInterval -Second $RepetitionDuration
        $ScheduledAtPair = New-ZipPairs -first $ScheduledAt -Second $repetitionPair
        $ScheduledAtPair `
        | %{
            if ($_.Item2.Item1 -ge $_.Item2.Item2){ throw New-Object System.InvalidOperationException ($errorMessages.InvalidTrigger -f $_.Item2.Item1, $_.Item2.Item2)}
            New-ScheduledTaskTrigger -At $_.Item1 -RepetitionInterval $_.Item2.Item1 -RepetitionDuration $_.Item2.Item2 -Once
        }
    }
    elseif ($Daily)
    {
        $ScheduledAt | %{New-ScheduledTaskTrigger -At $_ -Daily}
    }
    elseif ($Once)
    {
        $ScheduledAt | %{New-ScheduledTaskTrigger -At $_ -Once}
    }
    elseif ($AtStartup)
    {
        New-ScheduledTaskTrigger -AtStartup
    }
    elseif ($AtLogOn)
    {
        if (-not ([string]::IsNullOrWhiteSpace($LogOnUserId)))
        {
            New-ScheduledTaskTrigger -AtLogOn -User $LogOnUserId
        }
        else
        {
            New-ScheduledTaskTrigger -AtLogOn
        }
        
    }
    return $trigger
}

#endregion

#region Convert Helper

function TicksToTimeSpan
{
    [OutputType([System.TimeSpan])]
    [CmdletBinding()]
    param
    (
        [System.Int64]$Ticks
    )
    return [TimeSpan]::FromTicks($Ticks)
}

#endregion

#region Get Helper

function GetExistingTaskScheduler
{
    [CmdletBinding()]
    param
    (
        [string]$TaskName,
        [string]$TaskPath
    )
    return Get-ScheduledTask | where TaskName -eq $TaskName | where TaskPath -eq $TaskPath
}

function GetRegisterParam
{
    [OutputType([HashTable])]
    [CmdletBinding()]
    param
    (
        $Credential,
        $Runlevel,
        [string]$TaskName,
        [string]$TaskPath,
        $scheduleTaskParam
    )

    if (([PSCredential]::Empty -ne $Credential) -and ("SYSTEM" -ne $Credential.UserName))
    {
        Write-Debug $debugMessages.UsePrincipal
        # Principal
        $principalParam = 
        @{
            UserId = $Credential.UserName
            RunLevel = $Runlevel
            LogOnType = "InteractiveOrPassword"
        }
        $scheduleTaskParam.principal = New-ScheduledTaskPrincipal @principalParam

        # return
        return @{
            InputObject = New-ScheduledTask @scheduleTaskParam
            TaskName = $TaskName
            TaskPath = $TaskPath
            User = $Credential.UserName
            Password = $Credential.GetNetworkCredential().Password
        }
    }
    else
    {
        Write-Debug $debugMessages.SkipPrincipal
        $principalParam = 
        @{
            Id = "Author"
            UserId = "SYSTEM"
            RunLevel = $Runlevel
            LogOnType = "ServiceAccount"
            ProcessTokenSidType = "Default"
        }
        $scheduleTaskParam.principal = New-ScheduledTaskPrincipal @principalParam 

        # return
        return @{
            InputObject = New-ScheduledTask @scheduleTaskParam
            TaskName = $TaskName
            TaskPath = $TaskPath
        }
    }
}

#endregion

#region Test Helper

function TestExistingTaskScheduler
{
    [OutputType([bool])]
    [CmdletBinding()]
    param
    (
        [string]$TaskName,
        [string]$TaskPath
    )

    $task = GetExistingTaskScheduler -TaskName $TaskName -TaskPath $TaskPath
    return ($task | Measure-Object).count -ne 0
}

function TestExistingTaskSchedulerWithPath
{
    [OutputType([bool])]
    [CmdletBinding()]
    param
    (
        [string]$TaskName,
        [string]$TaskPath
    )

    if ($TaskPath -ne "\"){ return $false }

    # only run when taskpath is \
    $path = Join-Path $env:windir "System32\Tasks"
    $result = Get-ChildItem -Path $path -Directory | where Name -eq $TaskName

    if (($result | measure).count -ne 0)
    {
        return $true
    }
    return $false
}

function GetScheduledTask
{
    [OutputType([HashTable])]
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [Microsoft.Management.Infrastructure.CimInstance[]]$ScheduledTask,

        [parameter(Mandatory = $true)]
        [string]$Parameter,

        [parameter(Mandatory = $true)]
        [string]$Value
    )

    Write-Debug ($debugMessages.CheckScheduleTaskExist -f $parameter, $Value)
    $task = $ScheduledTask | where $Parameter -eq $Value
    $uniqueValue = $task.$Parameter | sort -Unique
    $result = $uniqueValue -eq $Value
    Write-Debug ($debugMessages.ScheduleTaskResult -f $Parameter, $result, $uniqueValue)
    return @{
        task = $task
        target = $uniqueValue
        result = $result
    }
}

function TestScheduledTask
{
    [OutputType([bool])]
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [Microsoft.Management.Infrastructure.CimInstance]$ScheduledTask,

        [parameter(Mandatory = $true)]
        [ScheduledParameterType]$Type,

        [parameter(Mandatory = $true)]
        [string]$Parameter,

        [parameter(Mandatory = $false)]
        [PSObject]$Value,

        [bool]$IsExist
    )

    # skip when Parameter not use
    if ($IsExist -eq $false)
    {
        Write-Debug ($debugMessages.SkipNoneUseParameter -f $Parameter)
        return @{
            target = $null
            result = $true
        }
    }

    # skip null
    if ($Value -eq $null)
    {
        Write-Debug ($debugMessages.SkipNullPassedParameter -f $Parameter)
        return @{
            target = $null
            result = $true
        }
    }

    Write-Debug ($debugMessages.CheckScheduleTaskParameter -f $Parameter, $Value)
    $target = switch ($Type)
    {
        ([ScheduledParameterType]::Root)
        {
            $ScheduledTask.$Parameter | sort -Unique
        }
        ([ScheduledParameterType]::Actions)
        {
            $ScheduledTask.Actions.$Parameter | sort -Unique
        }
        ([ScheduledParameterType]::Principal)
        {
            $ScheduledTask.Principal.$Parameter | sort -Unique
        }
        ([ScheduledParameterType]::Settings)
        {
            $ScheduledTask.Settings.$Parameter | sort -Unique
        }
        ([ScheduledParameterType]::Triggers)
        {
            $ScheduledTask.Triggers.$Parameter | sort -Unique
        }
    }
            
    if ($Value.GetType().FullName -eq [string].FullName)
    {
        if (($target -eq $null) -and ([string]::IsNullOrEmpty($Value)))
        {
            return @{
                target = $target
                result = $true
            }
            Write-Debug ($debugMessages.ScheduleTaskResult -f $Parameter, $result, $target)
        }
    }

    # value check
    $result = $target -eq $Value
    Write-Debug ($debugMessages.ScheduleTaskResult -f $Parameter, $result, $target)
    return @{
        target = $target
        result = $result
    }
}

function TestScheduledTaskExecutionTimeLimit
{
    [OutputType([bool])]
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [Microsoft.Management.Infrastructure.CimInstance]$ScheduledTask,

        [parameter(Mandatory = $false)]
        [PSObject]$Value,

        [bool]$IsExist
    )

    $private:parameter = "ExecutionTimeLimit"

    # skip when Parameter not use
    if ($IsExist -eq $false)
    {
        Write-Debug ($debugMessages.SkipNoneUseParameter -f $Parameter)
        return @{
            target = $null
            result = $true
        }
    }

    # skip null
    if ($Value -eq $null)
    {
        Write-Debug ($debugMessages.SkipNullPassedParameter -f $Parameter)
        return @{
            target = $null
            result = $true
        }
    }

    $Value = $Value -as [TimeSpan]
    Write-Debug ($debugMessages.CheckScheduleTaskParameterTimeSpan -f $parameter, $Value.TotalMinutes)
    $executionTimeLimitTimeSpan = [System.Xml.XmlConvert]::ToTimeSpan($ScheduledTask.Settings.$parameter)
    $result = $Value -eq $executionTimeLimitTimeSpan
    Write-Debug ($debugMessages.ScheduleTaskTimeSpanResult -f $parameter, $result, $executionTimeLimitTimeSpan.TotalMinutes)
    return @{
        target = $executionTimeLimitTimeSpan
        result = $result
    }
}

function TestScheduledTaskDisable
{
    [OutputType([bool])]
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [Microsoft.Management.Infrastructure.CimInstance]$ScheduledTask,

        [parameter(Mandatory = $false)]
        [PSObject]$Value,

        [bool]$IsExist
    )

    # skip when Parameter not use
    if ($IsExist -eq $false)
    {
        Write-Debug ($debugMessages.SkipNoneUseParameter -f $Parameter)
        return @{
            target = $null
            result = $true
        }
    }

    # convert Enable -> Disable
    $target = $ScheduledTask.Settings.Enabled -eq $false
            
    # value check
    Write-Debug ($debugMessages.CheckScheduleTaskParameter -f "Disable", $Value)
    $result = $target -eq $Value
    Write-Debug ($debugMessages.ScheduleTaskResult -f "Disable", $result, $target)
    return @{
        target = $target
        result = $result
    }
}

function TestScheduledTaskScheduledAt
{
    [OutputType([bool])]
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [Microsoft.Management.Infrastructure.CimInstance]$ScheduledTask,

        [parameter(Mandatory = $false)]
        [DateTime[]]$Value,

        [bool]$IsExist
    )

    $private:parameter = "StartBoundary"

    # skip when Parameter not use
    if ($IsExist -eq $false)
    {
        Write-Debug ($debugMessages.SkipNoneUseParameter -f $Parameter)
        return @{
            target = $null
            result = $true
        }
    }

    # skip null
    if ($Value -eq $null)
    {
        Write-Debug ($debugMessages.SkipNullPassedParameter -f $Parameter)
        return @{
            target = $null
            result = $true
        }
    }

    $valueCount = ($Value | measure).Count
    $scheduleCount = ($ScheduledTask.Triggers | measure).Count
    if ($valueCount -ne $scheduleCount)
    {
        throw New-Object System.ArgumentException ($errorMessages.ScheduleAtArgumentLength -f $scheduleCount, $valueCount)
    }

    $result = $target = @()
    for ($i = 0; $i -le ($ScheduledTask.Triggers.$parameter.Count -1); $i++)
    {
        Write-Debug ($debugMessages.CheckScheduleTaskParameter -f $parameter, $Value[$i])
        $startBoundaryDateTime = [System.Xml.XmlConvert]::ToDateTime(@($ScheduledTask.Triggers.$parameter)[$i])
        $target += $startBoundaryDateTime
        $result += @($Value)[$i] -eq $startBoundaryDateTime
        Write-Debug ($debugMessages.ScheduleTaskResult -f $parameter, $result[$i], $startBoundaryDateTime)
    }
    return @{
        target = $target
        result = $result | sort -Unique
    }
}

function TestScheduledTaskScheduledRepetition
{
    [OutputType([bool])]
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [Microsoft.Management.Infrastructure.CimInstance]$ScheduledTask,

        [parameter(Mandatory = $true)]
        [string]$Parameter,

        [parameter(Mandatory = $false)]
        [TimeSpan[]]$Value,

        [bool]$IsExist
    )

    # skip when Parameter not use
    if ($IsExist -eq $false)
    {
        Write-Debug ($debugMessages.SkipNoneUseParameter -f $Parameter)
        return @{
            target = $null
            result = $true
        }
    }

    # skip null
    if ($Value -eq $null)
    {
        Write-Debug ($debugMessages.SkipNullPassedParameter -f $Parameter)
        return @{
            target = $null
            result = $true
        }
    }

    $valueCount = ($Value | measure).Count
    $scheduleCount = ($ScheduledTask.Triggers | measure).Count
    if ($valueCount -ne $scheduleCount)
    {
        throw New-Object System.ArgumentException ($errorMessages.ScheduleRepetitionArgumentLength -f $scheduleCount, $valueCount)
    }

    $result = $target = @()
    for ($i = 0; $i -le ($ScheduledTask.Triggers.Repetition.$Parameter.Count -1); $i++)
    {
        Write-Debug ($debugMessages.CheckScheduleTaskParameter -f $Parameter, $Value[$i])
        $repetition = [System.Xml.XmlConvert]::ToTimeSpan(@($ScheduledTask.Triggers.Repetition.$Parameter)[$i])
        $target += $repetition
        $result = @($Value)[$i] -eq $repetition
        Write-Debug ($debugMessages.ScheduleTaskResult -f $Parameter, $result[$i], $target.TotalMinutes)
    }
    return @{
        target = $target
        result = $result | sort -Unique
    }
}

function TestScheduledTaskTriggerScheduleByDay
{
    [OutputType([bool])]
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [System.Xml.XmlDocument]$ScheduledTaskXml,

        [parameter(Mandatory = $true)]
        [string]$Parameter,

        [parameter(Mandatory = $false)]
        [PSObject]$Value,

        [bool]$IsExist
    )

    # skip when Parameter not use
    if ($IsExist -eq $false)
    {
        Write-Debug ($debugMessages.SkipNoneUseParameter -f $Parameter)
        return @{
            target = $null
            result = $true
        }
    }

    $trigger = ($ScheduledTaskXml.task.Triggers.CalendarTrigger.ScheduleByDay | measure).Count
    $result = $false
    switch ($Parameter)
    {
        "Daily"
        {
            Write-Debug $debugMessages.CheckSchedulerDaily
            $result = if ($Value)
            {
                $trigger -ne 0
            }
            else
            {
                $trigger-eq 0
            }
            Write-Debug ($debugMessages.ScheduleTaskResult -f $Parameter, $result, $trigger)
        }
        "Once"
        {
            Write-Debug $debugMessages.CheckSchedulerOnce
            $result = if ($Value)
            {
                $trigger -eq 0
            }
            else
            {
                $trigger -ne 0
            }
            Write-Debug ($debugMessages.ScheduleTaskResult -f $Parameter, $result, $trigger)
        }
    }
    return @{
        target = $result
        result = $result
    }
}

function TestScheduledTaskTriggerBootTrigger
{
    [OutputType([bool])]
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [System.Xml.XmlDocument]$ScheduledTaskXml,

        [parameter(Mandatory = $true)]
        [string]$Parameter,

        [parameter(Mandatory = $false)]
        [PSObject]$Value,

        [bool]$IsExist
    )

    # skip when Parameter not use
    if ($IsExist -eq $false)
    {
        Write-Debug ($debugMessages.SkipNoneUseParameter -f $Parameter)
        return @{
            target = $null
            result = $true
        }
    }

    $trigger = $ScheduledTaskXml.task.Triggers.BootTrigger
    $result = $false
    Write-Debug $debugMessages.CheckSchedulerAtStartup
    $target = $trigger.Enabled
    $result = $target -eq $Value
    Write-Debug ($debugMessages.ScheduleTaskResult -f $Parameter, $result, $target)
    return @{
        target = $target
        result = $result
    }
}

function TestScheduledTaskTriggerLogonTrigger
{
    [OutputType([bool])]
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [System.Xml.XmlDocument]$ScheduledTaskXml,

        [parameter(Mandatory = $true)]
        [string]$Parameter,

        [parameter(Mandatory = $false)]
        [PSObject]$Value,

        [bool]$IsExist
    )

    # skip when Parameter not use
    if ($IsExist -eq $false)
    {
        Write-Debug ($debugMessages.SkipNoneUseParameter -f $Parameter)
        return @{
            target = $null
            result = $true
        }
    }

    $trigger = $ScheduledTaskXml.task.Triggers.LogonTrigger
    $result = $false
    switch ($Parameter)
    {
        "AtLogOn"
        {
            Write-Debug $debugMessages.CheckSchedulerAtLogOn
            $target = $trigger.Enabled
            $result = $target -eq $Value
            Write-Debug ($debugMessages.ScheduleTaskResult -f $Parameter, $result, $target)
        }
        "UserId"
        {
            if ($value -eq ""){ $value = $null }
            Write-Debug ($debugMessages.CheckSchedulerUserId -f $Value)
            $target = $trigger.UserId
            $result = $target -eq $Value
            Write-Debug ($debugMessages.ScheduleTaskResult -f $Parameter, $result, $target)
        }
    }
    return @{
        target = $target
        result = $result
    }
}

function TestScheduledTaskStatus
{
    [OutputType([HashTable])]
    [CmdletBinding(DefaultParameterSetName = "Repetition")]
    param
    (
        [parameter(Mandatory = 1, Position  = 0)]
        [string]$TaskName,
    
        [parameter(Mandatory = 0, Position  = 1)]
        [string]$TaskPath = "\",

        [parameter(Mandatory = 0, Position  = 2)]
        [string]$Execute,

        [parameter(Mandatory = 0, Position  = 3)]
        [string]$Argument,
    
        [parameter(Mandatory = 0, Position  = 4)]
        [string]$WorkingDirectory,

        [parameter(Mandatory = 0, Position  = 5)]
        [datetime[]]$ScheduledAt,

        [parameter(Mandatory = 0, Position  = 6, parameterSetName = "Repetition")]
        [TimeSpan[]]$RepetitionInterval,

        [parameter(Mandatory = 0, Position  = 7, parameterSetName = "Repetition")]
        [TimeSpan[]]$RepetitionDuration,

        [parameter(Mandatory = 0, Position  = 8, parameterSetName = "Daily")]
        [bool]$Daily = $false,

        [parameter(Mandatory = 0, Position  = 9, parameterSetName = "Once")]
        [bool]$Once = $false,

        [parameter(Mandatory = 0, Position  = 10, parameterSetName = "AtStatup")]
        [bool]$AtStartup = $false,

        [parameter(Mandatory = 0, Position  = 11, parameterSetName = "AtLogOn")]
        [bool]$AtLogOn = $false,

        [parameter(Mandatory = 0, Position  = 12, parameterSetName = "AtLogOn")]
        [string]$AtLogOnUserId = "",

        [parameter(Mandatory = 0, Position  = 13)]
        [string]$Description,

        [parameter(Mandatory = 0, Position  = 14)]
        [PScredential]$Credential,

        [parameter(Mandatory = 0, Position  = 15)]
        [bool]$Disable,

        [parameter(Mandatory = 0, Position  = 16)]
        [bool]$Hidden,

        [parameter(Mandatory = 0, Position  = 17)]
        [TimeSpan]$ExecutionTimeLimit,

        [parameter(Mandatory = 0, Position  = 18)]
        [ValidateSet("At", "Win8", "Win7", "Vista", "V1")]
        [string]$Compatibility,

        [parameter(Mandatory = 0,Position  = 19)]
        [ValidateSet("Highest", "Limited")]
        [string]$Runlevel
    )

    #region Root

        $returnHash = [ordered]@{}

        # get whole task
        $root = Get-ScheduledTask

        # TaskPath
        $returnHash.TaskPath = GetScheduledTask -ScheduledTask $root -Parameter TaskPath -Value $TaskPath
        if ($null -eq $returnHash.TaskPath.task)
        {
            foreach ($item in [Enum]::GetNames([ScheduledTaskPropertyType]))
            {
                $returnHash.$item = @{target = $null; result = $true}
            }
            return $returnHash;
        }

        # TaskName
        $returnHash.TaskName = GetScheduledTask -ScheduledTask $returnHash.TaskPath.task -Parameter Taskname -Value $TaskName

        # default
        $current = $returnHash.TaskName.task
        if (($current | measure).Count -eq 0){ return $returnHash }

        # export as xml
        [xml]$script:xml = Export-ScheduledTask -TaskName $current.TaskName -TaskPath $current.TaskPath

        # Description
        $returnHash.Description = TestScheduledTask -ScheduledTask $current -Parameter Description -Value $Description -Type ([ScheduledParameterType]::Root) -IsExist ($PSBoundParameters.ContainsKey('Description'))

    #endregion

    #region Action

        # Execute
        $returnHash.Execute = TestScheduledTask -ScheduledTask $current -Parameter Execute -Value $Execute -Type ([ScheduledParameterType]::Actions) -IsExist ($PSBoundParameters.ContainsKey('Execute'))

        # Arguments
        $returnHash.Argument = TestScheduledTask -ScheduledTask $current -Parameter Arguments -Value $Argument -Type ([ScheduledParameterType]::Actions) -IsExist ($PSBoundParameters.ContainsKey('Argument'))

        # WorkingDirectory
        $returnHash.WorkingDirectory = TestScheduledTask -ScheduledTask $current -Parameter WorkingDirectory -Value $WorkingDirectory -Type ([ScheduledParameterType]::Actions) -IsExist ($PSBoundParameters.ContainsKey('WorkingDirectory'))

    #endregion

    #region Principal

        # UserId
        $returnHash.Credential = TestScheduledTask -ScheduledTask $current -Parameter UserId -Value $Credential.UserName -Type ([ScheduledParameterType]::Principal) -IsExist ($PSBoundParameters.ContainsKey('Credential'))

        # RunLevel
        $returnHash.RunLevel = TestScheduledTask -ScheduledTask $current -Parameter RunLevel -Value $Runlevel -Type ([ScheduledParameterType]::Principal) -IsExist ($PSBoundParameters.ContainsKey('Runlevel'))

    #endregion

    #region Settings

        # Compatibility
        $returnHash.Compatibility = TestScheduledTask -ScheduledTask $current -Parameter Compatibility -Value $Compatibility -Type ([ScheduledParameterType]::Settings) -IsExist ($PSBoundParameters.ContainsKey('Compatibility'))

        # ExecutionTimeLimit
        $returnHash.ExecutionTimeLimit = TestScheduledTaskExecutionTimeLimit -ScheduledTask $current -Value $ExecutionTimeLimit -IsExist ($PSBoundParameters.ContainsKey('ExecutionTimeLimit'))

        # Hidden
        $returnHash.Hidden = TestScheduledTask -ScheduledTask $current -Parameter Hidden -Value $Hidden -Type ([ScheduledParameterType]::Settings) -IsExist ($PSBoundParameters.ContainsKey('Hidden'))

        # Disable
        $returnHash.Disable = TestScheduledTaskDisable -ScheduledTask $current -Value $Disable -IsExist ($PSBoundParameters.ContainsKey('Disable'))

    #endregion

    #region Triggers

        # SchduledAt
        $returnHash.ScheduledAt = TestScheduledTaskScheduledAt -ScheduledTask $current -Value $ScheduledAt -IsExist ($PSBoundParameters.ContainsKey('ScheduledAt'))

        # RepetitionInterval
        $returnHash.RepetitionInterval = TestScheduledTaskScheduledRepetition -ScheduledTask $current -Value $RepetitionInterval -Parameter Interval -IsExist ($PSBoundParameters.ContainsKey('RepetitionInterval'))

        # RepetitionDuration
        $returnHash.RepetitionDuration = TestScheduledTaskScheduledRepetition -ScheduledTask $current -Value $RepetitionDuration -Parameter Duration -IsExist ($PSBoundParameters.ContainsKey('RepetitionDuration'))

        # Daily
        $returnHash.Daily = TestScheduledTaskTriggerScheduleByDay -ScheduledTaskXml $xml -Parameter Daily -Value $Daily -IsExist ($PSBoundParameters.ContainsKey('Daily'))

        # Once
        $returnHash.Once = TestScheduledTaskTriggerScheduleByDay -ScheduledTaskXml $xml -Parameter Once -Value $Once -IsExist ($PSBoundParameters.ContainsKey('Once'))

        # AtStartup
        $returnHash.AtStartup = TestScheduledTaskTriggerBootTrigger -ScheduledTaskXml $xml -Parameter AtStatup -Value $AtStartup -IsExist ($PSBoundParameters.ContainsKey('AtStartup'))

        # AtLogOn
        $returnHash.AtLogOn = TestScheduledTaskTriggerLogonTrigger -ScheduledTaskXml $xml -Parameter AtLogOn -Value $AtLogOn -IsExist ($PSBoundParameters.ContainsKey('AtLogOn'))

        # UserId (AtLogOn execute UserId)
        $returnHash.AtLogonUserId = TestScheduledTaskTriggerLogonTrigger -ScheduledTaskXml $xml -Parameter UserId -Value $AtLogOnUserId -IsExist ($PSBoundParameters.ContainsKey('AtLogOnUserId'));

    #endregion

    return $returnHash
}

#endregion

#region Remove Helper

function RemoveScheduledTaskEmptyDirectoryPath
{
    # validate target Directory is existing
    $path = Join-Path $env:windir "System32\Tasks"
    $result = Get-ChildItem -Path $path -Directory | where Name -ne "Microsoft"
    if (($result | measure).count -eq 0){ return; }

    # validate Child is blank
    $result.FullName `
    | where {(Get-ChildItem -Path $_) -eq $null} `
    | Remove-Item -Force
}

#endregion

#region Extension Helper

function New-ZipPairs
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $false, Position = 0, ValueFromPipeline = 1, ValueFromPipelineByPropertyName = 1)]
        [PSObject[]]$first,
 
        [parameter(Mandatory = $false, Position = 1, ValueFromPipelineByPropertyName = 1)]
        [PSObject[]]$second,

        [parameter(Mandatory = $false, Position = 2, ValueFromPipelineByPropertyName = 1)]
        [scriptBlock]$resultSelector
    )

    process
    {
        if ([string]::IsNullOrWhiteSpace($first)){ break }        
        if ([string]::IsNullOrWhiteSpace($second)){ break }
        
        try
        {
            $e1 = @($first).GetEnumerator()

            while ($e1.MoveNext() -and $e2.MoveNext())
            {
                if ($PSBoundParameters.ContainsKey('resultSelector'))
                {
                    $first = $e1.Current
                    $second = $e2.Current
                    $context = $resultselector.InvokeWithContext(
                        $null,
                        ($psvariable),
                        {
                            (New-Object System.Management.Automation.PSVariable ("first", $first)),
                            (New-Object System.Management.Automation.PSVariable ("second", $second))
                        }
                    )
                    $context
                }
                else
                {
                    $tuple = New-Object 'System.Tuple[PSObject, PSObject]' ($e1.Current, $e2.current)
                    $tuple
                }
            }
        }
        finally
        {
            if(($d1 = $e1 -as [IDisposable]) -ne $null) { $d1.Dispose() }
            if(($d2 = $e2 -as [IDisposable]) -ne $null) { $d2.Dispose() }
            if(($d3 = $psvariable -as [IDisposable]) -ne $null) {$d3.Dispose() }
            if(($d4 = $context -as [IDisposable]) -ne $null) {$d4.Dispose() }
            if(($d5 = $tuple -as [IDisposable]) -ne $null) {$d5.Dispose() }
        }
    }

    begin
    {
        $e2 = @($second).GetEnumerator()
        $psvariable = New-Object 'System.Collections.Generic.List[System.Management.Automation.psvariable]'
    }
}

#endregion

Export-ModuleMember -Function *-TargetResource