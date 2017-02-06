$errorActionPreference = 'Stop'
Set-StrictMode -Version 'Latest'

# Import CommonResourceHelper for Get-LocalizedData
$script:dscResourcesFolderFilePath = Split-Path $PSScriptRoot -Parent
$script:commonResourceHelperFilePath = Join-Path -Path $script:dscResourcesFolderFilePath -ChildPath 'CommonResourceHelper.psm1'
Import-Module -Name $script:commonResourceHelperFilePath

# Localized messages for verbose and error statements in this resource
$script:localizedData = Get-LocalizedData -ResourceName 'MSFT_xRegistryResource'

$script:registryDriveRoots = @{
    'HKCC' = 'HKEY_CURRENT_CONFIG'
    'HKCR' = 'HKEY_CLASSES_ROOT'
    'HKCU' = 'HKEY_CURRENT_USER'
    'HKLM' = 'HKEY_LOCAL_MACHINE'
    'HKUS' = 'HKEY_USERS'
}

<#
    .SYNOPSIS
        Retrieves the current state of the Registry resource with the given Key.

    .PARAMETER Key
        The path of the registry key to retrieve the state of.
        This path must include the registry hive.

    .PARAMETER ValueName
        The name of the registry value to retrieve the state of.

    .PARAMETER ValueData
        Used only as a boolean flag (along with ValueType) to determine if the target entity is the
        Default Value or the key itself.

    .PARAMETER ValueType
        Used only as a boolean flag (along with ValueData) to determine if the target entity is the
        Default Value or the key itself.
#>
function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $Key,

        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [String]
        [AllowEmptyString()]
        $ValueName,

        [String[]]
        $ValueData,

        [ValidateSet('String', 'Binary', 'DWord', 'QWord', 'MultiString', 'ExpandString')]
        [String]
        $ValueType
    )

    Write-Verbose -Message ($script:localizedData.GetTargetResourceStartMessage -f $Key)

    $registryResource = @{
        Key = $Key
        Ensure = 'Absent'
        ValueName = $null
        ValueType = $null
        ValueData = $null
    }

    # Retrieve the registry key at the specified path
    $registryKey = Get-RegistryKey -RegistryKeyPath $Key

    # Check if the registry key exists
    if ($null -eq $registryKey)
    {
        Write-Verbose -Message ($script:localizedData.RegistryKeyDoesNotExist -f $Key)
    }
    else
    {
        Write-Verbose -Message ($script:localizedData.RegistryKeyExists -f $Key)

        # Check if the user specified a value name to retrieve
        $valueNameSpecified = (-not [String]::IsNullOrEmpty($ValueName)) -or $PSBoundParameters.ContainsKey('ValueType') -or $PSBoundParameters.ContainsKey('ValueData')

        if ($valueNameSpecified)
        {
            $valueDisplayName = Get-RegistryKeyValueDisplayName -RegistryKeyValueName $ValueName
            $registryResource['ValueName'] = $valueDisplayName

            # If a value name was specified, retrieve the value with the specified name from the retrieved registry key
            $registryKeyValue = Get-RegistryKeyValue -RegistryKey $registryKey -RegistryKeyValueName $ValueName

            # Check if the registry key value exists
            if ($null -eq $registryKeyValue)
            {
                Write-Verbose -Message ($script:localizedData.RegistryKeyValueDoesNotExist -f $Key, $valueDisplayName)
            }
            else
            {
                Write-Verbose -Message ($script:localizedData.RegistryKeyValueExists -f $Key, $valueDisplayName)

                # If the registry key value exists, retrieve its type
                $actualValueType = Get-RegistryKeyValueType -RegistryKey $registryKey -RegistryKeyValueName $ValueName

                # If the registry key value exists, convert it to a readable string
                $registryKeyValueAsReadableString = ConvertTo-ReadableString -RegistryKeyValue $registryKeyValue -RegistryKeyValueType $actualValueType

                $registryResource['Ensure'] = 'Present'
                $registryResource['ValueType'] = $actualValueType
                $registryResource['ValueData'] = $registryKeyValueAsReadableString
            }
        }
        else
        {
            $registryResource['Ensure'] = 'Present'
        }
    }

    Write-Verbose -Message ($script:localizedData.GetTargetResourceEndMessage -f $Key)

    return $registryResource
}

<#
    .SYNOPSIS
        Sets the Registry resource with the given Key to the specified state.

    .PARAMETER Key
        The path of the registry key to set the state of.
        This path must include the registry hive.

    .PARAMETER ValueName
        The name of the registry value to set.

        To add or remove a registry key, specify this property as an empty string without
        specifying ValueType or ValueData. To modify or remove the default value of a registry key,
        specify this property as an empty string while also specifying ValueType or ValueData.

    .PARAMETER Ensure
        Specifies whether or not the registry key with the given path and the registry key value with the given name should exist.
        
        To ensure that the registry key and value exists, set this property to Present.
        To ensure that the registry key and value do not exist, set this property to Absent.
        
        The default value is Present.

    .PARAMETER ValueData
        The data to set as the registry key value.

    .PARAMETER ValueType
        The type of the value to set.
        
        The supported types are:
            String (REG_SZ)
            Binary (REG-BINARY)
            Dword 32-bit (REG_DWORD)
            Qword 64-bit (REG_QWORD)
            Multi-string (REG_MULTI_SZ)
            Expandable string (REG_EXPAND_SZ)

    .PARAMETER Hex
        Specifies whether or not the value data should be expressed in hexadecimal format.

        If specified, DWORD/QWORD value data is presented in hexadecimal format.
        Not valid for other value types.
        
        The default value is $false.

    .PARAMETER Force
        Specifies whether or not to overwrite the registry key with the given path with the new
        value if it is already present. 
#>
function Set-TargetResource
{
    [CmdletBinding(SupportsShouldProcess = $true)]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $Key,

        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [String]
        [AllowEmptyString()]
        $ValueName,

        [ValidateSet('Present', 'Absent')]
        [String]
        $Ensure = 'Present',

        [ValidateNotNull()]
        [String[]]
        $ValueData = @(),

        [ValidateSet('String', 'Binary', 'DWord', 'QWord', 'MultiString', 'ExpandString')]
        [String]
        $ValueType = 'String',

        [Boolean]
        $Hex = $false,

        [Boolean]
        $Force = $false
    )

    Write-Verbose -Message ($script:localizedData.SetTargetResourceStartMessage -f $Key)

    # Retrieve the registry key at the specified path
    $registryKey = Get-RegistryKey -RegistryKeyPath $Key -WriteAccessAllowed

    # Check if the registry key exists
    if ($null -eq $registryKey)
    {
        Write-Verbose -Message ($script:localizedData.RegistryKeyDoesNotExist -f $Key)

        # Check if the user wants the registry key to exist
        if ($Ensure -eq 'Present')
        {
            Write-Verbose -Message ($script:localizedData.CreatingRegistryKey -f $Key)
            $registryKey = New-RegistryKey -RegistryKeyPath $Key
        }
    }

    # Check if the registry key exists
    if ($null -ne $registryKey)
    {
        Write-Verbose -Message ($script:localizedData.RegistryKeyExists -f $Key)

        $valueNameSpecified = (-not [String]::IsNullOrEmpty($ValueName)) -or $PSBoundParameters.ContainsKey('ValueType') -or $PSBoundParameters.ContainsKey('ValueData')

        # Check if the user wants to set a registry key value
        if ($valueNameSpecified)
        {
            # Retrieve the display name of the specified registry key value
            $valueDisplayName = Get-RegistryKeyValueDisplayName -RegistryKeyValueName $ValueName

            # Retrieve the existing registry key value
            $actualRegistryKeyValue = Get-RegistryKeyValue -RegistryKey $registryKey -RegistryKeyValueName $ValueName

            # Check if the user wants to add/modify or remove the registry key value
            if ($Ensure -eq 'Present')
            {
                # Convert the specified registry key value to the specified type
                $expectedRegistryKeyValue = switch ($ValueType)
                {
                    'Binary' { ConvertTo-Binary  -RegistryKeyValue $ValueData; break }
                    'DWord' { ConvertTo-DWord -RegistryKeyValue $ValueData -Hex $Hex; break }
                    'MultiString' { ConvertTo-MultiString -RegistryKeyValue $ValueData; break }
                    'QWord' { ConvertTo-QWord -RegistryKeyValue $ValueData -Hex $Hex; break }
                    default { ConvertTo-String -RegistryKeyValue $ValueData}
                }

                # Retrieve the name of the registry key
                $registryKeyName = Get-RegistryKeyName -RegistryKey $registryKey

                # Check if the registry key value exists
                if ($null -eq $actualRegistryKeyValue)
                {
                    # If the registry key value does not exist, set the new value
                    Write-Verbose -Message ($script:localizedData.SettingRegistryKeyValue -f $valueDisplayName, $Key)
                    $null = Set-RegistryKeyValue -RegistryKeyName $registryKeyName -RegistryKeyValueName $ValueName -RegistryKeyValue $expectedRegistryKeyValue -ValueType $ValueType
                }
                else
                {
                    # If the registry key value exists, check if the specified registry key value matches the retrieved registry key value
                    if (Test-RegistryKeyValuesMatch -ExpectedRegistryKeyValue $expectedRegistryKeyValue -ActualRegistryKeyValue $actualRegistryKeyValue -RegistryKeyValueType $ValueType)
                    {
                        # If the specified registry key value matches the retrieved registry key value, no change is needed
                        Write-Verbose -Message ($script:localizedData.RegistryKeyValueAlreadySet -f $valueDisplayName, $Key)
                    }
                    else
                    {
                        # If the specified registry key value matches the retrieved registry key value, check if the user wants to overwrite the value
                        if (-not $Force)
                        {
                            # If the user does not want to overwrite the value, throw an error
                            New-InvalidOperationException -Message ($script:localizedData.CannotOverwriteExistingRegistryKeyValueWithoutForce -f $Key, $valueDisplayName)
                        }
                        else
                        {
                            # If the user does want to overwrite the value, overwrite the value
                            Write-Verbose -Message ($script:localizedData.OverwritingRegistryKeyValue -f $valueDisplayName, $Key)
                            $null = Set-RegistryKeyValue -RegistryKeyName $registryKeyName -RegistryKeyValueName $ValueName -RegistryKeyValue $expectedRegistryKeyValue -ValueType $ValueType
                        }
                    }   
                }
            }
            else
            {
                # Check if the registry key value exists
                if ($null -ne $actualRegistryKeyValue)
                {
                    Write-Verbose -Message ($script:localizedData.RemovingRegistryKeyValue -f $valueDisplayName, $Key)
                        
                    # If the specified registry key value exists, check if the user specified a registry key value with a name to remove
                    if (-not [String]::IsNullOrEmpty($ValueName))
                    {
                        # If the user specified a registry key value with a name to remove, remove the registry key value with the specified name
                        $null = Remove-ItemProperty -Path $Key -Name $ValueName -Force
                    }
                    else
                    {
                        # If the user did not specify a registry key value with a name to remove, remove the default registry key value
                        $null = Remove-DefaultRegistryKeyValue -RegistryKey $registryKey
                    }
                }
            }
        }
        else
        {
            # Check if the user wants to remove the registry key
            if ($Ensure -eq 'Absent')
            {
                # Retrieve the number of subkeys the registry key has
                $registryKeySubKeyCount = Get-RegistryKeySubKeyCount -RegistryKey $registryKey

                # Check if the registry key has subkeys and the user does not want to forcibly remove the registry key
                if ($registryKeySubKeyCount -gt 0 -and -not $Force)
                {
                    New-InvalidOperationException -Message ($script:localizedData.CannotRemoveExistingRegistryKeyWithSubKeysWithoutForce -f $Key)
                }
                else
                {
                    # Remove the registry key
                    Write-Verbose -Message ($script:localizedData.RemovingRegistryKey -f $Key)
                    $null = Remove-Item -Path $Key -Recurse -Force
                }
            }
        }
    }

    Write-Verbose -Message ($script:localizedData.SetTargetResourceEndMessage -f $Key)
}

<#
    .SYNOPSIS
        Tests if the Registry resource with the given key is in the specified state.

    .PARAMETER Key
        The path of the registry key to test the state of.
        This path must include the registry hive.

    .PARAMETER ValueName
        The name of the registry value to check for.
        Specify this property as an empty string ('') to check the default value of the registry key.

    .PARAMETER Ensure
        Specifies whether or not the registry key and value should exist.
        
        To test that they exist, set this property to "Present".
        To test that they do not exist, set the property to "Absent".
        The default value is "Present".

    .PARAMETER ValueData
        The data the registry key value should have.

    .PARAMETER ValueType
        The type of the value.
        
        The supported types are:
            String (REG_SZ)
            Binary (REG-BINARY)
            Dword 32-bit (REG_DWORD)
            Qword 64-bit (REG_QWORD)
            Multi-string (REG_MULTI_SZ)
            Expandable string (REG_EXPAND_SZ)

    .PARAMETER Hex
        Not used in Test-TargetResource.

    .PARAMETER Force
        Not used in Test-TargetResource.
#>
function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $Key,

        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [ValidateNotNull()]
        [String]
        $ValueName,

        [ValidateSet('Present', 'Absent')]
        [String]
        $Ensure = 'Present',

        [ValidateNotNull()]
        [String[]]
        $ValueData = @(),

        [ValidateSet('String', 'Binary', 'DWord', 'QWord', 'MultiString', 'ExpandString')]
        [String]
        $ValueType = 'String',

        [Boolean]
        $Hex = $false,

        [Boolean]
        $Force = $false
    )

    Write-Verbose -Message ($script:localizedData.TestTargetResourceStartMessage -f $Key)

    $registryResourceInDesiredState = $false

    $getTargetResourceParameters = @{
        Key = $Key
        ValueName = $ValueName
    }

    if ($PSBoundParameters.ContainsKey('ValueType'))
    {
        $getTargetResourceParameters['ValueType'] = $ValueType
    }

    if ($PSBoundParameters.ContainsKey('ValueData'))
    {
        $getTargetResourceParameters['ValueData'] = $ValueData
    }

    $registryResource = Get-TargetResource @getTargetResourceParameters

    # Check if the user specified a value name to retrieve
    $valueNameSpecified = (-not [String]::IsNullOrEmpty($ValueName)) -or $PSBoundParameters.ContainsKey('ValueType') -or $PSBoundParameters.ContainsKey('ValueData')

    if ($valueNameSpecified)
    {
        $valueDisplayName = Get-RegistryKeyValueDisplayName -RegistryKeyValueName $ValueName

        if ($registryResource.Ensure -eq 'Absent')
        {
            Write-Verbose -Message ($script:localizedData.RegistryKeyValueDoesNotExist -f $Key, $valueDisplayName)
            $registryResourceInDesiredState = $Ensure -eq 'Absent'
        }
        else
        {
            Write-Verbose -Message ($script:localizedData.RegistryKeyValueExists -f $Key, $valueDisplayName)

            if ($Ensure -eq 'Absent')
            {
                $registryResourceInDesiredState = $false
            }
            elseif ($PSBoundParameters.ContainsKey('ValueType') -and $ValueType -ne $registryResource.ValueType)
            {
                Write-Verbose -Message ($script:localizedData.RegistryKeyValueTypeDoesNotMatch -f $valueDisplayName, $Key, $ValueType, $registryResource.ValueType)

                $registryResourceInDesiredState = $false
            }
            elseif ($PSBoundParameters.ContainsKey('ValueData'))
            {
                # Need to get the actual registry key value since Get-TargetResource returns
                $registryKey = Get-RegistryKey -RegistryKeyPath $Key
                $actualRegistryKeyValue = Get-RegistryKeyValue -RegistryKey $registryKey -RegistryKeyValueName $ValueName

                if (-not $PSBoundParameters.ContainsKey('ValueType') -and $null -ne $registryResource.ValueType)
                {
                    $ValueType = $registryResource.ValueType
                }

                # Convert the specified registry key value to the specified type
                $expectedRegistryKeyValue = switch ($ValueType)
                {
                    'Binary' { ConvertTo-Binary  -RegistryKeyValue $ValueData; break }
                    'DWord' { ConvertTo-DWord -RegistryKeyValue $ValueData -Hex $Hex; break }
                    'MultiString' { ConvertTo-MultiString -RegistryKeyValue $ValueData; break }
                    'QWord' { ConvertTo-QWord -RegistryKeyValue $ValueData -Hex $Hex; break }
                    default { ConvertTo-String -RegistryKeyValue $ValueData; break }
                }

                if (-not (Test-RegistryKeyValuesMatch -ExpectedRegistryKeyValue $expectedRegistryKeyValue -ActualRegistryKeyValue $actualRegistryKeyValue -RegistryKeyValueType $ValueType))
                {
                    Write-Verbose -Message ($script:localizedData.RegistryKeyValueDoesNotMatch -f $valueDisplayName, $Key, $ValueData, $registryResource.ValueData)

                    $registryResourceInDesiredState = $false
                }
                else
                {
                    $registryResourceInDesiredState = $true
                }
            }
            else
            {
                $registryResourceInDesiredState = $true
            }
        }
    }
    else
    {
        if ($registryResource.Ensure -eq 'Present')
        {
            Write-Verbose -Message ($script:localizedData.RegistryKeyExists -f $Key)
            $registryResourceInDesiredState = $Ensure -eq 'Present'
        }
        else
        {
            Write-Verbose -Message ($script:localizedData.RegistryKeyDoesNotExist -f $Key)
            $registryResourceInDesiredState = $Ensure -eq 'Absent'
        }
    }

    Write-Verbose -Message ($script:localizedData.TestTargetResourceEndMessage -f $Key)

    return $registryResourceInDesiredState
}

<#
    .SYNOPSIS
        Retrieves the root of the specified path.

    .PARAMETER Path
        The path to retrieve the root of.
#>
function Get-PathRoot
{
    [OutputType([String])]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $Path
    )

    $pathParent = Split-Path -Path $Path -Parent
    $pathRoot = $Path

    while (-not [String]::IsNullOrEmpty($pathParent))
    {
        $pathRoot = Split-Path -Path $pathParent -Leaf
        $pathParent = Split-Path -Path $pathParent -Parent
    }

    return $pathRoot
}

<#
    .SYNOPSIS
        Converts the specified registry drive root to its corresponding registry drive name.

    .PARAMETER RegistryDriveRoot
        The registry drive root to convert.
#>
function ConvertTo-RegistryDriveName
{
    [OutputType([String])]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $RegistryDriveRoot
    )

    $registryDriveName = $null

    if ($script:registryDriveRoots.ContainsValue($RegistryDriveRoot))
    {
        foreach ($registryDriveRootsKey in $script:registryDriveRoots.Keys)
        {
            if ($script:registryDriveRoots[$registryDriveRootsKey] -ieq $RegistryDriveRoot)
            {
                $registryDriveName = $registryDriveRootsKey
                break
            }
        }
    }

    return $registryDriveName
}

<#
    .SYNOPSIS
        Retrieves the name of the registry drive at the root of the the specified registry key path.

    .PARAMETER RegistryKeyPath
        The registry key path to retrieve the registry drive name from.
#>
function Get-RegistryDriveName
{
    [OutputType([String])]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $RegistryKeyPath
    )

    $registryKeyPathRoot = Get-PathRoot -Path $RegistryKeyPath
    $registryKeyPathRoot = $registryKeyPathRoot.TrimEnd('\')

    if ($registryKeyPathRoot.Contains(':'))
    {
        $registryDriveName = $registryKeyPathRoot.TrimEnd(':')

        if (-not $script:registryDriveRoots.ContainsKey($registryDriveName))
        {
            New-InvalidArgumentException -ArgumentName 'Key' -Message ($script:localizedData.InvalidRegistryDrive -f $registryDriveName)
        }
    }
    else
    {
        $registryDriveName = ConvertTo-RegistryDriveName -RegistryDriveRoot $registryKeyPathRoot

        if ([String]::IsNullOrEmpty($registryDriveName))
        {
            New-InvalidArgumentException -ArgumentName 'Key' -Message ($script:localizedData.InvalidRegistryDrive -f $registryKeyPathRoot)
        }
    }

    return $registryDriveName
}

<#
    .SYNOPSIS
        Mounts the registry drive with the specified name.

    .PARAMETER RegistryKeyName
        The name of the registry drive to mount.
#>
function Mount-RegistryDrive
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $RegistryDriveName
    )

    $registryDriveInfo = Get-PSDrive -Name $RegistryDriveName -ErrorAction 'SilentlyContinue'

    if ($null -eq $registryDriveInfo)
    {
        $newPSDriveParameters = @{
            Name = $RegistryDriveName
            Root = $script:registryDriveRoots[$RegistryDriveName]
            PSProvider = 'Registry'
            Scope = 'Script'
        }

        $registryDriveInfo = New-PSDrive @newPSDriveParameters
    }

    # Validate that the specified PSDrive is valid
    if (($null -eq $registryDriveInfo) -or ($null -eq $registryDriveInfo.Provider) -or ($registryDriveInfo.Provider.Name -ine 'Registry'))
    {
        New-InvalidOperationException -Message ($script:localizedData.RegistryDriveCouldNotBeMounted -f $RegistryDriveName)
    }
}

<#
    .SYNOPSIS
        Opens the specified registry sub key under the specified registry parent key.
        This is a wrapper function for unit testing.

    .PARAMETER ParentKey
        The parent registry key which contains the sub key to open.

    .PARAMETER SubKey
        The sub key to open.

    .PARAMETER WriteAccessAllowed
        Specifies whether or not to open the sub key with permissions to write to it.
#>
function Open-RegistrySubKey
{
    [OutputType([Microsoft.Win32.RegistryKey])]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [Microsoft.Win32.RegistryKey]
        $ParentKey,

        [Parameter(Mandatory = $true)]
        [String]
        [AllowEmptyString()]
        $SubKey,

        [Parameter()]
        [Switch]
        $WriteAccessAllowed
    )

    return $ParentKey.OpenSubKey($SubKey, $WriteAccessAllowed)
}

<#
    .SYNOPSIS
        Opens and retrieves the registry key at the specified path.

    .PARAMETER RegistryKeyPath
        The path to the registry key to open.
        The path must include the registry drive.

    .PARAMETER WriteAccessAllowed
        Specifies whether or not to open the key with permissions to write to it.

    .NOTES
        This method is used instead of Get-Item so that there is no ambiguity between
        forward slashes as path separators vs literal characters in a key name
        (which is valid in the registry).

#>
function Get-RegistryKey
{
    [OutputType([Microsoft.Win32.RegistryKey])]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $RegistryKeyPath,

        [Switch]
        $WriteAccessAllowed
    )

    # Parse the registry drive from the specified registry key path
    $registryDriveName = Get-RegistryDriveName -RegistryKeyPath $RegistryKeyPath

    # Mount the registry drive if needed
    Mount-RegistryDrive -RegistryDriveName $registryDriveName

    # Retrieve the registry drive key
    $registryDriveKey = Get-Item -LiteralPath ($registryDriveName + ':')

    # Parse the registry drive subkey from the specified registry key path
    $indexOfBackSlashInPath = $RegistryKeyPath.IndexOf('\')
    if ($indexOfBackSlashInPath -ge 0 -and $indexOfBackSlashInPath -lt ($RegistryKeyPath.Length - 1))
    {
        $registryDriveSubKey = $RegistryKeyPath.Substring($RegistryKeyPath.IndexOf('\') + 1)
    }
    else
    {
        $registryDriveSubKey = ''
    }

    # Open the registry drive subkey
    $registryKey = Open-RegistrySubKey -ParentKey $registryDriveKey -SubKey $registryDriveSubKey -WriteAccessAllowed:$WriteAccessAllowed

    # Return the opened registry key
    return $registryKey
}

<#
    .SYNOPSIS
        Retrieves the display name of the default registry key value if needed.

    .PARAMETER RegistryKeyValueName
        The name of the registry key value to retrieve the display name of.
#>
function Get-RegistryKeyValueDisplayName
{
    [OutputType([String])]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [String]
        [AllowNull()]
        [AllowEmptyString()]
        $RegistryKeyValueName
    )

    $registryKeyValueDisplayName = $RegistryKeyValueName

    if ([String]::IsNullOrEmpty($RegistryKeyValueName))
    {
        $registryKeyValueDisplayName = $script:localizedData.DefaultValueDisplayName
    }

    return $registryKeyValueDisplayName
}

<#
    .SYNOPSIS
        Retrieves the registry key value with the specified name from the specified registry key.
        This is a wrapper function for unit testing.

    .PARAMETER RegistryKey
        The registry key to retrieve the value from.

    .PARAMETER RegistryKeyValueName
        The name of the registry key value to retrieve.
#>
function Get-RegistryKeyValue
{
    [OutputType([Object[]])]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [Microsoft.Win32.RegistryKey]
        $RegistryKey,

        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [String]
        [AllowEmptyString()]
        $RegistryKeyValueName
    )

    $registryValueOptions = [Microsoft.Win32.RegistryValueOptions]::DoNotExpandEnvironmentNames
    $registryKeyValue = $RegistryKey.GetValue($RegistryKeyValueName, $null, $registryValueOptions)
    return ,$registryKeyValue
}

<#
    .SYNOPSIS
        Retrieves the type of the registry key value with the specified name from the the specified
        registry key.
        This is a wrapper function for unit testing.

    .PARAMETER RegistryKey
        The registry key to retrieve the type of the value from.

    .PARAMETER RegistryKeyValueName
        The name of the registry key value to retrieve the type of.
#>
function Get-RegistryKeyValueType
{
    [OutputType([Type])]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [Microsoft.Win32.RegistryKey]
        $RegistryKey,

        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [String]
        [AllowEmptyString()]
        $RegistryKeyValueName
    )

    return $RegistryKey.GetValueKind($RegistryKeyValueName)
}

<#
    .SYNOPSIS
        Converts the specified byte array to a hex string.

    .PARAMETER ByteArray
        The byte array to convert.
#>
function Convert-ByteArrayToHexString
{
    [OutputType([String])]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [Object[]]
        [AllowEmptyCollection()]
        $ByteArray
    )

    $hexString = ''

    foreach ($byte in $ByteArray)
    {
        $hexString += ('{0:x2}' -f $byte)
    }

    return $hexString
}

<#
    .SYNOPSIS
        Converts the specified registry key value to a readable string.

    .PARAMETER RegistryKeyValue
        The registry key value to convert.

    .PARAMETER RegistryKeyValueType
        The type of the registry key value to convert.
#>
function ConvertTo-ReadableString
{
    [OutputType([String])]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [Object[]]
        [AllowNull()]
        [AllowEmptyCollection()]
        $RegistryKeyValue,

        [Parameter(Mandatory = $true)]
        [ValidateSet('String', 'Binary', 'DWord', 'QWord', 'MultiString', 'ExpandString')]
        [String]
        $RegistryKeyValueType
    )

    $registryKeyValueAsString = [String]::Empty

    if ($null -ne $RegistryKeyValue)
    {
        # For Binary type data, convert the received bytes back to a readable hex-string
        if ($RegistryKeyValueType -eq 'Binary')
        {
            $RegistryKeyValue = Convert-ByteArrayToHexString -ByteArray $RegistryKeyValue
        }
        
        if ($RegistryKeyValueType -ne 'MultiString')
        {
            $RegistryKeyValue = [String[]]@() + $RegistryKeyValue
        }

        if ($RegistryKeyValue.Count -eq 1 -and -not [String]::IsNullOrEmpty($RegistryKeyValue[0]))
        {
            $registryKeyValueAsString = $RegistryKeyValue[0].ToString()
        }
        elseif ($RegistryKeyValue.Count -gt 1)
        {
            $registryKeyValueAsString = "($($RegistryKeyValue -join ', '))"
        }
    }

    return $registryKeyValueAsString
}

<#
    .SYNOPSIS
        Creates a new subkey with the specified name under the specified registry key.
        This is a wrapper function for unit testing.

    .PARAMETER ParentRegistryKey
        The parent registry key to create the new subkey under.

    .PARAMETER SubKeyName
        The name of the new subkey to create.
#>
function New-RegistrySubKey
{
    [OutputType([Microsoft.Win32.RegistryKey])]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [Microsoft.Win32.RegistryKey]
        $ParentRegistryKey,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $SubKeyName
    )

    return $ParentRegistryKey.CreateSubKey($SubKeyName)
}

<#
    .SYNOPSIS
        Creates a new registry key at the specified registry key path.

    .PARAMETER RegistryKeyPath
        The path at which to create the registry key.
        This path must include the registry drive.
#>
function New-RegistryKey
{
    [OutputType([Microsoft.Win32.RegistryKey])]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $RegistryKeyPath
    )

    # registry key names can contain forward slashes, so we can't use Split-Path here (it will split on /)
    $lastSep = $RegistryKeyPath.LastIndexOf('\')
    $parentRegistryKeyPath = $RegistryKeyPath.Substring(0, $lastSep)
    $newRegistryKeyName = $RegistryKeyPath.Substring($lastSep + 1)

    $parentRegistryKey = Get-RegistryKey -RegistryKeyPath $parentRegistryKeyPath -WriteAccessAllowed

    if ($null -eq $parentRegistryKey)
    {
        # If the parent registry key does not exist, create it
        $parentRegistryKey = New-RegistryKey -RegistryKeyPath $parentRegistryKeyPath
    }

    $newRegistryKey = New-RegistrySubKey -ParentRegistryKey $parentRegistryKey -SubKeyName $newRegistryKeyName

    return $newRegistryKey
}

<#
    .SYNOPSIS
        Retrieves the name of the specified registry key.
        This is a wrapper function for unit testing.

    .PARAMETER RegistryKey
        The registry key to retrieve the name of.
#>
function Get-RegistryKeyName
{
    [OutputType([String])]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [Microsoft.Win32.RegistryKey]
        $RegistryKey
    )

    return $RegistryKey.Name
}

<#
    .SYNOPSIS
        Converts the specified registry key value to a byte array for the Binary registry type.

    .PARAMETER RegistryKeyValue
        The registry key value to convert.
#>
function ConvertTo-Binary
{
    [OutputType([Byte[]])]
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [AllowNull()]
        [String[]]
        [AllowEmptyCollection()]
        $RegistryKeyValue
    )

    if (($null -ne $RegistryKeyValue) -and ($RegistryKeyValue.Count -gt 1))
    {
        New-InvalidArgumentException -ArgumentName 'ValueData' -Message ($script:localizedData.ArrayNotAllowedForExpectedType -f 'Binary')
    }

    $binaryRegistryKeyValue = [Byte[]] @()

    if (($null -ne $RegistryKeyValue) -and ($RegistryKeyValue.Count -eq 1) -and (-not [String]::IsNullOrEmpty($RegistryKeyValue[0])))
    {
        $singleRegistryKeyValue = $RegistryKeyValue[0]

        if ($singleRegistryKeyValue.StartsWith('0x'))
        {
            $singleRegistryKeyValue = $singleRegistryKeyValue.Substring('0x'.Length)
        }

        if (($singleRegistryKeyValue.Length % 2) -ne 0)
        {
            $singleRegistryKeyValue = $singleRegistryKeyValue.PadLeft($singleRegistryKeyValue.Length + 1, '0')
        }

        try
        {
            for ($singleRegistryKeyValueIndex = 0 ; $singleRegistryKeyValueIndex -lt ($singleRegistryKeyValue.Length - 1) ; $singleRegistryKeyValueIndex = $singleRegistryKeyValueIndex + 2)
            {
                $binaryRegistryKeyValue += [Byte]::Parse($singleRegistryKeyValue.Substring($singleRegistryKeyValueIndex, 2), 'HexNumber')
            }
        }
        catch
        {
            New-InvalidArgumentException -ArgumentName 'ValueData' -Message ($script:localizedData.BinaryDataNotInHexFormat -f $singleRegistryKeyValue)
        }
    }

    return $binaryRegistryKeyValue
}

<#
    .SYNOPSIS
        Converts the specified registry key value to an Int32 for the DWord registry type.

    .PARAMETER RegistryKeyValue
        The registry key value to convert.
#>
function ConvertTo-DWord
{
    [OutputType([System.Int32])]
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [AllowNull()]
        [String[]]
        [AllowEmptyCollection()]
        $RegistryKeyValue,

        [Parameter()]
        [Boolean]
        $Hex = $false
    )

    if (($null -ne $RegistryKeyValue) -and ($RegistryKeyValue.Count -gt 1))
    {
        New-InvalidArgumentException -ArgumentName 'ValueData' -Message ($script:localizedData.ArrayNotAllowedForExpectedType -f 'Dword')
    }

    $dwordRegistryKeyValue = [System.Int32] 0

    if (($null -ne $RegistryKeyValue) -and ($RegistryKeyValue.Count -eq 1) -and (-not [String]::IsNullOrEmpty($RegistryKeyValue[0])))
    {
        $singleRegistryKeyValue = $RegistryKeyValue[0]

        if ($Hex)
        {
            if ($singleRegistryKeyValue.StartsWith('0x'))
            {
                $singleRegistryKeyValue = $singleRegistryKeyValue.Substring('0x'.Length)
            }

            $currentCultureInfo = [System.Globalization.CultureInfo]::CurrentCulture
            $referenceValue = $null

            if ([System.Int32]::TryParse($singleRegistryKeyValue, 'HexNumber', $currentCultureInfo, [Ref] $referenceValue))
            {
                $dwordRegistryKeyValue = $referenceValue
            }
            else
            {
                New-InvalidArgumentException -ArgumentName 'ValueData' -Message ($script:localizedData.DWordDataNotInHexFormat -f $singleRegistryKeyValue)
            }
        }
        else
        {
            $dwordRegistryKeyValue = [System.Int32]::Parse($singleRegistryKeyValue)
        }
    }

    return $dwordRegistryKeyValue
}

<#
    .SYNOPSIS
        Converts the specified registry key value to a string array for the MultiString registry type.

    .PARAMETER RegistryKeyValue
        The registry key value to convert.
#>
function ConvertTo-MultiString
{
    [OutputType([String[]])]
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [AllowNull()]
        [String[]]
        [AllowEmptyCollection()]
        $RegistryKeyValue
    )

    $multiStringRegistryKeyValue = [String[]] @()

    if (($null -ne $RegistryKeyValue) -and ($RegistryKeyValue.Length -gt 0))
    {
        $multiStringRegistryKeyValue = [String[]]$RegistryKeyValue
    }

    return $multiStringRegistryKeyValue
}

<#
    .SYNOPSIS
        Converts the specified registry key value to an Int64 for the QWord registry type.

    .PARAMETER RegistryKeyValue
        The registry key value to convert.
#>
function ConvertTo-QWord
{
    [OutputType([System.Int64])]
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [AllowNull()]
        [String[]]
        [AllowEmptyCollection()]
        $RegistryKeyValue,

        [Parameter()]
        [Boolean]
        $Hex = $false
    )

    if (($null -ne $RegistryKeyValue) -and ($RegistryKeyValue.Count -gt 1))
    {
        New-InvalidArgumentException -ArgumentName 'ValueData' -Message ($script:localizedData.ArrayNotAllowedForExpectedType -f 'Qword')
    }

    $qwordRegistryKeyValue = [System.Int64] 0

    if (($null -ne $RegistryKeyValue) -and ($RegistryKeyValue.Count -eq 1) -and (-not [String]::IsNullOrEmpty($RegistryKeyValue[0])))
    {
        $singleRegistryKeyValue = $RegistryKeyValue[0]

        if ($Hex)
        {
            if ($singleRegistryKeyValue.StartsWith('0x'))
            {
                $singleRegistryKeyValue = $singleRegistryKeyValue.Substring('0x'.Length)
            }

            $currentCultureInfo = [System.Globalization.CultureInfo]::CurrentCulture
            $referenceValue = $null

            if ([System.Int64]::TryParse($singleRegistryKeyValue, 'HexNumber', $currentCultureInfo, [Ref] $referenceValue))
            {
                $qwordRegistryKeyValue = $referenceValue
            }
            else
            {
                New-InvalidArgumentException -ArgumentName 'ValueData' -Message ($script:localizedData.QWordDataNotInHexFormat -f $singleRegistryKeyValue)
            }
        }
        else
        {
            $qwordRegistryKeyValue = [System.Int64]::Parse($singleRegistryKeyValue)
        }
    }

    return $qwordRegistryKeyValue
}

<#
    .SYNOPSIS
        Converts the specified registry key value to a string for the String or ExpandString registry types.

    .PARAMETER RegistryKeyValue
        The registry key value to convert.
#>
function ConvertTo-String
{
    [OutputType([String])]
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [AllowNull()]
        [String[]]
        [AllowEmptyCollection()]
        $RegistryKeyValue
    )

    if (($null -ne $RegistryKeyValue) -and ($RegistryKeyValue.Count -gt 1))
    {
        New-InvalidArgumentException -ArgumentName 'ValueData' -Message ($script:localizedData.ArrayNotAllowedForExpectedType -f 'String or ExpandString')
    }

    $registryKeyValueAsString = [String]::Empty

    if (($null -ne $RegistryKeyValue) -and ($RegistryKeyValue.Count -eq 1))
    {
        $registryKeyValueAsString = [String]$RegistryKeyValue[0]
    }

    return $registryKeyValueAsString
}

<#
    .SYNOPSIS
        Sets the specified registry key value with the specified name to the specified value.
        This is a wrapper function for unit testing.

    .PARAMETER RegistryKeyName
        The name of the registry key that the value to set is under.

    .PARAMETER RegistryKeyValueName
        The name of the registry key value to set.

    .PARAMETER RegistryKeyValue
        The new value to set the registry key value to.

    .PARAMETER RegistryKeyValueType
        The type of the new value to set the registry key value to.
#>
function Set-RegistryKeyValue
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $RegistryKeyName,

        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [String]
        [AllowEmptyString()]
        $RegistryKeyValueName,

        [Parameter(Mandatory = $true)]
        [Object]
        [AllowNull()]
        $RegistryKeyValue,

        [Parameter(Mandatory = $true)]
        [ValidateSet('String', 'Binary', 'DWord', 'QWord', 'MultiString', 'ExpandString')]
        [String]
        $ValueType
    )

    if ($ValueType -eq 'Binary')
    {
        $RegistryKeyValue = [Byte[]]$RegistryKeyValue
    }
    elseif ($ValueType -eq 'MultiString')
    {
        $RegistryKeyValue = [String[]]$RegistryKeyValue
    }

    $null = [Microsoft.Win32.Registry]::SetValue($RegistryKeyName, $RegistryKeyValueName, $RegistryKeyValue, $ValueType)
}

<#
    .SYNOPSIS
        Tests if the actual registry key value matches the expected registry key value.

    .PARAMETER ExpectedRegistryKeyValue
        The expected registry key value to test against.

    .PARAMETER ActualRegistryKeyValue
        The actual registry key value to test.

    .PARAMETER RegistryKeyValueType
        The type of the registry key values.
#>
function Test-RegistryKeyValuesMatch
{
    [OutputType([Boolean])]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [Object]
        [AllowNull()]
        $ExpectedRegistryKeyValue,

        [Parameter(Mandatory = $true)]
        [Object]
        [AllowNull()]
        $ActualRegistryKeyValue,

        [Parameter(Mandatory = $true)]
        [ValidateSet('String', 'Binary', 'DWord', 'QWord', 'MultiString', 'ExpandString')]
        [String]
        $RegistryKeyValueType
    )

    $registryKeyValuesMatch = $true

    if ($RegistryKeyValueType -eq 'Multistring' -or $RegistryKeyValueType -eq 'Binary')
    {
        if ($null -eq $ExpectedRegistryKeyValue)
        {
            $ExpectedRegistryKeyValue = @()
        }

        if ($null -eq $ActualRegistryKeyValue)
        {
            $ActualRegistryKeyValue = @()
        }

        $registryKeyValuesMatch = $null -eq (Compare-Object -ReferenceObject $ExpectedRegistryKeyValue -DifferenceObject $ActualRegistryKeyValue)
    }
    else
    {
        if ($null -eq $ExpectedRegistryKeyValue)
        {
            $ExpectedRegistryKeyValue = ''
        }

        if ($null -eq $ActualRegistryKeyValue)
        {
            $ActualRegistryKeyValue = ''
        }

        $registryKeyValuesMatch = $ExpectedRegistryKeyValue -ieq $ActualRegistryKeyValue
    }

    return $registryKeyValuesMatch
}

<#
    .SYNOPSIS
        Removes the default value of the specified registry key.
        This is a wrapper function for unit testing.
        
    .PARAMETER RegistryKey
        The registry key to remove the default value of. 
#>
function Remove-DefaultRegistryKeyValue
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [Microsoft.Win32.RegistryKey]
        $RegistryKey
    )

    $null = $RegistryKey.DeleteValue('')
}

<#
    .SYNOPSIS
        Retrieves the number of subkeys under the specified registry key.
        This is a wrapper function for unit testing.

    .PARAMETER RegistryKey
        The registry key to retrieve the subkeys of.
#>
function Get-RegistryKeySubKeyCount
{
    [OutputType([Int])]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [Microsoft.Win32.RegistryKey]
        $RegistryKey
    )

    return $RegistryKey.SubKeyCount
}
