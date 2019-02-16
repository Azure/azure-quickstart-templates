function Add-SPDSCUserToLocalAdmin
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true,Position=1)]
        [string]
        $UserName
    )

    if ($UserName.Contains("\") -eq $false)
    {
        throw [Exception] "Usernames should be formatted as domain\username"
    }

    $domainName = $UserName.Split('\')[0]
    $accountName = $UserName.Split('\')[1]

    Write-Verbose -Message "Adding $domainName\$userName to local admin group"
    ([ADSI]"WinNT://$($env:computername)/Administrators,group").Add("WinNT://$domainName/$accountName") | Out-Null
}

function Clear-SPDscKerberosToken
{
    param (
        [Parameter(Mandatory=$true)]
        [System.String]
        $Account
    )

    $sessions = klist sessions
    foreach ($session in $sessions)
    {
        if ($session -like "*$($Account)*")
        {
            Write-Verbose -Message "Purging Kerberos ticket for $LogonId"
            $LogonId = $session.split(' ')[3]
            $LogonId = $LogonId.Replace('0:','')
            klist -li $LogonId purge | Out-Null
        }

    }
}

function Convert-SPDscADGroupIDToName
{
    param(
        [Parameter(Mandatory=$true)]
        [System.Guid]
        $GroupId
    )

    $bytes = $GroupId.ToByteArray()
    $queryGuid = ""
    $bytes | ForEach-Object -Process {
        $queryGuid += "\" + $_.ToString("x2")
    }

    $domain = New-Object -TypeName "System.DirectoryServices.DirectoryEntry"
    $search = New-Object -TypeName "System.DirectoryServices.DirectorySearcher"
    $search.SearchRoot = $domain
    $search.PageSize = 1
    $search.Filter = "(&(objectGuid=$queryGuid))"
    $search.SearchScope = "Subtree"
    $search.PropertiesToLoad.Add("name") | Out-Null
    $result = $search.FindOne()

    if ($null -ne $result)
    {
        $sid = New-Object -TypeName "System.Security.Principal.SecurityIdentifier" `
                          -ArgumentList @($result.GetDirectoryEntry().objectsid[0], 0)

        return $sid.Translate([System.Security.Principal.NTAccount]).ToString()
    }
    else
    {
        throw "Unable to locate group with id $GroupId"
    }
}

function Convert-SPDscADGroupNameToID
{
    param(
        [Parameter(Mandatory=$true)]
        [System.String]
        $GroupName
    )

    $groupNTaccount = New-Object -TypeName "System.Security.Principal.NTAccount" `
                                 -ArgumentList $groupName
    $groupSid = $groupNTaccount.Translate([System.Security.Principal.SecurityIdentifier])

    $result = New-Object -TypeName "System.DirectoryServices.DirectoryEntry" `
                         -ArgumentList "LDAP://<SID=$($groupSid.ToString())>"
    return ([Guid]::new($result.objectGUID.Value))
}

function Get-SPDscOSVersion
{
    [CmdletBinding()]
    param()
    return [System.Environment]::OSVersion.Version
}

function Get-SPDSCAssemblyVersion
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true,Position=1)]
        [string]
        $PathToAssembly
    )
    return (Get-Command $PathToAssembly).FileVersionInfo.FileMajorPart
}

function Get-SPDSCBuildVersion
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true,Position=1)]
        [string]
        $PathToAssembly
    )
    return (Get-Command $PathToAssembly).FileVersionInfo.FileBuildPart
}

function Get-SPDscFarmAccount
{
    [CmdletBinding()]
    param
    ()

    $farmaccount = (Get-SPFarm).DefaultServiceAccount.Name

    $account = Get-SPManagedAccount | Where-Object -FilterScript { $_.UserName -eq $farmaccount }

    $bindings = [System.Reflection.BindingFlags]::CreateInstance -bor `
                [System.Reflection.BindingFlags]::GetField -bor `
                [System.Reflection.BindingFlags]::Instance -bor `
                [System.Reflection.BindingFlags]::NonPublic

    $pw = $account.GetType().GetField("m_Password", $bindings).GetValue($account);

    return New-Object -TypeName System.Management.Automation.PSCredential `
                      -ArgumentList $farmaccount, $pw.SecureStringValue
}


function Get-SPDscFarmAccountName
{
    [CmdletBinding()]
    param
    ()
    $spFarm = Get-SPFarm
    return $spFarm.DefaultServiceAccount.Name
}


function Get-SPDscFarmVersionInfo
{
    param
    (
        [Parameter()]
        [System.String]
        $ProductToCheck
    )

    $farm = Get-SPFarm
    $productVersions = [Microsoft.SharePoint.Administration.SPProductVersions]::GetProductVersions($farm)
    $server = Get-SPServer -Identity $env:COMPUTERNAME
    $versionInfo = @{}
    $versionInfo.Highest = ""
    $versionInfo.Lowest = ""

    $serverProductInfo = $productVersions.GetServerProductInfo($server.id)
    $products = $serverProductInfo.Products

    if ($ProductToCheck)
    {
        $products = $products | Where-Object -FilterScript {
            $_ -eq $ProductToCheck
        }

        if ($null -eq $products)
        {
            throw "Product not found: $ProductToCheck"
        }
    }

    # Loop through all products
    foreach ($product in $products)
    {
        $singleProductInfo = $serverProductInfo.GetSingleProductInfo($product)
        $patchableUnits = $singleProductInfo.PatchableUnitDisplayNames

        # Loop through all individual components within the product
        foreach ($patchableUnit in $patchableUnits)
        {
            # Check if the displayname is the Proofing tools (always mentioned in first product,
            # generates noise)
            if (($patchableUnit -notmatch "Microsoft Server Proof") -and
                ($patchableUnit -notmatch "SQL Express") -and
                ($patchableUnit -notmatch "OMUI") -and
                ($patchableUnit -notmatch "XMUI") -and
                ($patchableUnit -notmatch "Project Server") -and
                (($patchableUnit -notmatch "Microsoft SharePoint Server (2013|2016|2019)" -or `
                  $patchableUnit -match "Core")))
            {
                $patchableUnitsInfo = $singleProductInfo.GetPatchableUnitInfoByDisplayName($patchableUnit)
                $currentVersion = ""
                foreach ($patchableUnitInfo in $patchableUnitsInfo)
                {
                    # Loop through version of the patchableUnit
                    $currentVersion = $patchableUnitInfo.LatestPatch.Version.ToString()

                    # Check if the version of the patchableUnit is the highest for the installed product
                    if ($currentVersion -gt $versionInfo.Highest)
                    {
                        $versionInfo.Highest = $currentVersion
                    }

                    if ($versionInfo.Lowest -eq "")
                    {
                        $versionInfo.Lowest = $currentVersion
                    }
                    else
                    {
                        if ($currentversion -lt $versionInfo.Lowest)
                        {
                            $versionInfo.Lowest = $currentVersion
                        }
                    }
                }
            }
        }
    }
    return $versionInfo
}

function Get-SPDscFarmProductsInfo
{
    $farm = Get-SPFarm
    $productVersions = [Microsoft.SharePoint.Administration.SPProductVersions]::GetProductVersions($farm)
    $server = Get-SPServer -Identity $env:COMPUTERNAME

    $serverProductInfo = $productVersions.GetServerProductInfo($server.id)
    return $serverProductInfo.Products
}

function Get-SPDscRegProductsInfo
{
    $registryLocation = Get-ChildItem -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall"
    $sharePointPrograms = $registryLocation | Where-Object -FilterScript {
         $_.PsPath -like "*\Office*"
    } | ForEach-Object -Process {
        Get-ItemProperty -Path $_.PsPath
    }

    return $sharePointPrograms.DisplayName
}

function Get-SPDSCRegistryKey
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Key,

        [Parameter(Mandatory = $true)]
        [System.String]
        $Value
    )

    if ((Test-Path -Path $Key) -eq $true)
    {
        $regKey = Get-ItemProperty -LiteralPath $Key
        return $regKey.$Value
    }
    else
    {
        throw "Specified registry key $Key could not be found."
    }
}

function Get-SPDSCServiceContext
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true,Position=1)]
        $ProxyGroup
    )
    Write-Verbose -Message "Getting SPContext for Proxy group $($proxyGroup)"
    return [Microsoft.SharePoint.SPServiceContext]::GetContext($proxyGroup,[Microsoft.SharePoint.SPSiteSubscriptionIdentifier]::Default)
}

function Get-SPDSCContentService
{
    [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SharePoint") | Out-Null
    return [Microsoft.SharePoint.Administration.SPWebService]::ContentService
}

function Get-SPDSCUserProfileSubTypeManager
{
    [CmdletBinding()]
    param
    (
        $Context
    )
    [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SharePoint") | Out-Null
    return [Microsoft.Office.Server.UserProfiles.ProfileSubtypeManager]::Get($Context)
}

function Get-SPDSCInstalledProductVersion
{
    $pathToSearch = "C:\Program Files\Common Files\microsoft shared\Web Server Extensions\*\ISAPI\Microsoft.SharePoint.dll"
    $fullPath = Get-Item $pathToSearch | Sort-Object { $_.Directory } -Descending | Select-Object -First 1
    return (Get-Command $fullPath).FileVersionInfo
}

function Invoke-SPDSCCommand
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [System.Management.Automation.PSCredential]
        $Credential,

        [Parameter()]
        [Object[]]
        $Arguments,

        [Parameter(Mandatory = $true)]
        [ScriptBlock]
        $ScriptBlock
    )

    $VerbosePreference = 'Continue'

    $baseScript = @"
        if (`$null -eq (Get-PSSnapin -Name Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue))
        {
            Add-PSSnapin Microsoft.SharePoint.PowerShell
        }

"@

    $invokeArgs = @{
        ScriptBlock = [ScriptBlock]::Create($baseScript + $ScriptBlock.ToString())
    }
    if ($null -ne $Arguments)
    {
        $invokeArgs.Add("ArgumentList", $Arguments)
    }

    if ($null -eq $Credential)
    {
        if ($Env:USERNAME.Contains("$"))
        {
            throw [Exception] ("You need to specify a value for either InstallAccount " + `
                               "or PsDscRunAsCredential.")
            return
        }
        Write-Verbose -Message "Executing as the local run as user $($Env:USERDOMAIN)\$($Env:USERNAME)"

        try
        {
            $result = Invoke-Command @invokeArgs -Verbose
        }
        catch
        {
            if ($_.Exception.Message.Contains("An update conflict has occurred, and you must re-try this action"))
            {
                Write-Verbose -Message ("Detected an update conflict, restarting server to " + `
                                        "allow DSC to resume and retry")
                $global:DSCMachineStatus = 1
            }
            else
            {
                throw $_
            }
        }
        return $result
    }
    else
    {
        if ($Credential.UserName.Split("\")[1] -eq $Env:USERNAME)
        {
            if (-not $Env:USERNAME.Contains("$"))
            {
                throw [Exception] ("Unable to use both InstallAccount and " + `
                                   "PsDscRunAsCredential in a single resource. Remove one " + `
                                   "and try again.")
                return
            }
        }
        Write-Verbose -Message ("Executing using a provided credential and local PSSession " + `
                                "as user $($Credential.UserName)")

        # Running garbage collection to resolve issues related to Azure DSC extention use
        [GC]::Collect()

        $session = New-PSSession -ComputerName $env:COMPUTERNAME `
                                 -Credential $Credential `
                                 -Authentication CredSSP `
                                 -Name "Microsoft.SharePoint.DSC" `
                                 -SessionOption (New-PSSessionOption -OperationTimeout 0 `
                                                                     -IdleTimeout 60000) `
                                 -ErrorAction Continue

        if ($session)
        {
            $invokeArgs.Add("Session", $session)
        }

        try
        {
            $result = Invoke-Command @invokeArgs -Verbose
        }
        catch
        {
            if ($_.Exception.Message.Contains("An update conflict has occurred, and you must re-try this action"))
            {
                Write-Verbose -Message ("Detected an update conflict, restarting server to " + `
                                        "allow DSC to resume and retry")
                $global:DSCMachineStatus = 1
            }
            else
            {
                throw $_
            }
        }

        if ($session)
        {
            Remove-PSSession -Session $session
        }
        return $result
    }
}

function Rename-SPDSCParamValue
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true,Position=1,ValueFromPipeline=$true)]
        $Params,

        [Parameter(Mandatory = $true,Position=2)]
        $OldName,

        [Parameter(Mandatory = $true,Position=3)]
        $NewName
    )

    if ($Params.ContainsKey($OldName))
    {
        $Params.Add($NewName, $Params.$OldName)
        $Params.Remove($OldName) | Out-Null
    }
    return $Params
}

function Remove-SPDSCUserToLocalAdmin
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true,Position=1)]
        [string]
        $UserName
    )

    if ($UserName.Contains("\") -eq $false)
    {
        throw [Exception] "Usernames should be formatted as domain\username"
    }

    $domainName = $UserName.Split('\')[0]
    $accountName = $UserName.Split('\')[1]

    Write-Verbose -Message "Removing $domainName\$userName from local admin group"
    ([ADSI]"WinNT://$($env:computername)/Administrators,group").Remove("WinNT://$domainName/$accountName") | Out-Null
}

function Resolve-SPDscSecurityIdentifier
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [String]
        $SID
    )
    $memberName = ([wmi]"Win32_SID.SID='$SID'").AccountName
    $memberName = "$($env:USERDOMAIN)\$memberName"
    return $memberName
}

function Test-SPDSCObjectHasProperty
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true,Position=1)]
        [Object]
        $Object,

        [Parameter(Mandatory = $true,Position=2)]
        [String]
        $PropertyName
    )

    if (([bool]($Object.PSobject.Properties.name -contains $PropertyName)) -eq $true)
    {
        if ($null -ne $Object.$PropertyName)
        {
            return $true
        }
    }
    return $false
}

function Test-SPDSCRunAsCredential
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter()]
        [System.Management.Automation.PSCredential]
        $Credential
    )

    # If no specific credential is passed and it's not the machine account, it must be
    # PsDscRunAsCredential
    if (($null -eq $Credential) -and ($Env:USERNAME.Contains("$") -eq $false))
    {
        return $true
    }
    # return false for all other scenarios
    return $false
}

function Test-SPDSCRunningAsFarmAccount
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param (
        [Parameter()]
        [pscredential]
        $InstallAccount
    )

    if ($null -eq $InstallAccount)
    {
        if ($Env:USERNAME.Contains("$"))
        {
            throw [Exception] "You need to specify a value for either InstallAccount or PsDscRunAsCredential."
            return
        }
        $Username = "$($Env:USERDOMAIN)\$($Env:USERNAME)"
    }
    else
    {
        $Username = $InstallAccount.UserName
    }

    $result = Invoke-SPDSCCommand -Credential $InstallAccount -ScriptBlock {
        try
        {
            $spFarm = Get-SPFarm
        }
        catch
        {
            Write-Verbose -Message "Unable to detect local farm."
            return $null
        }
        return $spFarm.DefaultServiceAccount.Name
    }

    if ($Username -eq $result)
    {
        return $true
    }
    return $false
}

function Test-SPDscParameterState
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true, Position=1)]
        [HashTable]
        $CurrentValues,

        [Parameter(Mandatory = $true, Position=2)]
        [Object]
        $DesiredValues,

        [Parameter(, Position=3)]
        [Array]
        $ValuesToCheck
    )

    $returnValue = $true

    if (($DesiredValues.GetType().Name -ne "HashTable") `
        -and ($DesiredValues.GetType().Name -ne "CimInstance") `
        -and ($DesiredValues.GetType().Name -ne "PSBoundParametersDictionary"))
    {
        throw ("Property 'DesiredValues' in Test-SPDscParameterState must be either a " + `
               "Hashtable or CimInstance. Type detected was $($DesiredValues.GetType().Name)")
    }

    if (($DesiredValues.GetType().Name -eq "CimInstance") -and ($null -eq $ValuesToCheck))
    {
        throw ("If 'DesiredValues' is a CimInstance then property 'ValuesToCheck' must contain " + `
               "a value")
    }

    if (($null -eq $ValuesToCheck) -or ($ValuesToCheck.Count -lt 1))
    {
        $KeyList = $DesiredValues.Keys
    }
    else
    {
        $KeyList = $ValuesToCheck
    }

    $KeyList | ForEach-Object -Process {
        if (($_ -ne "Verbose") -and ($_ -ne "InstallAccount"))
        {
            if (($CurrentValues.ContainsKey($_) -eq $false) `
            -or ($CurrentValues.$_ -ne $DesiredValues.$_) `
            -or (($DesiredValues.ContainsKey($_) -eq $true) -and ($null -ne $DesiredValues.$_ -and $DesiredValues.$_.GetType().IsArray)))
            {
                if ($DesiredValues.GetType().Name -eq "HashTable" -or `
                    $DesiredValues.GetType().Name -eq "PSBoundParametersDictionary")
                {
                    $CheckDesiredValue = $DesiredValues.ContainsKey($_)
                }
                else
                {
                    $CheckDesiredValue = Test-SPDSCObjectHasProperty -Object $DesiredValues -PropertyName $_
                }

                if ($CheckDesiredValue)
                {
                    $desiredType = $DesiredValues.$_.GetType()
                    $fieldName = $_
                    if ($desiredType.IsArray -eq $true)
                    {
                        if (($CurrentValues.ContainsKey($fieldName) -eq $false) `
                        -or ($null -eq $CurrentValues.$fieldName))
                        {
                            Write-Verbose -Message ("Expected to find an array value for " + `
                                                    "property $fieldName in the current " + `
                                                    "values, but it was either not present or " + `
                                                    "was null. This has caused the test method " + `
                                                    "to return false.")
                            $returnValue = $false
                        }
                        else
                        {
                            $arrayCompare = Compare-Object -ReferenceObject $CurrentValues.$fieldName `
                                                           -DifferenceObject $DesiredValues.$fieldName
                            if ($null -ne $arrayCompare)
                            {
                                Write-Verbose -Message ("Found an array for property $fieldName " + `
                                                        "in the current values, but this array " + `
                                                        "does not match the desired state. " + `
                                                        "Details of the changes are below.")
                                $arrayCompare | ForEach-Object -Process {
                                    Write-Verbose -Message "$($_.InputObject) - $($_.SideIndicator)"
                                }
                                $returnValue = $false
                            }
                        }
                    }
                    else
                    {
                        switch ($desiredType.Name)
                        {
                            "String" {
                                if ([string]::IsNullOrEmpty($CurrentValues.$fieldName) `
                                -and [string]::IsNullOrEmpty($DesiredValues.$fieldName))
                                {}
                                else
                                {
                                    Write-Verbose -Message ("String value for property " + `
                                                            "$fieldName does not match. " + `
                                                            "Current state is " + `
                                                            "'$($CurrentValues.$fieldName)' " + `
                                                            "and desired state is " + `
                                                            "'$($DesiredValues.$fieldName)'")
                                    $returnValue = $false
                                }
                            }
                            "Int32" {
                                if (($DesiredValues.$fieldName -eq 0) `
                                -and ($null -eq $CurrentValues.$fieldName))
                                {}
                                else
                                {
                                    Write-Verbose -Message ("Int32 value for property " + `
                                                            "$fieldName does not match. " + `
                                                            "Current state is " + `
                                                            "'$($CurrentValues.$fieldName)' " + `
                                                            "and desired state is " + `
                                                            "'$($DesiredValues.$fieldName)'")
                                    $returnValue = $false
                                }
                            }
                            "Int16" {
                                if (($DesiredValues.$fieldName -eq 0) `
                                -and ($null -eq $CurrentValues.$fieldName))
                                {}
                                else
                                {
                                    Write-Verbose -Message ("Int16 value for property " + `
                                                            "$fieldName does not match. " + `
                                                            "Current state is " + `
                                                            "'$($CurrentValues.$fieldName)' " + `
                                                            "and desired state is " + `
                                                            "'$($DesiredValues.$fieldName)'")
                                    $returnValue = $false
                                }
                            }
                            "Boolean" {
                                if ($CurrentValues.$fieldName -ne $DesiredValues.$fieldName)
                                {
                                    Write-Verbose -Message ("Boolean value for property " + `
                                                            "$fieldName does not match. " + `
                                                            "Current state is " + `
                                                            "'$($CurrentValues.$fieldName)' " + `
                                                            "and desired state is " + `
                                                            "'$($DesiredValues.$fieldName)'")
                                    $returnValue = $false
                                }
                            }
                            "Single" {
                                if (($DesiredValues.$fieldName -eq 0) `
                                -and ($null -eq $CurrentValues.$fieldName))
                                {}
                                else
                                {
                                    Write-Verbose -Message ("Single value for property " + `
                                                            "$fieldName does not match. " + `
                                                            "Current state is " + `
                                                            "'$($CurrentValues.$fieldName)' " + `
                                                            "and desired state is " + `
                                                            "'$($DesiredValues.$fieldName)'")
                                    $returnValue = $false
                                }
                            }
                            default {
                                Write-Verbose -Message ("Unable to compare property $fieldName " + `
                                                        "as the type ($($desiredType.Name)) is " + `
                                                        "not handled by the " + `
                                                        "Test-SPDscParameterState cmdlet")
                                $returnValue = $false
                            }
                        }
                    }
                }
            }
        }
    }
    return $returnValue
}

function Test-SPDSCUserIsLocalAdmin
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true,Position=1)]
        [string]
        $UserName
    )

    if ($UserName.Contains("\") -eq $false)
    {
        throw [Exception] "Usernames should be formatted as domain\username"
    }

    $domainName = $UserName.Split('\')[0]
    $accountName = $UserName.Split('\')[1]

    return ([ADSI]"WinNT://$($env:computername)/Administrators,group").PSBase.Invoke("Members") | `
        ForEach-Object -Process {
            $_.GetType().InvokeMember("Name", 'GetProperty', $null, $_, $null)
        } | Where-Object -FilterScript {
            $_ -eq $accountName
        }
}

function Test-SPDSCIsADUser
{
    [OutputType([System.Boolean])]
    [CmdletBinding()]
    param (
        [string]
        $IdentityName
    )

    if ($IdentityName -like "*\*")
    {
        $IdentityName = $IdentityName.Substring($IdentityName.IndexOf('\') + 1)
    }

    $searcher = New-Object -TypeName System.DirectoryServices.DirectorySearcher
    $searcher.filter = "((samAccountName=$IdentityName))"
    $searcher.SearchScope = "subtree"
    $searcher.PropertiesToLoad.Add("objectClass") | Out-Null
    $searcher.PropertiesToLoad.Add("objectCategory") | Out-Null
    $searcher.PropertiesToLoad.Add("name") | Out-Null
    $result = $searcher.FindOne()

    if ($null -eq $result)
    {
        throw "Unable to locate identity '$IdentityName' in the current domain."
    }

    if ($result[0].Properties.objectclass -contains "user")
    {
        return $true
    }
    else
    {
        return $false
    }
}

function Set-SPDscObjectPropertyIfValuePresent
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [object]
        $ObjectToSet,

        [Parameter(Mandatory = $true)]
        [string]
        $PropertyToSet,

        [Parameter(Mandatory = $true)]
        [object]
        $ParamsValue,

        [Parameter(Mandatory = $true)]
        [string]
        $ParamKey
    )
    if ($ParamsValue.PSobject.Methods.name -contains "ContainsKey")
    {
        if ($ParamsValue.ContainsKey($ParamKey) -eq $true)
        {
            $ObjectToSet.$PropertyToSet = $ParamsValue.$ParamKey
        }
    }
    else
    {
        if (((Test-SPDSCObjectHasProperty $ParamsValue $ParamKey) -eq $true) `
          -and ($null -ne $ParamsValue.$ParamKey))
        {
            $ObjectToSet.$PropertyToSet = $ParamsValue.$ParamKey
        }
    }
}

function Remove-SPDSCGenericObject
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [Object]
        $SourceCollection,

        [Parameter(Mandatory = $true)]
        [Object]
        $Target
    )
    $SourceCollection.Remove($Target)
}

function Format-OfficePatchGUID
{
    [CmdletBinding()]
    param(
        [parameter(Mandatory = $true)]
        [String]
        $PatchGUID
    )

    $guidParts = $PatchGUID.Split("-")
    if($guidParts.Count -ne 5 `
        -or $guidParts[0].Length -ne 8 `
        -or $guidParts[1].Length -ne 4 `
        -or $guidParts[2].Length -ne 4 `
        -or $guidParts[3].Length -ne 4 `
        -or $guidParts[4].Length -ne 12)
    {
        throw "The provided Office Patch GUID is not in the expected format (e.g. XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"
    }

    $newPart1 = ConvertTo-ReverseString -InputString $guidParts[0]
    $newPart2 = ConvertTo-ReverseString -InputString $guidParts[1]
    $newPart3 = ConvertTo-ReverseString -InputString $guidParts[2]
    $newPart4 = ConvertTo-TwoDigitFlipString -InputString $guidParts[3]
    $newPart5 = ConvertTo-TwoDigitFlipString -InputString $guidParts[4]

    $newGUID = $newPart1 + $newPart2 +$newPart3 + $newPart4 + $newPart5
    return $newGUID
}

function ConvertTo-TwoDigitFlipString
{
    [CmdletBinding()]
    param(
        [parameter(Mandatory = $true)]
        [string]
        $InputString
    )

    if($InputString.Length % 2 -ne 0)
    {
        throw "The input string was not in the correct format. It needs to have an even length."
    }

    $flippedString = ""

    for($i = 0; $i -lt $InputString.Length; $i++)
    {
        $flippedString += $InputString[$i+1] + $InputString[$i]
        $i++
    }
    return $flippedString
}

function ConvertTo-ReverseString
{
    [CmdletBinding()]
    param(
        [parameter(Mandatory = $true)]
        [string]
        $InputString
    )

    $reverseString = ""
    for($i = $InputString.Length - 1; $i -ge 0; $i--)
    {
        $reverseString += $InputString[$i]
    }
    return $reverseString
}

Export-ModuleMember -Function *
