<#
    .SYNOPSIS
        Tests if a registry key exists.

    .PARAMETER KeyPath
        The path to the registry key to test for existence. 
        Must include the registry hive.
#>
function Test-RegistryKeyExists
{
    [CmdletBinding()]
    [OutputType([Boolean])]
    param 
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $KeyPath
    )

    return Test-Path -Path $KeyPath
}

<#
    .SYNOPSIS
        Tests if a registry key value exists.

    .PARAMETER KeyPath
        The path to the registry key that should contain the value to test for existence. 
        Must include the registry hive.

    .PARAMETER ValueName
        The name of the value to test for existence.

    .PARAMETER ValueData
        The data the existing value should contain.

    .PARAMETER ValueType
        The value type that the registry value should have.
#>
function Test-RegistryValueExists
{
    [CmdletBinding()]
    [OutputType([Boolean])]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $KeyPath,

        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [AllowEmptyString()]
        [String]
        $ValueName,

        [String]
        $ValueData,

        [ValidateNotNullOrEmpty()]
        [String]
        $ValueType
    )

    try 
    {
        $registryValue = Get-ItemProperty -Path $KeyPath -Name $ValueName -ErrorAction 'SilentlyContinue'
        Write-Verbose -Message "Test-RegistryValueExists - Registry key value: $registryKeyValue"

        $registryValueExists = $null -ne $registryValue

        Write-Verbose -Message "Test-RegistryValueExists - Registry value is not null: $registryValueExists"

        if (-not $registryValueExists)
        {
            return $false
        }

        $registryValue = $registryValue.$ValueName

        if ($PSBoundParameters.ContainsKey('ValueType'))
        {
            Write-Verbose -Message "Test-RegistryValueExists - Registry value type: $($registryValue.GetType().Name)"

            if ($ValueType -eq 'Binary')
            {
                $registryValueExists = $registryValueExists -and ($registryValue.GetType().Name -eq 'Byte[]')
                $registryValue = Convert-ByteArrayToHexString -Data $registryValue
            }
            else 
            {
                $registryValueExists = $registryValueExists -and ($registryValue.GetType().Name -eq $ValueType)
            }
        }

        if ($PSBoundParameters.ContainsKey('ValueData'))
        {
            Write-Verbose -Message "Test-RegistryValueExists - Registry value data: $registryValue"

            $registryValueExists = $registryValueExists -and ($ValueData -eq $registryValue)
        }

        return $registryValueExists
    }
    catch
    {
        return $false
    }
}

<#
    .SYNOPSIS
        Creates a registry key.

    .PARAMETER KeyPath
        The path to the registry key to be created. 
        Must include the registry hive.
#>
function New-TestRegistryKey
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $KeyPath
    )

    $parentPath = Split-Path -Path $KeyPath -Parent
    
    if (-not (Test-RegistryKeyExists -KeyPath $parentPath))
    {
        New-TestRegistryKey -KeyPath $parentPath
    }
    
    Write-Verbose -Message "New-TestRegistryKey - Creating new registry key at: $KeyPath"

    $null = New-Item -Path $KeyPath
}

<#
    .SYNOPSIS
        Creates a registry key.

    .PARAMETER KeyPath
        The path to the registry key to be created. 
        Must include the registry hive.

    .PARAMETER ValueName
        The name of the value to add

    .PARAMETER ValueData
        The data of the value to add.

    .PARAMETER ValueType
        The type of the value to add.
#>
function New-RegistryValue
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $KeyPath,

        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [AllowEmptyString()]
        [String]
        $ValueName,

        [Object]
        $ValueData,

        [ValidateNotNullOrEmpty()]
        [String]
        $ValueType
    )

    if (-not (Test-Path -Path $KeyPath))
    {
        New-TestRegistryKey -KeyPath $KeyPath
    }

    if ($ValueType -ieq 'Binary')
    {
        $convertedValueData = @()

        if (($ValueData.Length % 2) -eq 1)
        {
            $ValueData = '0' + $ValueData
        }

        for($index = 0; $index -lt $ValueData.Length - 1; $index += 2)
        {
            $convertedValueData += [Convert]::ToInt32($ValueData.Substring($index, 2), 16)
        }

        $ValueData = [Byte[]] $convertedValueData

        Write-Verbose -Message "New-RegistryValue - Binary data: $ValueData"
    }
    
    $null = New-ItemProperty -Path $KeyPath -Name $ValueName -Value $ValueData -PropertyType $ValueType
}

<#
    .SYNOPSIS
        Removes a registry key.

    .PARAMETER KeyPath
        The path to the registry key to remove 
        Must include the registry hive.
#>
function Remove-RegistryKey
{
    [CmdletBinding()]
    param 
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $KeyPath
    )

    $null = Remove-Item -Path $KeyPath -Recurse -Force
}

<#
    .SYNOPSIS
        Removes a registry value.

    .PARAMETER KeyPath
        The path to the registry key that contains the value to remove. 
        Must include the registry hive.

    .PARAMETER ValueName
        The name of the value to remove.
#>
function Remove-RegistryValue
{
    [CmdletBinding()]
    param 
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $KeyPath,

        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [AllowEmptyString()]
        [String]
        $ValueName
    )

    $null = Remove-ItemProperty -Path $KeyPath -Name $ValueName -Force
}

<#
    .SYNOPSIS
        Mounts the registry drive of the given registry key path.

    .PARAMETER KeyPath
        The registry key path that contains the registry drive to mount.
#>
function Mount-RegistryDrive
{
    [CmdletBinding()]
    param 
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $KeyPath
    )

    $driveName = (Split-Path -Path $KeyPath -Qualifier).TrimEnd(':')
    Write-Verbose -Message "Mount-RegistryDrive - Drive name: $driveName"

    $registryDriveRootMappings = @{
        'HKCR' = 'HKEY_CLASSES_ROOT'
        'HKUS' = 'HKEY_USERS'
        'HKCC' = 'HKEY_CURRENT_CONFIG'
        'HKCU' = 'HKEY_CURRENT_USER'
        'HKLM' = 'HKEY_LOCAL_MACHINE'
    }

    if ($registryDriveRootMappings.ContainsKey($driveName))
    {
        # Abbreviated name was given. Use this as the new PSDrive name and the elongated name as the root
        $null = New-PSDrive -Name $driveName -Root $registryDriveRootMappings[$driveName] -PSProvider 'Registry' -Scope 'Script'
    }
    elseif ($registryDriveRootMappings.ContainsValue($driveName))
    {
        $mappingKey = $null

        # Find the abbreviated key that goes with the given registry drive path
        foreach ($key in $registryDriveRootMappings.Keys)
        {
            if ($registryDriveRootMappings[$key] -ieq $driveName)
            {
                $mappingKey = $key
                break
            }
        }

        # Mount the PSDrive with the abbreviated name as the Name and the elongated name as the root
        $null = New-PSDrive -Name $mappingKey -Root $driveName -PSProvider 'Registry' -Scope 'Script'
    }
    else
    {
        throw "Mount-RegistryDrive - Invalid registry drive in key path provided: $KeyPath"
    }
}

<#
    .SYNOPSIS
        Removes a registry drive.

    .PARAMETER KeyPath
        The registry key path that contains the registry drive to remove.
#>
function Dismount-RegistryDrive
{
    [CmdletBinding()]
    param 
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $KeyPath
    )

    $driveName = Split-Path -Path $KeyPath -Qualifier
    Write-Verbose -Message "Dismount-RegistryDrive - Drive name: $driveName"

    $null = Remove-PSDrive -Name $driveName -PSProvider 'Registry' -Scope 'Script' -Force
}

<#
    .SYNOPSIS
        Tests if the registry drive of the given registry key path is mounted.

    .PARAMETER KeyPath
        The registry key path that contains the registry drive to test.
#>
function Test-RegistryDriveMounted
{
    [CmdletBinding()]
    [OutputType([Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $KeyPath
    )

    $driveName = Split-Path -Path $KeyPath -Qualifier
    Write-Verbose -Message "Test-RegistryDriveMounted - Drive name: $driveName"

    $psDriveNames = (Get-PSDrive).Name.ToUpperInvariant()

    return $psDriveNames -icontains $driveName
}

<#
    .SYNOPSIS
        Helper function to convert a byte array to its hex string representation

    .PARAMETER Data
        Specifies the byte array to be converted.
#>
function Convert-ByteArrayToHexString
{
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [System.Object]
        $Data
    )

    $hexString = ''
    $Data | ForEach-Object { $hexString += ('{0:x2}' -f $_) }

    return $hexString
}

Export-ModuleMember -Function `
    'Test-RegistryKeyExists', `
    'Test-RegistryValueExists', `
    'New-TestRegistryKey', `
    'New-RegistryValue', `
    'Remove-RegistryKey', `
    'Remove-RegistryValue', `
    'Dismount-RegistryDrive', `
    'Test-RegistryDriveMounted'
