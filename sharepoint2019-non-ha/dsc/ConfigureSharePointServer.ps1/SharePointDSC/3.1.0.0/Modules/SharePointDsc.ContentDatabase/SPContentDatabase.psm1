function Mount-SPDscContentDatabase()
{
    param
    (
        [Parameter(Mandatory=$true)]
        [System.Collections.Hashtable]
        $params,

        [Parameter(Mandatory=$true)]
        [System.Boolean]
        $enabled
    )

    if ($params.ContainsKey("Enabled"))
    {
        $params.Remove("Enabled")
    }
    
    if ($params.ContainsKey("Ensure"))
    {
        $params.Remove("Ensure")
    }
    
    if ($params.ContainsKey("InstallAccount"))
    {
        $params.Remove("InstallAccount")
    }
    
    if ($params.ContainsKey("MaximumSiteCount"))
    {
        $params.MaxSiteCount = $params.MaximumSiteCount
        $params.Remove("MaximumSiteCount")
    }
    if ($params.ContainsKey("WebAppUrl"))
    {
        $params.WebApplication = $params.WebAppUrl
        $params.Remove("WebAppUrl")
    }

    try
    {
        $cdb = Mount-SPContentDatabase @params
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

    if ($enabled -ne $cdbenabled)
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

    return $cdb
}
