function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]  
        [System.String] 
        $Url,
        
        [Parameter()]  
        [System.Boolean]
        $EnableOvertimeAndNonBillableTracking,

        [Parameter()] 
        [ValidateSet("CurrentTaskAssignments","CurrentProjects","NoPrepopulation")]
        [System.String] 
        $DefaultTimesheetCreationMode,

        [Parameter()]
        [ValidateSet("Days","Weeks")]
        [System.String] 
        $DefaultTrackingUnit,

        [Parameter()]
        [ValidateSet("Hours","Days")]
        [System.String] 
        $DefaultReportingUnit,

        [Parameter()]  
        [System.Single] 
        $HoursInStandardDay,

        [Parameter()]  
        [System.Single] 
        $HoursInStandardWeek,

        [Parameter()]  
        [System.Single] 
        $MaxHoursPerTimesheet,

        [Parameter()]  
        [System.Single] 
        $MinHoursPerTimesheet,

        [Parameter()]  
        [System.Single] 
        $MaxHoursPerDay,

        [Parameter()]  
        [System.Boolean]
        $AllowFutureTimeReporting,

        [Parameter()]  
        [System.Boolean]
        $AllowNewPersonalTasks,

        [Parameter()]  
        [System.Boolean]
        $AllowTopLevelTimeReporting,

        [Parameter()]  
        [System.Boolean]
        $RequireTaskStatusManagerApproval,

        [Parameter()]  
        [System.Boolean]
        $RequireLineApprovalBeforeTimesheetApproval,

        [Parameter()]  
        [System.Boolean]
        $EnableTimesheetAuditing,

        [Parameter()]  
        [System.Boolean]
        $FixedApprovalRouting,

        [Parameter()]  
        [System.Boolean]
        $SingleEntryMode,

        [Parameter()]
        [ValidateSet("PercentComplete","ActualDoneAndRemaining","HoursPerPeriod","FreeForm")]
        [System.String] 
        $DefaultTrackingMode,

        [Parameter()]  
        [System.Boolean]
        $ForceTrackingModeForAllProjects,

        [Parameter()] 
        [System.Management.Automation.PSCredential] 
        $InstallAccount
    )

    Write-Verbose -Message "Getting Timesheet settings for $Url"

    if ((Get-SPDSCInstalledProductVersion).FileMajorPart -lt 16) 
    {
        throw [Exception] ("Support for Project Server in SharePointDsc is only valid for " + `
                           "SharePoint 2016 and 2019.")
    }

    $result = Invoke-SPDSCCommand -Credential $InstallAccount `
                                  -Arguments @($PSBoundParameters, $PSScriptRoot) `
                                  -ScriptBlock {
        $params = $args[0]
        $scriptRoot = $args[1]
        
        $modulePath = "..\..\Modules\SharePointDsc.ProjectServer\ProjectServerConnector.psm1"
        Import-Module -Name (Join-Path -Path $scriptRoot -ChildPath $modulePath -Resolve)

        $webAppUrl = (Get-SPSite -Identity $params.Url).WebApplication.Url
        $useKerberos = -not (Get-SPAuthenticationProvider -WebApplication $webAppUrl -Zone Default).DisableKerberos
        $adminService = New-SPDscProjectServerWebService -PwaUrl $params.Url `
                                                         -EndpointName Admin `
                                                         -UseKerberos:$useKerberos

        $script:currentSettings = $null
        Use-SPDscProjectServerWebService -Service $adminService -ScriptBlock {
            $script:currentSettings = $adminService.ReadTimeSheetSettings().TimeSheetSettings
        }

        if ($null -eq $script:currentSettings)
        {
            return @{
                Url = $params.Url
                EnableOvertimeAndNonBillableTracking = $false
                DefaultTimesheetCreationMode = ""
                DefaultTrackingUnit = ""
                DefaultReportingUnit = ""
                HoursInStandardDay = 0
                HoursInStandardWeek = 0
                MaxHoursPerTimesheet = 0
                MinHoursPerTimesheet = 0
                MaxHoursPerDay = 0
                AllowFutureTimeReporting = $false
                AllowNewPersonalTasks  = $false
                AllowTopLevelTimeReporting = $false
                RequireTaskStatusManagerApproval = $false
                RequireLineApprovalBeforeTimesheetApproval = $false
                EnableTimesheetAuditing = $false
                FixedApprovalRouting = $false
                SingleEntryMode = $false
                DefaultTrackingMode = ""
                ForceTrackingModeForAllProjects = $false
                InstallAccount = $params.InstallAccount
            }
        }
        else
        {
            $currentDefaultTimesheetCreationMode = "Unknown"
            switch ($script:currentSettings.WADMIN_TS_CREATE_MODE_ENUM)
            {
                1 {
                    $currentDefaultTimesheetCreationMode = "CurrentTaskAssignments"
                }
                2 {
                    $currentDefaultTimesheetCreationMode = "CurrentProjects"
                }
                0 {
                    $currentDefaultTimesheetCreationMode = "NoPrepopulation"
                }
            }

            $currentDefaultTrackingUnit = "Unknown"
            switch ($script:currentSettings.WADMIN_TS_DEF_ENTRY_MODE_ENUM)
            {
                1 {
                    $currentDefaultTrackingUnit = "Weeks"
                }
                0 {
                    $currentDefaultTrackingUnit = "Days"
                }
            }

            $currentDefaultReportingUnit = "Unknown"
            switch ($script:currentSettings.WADMIN_TS_REPORT_UNIT_ENUM)
            {
                1 {
                    $currentDefaultReportingUnit = "Days"
                }
                0 {
                    $currentDefaultReportingUnit = "Hours"
                }
            }

            $currentDefaultTrackingMode = "Unknown"
            switch ($script:currentSettings.WADMIN_DEFAULT_TRACKING_METHOD)
            {
                3 {
                    $currentDefaultTrackingMode = "ActualDoneAndRemaining"
                }
                2 {
                    $currentDefaultTrackingMode = "PercentComplete"
                }
                1 {
                    $currentDefaultTrackingMode = "HoursPerPeriod"
                }
                0 {
                    $currentDefaultTrackingMode = "FreeForm"
                }
            }

            $currentEnableOvertimeAndNonBillableTracking = $false
            switch ($script:currentSettings.WADMIN_TS_DEF_DISPLAY_ENUM)
            {
                7 {
                    $currentEnableOvertimeAndNonBillableTracking = $true
                }
                0 {
                    $currentEnableOvertimeAndNonBillableTracking = $false
                }
            }

            return @{
                Url = $params.Url
                EnableOvertimeAndNonBillableTracking = $currentEnableOvertimeAndNonBillableTracking
                DefaultTimesheetCreationMode = $currentDefaultTimesheetCreationMode
                DefaultTrackingUnit = $currentDefaultTrackingUnit
                DefaultReportingUnit = $currentDefaultReportingUnit
                HoursInStandardDay = ([System.Single]::Parse($script:currentSettings.WADMIN_TS_HOURS_PER_DAY) / 60000)
                HoursInStandardWeek = ([System.Single]::Parse($script:currentSettings.WADMIN_TS_HOURS_PER_WEEK) / 60000)
                MaxHoursPerTimesheet = ([System.Single]::Parse($script:currentSettings.WADMIN_TS_MAX_HR_PER_TS) / 60000)
                MinHoursPerTimesheet = ([System.Single]::Parse($script:currentSettings.WADMIN_TS_MIN_HR_PER_TS) / 60000)
                MaxHoursPerDay = ([System.Single]::Parse($script:currentSettings.WADMIN_TS_MAX_HR_PER_DAY) / 60000)
                AllowFutureTimeReporting = $script:currentSettings.WADMIN_TS_IS_FUTURE_REP_ALLOWED
                AllowNewPersonalTasks = $script:currentSettings.WADMIN_TS_IS_UNVERS_TASK_ALLOWED
                AllowTopLevelTimeReporting = $script:currentSettings.WADMIN_TS_ALLOW_PROJECT_LEVEL
                RequireTaskStatusManagerApproval = $script:currentSettings.WADMIN_TS_PROJECT_MANAGER_COORDINATION
                RequireLineApprovalBeforeTimesheetApproval = $script:currentSettings.WADMIN_TS_PROJECT_MANAGER_APPROVAL
                EnableTimesheetAuditing = $script:currentSettings.WADMIN_TS_IS_AUDIT_ENABLED
                FixedApprovalRouting = $script:currentSettings.WADMIN_TS_FIXED_APPROVAL_ROUTING
                SingleEntryMode = $script:currentSettings.WADMIN_TS_TIED_MODE
                DefaultTrackingMode = $currentDefaultTrackingMode
                ForceTrackingModeForAllProjects = $script:currentSettings.WADMIN_IS_TRACKING_METHOD_LOCKED
                InstallAccount = $params.InstallAccount
            }
        }
    }
    return $result
}


function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]  
        [System.String] 
        $Url,
        
        [Parameter()]  
        [System.Boolean]
        $EnableOvertimeAndNonBillableTracking,

        [Parameter()] 
        [ValidateSet("CurrentTaskAssignments","CurrentProjects","NoPrepopulation")]
        [System.String] 
        $DefaultTimesheetCreationMode,

        [Parameter()]
        [ValidateSet("Days","Weeks")]
        [System.String] 
        $DefaultTrackingUnit,

        [Parameter()]
        [ValidateSet("Hours","Days")]
        [System.String] 
        $DefaultReportingUnit,

        [Parameter()]  
        [System.Single] 
        $HoursInStandardDay,

        [Parameter()]  
        [System.Single] 
        $HoursInStandardWeek,

        [Parameter()]  
        [System.Single] 
        $MaxHoursPerTimesheet,

        [Parameter()]  
        [System.Single] 
        $MinHoursPerTimesheet,

        [Parameter()]  
        [System.Single] 
        $MaxHoursPerDay,

        [Parameter()]  
        [System.Boolean]
        $AllowFutureTimeReporting,

        [Parameter()]  
        [System.Boolean]
        $AllowNewPersonalTasks,

        [Parameter()]  
        [System.Boolean]
        $AllowTopLevelTimeReporting,

        [Parameter()]  
        [System.Boolean]
        $RequireTaskStatusManagerApproval,

        [Parameter()]  
        [System.Boolean]
        $RequireLineApprovalBeforeTimesheetApproval,

        [Parameter()]  
        [System.Boolean]
        $EnableTimesheetAuditing,

        [Parameter()]  
        [System.Boolean]
        $FixedApprovalRouting,

        [Parameter()]  
        [System.Boolean]
        $SingleEntryMode,

        [Parameter()]
        [ValidateSet("PercentComplete","ActualDoneAndRemaining","HoursPerPeriod","FreeForm")]
        [System.String] 
        $DefaultTrackingMode,

        [Parameter()]  
        [System.Boolean]
        $ForceTrackingModeForAllProjects,

        [Parameter()] 
        [System.Management.Automation.PSCredential] 
        $InstallAccount
    )

    Write-Verbose -Message "Setting Timesheet settings for $Url"

    if ((Get-SPDSCInstalledProductVersion).FileMajorPart -lt 16) 
    {
        throw [Exception] ("Support for Project Server in SharePointDsc is only valid for " + `
                           "SharePoint 2016 and 2019.")
    }

    Invoke-SPDSCCommand -Credential $InstallAccount `
                        -Arguments $PSBoundParameters `
                        -ScriptBlock {

        $params = $args[0]

        $webAppUrl = (Get-SPSite -Identity $params.Url).WebApplication.Url
        $useKerberos = -not (Get-SPAuthenticationProvider -WebApplication $webAppUrl -Zone Default).DisableKerberos
        $adminService = New-SPDscProjectServerWebService -PwaUrl $params.Url `
                                                         -EndpointName Admin `
                                                         -UseKerberos:$useKerberos

        Use-SPDscProjectServerWebService -Service $adminService -ScriptBlock {
            $settings = $adminService.ReadTimeSheetSettings()

            if ($params.ContainsKey("EnableOvertimeAndNonBillableTracking") -eq $true)
            {
                switch ($params.EnableOvertimeAndNonBillableTracking)
                {
                    $true {
                        $settings.TimeSheetSettings.Rows[0]["WADMIN_TS_DEF_DISPLAY_ENUM"] = 7
                    }
                    $false {
                        $settings.TimeSheetSettings.Rows[0]["WADMIN_TS_DEF_DISPLAY_ENUM"] = 0
                    }
                }
            }
            if ($params.ContainsKey("DefaultTimesheetCreationMode") -eq $true)
            {
                switch ($params.DefaultTimesheetCreationMode)
                {
                    "CurrentTaskAssignments" {
                        $settings.TimeSheetSettings.Rows[0]["WADMIN_TS_CREATE_MODE_ENUM"] = 1
                    }
                    "CurrentProjects" {
                        $settings.TimeSheetSettings.Rows[0]["WADMIN_TS_CREATE_MODE_ENUM"] = 2
                    }
                    "NoPrepopulation" {
                        $settings.TimeSheetSettings.Rows[0]["WADMIN_TS_CREATE_MODE_ENUM"] = 0
                    }
                }
            }
            if ($params.ContainsKey("DefaultTrackingUnit") -eq $true)
            {
                switch ($params.DefaultTrackingUnit)
                {
                    "Weeks" {
                        $settings.TimeSheetSettings.Rows[0]["WADMIN_TS_DEF_ENTRY_MODE_ENUM"] = 1
                    }
                    "Days" {
                        $settings.TimeSheetSettings.Rows[0]["WADMIN_TS_DEF_ENTRY_MODE_ENUM"] = 0
                    }
                }
            }
            if ($params.ContainsKey("DefaultReportingUnit") -eq $true)
            {
                switch ($params.DefaultReportingUnit)
                {
                    "Days" {
                        $settings.TimeSheetSettings.Rows[0]["WADMIN_TS_REPORT_UNIT_ENUM"] = 1
                    }
                    "Hours" {
                        $settings.TimeSheetSettings.Rows[0]["WADMIN_TS_REPORT_UNIT_ENUM"] = 0
                    }
                }
            }
            if ($params.ContainsKey("HoursInStandardDay") -eq $true)
            {
                $settings.TimeSheetSettings.Rows[0]["WADMIN_TS_HOURS_PER_DAY"] = $params.HoursInStandardDay * 60000
            }
            if ($params.ContainsKey("HoursInStandardWeek") -eq $true)
            {
                $settings.TimeSheetSettings.Rows[0]["WADMIN_TS_HOURS_PER_WEEK"] = $params.HoursInStandardWeek * 60000
            }
            if ($params.ContainsKey("MaxHoursPerTimesheet") -eq $true)
            {
                $settings.TimeSheetSettings.Rows[0]["WADMIN_TS_MAX_HR_PER_TS"] = $params.MaxHoursPerTimesheet * 60000
            }
            if ($params.ContainsKey("MinHoursPerTimesheet") -eq $true)
            {
                $settings.TimeSheetSettings.Rows[0]["WADMIN_TS_MIN_HR_PER_TS"] = $params.MinHoursPerTimesheet * 60000
            }
            if ($params.ContainsKey("MaxHoursPerDay") -eq $true)
            {
                $settings.TimeSheetSettings.Rows[0]["WADMIN_TS_MAX_HR_PER_DAY"] = $params.MaxHoursPerDay * 60000
            }
            if ($params.ContainsKey("AllowFutureTimeReporting") -eq $true)
            {
                $settings.TimeSheetSettings.Rows[0]["WADMIN_TS_IS_FUTURE_REP_ALLOWED"] = $params.AllowFutureTimeReporting
            }
            if ($params.ContainsKey("AllowNewPersonalTasks") -eq $true)
            {
                $settings.TimeSheetSettings.Rows[0]["WADMIN_TS_IS_UNVERS_TASK_ALLOWED"] = $params.AllowNewPersonalTasks
            }
            if ($params.ContainsKey("AllowTopLevelTimeReporting") -eq $true)
            {
                $settings.TimeSheetSettings.Rows[0]["WADMIN_TS_ALLOW_PROJECT_LEVEL"] = $params.AllowTopLevelTimeReporting
            }
            if ($params.ContainsKey("RequireTaskStatusManagerApproval") -eq $true)
            {
                $settings.TimeSheetSettings.Rows[0]["WADMIN_TS_PROJECT_MANAGER_COORDINATION"] = $params.RequireTaskStatusManagerApproval
            }
            if ($params.ContainsKey("RequireLineApprovalBeforeTimesheetApproval") -eq $true)
            {
                $settings.TimeSheetSettings.Rows[0]["WADMIN_TS_PROJECT_MANAGER_APPROVAL"] = $params.RequireLineApprovalBeforeTimesheetApproval
            }
            if ($params.ContainsKey("EnableTimesheetAuditing") -eq $true)
            {
                $settings.TimeSheetSettings.Rows[0]["WADMIN_TS_IS_AUDIT_ENABLED"] = $params.EnableTimesheetAuditing
            }
            if ($params.ContainsKey("FixedApprovalRouting") -eq $true)
            {
                $settings.TimeSheetSettings.Rows[0]["WADMIN_TS_FIXED_APPROVAL_ROUTING"] = $params.FixedApprovalRouting
            }
            if ($params.ContainsKey("SingleEntryMode") -eq $true)
            {
                $settings.TimeSheetSettings.Rows[0]["WADMIN_TS_TIED_MODE"] = $params.SingleEntryMode
            }
            if ($params.ContainsKey("DefaultTrackingMode") -eq $true)
            {
                switch ($params.DefaultTrackingMode)
                {
                    "ActualDoneAndRemaining" {
                        $settings.TimeSheetSettings.Rows[0]["WADMIN_DEFAULT_TRACKING_METHOD"] = 3
                    }
                    "PercentComplete" {
                        $settings.TimeSheetSettings.Rows[0]["WADMIN_DEFAULT_TRACKING_METHOD"] = 2
                    }
                    "HoursPerPeriod" {
                        $settings.TimeSheetSettings.Rows[0]["WADMIN_DEFAULT_TRACKING_METHOD"] = 1
                    }
                    "FreeForm" {
                        $settings.TimeSheetSettings.Rows[0]["WADMIN_DEFAULT_TRACKING_METHOD"] = 0
                    }
                }
            }
            if ($params.ContainsKey("ForceTrackingModeForAllProjects") -eq $true)
            {
                $settings.TimeSheetSettings.Rows[0]["WADMIN_IS_TRACKING_METHOD_LOCKED"] = $params.ForceTrackingModeForAllProjects
            }

            $adminService.UpdateTimeSheetSettings($settings)
        }
    }
}


function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]  
        [System.String] 
        $Url,
        
        [Parameter()]  
        [System.Boolean]
        $EnableOvertimeAndNonBillableTracking,

        [Parameter()] 
        [ValidateSet("CurrentTaskAssignments","CurrentProjects","NoPrepopulation")]
        [System.String] 
        $DefaultTimesheetCreationMode,

        [Parameter()]
        [ValidateSet("Days","Weeks")]
        [System.String] 
        $DefaultTrackingUnit,

        [Parameter()]
        [ValidateSet("Hours","Days")]
        [System.String] 
        $DefaultReportingUnit,

        [Parameter()]  
        [System.Single] 
        $HoursInStandardDay,

        [Parameter()]  
        [System.Single] 
        $HoursInStandardWeek,

        [Parameter()]  
        [System.Single] 
        $MaxHoursPerTimesheet,

        [Parameter()]  
        [System.Single] 
        $MinHoursPerTimesheet,

        [Parameter()]  
        [System.Single] 
        $MaxHoursPerDay,

        [Parameter()]  
        [System.Boolean]
        $AllowFutureTimeReporting,

        [Parameter()]  
        [System.Boolean]
        $AllowNewPersonalTasks,

        [Parameter()]  
        [System.Boolean]
        $AllowTopLevelTimeReporting,

        [Parameter()]  
        [System.Boolean]
        $RequireTaskStatusManagerApproval,

        [Parameter()]  
        [System.Boolean]
        $RequireLineApprovalBeforeTimesheetApproval,

        [Parameter()]  
        [System.Boolean]
        $EnableTimesheetAuditing,

        [Parameter()]  
        [System.Boolean]
        $FixedApprovalRouting,

        [Parameter()]  
        [System.Boolean]
        $SingleEntryMode,

        [Parameter()]
        [ValidateSet("PercentComplete","ActualDoneAndRemaining","HoursPerPeriod","FreeForm")]
        [System.String] 
        $DefaultTrackingMode,

        [Parameter()]  
        [System.Boolean]
        $ForceTrackingModeForAllProjects,

        [Parameter()] 
        [System.Management.Automation.PSCredential] 
        $InstallAccount
    )

    Write-Verbose -Message "Testing Timesheet settings for $Url"

    $currentValues = Get-TargetResource @PSBoundParameters

    return Test-SPDscParameterState -CurrentValues $CurrentValues `
                                    -DesiredValues $PSBoundParameters
}

Export-ModuleMember -Function *-TargetResource
