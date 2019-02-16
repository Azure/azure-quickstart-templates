function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [Parameter()]
        [System.String]
        $DatabaseServer,

        [Parameter(Mandatory = $true)]
        [System.String]
        $WebAppUrl,

        [Parameter()]
        [System.Boolean]
        $Enabled,

        [Parameter()]
        [System.UInt16]
        $WarningSiteCount,

        [Parameter()]
        [System.UInt16]
        $MaximumSiteCount,

        [Parameter()]
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure = "Present",

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )

    Write-Verbose -Message "Getting content database configuration settings"

    $result = Invoke-SPDSCCommand -Credential $InstallAccount `
                                  -Arguments $PSBoundParameters `
                                  -ScriptBlock {
        $params = $args[0]

        $cdb = Get-SPDatabase | Where-Object -FilterScript {
            $_.GetType().FullName -eq "Microsoft.SharePoint.Administration.SPContentDatabase" -and `
            $_.Name -eq $params.Name
        }

        if ($null -eq $cdb)
        {
            # Database does not exist
            return @{
                Name = $params.Name
                DatabaseServer = $params.DatabaseServer
                WebAppUrl = $params.WebAppUrl
                Enabled = $params.Enabled
                WarningSiteCount = $params.WarningSiteCount
                MaximumSiteCount = $params.MaximumSiteCount
                Ensure = "Absent"
                InstallAccount = $params.InstallAccount
            }
        }
        else
        {
            # Database exists
            if ($cdb.Status -eq "Online")
            {
                $cdbenabled = $true
            }
            else
            {
                $cdbenabled = $false
            }

            $returnVal = @{
                Name = $params.Name
                DatabaseServer = $cdb.Server
                WebAppUrl = $cdb.WebApplication.Url.Trim("/")
                Enabled = $cdbenabled
                WarningSiteCount = $cdb.WarningSiteCount
                MaximumSiteCount = $cdb.MaximumSiteCount
                Ensure = "Present"
                InstallAccount = $params.InstallAccount
            }
            return $returnVal
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
        $Name,

        [Parameter()]
        [System.String]
        $DatabaseServer,

        [Parameter(Mandatory = $true)]
        [System.String]
        $WebAppUrl,

        [Parameter()]
        [System.Boolean]
        $Enabled,

        [Parameter()]
        [System.UInt16]
        $WarningSiteCount,

        [Parameter()]
        [System.UInt16]
        $MaximumSiteCount,

        [Parameter()]
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure = "Present",

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )

    Write-Verbose -Message "Setting content database configuration settings"

    Invoke-SPDSCCommand -Credential $InstallAccount `
                        -Arguments $PSBoundParameters `
                        -ScriptBlock {
        $params = $args[0]

        # Use Get-SPDatabase instead of Get-SPContentDatabase because the Get-SPContentDatabase
        # does not return disabled databases.
        $cdb = Get-SPDatabase | Where-Object -FilterScript {
            $_.Type -eq "Content Database" -and $_.Name -eq $params.Name
        }

        if ($params.Ensure -eq "Present")
        {
            # Check if specified web application exists and throw exception when
            # this is not the case
            $webapp = Get-SPWebApplication | Where-Object -FilterScript {
                $_.Url.Trim("/") -eq $params.WebAppUrl.Trim("/")
            }

            if ($null -eq $webapp)
            {
                throw "Specified web application does not exist."
            }

            # Check if database exists
            if ($null -ne $cdb)
            {
                if ($cdb.Server -ne $params.DatabaseServer)
                {
                    throw ("Specified database server does not match the actual database " + `
                           "server. This resource cannot move the database to a different " + `
                           "SQL instance.")
                }

                # Check and change attached web application.
                # Dismount and mount to correct web application
                if ($params.WebAppUrl.Trim("/") -ne $cdb.WebApplication.Url.Trim("/"))
                {
                    Dismount-SPContentDatabase $params.Name -Confirm:$false

                    $newParams= @{}
                    foreach ($param in $params.GetEnumerator())
                    {
                        $skipParams = @("Enabled", "Ensure", "InstallAccount", "MaximumSiteCount", "WebAppUrl")

                        if ($skipParams -notcontains $param.Key)
                        {
                            $newParams.$($param.Key) = $param.Value
                        }

                        if ($param.Key -eq "MaximumSiteCount")
                        {
                            $newParams.MaxSiteCount = $param.Value
                        }

                        if ($param.Key -eq "WebAppUrl")
                        {
                            $newParams.WebApplication = $param.Value
                        }
                    }

                    try
                    {
                        $cdb = Mount-SPContentDatabase @newParams -ErrorAction Stop
                    }
                    catch
                    {
                        throw ("Error occurred while mounting content database. " + `
                                "Content database is not mounted. " + `
                                "Error details: $($_.Exception.Message)")
                    }

                    if ($cdb.Status -eq "Online")
                    {
                        $cdbenabled = $true
                    }
                    else
                    {
                        $cdbenabled = $false
                    }

                    if ($params.Enabled -ne $cdbenabled)
                    {
                        switch ($params.Enabled)
                        {
                            $true
                            {
                                $cdb.Status = [Microsoft.SharePoint.Administration.SPObjectStatus]::Online
                            }
                            $false
                            {
                                $cdb.Status = [Microsoft.SharePoint.Administration.SPObjectStatus]::Disabled
                            }
                        }
                    }
                }

                # Check and change database status
                if ($cdb.Status -eq "Online")
                {
                    $cdbenabled = $true
                }
                else
                {
                    $cdbenabled = $false
                }

                if ($params.ContainsKey("Enabled") -and $params.Enabled -ne $cdbenabled)
                {
                    switch ($params.Enabled)
                    {
                        $true
                        {
                            $cdb.Status = [Microsoft.SharePoint.Administration.SPObjectStatus]::Online
                        }
                        $false
                        {
                            $cdb.Status = [Microsoft.SharePoint.Administration.SPObjectStatus]::Disabled
                        }
                    }
                 }

                 # Check and change site count settings
                if ($null -ne $params.WarningSiteCount -and $params.WarningSiteCount -ne $cdb.WarningSiteCount)
                {
                    $cdb.WarningSiteCount = $params.WarningSiteCount
                }

                if ($params.MaximumSiteCount -and $params.MaximumSiteCount -ne $cdb.MaximumSiteCount)
                {
                    $cdb.MaximumSiteCount = $params.MaximumSiteCount
                }
            }
            else
            {
                # Database does not exist, but should. Create/mount database
                $newParams= @{}
                foreach ($param in $params.GetEnumerator())
                {
                    $skipParams = @("Enabled", "Ensure", "InstallAccount", "MaximumSiteCount", "WebAppUrl")

                    if ($skipParams -notcontains $param.Key)
                    {
                        $newParams.$($param.Key) = $param.Value
                    }

                    if ($param.Key -eq "MaximumSiteCount")
                    {
                        $newParams.MaxSiteCount = $param.Value
                    }

                    if ($param.Key -eq "WebAppUrl")
                    {
                        $newParams.WebApplication = $param.Value
                    }
                }

                try
                {
                    $cdb = Mount-SPContentDatabase @newParams -ErrorAction Stop
                }
                catch
                {
                    throw ("Error occurred while mounting content database. " + `
                            "Content database is not mounted. " + `
                            "Error details: $($_.Exception.Message)")
                }

                if ($cdb.Status -eq "Online")
                {
                    $cdbenabled = $true
                }
                else
                {
                    $cdbenabled = $false
                }

                if ($params.ContainsKey("Enabled") -eq $true -and `
                    $params.Enabled -ne $cdbenabled)
                {
                    switch ($params.Enabled)
                    {
                        $true
                        {
                            $cdb.Status = [Microsoft.SharePoint.Administration.SPObjectStatus]::Online
                        }
                        $false
                        {
                            $cdb.Status = [Microsoft.SharePoint.Administration.SPObjectStatus]::Disabled
                        }
                    }
                }
            }
            $cdb.Update()
        }
        else
        {
            if ($null -ne $cdb)
            {
                # Database exists, but shouldn't. Dismount database
                Dismount-SPContentDatabase $params.Name -Confirm:$false
            }
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
        $Name,

        [Parameter()]
        [System.String]
        $DatabaseServer,

        [Parameter(Mandatory = $true)]
        [System.String]
        $WebAppUrl,

        [Parameter()]
        [System.Boolean]
        $Enabled,

        [Parameter()]
        [System.UInt16]
        $WarningSiteCount,

        [Parameter()]
        [System.UInt16]
        $MaximumSiteCount,

        [Parameter()]
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure = "Present",

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )

    Write-Verbose -Message "Testing content database configuration settings"

    $PSBoundParameters.Ensure = $Ensure

    $CurrentValues = Get-TargetResource @PSBoundParameters

    if ($CurrentValues.DatabaseServer -ne $DatabaseServer)
    {
        Write-Verbose -Message ("Specified database server does not match the actual " + `
                                "database server. This resource cannot move the database " + `
                                "to a different SQL instance.")
        return $false
    }

    return Test-SPDscParameterState -CurrentValues $CurrentValues `
                                    -DesiredValues $PSBoundParameters
}

Export-ModuleMember -Function *-TargetResource
