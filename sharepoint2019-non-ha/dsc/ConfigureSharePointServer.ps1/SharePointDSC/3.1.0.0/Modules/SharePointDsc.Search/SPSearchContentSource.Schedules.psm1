function Get-SPDSCSearchCrawlSchedule
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param(
        [Parameter()]
        $Schedule
    )

    if ($null -eq $Schedule)
    {
        return @{
            ScheduleType = "None"
        }
    }

    $scheduleType = $Schedule.GetType().Name
    $result = @{
        CrawlScheduleRepeatDuration = $Schedule.RepeatDuration
        CrawlScheduleRepeatInterval = $Schedule.RepeatInterval
        StartHour = $Schedule.StartHour
        StartMinute = $Schedule.StartMinute
    }

    switch ($scheduleType)
    {
        "DailySchedule" {
            $result.Add("ScheduleType", "Daily")
            $result.Add("CrawlScheduleRunEveryInterval", $Schedule.DaysInterval)
        }
        "WeeklySchedule" {
            $result.Add("ScheduleType", "Weekly")
            $result.Add("CrawlScheduleRunEveryInterval", $Schedule.WeeksInterval)
            $result.Add("CrawlScheduleDaysOfWeek", $Schedule.DaysOfWeek)
        }
        "MonthlyDateSchedule" {
            $result.Add("ScheduleType", "Monthly")
            $result.Add("CrawlScheduleDaysOfMonth", ($Schedule.DaysOfMonth.ToString() -replace "Day"))
            $result.Add("CrawlScheduleMonthsOfYear", $schedule.MonthsOfYear)
        }
        Default {
            throw "An unknown schedule type was detected"
        }
    }
    return $result
}

function Test-SPDSCSearchCrawlSchedule
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param(
        [Parameter(Mandatory = $true)] $CurrentSchedule,
        [Parameter(Mandatory = $true)] $DesiredSchedule
    )

    Import-Module -Name (Join-Path -Path $PSScriptRoot `
                                   -ChildPath "..\SharePointDsc.Util\SharePointDsc.Util.psm1")

    if ($CurrentSchedule.ScheduleType -ne $DesiredSchedule.ScheduleType)
    {
        return $false
    }

    if ((Test-SPDSCObjectHasProperty -Object $DesiredSchedule `
                                     -PropertyName "CrawlScheduleRepeatDuration") -eq $true `
        -and $CurrentSchedule.CrawlScheduleRepeatDuration -ne $DesiredSchedule.CrawlScheduleRepeatDuration)
    {
        return $false
    }
    if ((Test-SPDSCObjectHasProperty -Object $DesiredSchedule `
                                     -PropertyName "CrawlScheduleRepeatInterval") -eq $true `
        -and $CurrentSchedule.CrawlScheduleRepeatInterval -ne $DesiredSchedule.CrawlScheduleRepeatInterval)
    {
        return $false
    }
    if ((Test-SPDSCObjectHasProperty -Object $DesiredSchedule `
                                     -PropertyName "StartHour") -eq $true `
        -and $CurrentSchedule.StartHour -ne $DesiredSchedule.StartHour)
    {
        return $false
    }
    if ((Test-SPDSCObjectHasProperty -Object $DesiredSchedule `
                                     -PropertyName "StartMinute") -eq $true `
        -and $CurrentSchedule.StartMinute -ne $DesiredSchedule.StartMinute)
    {
        return $false
    }

    switch ($CurrentSchedule.ScheduleType)
    {
        "Daily" {
            if ((Test-SPDSCObjectHasProperty -Object $DesiredSchedule `
                                             -PropertyName "CrawlScheduleRunEveryInterval") -eq $true `
                -and $CurrentSchedule.CrawlScheduleRunEveryInterval -ne $DesiredSchedule.CrawlScheduleRunEveryInterval)
            {
                return $false
            }
        }
        "Weekly" {
            if ((Test-SPDSCObjectHasProperty -Object $DesiredSchedule `
                                             -PropertyName "CrawlScheduleRunEveryInterval") -eq $true `
                -and $CurrentSchedule.CrawlScheduleRunEveryInterval -ne $DesiredSchedule.CrawlScheduleRunEveryInterval)
            {
                return $false
            }
            $days = $CurrentSchedule.CrawlScheduleDaysOfWeek.ToString()
            if ((Test-SPDSCObjectHasProperty -Object $DesiredSchedule `
                                             -PropertyName "CrawlScheduleDaysOfWeek") -eq $true `
                -and $null -ne (Compare-Object -ReferenceObject $days.Split(', ', [System.StringSplitOptions]::RemoveEmptyEntries) `
                                               -DifferenceObject $DesiredSchedule.CrawlScheduleDaysOfWeek))
            {
                return $false
            }
        }
        "Monthly" {
            if ((Test-SPDSCObjectHasProperty -Object $DesiredSchedule `
                                             -PropertyName "CrawlScheduleDaysOfMonth") -eq $true `
                -and $CurrentSchedule.CrawlScheduleDaysOfMonth -ne $DesiredSchedule.CrawlScheduleDaysOfMonth)
            {
                return $false
            }
            $months = $CurrentSchedule.CrawlScheduleMonthsOfYear.ToString()
            if ((Test-SPDSCObjectHasProperty -Object $DesiredSchedule `
                                             -PropertyName "CrawlScheduleMonthsOfYear") -eq $true `
                -and $null -eq (Compare-Object -ReferenceObject $months.Split(', ', [System.StringSplitOptions]::RemoveEmptyEntries) `
                                               -DifferenceObject $DesiredSchedule.CrawlScheduleMonthsOfYear))
            {
                return $false
            }
        }
    }
    return $true
}

Export-ModuleMember -Function *
