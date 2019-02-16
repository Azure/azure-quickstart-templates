function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateSet('Yes')]
        [String]
        $IsSingleInstance,

        [Parameter()]
        [System.String[]]
        $Members,

        [Parameter()]
        [System.String[]]
        $MembersToInclude,

        [Parameter()]
        [System.String[]]
        $MembersToExclude,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $Databases,

        [Parameter()]
        [System.Boolean]
        $AllDatabases,

        [Parameter()]
        [System.String[]]
        $ExcludeDatabases,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )

    Write-Verbose -Message "Getting Shell Admins config"

    $nullreturn = @{
        IsSingleInstance = "Yes"
        Members          = $null
        MembersToInclude = $null
        MembersToExclude = $null
    }

    if ($Members -and (($MembersToInclude) -or ($MembersToExclude)))
    {
        Write-Verbose -Message ("Cannot use the Members parameter together with the " + `
                                "MembersToInclude or MembersToExclude parameters")
        return $nullreturn
    }

    if ($Databases)
    {
        foreach ($database in $Databases)
        {
            if ($database.Members -and (($database.MembersToInclude) `
                -or ($database.MembersToExclude)))
            {
                Write-Verbose -Message ("Databases: Cannot use the Members parameter " + `
                                        "together with the MembersToInclude or " + `
                                        "MembersToExclude parameters")
                return $nullreturn
            }

            if (!$database.Members `
                -and !$database.MembersToInclude `
                -and !$database.MembersToExclude)
            {
                Write-Verbose -Message ("Databases: At least one of the following " + `
                                        "parameters must be specified: Members, " + `
                                        "MembersToInclude, MembersToExclude")
                return $nullreturn
            }
        }
    }
    else
    {
        if (!$Members -and !$MembersToInclude -and !$MembersToExclude)
        {
            Write-Verbose -Message ("At least one of the following parameters must be " + `
                                    "specified: Members, MembersToInclude, MembersToExclude")
            return $nullreturn
        }
    }

    if ($Databases -and $AllDatabases)
    {
        Write-Verbose -Message ("Cannot use the Databases parameter together with the " + `
                                "AllDatabases parameter")
        return $nullreturn
    }

    if ($Databases -and $ExcludeDatabases)
    {
        Write-Verbose -Message ("Cannot use the Databases parameter together with the " + `
                                "ExcludeDatabases parameter")
        return $nullreturn
    }

    $result = Invoke-SPDSCCommand -Credential $InstallAccount `
                                  -Arguments @($PSBoundParameters, $PSScriptRoot) `
                                  -ScriptBlock {
        $params = $args[0]
        $scriptRoot = $args[1]

        Import-Module -Name (Join-Path -Path $scriptRoot -ChildPath "MSFT_SPShellAdmins.psm1")

        try
        {
            $spFarm = Get-SPFarm
        }
        catch
        {
            Write-Verbose -Message ("No local SharePoint farm was detected. Shell admin " + `
                                    "settings will not be applied")
            return $nullreturn
        }

        $shellAdmins = Get-SPShellAdmin

        $cdbPermissions = @()
        $databases = Get-SPDatabase
        if ($params.ContainsKey("ExcludeDatabases"))
        {
            $databases = $databases | Where-Object -FilterScript {
                                        $_.Name -notin $params.ExcludeDatabases
                                      }
        }

        foreach ($database in $databases)
        {
            $cdbPermission = @{}

            $cdbPermission.Name = $database.Name
            $dbShellAdmins = Get-SPShellAdmin -Database $database.Id
            $cdbPermission.Members = $dbShellAdmins.UserName

            $cdbPermissions += $cdbPermission
        }

        return @{
            IsSingleInstance = "Yes"
            Members = $shellAdmins.UserName
            MembersToInclude = $params.MembersToInclude
            MembersToExclude = $params.MembersToExclude
            Databases = $cdbPermissions
            AllDatabases = $params.AllDatabases
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
        [ValidateSet('Yes')]
        [String]
        $IsSingleInstance,

        [Parameter()]
        [System.String[]]
        $Members,

        [Parameter()]
        [System.String[]]
        $MembersToInclude,

        [Parameter()]
        [System.String[]]
        $MembersToExclude,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $Databases,

        [Parameter()]
        [System.Boolean]
        $AllDatabases,

        [Parameter()]
        [System.String[]]
        $ExcludeDatabases,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )

    Write-Verbose -Message "Setting Shell Admin config"

    if ($Members -and (($MembersToInclude) -or ($MembersToExclude)))
    {
        throw ("Cannot use the Members parameter together with the " + `
               "MembersToInclude or MembersToExclude parameters")
    }

    if ($Databases)
    {
        foreach ($database in $Databases)
        {
            if ($database.Members -and (($database.MembersToInclude) `
                -or ($database.MembersToExclude)))
            {
                throw ("Databases: Cannot use the Members parameter " + `
                       "together with the MembersToInclude or " + `
                       "MembersToExclude parameters")
            }

            if (!$database.Members `
                -and !$database.MembersToInclude `
                -and !$database.MembersToExclude)
            {
                throw ("Databases: At least one of the following " + `
                       "parameters must be specified: Members, " + `
                       "MembersToInclude, MembersToExclude")
            }
        }
    }
    else
    {
        if (!$Members -and !$MembersToInclude -and !$MembersToExclude)
        {
            throw ("At least one of the following parameters must be " + `
                   "specified: Members, MembersToInclude, MembersToExclude")
        }
    }

    if ($Databases -and $AllDatabases)
    {
        throw ("Cannot use the Databases parameter together with the " + `
               "AllDatabases parameter")
    }

    if ($Databases -and $ExcludeDatabases)
    {
        throw ("Cannot use the Databases parameter together with the " + `
               "ExcludeDatabases parameter")
    }

    $result = Invoke-SPDSCCommand -Credential $InstallAccount `
                                  -Arguments @($PSBoundParameters, $PSScriptRoot) `
                                  -ScriptBlock {
        $params = $args[0]
        $scriptRoot = $args[1]

        Import-Module -Name (Join-Path -Path $scriptRoot -ChildPath "MSFT_SPShellAdmins.psm1")

        try
        {
            $spFarm = Get-SPFarm
        }
        catch
        {
            throw ("No local SharePoint farm was detected. Shell admin " + `
                   "settings will not be applied")
        }

        $shellAdmins = Get-SPShellAdmin

        if ($params.Members)
        {
            Write-Verbose -Message "Processing Members"
            if ($shellAdmins)
            {
                $differences = Compare-Object -ReferenceObject $shellAdmins.UserName `
                                              -DifferenceObject $params.Members

                if ($null -eq $differences)
                {
                    Write-Verbose -Message ("Shell Admins group matches. No further " + `
                                            "processing required")
                }
                else
                {
                    Write-Verbose -Message ("Shell Admins group does not match. Perform " + `
                                            "corrective action")

                    foreach ($difference in $differences)
                    {
                        if ($difference.SideIndicator -eq "=>")
                        {
                            $user = $difference.InputObject
                            try
                            {
                                Add-SPShellAdmin -UserName $user
                            }
                            catch
                            {
                                throw ("Error while setting the Shell Admin. The Shell " + `
                                       "Admin permissions will not be applied. Error " + `
                                       "details: $($_.Exception.Message)")
                                return
                            }
                        }
                        elseif ($difference.SideIndicator -eq "<=")
                        {
                            $user = $difference.InputObject
                            try
                            {
                                Remove-SPShellAdmin -UserName $user -Confirm:$false
                            }
                            catch
                            {
                                throw ("Error while removing the Shell Admin. The Shell Admin " + `
                                       "permissions will not be revoked. Error details: " + `
                                       "$($_.Exception.Message)")
                                return
                            }
                        }
                    }
                }
            }
            else
            {
                foreach ($member in $params.Members)
                {
                    try
                    {
                        Add-SPShellAdmin -UserName $member
                    }
                    catch
                    {
                        throw ("Error while setting the Shell Admin. The Shell Admin " + `
                               "permissions will not be applied. Error details: " + `
                               "$($_.Exception.Message)")
                        return
                    }
                }
            }
        }

        if ($params.MembersToInclude)
        {
            Write-Verbose -Message "Processing MembersToInclude"
            if ($shellAdmins)
            {
                foreach ($member in $params.MembersToInclude)
                {
                    if (-not $shellAdmins.UserName.Contains($member))
                    {
                        try
                        {
                            Add-SPShellAdmin -UserName $member
                        }
                        catch
                        {
                            throw ("Error while setting the Shell Admin. The Shell Admin " + `
                                   "permissions will not be applied. Error details: " + `
                                   "$($_.Exception.Message)")
                            return
                        }
                    }
                }
            }
            else
            {
                foreach ($member in $params.MembersToInclude)
                {
                    try
                    {
                        Add-SPShellAdmin -UserName $member
                    }
                    catch
                    {
                        throw ("Error while setting the Shell Admin. The Shell Admin " + `
                               "permissions will not be applied. Error details: $($_.Exception.Message)")
                        return
                    }
                }
            }
        }

        if ($params.MembersToExclude)
        {
            Write-Verbose -Message "Processing MembersToExclude"
            if ($shellAdmins)
            {
                foreach ($member in $params.MembersToExclude)
                {
                    if ($shellAdmins.UserName.Contains($member))
                    {
                        try
                        {
                            Remove-SPShellAdmin -UserName $member -Confirm:$false
                        }
                        catch
                        {
                            throw ("Error while removing the Shell Admin. The Shell Admin " + `
                                   "permissions will not be revoked. Error details: " + `
                                   "$($_.Exception.Message)")
                            return
                        }
                    }
                }
            }
        }

        if ($params.Databases)
        {
            Write-Verbose -Message "Processing Databases parameter"
            # The Databases parameter is set
            # Compare the configuration against the actual set and correct any issues

            foreach ($database in $params.Databases)
            {
                # Check if configured database exists, throw error if not
                Write-Verbose -Message "Processing Database: $($database.Name)"

                $currentCDB = Get-SPDatabase | Where-Object -FilterScript {
                    $_.Name -eq $database.Name
                }
                if ($null -ne $currentCDB)
                {
                    $dbShellAdmins = Get-SPShellAdmin -database $currentCDB.Id

                    if ($database.Members)
                    {
                        Write-Verbose -Message "Processing Members"
                        if ($dbShellAdmins)
                        {
                            $differences = Compare-Object -ReferenceObject $database.Members `
                                                          -DifferenceObject $dbShellAdmins.UserName
                            foreach ($difference in $differences)
                            {
                                if ($difference.SideIndicator -eq "<=")
                                {
                                    $user = $difference.InputObject
                                    try
                                    {
                                        Add-SPShellAdmin -database $currentCDB.Id -UserName $user
                                    }
                                    catch
                                    {
                                        throw ("Error while setting the Shell Admin. The " + `
                                               "Shell Admin permissions will not be applied. " + `
                                               "Error details: $($_.Exception.Message)")
                                        return
                                    }
                                }
                                elseif ($difference.SideIndicator -eq "=>")
                                {
                                    $user = $difference.InputObject
                                    try
                                    {
                                        Remove-SPShellAdmin -Database $currentCDB.Id `
                                                            -UserName $user `
                                                            -Confirm:$false
                                    }
                                    catch
                                    {
                                        throw ("Error while removing the Shell Admin. The " + `
                                               "Shell Admin permissions will not be revoked. " + `
                                               "Error details: $($_.Exception.Message)")
                                        return
                                    }
                                }
                            }
                        }
                        else
                        {
                            foreach ($member in $database.Members)
                            {
                                try
                                {
                                    Add-SPShellAdmin -database $currentCDB.Id -UserName $member
                                }
                                catch
                                {
                                    throw ("Error while setting the Shell Admin. The Shell " + `
                                           "Admin permissions will not be applied. Error " + `
                                           "details: $($_.Exception.Message)")
                                    return
                                }
                            }
                        }
                    }

                    if ($database.MembersToInclude)
                    {
                        Write-Verbose -Message "Processing MembersToInclude"
                        if ($dbShellAdmins)
                        {
                            foreach ($member in $database.MembersToInclude)
                            {
                                if (-not $dbShellAdmins.UserName.Contains($member))
                                {
                                    try
                                    {
                                        Add-SPShellAdmin -database $currentCDB.Id -UserName $member
                                    }
                                    catch
                                    {
                                        throw ("Error while setting the Shell Admin. The " + `
                                               "Shell Admin permissions will not be applied. " + `
                                               "Error details: $($_.Exception.Message)")
                                        return
                                    }
                                }
                            }
                        }
                        else
                        {
                            foreach ($member in $database.MembersToInclude)
                            {
                                try
                                {
                                    Add-SPShellAdmin -database $currentCDB.Id -UserName $member
                                }
                                catch
                                {
                                    throw ("Error while setting the Shell Admin. The Shell " + `
                                           "Admin permissions will not be applied. Error " + `
                                           "details: $($_.Exception.Message)")
                                    return
                                }
                            }
                        }
                    }

                    if ($database.MembersToExclude)
                    {
                        Write-Verbose -Message "Processing MembersToExclude"
                        if ($dbShellAdmins)
                        {
                            foreach ($member in $database.MembersToExclude)
                            {
                                if ($dbShellAdmins.UserName.Contains($member))
                                {
                                    try
                                    {
                                        Remove-SPShellAdmin -Database $currentCDB.Id `
                                                            -UserName $member `
                                                            -Confirm:$false
                                    }
                                    catch
                                    {
                                        throw ("Error while removing the Shell Admin. The " + `
                                               "Shell Admin permissions will not be revoked. " + `
                                               "Error details: $($_.Exception.Message)")
                                        return
                                    }
                                }
                            }
                        }
                    }
                }
                else
                {
                    throw "Specified database does not exist: $($database.Name)"
                }
            }
        }

        if ($params.AllDatabases)
        {
            Write-Verbose -Message "Processing AllDatabases parameter"

            $databases = Get-SPDatabase
            if ($params.ContainsKey("ExcludeDatabases"))
            {
                $databases = $databases | Where-Object -FilterScript {
                                            $_.Name -notin $params.ExcludeDatabases
                                          }
            }
            foreach ($database in $databases)
            {
                $dbShellAdmins = Get-SPShellAdmin -database $database.Id
                if ($params.Members)
                {
                    Write-Verbose -Message "Processing Database: $($database.Name)"
                    if ($dbShellAdmins)
                    {
                        $differences = Compare-Object -ReferenceObject $dbShellAdmins.UserName `
                                                      -DifferenceObject $params.Members

                        if ($null -eq $differences)
                        {
                            Write-Verbose -Message ("Shell Admins group matches. No further " + `
                                                    "processing required")
                        }
                        else
                        {
                            Write-Verbose -Message ("Shell Admins group does not match. Perform " + `
                                                    "corrective action")

                            foreach ($difference in $differences)
                            {
                                if ($difference.SideIndicator -eq "=>")
                                {
                                    $user = $difference.InputObject
                                    try
                                    {
                                        Add-SPShellAdmin -database $database.Id -UserName $user
                                    }
                                    catch
                                    {
                                        throw ("Error while setting the Shell Admin. The " + `
                                               "Shell Admin permissions will not be applied. " + `
                                               "Error details: $($_.Exception.Message)")
                                        return
                                    }
                                }
                                elseif ($difference.SideIndicator -eq "<=")
                                {
                                    $user = $difference.InputObject
                                    try
                                    {
                                        Remove-SPShellAdmin -Database $database.Id `
                                                            -UserName $user `
                                                            -Confirm:$false
                                    }
                                    catch
                                    {
                                        throw ("Error while removing the Shell Admin. The " + `
                                               "Shell Admin permissions will not be revoked. " + `
                                               "Error details: $($_.Exception.Message)")
                                        return
                                    }
                                }
                            }
                        }
                    }
                    else
                    {
                        foreach ($member in $params.Members)
                        {
                            try
                            {
                                Add-SPShellAdmin -database $database.Id -UserName $member
                            }
                            catch
                            {
                                throw ("Error while setting the Shell Admin. The Shell Admin " + `
                                       "permissions will not be applied. Error details: " + `
                                       "$($_.Exception.Message)")
                                return
                            }
                        }
                    }
                }

                if ($params.MembersToInclude)
                {
                    if ($dbShellAdmins)
                    {
                        foreach ($member in $params.MembersToInclude)
                        {
                            if (-not $dbShellAdmins.UserName.Contains($member))
                            {
                                try
                                {
                                    Add-SPShellAdmin -database $database.Id -UserName $member
                                }
                                catch
                                {
                                    throw ("Error while setting the Shell Admin. The Shell " + `
                                           "Admin permissions will not be applied. Error " + `
                                           "details: $($_.Exception.Message)")
                                    return
                                }
                            }
                        }
                    }
                    else
                    {
                        foreach ($member in $params.MembersToInclude)
                        {
                            try
                            {
                                Add-SPShellAdmin -database $database.Id -UserName $member
                            }
                            catch
                            {
                                throw ("Error while setting the Shell Admin. The Shell Admin " + `
                                       "permissions will not be applied. Error details: " + `
                                       "$($_.Exception.Message)")
                                return
                            }
                        }

                    }
                }

                if ($params.MembersToExclude)
                {
                    if ($dbShellAdmins)
                    {
                        foreach ($member in $params.MembersToExclude)
                        {
                            if ($dbShellAdmins.UserName.Contains($member))
                            {
                                try
                                {
                                    Remove-SPShellAdmin -Database $database.Id `
                                                        -UserName $member `
                                                        -Confirm:$false
                                }
                                catch
                                {
                                    throw ("Error while removing the Shell Admin. The Shell " + `
                                           "Admin permissions will not be revoked. Error " + `
                                           "details: $($_.Exception.Message)")
                                    return
                                }
                            }
                        }
                    }
                }
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
        [ValidateSet('Yes')]
        [String]
        $IsSingleInstance,

        [Parameter()]
        [System.String[]]
        $Members,

        [Parameter()]
        [System.String[]]
        $MembersToInclude,

        [Parameter()]
        [System.String[]]
        $MembersToExclude,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $Databases,

        [Parameter()]
        [System.Boolean]
        $AllDatabases,

        [Parameter()]
        [System.String[]]
        $ExcludeDatabases,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )

    Write-Verbose -Message "Testing Shell Admin settings"

    # Start checking
    $CurrentValues = Get-TargetResource @PSBoundParameters

    if ($null -eq $CurrentValues.Members -and `
        $null -eq $CurrentValues.MembersToInclude -and `
        $null -eq $CurrentValues.MembersToExclude)
    {
        return $false
    }

    if ($Members)
    {
        Write-Verbose -Message "Processing Members parameter"
        if (-not $CurrentValues.Members)
        {
            return $false
        }

        $differences = Compare-Object -ReferenceObject $CurrentValues.Members `
                                      -DifferenceObject $Members

        if ($null -eq $differences)
        {
            Write-Verbose -Message "Shell Admins group matches"
        }
        else
        {
            Write-Verbose -Message "Shell Admins group does not match"
            return $false
        }
    }

    if ($MembersToInclude)
    {
        Write-Verbose -Message "Processing MembersToInclude parameter"
        if (-not $CurrentValues.Members)
        {
            return $false
        }

        foreach ($member in $MembersToInclude)
        {
            if (-not($CurrentValues.Members.Contains($member)))
            {
                Write-Verbose -Message "$member is not a Shell Admin. Set result to false"
                return $false
            }
            else
            {
                Write-Verbose -Message "$member is already a Shell Admin. Skipping"
            }
        }
    }

    if ($MembersToExclude)
    {
        Write-Verbose -Message "Processing MembersToExclude parameter"
        if ($CurrentValues.Members)
        {
            foreach ($member in $MembersToExclude)
            {
                if ($CurrentValues.Members.Contains($member))
                {
                    Write-Verbose -Message "$member is a Shell Admin. Set result to false"
                    return $false
                }
                else
                {
                    Write-Verbose -Message "$member is not a Shell Admin. Skipping"
                }
            }
        }
    }

    if ($AllDatabases)
    {
        # The AllDatabases parameter is set
        # Check the Members group against all databases
        Write-Verbose -Message "Processing AllDatabases parameter"

        foreach ($database in $CurrentValues.Databases)
        {
            # Check if configured database exists, throw error if not
            Write-Verbose -Message "Processing Database: $($database.Name)"

            if ($Members)
            {
                if (-not $database.Members)
                {
                    return $false
                }

                $differences = Compare-Object -ReferenceObject $database.Members `
                                              -DifferenceObject $Members

                if ($null -eq $differences)
                {
                    Write-Verbose -Message "Shell Admins group matches"
                }
                else
                {
                    Write-Verbose -Message "Shell Admins group does not match"
                    return $false
                }
            }

            if ($MembersToInclude)
            {
                if (-not $database.Members)
                {
                    return $false
                }

                foreach ($member in $MembersToInclude)
                {
                    if (-not($database.Members.Contains($member)))
                    {
                        Write-Verbose -Message "$member is not a Shell Admin. Set result to false"
                        return $false
                    }
                    else
                    {
                        Write-Verbose -Message "$member is already a Shell Admin. Skipping"
                    }
                }
            }

            if ($MembersToExclude)
            {
                if ($database.Members)
                {
                    foreach ($member in $MembersToExclude)
                    {
                        if ($database.Members.Contains($member))
                        {
                            Write-Verbose -Message "$member is a Shell Admin. Set result to false"
                            return $false
                        }
                        else
                        {
                            Write-Verbose -Message "$member is not a Shell Admin. Skipping"
                        }
                    }
                }
            }
        }
    }

    if ($Databases)
    {
        # The Databases parameter is set
        # Compare the configuration against the actual set
        Write-Verbose -Message "Processing Databases parameter"

        foreach ($database in $Databases)
        {
            # Check if configured database exists, throw error if not
            Write-Verbose -Message "Processing Database: $($database.Name)"

            $currentCDB = $CurrentValues.Databases | Where-Object -FilterScript {
                $_.Name -eq $database.Name
            }

            if ($null -ne $currentCDB)
            {
                if ($database.Members)
                {
                    Write-Verbose -Message "Processing Members parameter"
                    if (-not $currentCDB.Members)
                    {
                        return $false
                    }

                    $differences = Compare-Object -ReferenceObject $currentCDB.Members `
                                                  -DifferenceObject $database.Members

                    if ($null -eq $differences)
                    {
                        Write-Verbose -Message "Shell Admins group matches"
                    }
                    else
                    {
                        Write-Verbose -Message "Shell Admins group does not match"
                        return $false
                    }
                }

                if ($database.MembersToInclude)
                {
                    Write-Verbose -Message "Processing MembersToInclude parameter"
                    if (-not $currentCDB.Members)
                    {
                        return $false
                    }

                    foreach ($member in $database.MembersToInclude)
                    {
                        if (-not($currentCDB.Members.Contains($member)))
                        {
                            Write-Verbose -Message "$member is not a Shell Admin. Set result to false"
                            return $false
                        }
                        else
                        {
                            Write-Verbose -Message "$member is already a Shell Admin. Skipping"
                        }
                    }
                }

                if ($database.MembersToExclude)
                {
                    Write-Verbose -Message "Processing MembersToExclude parameter"
                    if ($currentCDB.Members)
                    {
                        foreach ($member in $database.MembersToExclude)
                        {
                            if ($currentCDB.Members.Contains($member))
                            {
                                Write-Verbose -Message "$member is a Shell Admin. Set result to false"
                                return $false
                            }
                            else
                            {
                                Write-Verbose -Message "$member is not a Shell Admin. Skipping"
                            }
                        }
                    }
                }
            }
            else
            {
                throw "Specified database does not exist: $($database.Name)"
            }
        }
    }

    return $true
}

Export-ModuleMember -Function *-TargetResource
