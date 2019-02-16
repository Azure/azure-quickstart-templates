function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $WebAppUrl,

        [Parameter()]
        [System.Boolean]
        $SendUnusedSiteCollectionNotifications,

        [Parameter()]
        [System.UInt32]
        $UnusedSiteNotificationPeriod,

        [Parameter()]
        [System.Boolean]
        $AutomaticallyDeleteUnusedSiteCollections,

        [Parameter()]
        [ValidateRange(2,168)]
        [System.UInt32]
        $UnusedSiteNotificationsBeforeDeletion,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )

    Write-Verbose -Message "Getting web application '$WebAppUrl' site use and deletion settings"

    $result = Invoke-SPDSCCommand -Credential $InstallAccount `
                                  -Arguments $PSBoundParameters `
                                  -ScriptBlock {
        $params = $args[0]

        try
        {
            $spFarm = Get-SPFarm
        }
        catch
        {
            Write-Verbose -Message ("No local SharePoint farm was detected. Site Use and " + `
                                    "Deletion settings will not be applied")
            return $null
        }

        $wa = Get-SPWebApplication -Identity $params.WebAppUrl `
                                   -ErrorAction SilentlyContinue
        if ($null -eq $wa)
        {
            return $null
        }

        return @{
            # Set the Site Use and Deletion settings
            WebAppUrl = $params.WebAppUrl
            SendUnusedSiteCollectionNotifications = $wa.SendUnusedSiteCollectionNotifications
            UnusedSiteNotificationPeriod = $wa.UnusedSiteNotificationPeriod.TotalDays
            AutomaticallyDeleteUnusedSiteCollections = $wa.AutomaticallyDeleteUnusedSiteCollections
            UnusedSiteNotificationsBeforeDeletion = $wa.UnusedSiteNotificationsBeforeDeletion
            InstallAccount = $params.InstallAccount
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
        $WebAppUrl,

        [Parameter()]
        [System.Boolean]
        $SendUnusedSiteCollectionNotifications,

        [Parameter()]
        [System.UInt32]
        $UnusedSiteNotificationPeriod,

        [Parameter()]
        [System.Boolean]
        $AutomaticallyDeleteUnusedSiteCollections,

        [Parameter()]
        [ValidateRange(2,168)]
        [System.UInt32]
        $UnusedSiteNotificationsBeforeDeletion,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )

    Write-Verbose -Message "Setting web application '$WebAppUrl' Site Use and Deletion settings"

    Invoke-SPDSCCommand -Credential $InstallAccount `
                        -Arguments $PSBoundParameters `
                        -ScriptBlock {
        $params = $args[0]

        try
        {
            $spFarm = Get-SPFarm
        }
        catch
        {
            throw ("No local SharePoint farm was detected. Site Use and Deletion settings " + `
                   "will not be applied")
        }

        $wa = Get-SPWebApplication -Identity $params.WebAppUrl -ErrorAction SilentlyContinue
        if ($null -eq $wa)
        {
            throw "Configured web application could not be found"
        }

        # Check if the specified value is in the range for the configured schedule
        $job = Get-SPTimerJob -Identity job-dead-site-delete -WebApplication $params.WebAppUrl
        if ($null -eq $job)
        {
            throw "Dead Site Delete timer job for web application $($params.WebAppUrl) could not be found"
        }
        else
        {
            # Check schedule value
            switch ($job.Schedule.Description)
            {
                "Daily"   {
                    if (($params.UnusedSiteNotificationsBeforeDeletion -lt 28) -or
                        ($params.UnusedSiteNotificationsBeforeDeletion -gt 168))
                    {
                        throw ("Value of UnusedSiteNotificationsBeforeDeletion has to be >28 and " + `
                               "<168 when the schedule is set to daily")
                    }
                }
                "Weekly"  {
                    if (($params.UnusedSiteNotificationsBeforeDeletion -lt 4) -or
                        ($params.UnusedSiteNotificationsBeforeDeletion -gt 24))
                    {
                        throw ("Value of UnusedSiteNotificationsBeforeDeletion has to be >4 and " + `
                               "<24 when the schedule is set to weekly")
                    }
                }
                "Monthly" {
                    if (($params.UnusedSiteNotificationsBeforeDeletion -lt 2) -or
                        ($params.UnusedSiteNotificationsBeforeDeletion -gt 6))
                    {
                        throw ("Value of UnusedSiteNotificationsBeforeDeletion has to be >2 and " + `
                               "<6 when the schedule is set to monthly")
                    }
                }
            }
        }

        Write-Verbose -Message "Start update"

        # Set the Site Use and Deletion settings
        if ($params.ContainsKey("SendUnusedSiteCollectionNotifications"))
        {
            $wa.SendUnusedSiteCollectionNotifications = `
                $params.SendUnusedSiteCollectionNotifications
        }
        if ($params.ContainsKey("UnusedSiteNotificationPeriod"))
        {
            $timespan = New-TimeSpan -Days $params.UnusedSiteNotificationPeriod
            $wa.UnusedSiteNotificationPeriod = $timespan
        }
        if ($params.ContainsKey("AutomaticallyDeleteUnusedSiteCollections"))
        {
            $wa.AutomaticallyDeleteUnusedSiteCollections = `
                $params.AutomaticallyDeleteUnusedSiteCollections
        }
        if ($params.ContainsKey("UnusedSiteNotificationsBeforeDeletion"))
        {
            $wa.UnusedSiteNotificationsBeforeDeletion = `
                $params.UnusedSiteNotificationsBeforeDeletion
        }
        $wa.Update()
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
        $WebAppUrl,

        [Parameter()]
        [System.Boolean]
        $SendUnusedSiteCollectionNotifications,

        [Parameter()]
        [System.UInt32]
        $UnusedSiteNotificationPeriod,

        [Parameter()]
        [System.Boolean]
        $AutomaticallyDeleteUnusedSiteCollections,

        [Parameter()]
        [ValidateRange(2,168)]
        [System.UInt32]
        $UnusedSiteNotificationsBeforeDeletion,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )

    Write-Verbose -Message "Testing web application '$WebAppUrl' site use and deletion settings"

    $CurrentValues = Get-TargetResource @PSBoundParameters

    if ($null -eq $CurrentValues)
    {
        return $false
    }

    return Test-SPDscParameterState -CurrentValues $CurrentValues `
                                    -DesiredValues $PSBoundParameters
}

Export-ModuleMember -Function *-TargetResource
