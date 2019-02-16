function Get-SPDSCWebApplicationBlockedFileTypeConfig
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param(
        [Parameter(Mandatory = $true)]
        $WebApplication
    )
    $result = @()
    $WebApplication.BlockedFileExtensions | ForEach-Object -Process {
        $result += $_
    }
    return @{
       Blocked = $result
    }
}

function Set-SPDSCWebApplicationBlockedFileTypeConfig
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $WebApplication,

        [Parameter(Mandatory = $true)]
        $Settings
    )

    if (($Settings.ContainsKey("Blocked") -eq $true) `
            -and (($Settings.ContainsKey("EnsureBlocked") -eq $true) `
          -or ($Settings.ContainsKey("EnsureAllowed") -eq $true)))
    {
        throw ("Blocked file types must use either the 'blocked' property or the " + `
               "'EnsureBlocked' and/or 'EnsureAllowed' properties, but not both.")
    }

    if (($Settings.ContainsKey("Blocked") -eq $false) `
            -and ($Settings.ContainsKey("EnsureBlocked") -eq $false) `
            -and ($Settings.ContainsKey("EnsureAllowed") -eq $false))
    {
        throw ("Blocked file types must specify at least one property (either 'Blocked, " + `
               "'EnsureBlocked' or 'EnsureAllowed')")
    }

    if($Settings.ContainsKey("Blocked") -eq $true)
    {
        $WebApplication.BlockedFileExtensions.Clear();
        $Settings.Blocked | ForEach-Object -Process {
            $WebApplication.BlockedFileExtensions.Add($_.ToLower());
        }
    }

    if($Settings.ContainsKey("EnsureBlocked") -eq $true)
    {
        $Settings.EnsureBlocked | ForEach-Object -Process {
            if(!$WebApplication.BlockedFileExtensions.Contains($_.ToLower())){
                $WebApplication.BlockedFileExtensions.Add($_.ToLower());
            }
        }
    }

    if($Settings.ContainsKey("EnsureAllowed") -eq $true)
    {
        $Settings.EnsureAllowed | ForEach-Object -Process {
            if($WebApplication.BlockedFileExtensions.Contains($_.ToLower())){
                $WebApplication.BlockedFileExtensions.Remove($_.ToLower());
            }
        }
    }
}

function Test-SPDSCWebApplicationBlockedFileTypeConfig
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param(
        [Parameter(Mandatory = $true)]
        $CurrentSettings,

        [Parameter(Mandatory = $true)]
        $DesiredSettings
    )

    if (($DesiredSettings.ContainsKey("Blocked") -eq $true) `
            -and (($DesiredSettings.ContainsKey("EnsureBlocked") -eq $true) `
          -or ($DesiredSettings.ContainsKey("EnsureAllowed") -eq $true)))
    {
        throw ("Blocked file types must use either the 'blocked' property or the " + `
               "'EnsureBlocked' and/or 'EnsureAllowed' properties, but not both.")
    }

    if (($DesiredSettings.ContainsKey("Blocked") -eq $false) `
            -and ($DesiredSettings.ContainsKey("EnsureBlocked") -eq $false) `
            -and ($DesiredSettings.ContainsKey("EnsureAllowed") -eq $false))
    {
        throw ("Blocked file types must specify at least one property (either 'Blocked, " + `
               "'EnsureBlocked' or 'EnsureAllowed')")
    }

    if ($DesiredSettings.ContainsKey("Blocked") -eq $true)
    {
        $compareResult = Compare-Object -ReferenceObject $CurrentSettings.Blocked `
                                        -DifferenceObject $DesiredSettings.Blocked
        if ($null -eq $compareResult)
        {
            return $true
        }
        else
        {
            return $false
        }
    }

    if ($DesiredSettings.ContainsKey("EnsureBlocked") -eq $true)
    {
        $itemsToAdd = Compare-Object -ReferenceObject $CurrentSettings.Blocked `
                                     -DifferenceObject $DesiredSettings.EnsureBlocked | Where-Object {
                                         $_.SideIndicator -eq "=>"
                                        }
        if ($null -ne $itemsToAdd)
        {
            return $false
        }
    }

    if ($DesiredSettings.ContainsKey("EnsureAllowed") -eq $true)
    {
        $itemsToRemove = Compare-Object -ReferenceObject $CurrentSettings.Blocked `
                                        -DifferenceObject $DesiredSettings.EnsureAllowed `
                                        -ExcludeDifferent -IncludeEqual
        if ($null -ne $itemsToRemove)
        {
            return $false
        }
    }
    return $true
}

