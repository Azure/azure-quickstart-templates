$errorActionPreference = 'Stop'
Set-StrictMode -Version 'Latest'

# Import CommonResourceHelper for Get-LocalizedData
$script:dscResourcesFolderFilePath = Split-Path $PSScriptRoot -Parent
$script:commonResourceHelperFilePath = Join-Path -Path $script:dscResourcesFolderFilePath -ChildPath 'CommonResourceHelper.psm1'
Import-Module -Name $script:commonResourceHelperFilePath

$script:localizedData = Get-LocalizedData -ResourceName 'MSFT_xEnvironmentResource'

$script:envVarRegPathMachine = 'HKLM:\System\CurrentControlSet\Control\Session Manager\Environment'
$script:envVarRegPathUser = 'HKCU:\Environment'

$script:maxSystemEnvVariableLength = 1024
$script:maxUserEnvVariableLength = 255

<#
    .SYNOPSIS
        Retrieves the state of the environment variable. If both Machine and Process Target are
        specified, only the machine value will be returned.

    .PARAMETER Name
        The name of the environment variable to retrieve.

    .PARAMETER Target
        Indicates where to retrieve the variable: The machine or the process. If both are indicated
        then only the value from the machine is returned.
        The default is both since that is the default for the rest of the resource.
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
        $Name,
        
        [ValidateSet('Process', 'Machine')]
        [ValidateNotNullOrEmpty()]
        [String[]]
        $Target = ('Process', 'Machine')      
    )
    
    $valueToReturn = $null

    if ($Target -contains 'Machine')
    {   
        $environmentVaraible = Get-EnvironmentVariableWithoutExpanding -Name $Name -ErrorAction 'SilentlyContinue'

        if ($null -ne $environmentVaraible)
        {
            $valueToReturn = $environmentVaraible.$Name
        }
    }
    else
    {
        $valueToReturn = Get-ProcessEnvironmentVariable -Name $Name
    }
    
    $environmentResource = @{
        Name = $Name
        Value = $null
        Ensure = 'Absent'
    }
    
    if ($null -eq $valueToReturn)
    {        
        Write-Verbose -Message ($script:localizedData.EnvVarNotFound -f $Name)
    }    
    else
    {
        Write-Verbose -Message ($script:localizedData.EnvVarFound -f $Name, $valueToReturn)
        $environmentResource.Ensure = 'Present'
        $environmentResource.Value = $valueToReturn
    }

    return $environmentResource
}

<#
    .SYNOPSIS
        Creates, modifies, or removes an environment variable.
        
    .PARAMETER Name
        The name of the environment variable to create, modify, or remove.

    .PARAMETER Value
        The value to set the environment variable to.
        If a value is not provided, the variable cannot be created.
        If Ensure is set to Present, the variable does not already exist, and a value is not
        specified, an error will be thrown indicating that the variable cannot be created without
        a specified value. If Ensure is set to Present, the variable already exists, and no value
        is specified, nothing will be changed.

    .PARAMETER Ensure
        Specifies whether the variable should exist or not.
        To ensure that the variable or value does exist, set this property to Present.
        To ensure that the variable or value does not exist, set this property to Absent.
        The default value is Present.

    .PARAMETER Path
        Indicates whether or not this is a path variable. If this property is set to True,
        the value provided through the Value property will be appended to (or removed from if
        Ensure is set to Absent) the existing value.
        If this property is set to False, the existing value will be replaced by the new Value.
        The default value is False.

    .PARAMETER Target
        Indicates where to set the environment variable: The machine, the process, or both.
        The default is both: ('Process', 'Machine')
#>
function Set-TargetResource
{
    [CmdletBinding()]
    param
    (       
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $Name,
        
        [ValidateNotNull()]
        [String]
        $Value = [String]::Empty,
        
        [ValidateSet('Present', 'Absent')]
        [String]
        $Ensure = 'Present',
        
        [Boolean]
        $Path = $false,

        [ValidateSet('Process', 'Machine')]
        [ValidateNotNullOrEmpty()]
        [String[]]
        $Target = ('Process', 'Machine')
    )
    
    $valueSpecified = ($Value -ne [String]::Empty)
    $currentValueFromMachine = $null
    $currentValueFromProcess = $null
    $currentPropertiesFromMachine = $null

    $setMachineVariable = ($Target -contains 'Machine')
    $setProcessVariable = ($Target -contains 'Process')

    if ($setMachineVariable)
    {
        if ($Path)
        {
            $currentPropertiesFromMachine = Get-EnvironmentVariableWithoutExpanding -Name $Name -ErrorAction 'SilentlyContinue'

            if ($null -ne $currentPropertiesFromMachine)
            {
                $currentValueFromMachine = $currentPropertiesFromMachine.$Name
            }
        } 
        else
        {
            $currentPropertiesFromMachine = Get-ItemProperty -Path $script:envVarRegPathMachine -Name $Name -ErrorAction 'SilentlyContinue'
            $currentValueFromMachine = Get-EnvironmentVariable -Name $Name -Target 'Machine'
        }
    }

    if ($setProcessVariable)
    {
        $currentValueFromProcess = Get-EnvironmentVariable -Name $Name -Target 'Process'
    }

    # A different value of the environment variable needs to be displayed depending on the Target
    $currentValueToDisplay = ''
    if ($setMachineVariable -and $setProcessVariable)
    {
        $currentValueToDisplay = "Machine: $currentValueFromMachine, Process: $currentValueFromProcess"
    }
    elseif ($setMachineVariable)
    {
        $currentValueToDisplay = $currentValueFromMachine
    }
    else
    {
        $currentValueToDisplay = $currentValueFromProcess
    }

    if ($Ensure -eq 'Present')
    {
        $createMachineVariable = ((-not $setMachineVariable) -or ($null -eq $currentPropertiesFromMachine) -or ($currentValueFromMachine -eq [String]::Empty))
        $createProcessVariable = ((-not $setProcessVariable) -or ($null -eq $currentValueFromProcess) -or ($currentValueFromProcess -eq [String]::Empty))

        if ($createMachineVariable -and $createProcessVariable)
        {

            if (-not $valueSpecified)
            {
                <#
                    If the environment variable doesn't exist and no value is passed in
                    then there is nothing to set - so throw an error.
                #>

                New-InvalidOperationException -Message ($script:localizedData.CannotSetValueToEmpty -f $Name)
            }

            <#
                Given the specified $Name environment variable hasn't been created or set
                simply create one with the specified value and return.
                Both path and non-path cases are covered by this.
            #>

            Set-EnvironmentVariable -Name $Name -Value $Value -Target $Target
            
            Write-Verbose -Message ($script:localizedData.EnvVarCreated -f $Name, $Value)
            return
        }

        if (-not $valueSpecified)
        {
            <#
                Given no $Value was specified to be set and the variable exists,
                we'll leave the existing variable as is.
                This covers both path and non-path variables.
            #>

            Write-Verbose -Message ($script:localizedData.EnvVarUnchanged -f $Name, $currentValueToDisplay)
            return
        }

        # Check if an empty, whitespace or semi-colon only string has been specified. If yes, return unchanged.
        $trimmedValue = $Value.Trim(';').Trim()

        if ([String]::IsNullOrEmpty($trimmedValue))
        {
            Write-Verbose -Message ($script:localizedData.EnvVarPathUnchanged -f $Name, $currentValueToDisplay)
            return        
        }

        if (-not $Path)
        {
            # For non-path variables, simply set the specified $Value as the new value of the specified 
            # variable $Name for the given $Target

            if (($setMachineVariable -and ($Value -cne $currentValueFromMachine)) -or `
                ($setProcessVariable -and ($Value -cne $currentValueFromProcess)))
            {
                Set-EnvironmentVariable -Name $Name -Value $Value -Target $Target
                Write-Verbose -Message ($script:localizedData.EnvVarUpdated -f $Name, $currentValueToDisplay, $Value)
            }
            else
            {
                Write-Verbose -Message ($script:localizedData.EnvVarUnchanged -f $Name, $currentValueToDisplay)
            }

            return
        }

        # If the control reaches here, the specified variable exists, it is a path variable, and a value has been specified to be set.

        if ($setMachineVariable)
        {
            $valueUnchanged = Test-PathsInValue -ExistingPaths $currentValueFromMachine -QueryPaths $trimmedValue -FindCriteria 'All'

            if ($currentValueFromMachine -and -not $valueUnchanged)
            {
                $updatedValue = Add-PathsToValue -CurrentValue $currentValueFromMachine -NewValue $trimmedValue
                Set-EnvironmentVariable -Name $Name -Value $updatedValue -Target @('Machine')
                Write-Verbose -Message ($script:localizedData.EnvVarPathUpdated -f $Name, $currentValueFromMachine, $updatedValue)
            }
            else
            {
                Write-Verbose -Message ($script:localizedData.EnvVarPathUnchanged -f $Name, $currentValueFromMachine)
            }
        }

        if ($setProcessVariable)
        {
            $valueUnchanged = Test-PathsInValue -ExistingPaths $currentValueFromProcess -QueryPaths $trimmedValue -FindCriteria 'All'
            
            if ($currentValueFromProcess -and -not $valueUnchanged)
            {
                $updatedValue = Add-PathsToValue -CurrentValue $currentValueFromProcess -NewValue $trimmedValue
                Set-EnvironmentVariable -Name $Name -Value $updatedValue -Target @('Process')
                Write-Verbose -Message ($script:localizedData.EnvVarPathUpdated -f $Name, $currentValueFromProcess, $updatedValue)
            }
            else
            {
                Write-Verbose -Message ($script:localizedData.EnvVarPathUnchanged -f $Name, $currentValueFromProcess)
            }
        }
    }

    # Ensure = 'Absent'
    else
    {
        $machineVariableRemoved = ((-not $setMachineVariable) -or ($null -eq $currentPropertiesFromMachine))
        $processVariableRemoved = ((-not $setProcessVariable) -or ($null -eq $currentValueFromProcess))

        if ($machineVariableRemoved -and $processVariableRemoved)
        {
            # Variable not found, condition is satisfied and there is nothing to set/remove, return
            Write-Verbose -Message ($script:localizedData.EnvVarNotFound -f $Name)        
            return
        }
        
        if ((-not $ValueSpecified) -or (-not $Path))
        {
            <#
                If $Value is not specified or if $Value is a non-path variable,
                simply remove the environment variable.
            #>

            Remove-EnvironmentVariable -Name $Name -Target $Target

            Write-Verbose -Message ($script:localizedData.EnvVarRemoved -f $Name)
            return
        }

        # Check if an empty string or semi-colon only string has been specified as $Value. If yes, return unchanged as we don't need to remove anything.
        $trimmedValue = $Value.Trim(';').Trim()

        if ([String]::IsNullOrEmpty($trimmedValue))
        {
            Write-Verbose -Message ($script:localizedData.EnvVarPathUnchanged -f $Name, $currentValueToDisplay)
            return
        }

        # If the control reaches here: target variable is an existing environment path-variable and a specified $Value needs be removed from it

        if ($setMachineVariable)
        {
            $finalPath = $null
            
            if ($currentValueFromMachine)
            {
                <#
                    If this value returns $null or an empty string, than the entire path should be removed.
                    If it returns the same value as the path that was passed in, than nothing needs to be
                    updated, otherwise, only the specified paths were removed but there are still others
                    that need to be left in, so the path variable is updated to remove only the specified paths.
                #>
                $finalPath = Remove-PathsFromValue -CurrentValue $currentValueFromMachine -PathsToRemove $trimmedValue
            }

            if ([String]::IsNullOrEmpty($finalPath))
            {
                Remove-EnvironmentVariable -Name $Name -Target @('Machine')
                Write-Verbose -Message ($script:localizedData.EnvVarRemoved -f $Name)
            }
            elseif ($finalPath -ceq $currentValueFromMachine)
            {
                Write-Verbose -Message ($script:localizedData.EnvVarPathUnchanged -f $Name, $currentValueFromMachine)
            }
            else
            {
                Set-EnvironmentVariable -Name $Name -Value $finalPath -Target @('Machine')
                Write-Verbose -Message ($script:localizedData.EnvVarPathUpdated -f $Name, $currentValueFromMachine, $finalPath)
            }       
        }

        if ($setProcessVariable)
        {
            $finalPath = $null
            
            if ($currentValueFromProcess)
            {
                <#
                    If this value returns $null or an empty string, than the entire path should be removed.
                    If it returns the same value as the path that was passed in, than nothing needs to be
                    updated, otherwise, only the specified paths were removed but there are still others
                    that need to be left in, so the path variable is updated to remove only the specified paths.
                #>
                $finalPath = Remove-PathsFromValue -CurrentValue $currentValueFromProcess -PathsToRemove $trimmedValue
            }

            if ([String]::IsNullOrEmpty($finalPath))
            {
                Remove-EnvironmentVariable -Name $Name -Target @('Process')
                Write-Verbose -Message ($script:localizedData.EnvVarRemoved -f $Name)
            }
            elseif ($finalPath -ceq $currentValueFromProcess)
            {
                Write-Verbose -Message ($script:localizedData.EnvVarPathUnchanged -f $Name, $currentValueFromProcess)
            }
            else
            {
                Set-EnvironmentVariable -Name $Name -Value $finalPath -Target @('Process')
                Write-Verbose -Message ($script:localizedData.EnvVarPathUpdated -f $Name, $currentValueFromProcess, $finalPath)
            }       
        }
    }
}

<#
    .SYNOPSIS
        Tests if the environment variable is in the desired state.
        
    .PARAMETER Name
        The name of the environment variable to test.

    .PARAMETER Value
        The value of the environment variable to test. If no value is specified then only the
        existence of the variable will be checked.

    .PARAMETER Ensure
        Specifies whether the variable should exist or not.
        To test that the variable does exist, set this property to Present.
        To test that the variable does not exist, set this property to Absent.
        The default value is Present.

    .PARAMETER Path
        Indicates whether or not this is a path variable. If this property is set to True,
        the value(s) provided through the Value property will be checked against all existing
        values already set in this variable.
        If this property is set to False, the value will be compared directly to the existing value.
        The default value is False.

    .PARAMETER Target
        Indicates where to test the environment variable: The machine, the process, or both.
        The default is both: ('Process', 'Machine')
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
        $Name,
        
        [ValidateNotNull()]
        [String]
        $Value,

        [ValidateSet('Present', 'Absent')]
        [String]
        $Ensure = 'Present',
        
        [Boolean]
        $Path = $false,

        [ValidateSet('Process', 'Machine')]
        [ValidateNotNullOrEmpty()]
        [String[]]
        $Target = ('Process', 'Machine')
    )
    
    $valueSpecified = $PSBoundParameters.ContainsKey('Value') -and ($Value -ne [String]::Empty)
    $currentValueFromMachine = $null
    $currentValueFromProcess = $null
    $currentPropertiesFromMachine = $null

    $checkMachineTarget = ($Target -contains 'Machine')
    $checkProcessTarget = ($Target -contains 'Process')

    if ($checkMachineTarget)
    {
        if ($Path)
        {
            $currentPropertiesFromMachine = Get-EnvironmentVariableWithoutExpanding -Name $Name -ErrorAction 'SilentlyContinue'

            if ($null -ne $currentPropertiesFromMachine)
            {
                $currentValueFromMachine = $currentPropertiesFromMachine.$Name
            }
        } 
        else
        {
            $currentPropertiesFromMachine = Get-ItemProperty -Path $script:envVarRegPathMachine -Name $Name -ErrorAction 'SilentlyContinue'
            $currentValueFromMachine = Get-EnvironmentVariable -Name $Name -Target 'Machine'
        }
    }

    if ($checkProcessTarget)
    {
        $currentValueFromProcess = Get-EnvironmentVariable -Name $Name -Target 'Process'
    }

    # A different value of the environment variable needs to be displayed depending on the Target
    $currentValueToDisplay = ''
    if ($checkMachineTarget -and $checkProcessTarget)
    {
        $currentValueToDisplay = "Machine: $currentValueFromMachine, Process: $currentValueFromProcess"
    }
    elseif ($checkMachineTarget)
    {
        $currentValueToDisplay = $currentValueFromMachine
    }
    else
    {
        $currentValueToDisplay = $currentValueFromProcess
    }
   
    if (($checkMachineTarget -and ($null -eq $currentPropertiesFromMachine)) -or ($checkProcessTarget -and ($null -eq $currentValueFromProcess)))
    {
        # Variable not found
        Write-Verbose ($script:localizedData.EnvVarNotFound -f $Name)
        return ($Ensure -eq 'Absent')
    }

    if (-not $valueSpecified)
    {
        Write-Verbose ($script:localizedData.EnvVarFound -f $Name, $currentValueToDisplay)
        return ($Ensure -eq 'Present')
    }
    
    if (-not $Path)
    {
        # For this non-path variable, make sure that the specified $Value matches the current value.

        if (($checkMachineTarget -and ($Value -cne $currentValueFromMachine)) -or `
           ($checkProcessTarget -and ($Value -cne $currentValueFromProcess)))
        {
            Write-Verbose ($script:localizedData.EnvVarFoundWithMisMatchingValue -f $Name, $currentValueToDisplay, $Value)
            return ($Ensure -eq 'Absent')
        }
        else
        {
            Write-Verbose ($script:localizedData.EnvVarFound -f $Name, $currentValueToDisplay)
            return ($Ensure -eq 'Present')
        }
    }

    # If the control reaches here, the expected environment variable exists, it is a path variable and a $Value is specified to test against
    if ($Ensure -eq 'Present')
    {                   
        if ($checkMachineTarget)
        {        
            if (-not (Test-PathsInValue -ExistingPaths $currentValueFromMachine -QueryPaths $Value -FindCriteria 'All'))
            {
                # If the control reached here some part of the specified path ($Value) was not found in the existing variable, return failure       
                Write-Verbose ($script:localizedData.EnvVarFoundWithMisMatchingValue -f $Name, $currentValueToDisplay, $Value)
                return $false
            }
        }

        if ($checkProcessTarget)
        {
            if (-not (Test-PathsInValue -ExistingPaths $currentValueFromProcess -QueryPaths $Value -FindCriteria 'All'))
            {
                # If the control reached here some part of the specified path ($Value) was not found in the existing variable, return failure       
                Write-Verbose ($script:localizedData.EnvVarFoundWithMisMatchingValue -f $Name, $currentValueToDisplay, $Value)
                return $false
            }
        }

        # The specified path was completely present in the existing environment variable, return success
        Write-Verbose ($script:localizedData.EnvVarFound -f $Name, $currentValueToDisplay)
        return $true
    }
    # Ensure = 'Absent'
    else
    {                             
        if ($checkMachineTarget)
        {
            if (Test-PathsInValue -ExistingPaths $currentValueFromMachine -QueryPaths $Value -FindCriteria 'Any')
            {
                # One of the specified paths in $Value exists in the environment variable path, thus the test fails
                Write-Verbose ($script:localizedData.EnvVarFound -f $Name, $currentValueFromMachine)
                return $false
            }
        }

        if ($checkProcessTarget)
        {
            if (Test-PathsInValue -ExistingPaths $currentValueFromProcess -QueryPaths $Value -FindCriteria 'Any')
            {
                # One of the specified paths in $Value exists in the environment variable path, thus the test fails
                Write-Verbose ($script:localizedData.EnvVarFound -f $Name, $currentValueFromProcess)
                return $false
            }
        }
                    
        # If the control reached here, none of the specified paths were found in the existing path-variable, return success
        Write-Verbose ($script:localizedData.EnvVarFoundWithMisMatchingValue -f $Name, $currentValueToDisplay, $Value)
        return $true
    }
}

<#
    .SYNOPSIS
        Retrieves the value of the environment variable from the given Target.
        
    .PARAMETER Name
        The name of the environment variable to retrieve the value from.

    .PARAMETER Target
        Indicates where to retrieve the environment variable from. Currently, only
        Process and Machine are being used, but User is included for future extension
        of this resource.
#>
function Get-EnvironmentVariable
{
    [CmdletBinding()]
    [OutputType([String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $Name,

        [Parameter(Mandatory = $true)]
        [ValidateSet('Process', 'Machine')]
        [String]
        $Target
    )

    $valueToReturn = $null

    if ($Target -eq 'Process') 
    {
        $valueToReturn = Get-ProcessEnvironmentVariable -Name $Name
    }
    elseif ($Target -eq 'Machine')
    {
        $retrievedProperty = Get-ItemProperty -Path $script:envVarRegPathMachine -Name $Name -ErrorAction 'SilentlyContinue'

        if ($null -ne $retrievedProperty)
        {
            $valueToReturn = $retrievedProperty.$Name
        }
    }
    elseif ($Target -eq 'User')
    {
        $retrievedProperty = Get-ItemProperty -Path $script:envVarRegPathUser -Name $Name -ErrorAction 'SilentlyContinue'

        if ($null -ne $retrievedProperty)
        {
            $valueToReturn = $retrievedProperty.$Name
        }
    }
 
    return $valueToReturn
}

<#
    .SYNOPSIS
        Wrapper function to retrieve an environment variable from the current process.
        
    .PARAMETER Name
        The name of the variable to retrieve
      
#>
function Get-ProcessEnvironmentVariable
{
    [CmdletBinding()]
    [OutputType([String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $Name
    )

    return [System.Environment]::GetEnvironmentVariable($Name)
}

<#
    .SYNOPSIS
        If there are any paths in NewPaths that aren't in CurrentValue they will be added
        to the current paths value and a String will be returned containing all old paths
        and new paths. Otherwise the original value will be returned unchanged.
        
    .PARAMETER CurrentValue
        A semicolon-separated String containing the current path values.

    .PARAMETER NewPaths
        A semicolon-separated String containing any paths that should be added to
        the current value. If CurrentValue already contains a path, it will not be added.   
#>
function Add-PathsToValue
{
    [CmdletBinding()]
    [OutputType([String])]
    param
    (       
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $CurrentValue,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $NewValue
    )

    $finalValue = $CurrentValue + ';'
    $currentPaths = $CurrentValue -split ';'
    $newPaths = $NewValue -split ';'

    foreach ($path in $newPaths)            
    {            
        if ($currentPaths -notcontains $path)
        {
            <#
                If the control reached here, we didn't find this $specifiedPath in the $currentPaths,
                so add it.
            #>

            $finalValue += ($path + ';')
        }                            
    }  

    # Remove any extraneous ';' at the end (and potentially start - as a side-effect) of the value to be set
    return $finalValue.Trim(';')
}

<#
    .SYNOPSIS
        If there are any paths in PathsToRemove that aren't in CurrentValue they will be removed
        from the current paths value and either the new value will be returned if there are still
        paths that remain, or an empty string will be returned if all paths were removed.
        If none of the paths in PathsToRemove are in CurrentValue then this function will
        return CurrentValue since nothing needs to be changed.
        
    .PARAMETER CurrentValue
        A semicolon-separated String containing the current path values.

    .PARAMETER PathsToRemove
        A semicolon-separated String containing any paths that should be removed from
        the current value.
#>
function Remove-PathsFromValue
{
    [OutputType([String])]
    [CmdletBinding()]
    param
    (       
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $CurrentValue,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $PathsToRemove
    )

    $finalPath = ''
    $specifiedPaths = $PathsToRemove -split ';'
    $currentPaths = $CurrentValue -split ';'
    $varAltered = $false

    foreach ($subpath in $currentPaths)
    {
        if ($specifiedPaths -contains $subpath)
        {
            <#
                Found this $subpath as one of the $specifiedPaths, skip adding this to the final
                value/path of this variable and mark the variable as altered.
            #>
            $varAltered = $true
        }
        else
        {
            # the current $subpath was not part of the $specifiedPaths (to be removed) so keep this $subpath in the finalPath
            $finalPath += $subpath + ';'
        }                            
    }                          
    
    # Remove any extraneous ';' at the end (and potentially start - as a side-effect) of the $finalPath        
    $finalPath = $finalPath.Trim(';')                
        
    if ($varAltered)
    {
        return $finalPath
    }
    else
    {
        return $CurrentValue
    }
}

<#
    .SYNOPSIS
        Sets the value of the environment variable with the given name if a value is specified.
        If no value is specified, then the environment variable will be removed.
        
    .PARAMETER Name
        The name of the environment variable to set or remove.

    .PARAMETER Value
        The value to set the environment variable to. If not provided, then the variable will
        be removed.
    
    .PARAMETER Target
        Indicates where to set or remove the environment variable: The machine, the process, or both.
        The logic for User is also included here for future expansion of this resource.
#>
function Set-EnvironmentVariable
{
    [CmdletBinding()]
    param
    (       
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $Name,

        [String]
        $Value,

        [Parameter(Mandatory = $true)]
        [ValidateSet('Process', 'Machine')]
        [String[]]
        $Target
    )

    $valueSpecified = $PSBoundParameters.ContainsKey('Value')

    try
    {
        # If the Value is set to [String]::Empty then nothing should be updated for the process
        if (($Target -contains 'Process') -and (-not $valueSpecified -or ($Value -ne [String]::Empty)))
        {
            if (-not $valueSpecified)
            {
                Set-ProcessEnvironmentVariable -Name $Name -Value $null
            }
            else
            {
                Set-ProcessEnvironmentVariable -Name $Name -Value $Value
            }
        }

        if ($Target -contains 'Machine')
        {
            if ($Name.Length -ge $script:maxSystemEnvVariableLength)
            {
                New-InvalidArgumentException -Message $script:localizedData.ArgumentTooLong -ArgumentName $Name
            }

            $path = $script:envVarRegPathMachine

            if (-not $valueSpecified) 
            {
                $environmentKey = Get-ItemProperty -Path $path -Name $Name -ErrorAction 'SilentlyContinue'

                if ($environmentKey)
                {
                    Remove-ItemProperty -Path $path -Name $Name
                }
                else
                {
                    $message = ($script:localizedData.RemoveNonExistentVarError -f $Name)
                    New-InvalidArgumentException -Message $message -ArgumentName $Name
                }
            }
            else
            {
                Set-ItemProperty -Path $path -Name $Name -Value $Value
                $environmentKey = Get-ItemProperty -Path $path -Name $Name -ErrorAction 'SilentlyContinue'

                if ($null -eq $environmentKey) 
                {
                    $message = ($script:localizedData.GetItemPropertyFailure -f $Name, $path)
                    New-InvalidArgumentException -Message $message -ArgumentName $Name
                }
            }
        }

        # The User feature of this resource is not yet implemented.
        if ($Target -contains 'User')
        {
            if ($Name.Length -ge $script:maxUserEnvVariableLength)
            {
                New-InvalidArgumentException -Message $script:localizedData.ArgumentTooLong -ArgumentName $Name
            }

            $path = $script:envVarRegPathUser

            if (-not $valueSpecified) 
            {
                $environmentKey = Get-ItemProperty -Path $path -Name $Name -ErrorAction 'SilentlyContinue'

                if ($environmentKey)
                {
                    Remove-ItemProperty -Path $path -Name $Name
                }
                else
                {
                    $message = ($script:localizedData.RemoveNonExistentVarError -f $Name)
                    New-InvalidArgumentException -Message $message -ArgumentName $Name
                }
            }
            else
            {
                Set-ItemProperty -Path $path -Name $Name -Value $Value
                $environmentKey = Get-ItemProperty -Path $path -Name $Name -ErrorAction 'SilentlyContinue'

                if ($null -eq $environmentKey) 
                {
                    $message = ($script:localizedData.GetItemPropertyFailure -f $Name, $path)
                    New-InvalidArgumentException -Message $message -ArgumentName $Name
                }
            }
        }
    }
    catch 
    {
        New-InvalidOperationException -Message ($script:localizedData.EnvVarSetError -f $Name, $Value) `
                                      -ErrorRecord $_
    }

}

<#
    .SYNOPSIS
        Wrapper function to set an environment variable for the current process.
        
    .PARAMETER Name
        The name of the environment variable to set.

    .PARAMETER Value
        The value to set the environment variable to.
         
#>
function Set-ProcessEnvironmentVariable
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $Name,

        [String]
        $Value = [String]::Empty
    )

    [System.Environment]::SetEnvironmentVariable($Name, $Value)
}

<#
    .SYNOPSIS
        Removes an environment variable from the given target(s) by calling Set-EnvironmentVariable
        with no Value specified.
        
    .PARAMETER Name
        The name of the environment variable to remove.

    .PARAMETER Target
        Indicates where to remove the environment variable from: The machine, the process, or both.
#>
function Remove-EnvironmentVariable
{
    [CmdletBinding()]
    param
    (       
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $Name,

        [Parameter(Mandatory = $true)]
        [ValidateSet('Process', 'Machine')]
        [String[]]
        $Target
    )
        
    try
    {
        Set-EnvironmentVariable -Name $Name -Target $Target
    }
    catch 
    {
        New-InvalidOperationException -Message ($script:localizedData.EnvVarRemoveError -f $Name) `
                                      -ErrorRecord $_
    }
}

<#
    .SYNOPSIS
        Tests all of the paths in QueryPaths against those in ExistingPaths.
        If FindCriteria is set to 'All' then it will only return True if all of the
        paths in QueryPaths are in ExistingPaths, otherwise it will return False.
        If FindCriteria is set to 'Any' then it will return True if any of the paths
        in QueryPaths are in ExistingPaths, otherwise it will return False.
          
    .PARAMETER ExistingPaths
        A semicolon-separated String containing the path values to test against.

    .PARAMETER QueryPaths
        A semicolon-separated String containing the path values to ensure are either
        included or not included in ExistingPaths.

    .PARAMETER FindCriteria
        Set to either 'All' or 'Any' to indicate whether all of the paths in QueryPaths
        should be included in ExistingPaths or any of them.
#>
function Test-PathsInValue
{
    [OutputType([Boolean])]  
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]               
        [String]
        $ExistingPaths,
        
        [Parameter(Mandatory = $true)]
        [String]
        $QueryPaths,

        [Parameter(Mandatory = $true)]      
        [ValidateSet('Any', 'All')]
        [String]
        $FindCriteria
    )

    $existingPathList = $ExistingPaths -split ';'
    $queryPathList = $QueryPaths -split ';'

    switch ($FindCriteria)
    {
        'Any'
        {
            foreach ($queryPath in $queryPathList)
            {            
                if ($existingPathList -contains $queryPath)
                {
                    # Found this $queryPath in the existing paths, return $true
                    return $true
                }                             
            }

            # If the control reached here, none of the QueryPaths were found in ExistingPaths
            return $false   
        }

        'All'
        {
            foreach ($queryPath in $queryPathList)
            {
                if ($queryPath) 
                {
                    if ($existingPathList -notcontains $queryPath)
                    {
                        # The current $queryPath wasn't found in any of the $existingPathList, return false                    
                        return $false
                    }
                }                
            }

            # If the control reached here, all of the QueryPaths were found in ExistingPaths
            return $true
        }    
    }
}

<#
    .SYNOPSIS
        Retrieves the Environment variable with the given name from the registry on the machine.
        It returns the result as an object containing a Hashtable with the environment variable
        name and its current value on the machine. This is to most closely represent what the
        actual API call returns. If an environment variable with the given name is not found, then
        $null will be returned.
          
    .PARAMETER Name
        The name of the environment variable to retrieve the value of.
#>
function Get-EnvironmentVariableWithoutExpanding
{
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [String]
        $Name
    )

    $path = $script:envVarRegPathMachine
    $pathTokens = $path.Split('\',[System.StringSplitOptions]::RemoveEmptyEntries)
    $entry = $pathTokens[1..($pathTokens.Count - 1)] -join '\'
    
    # Since the target registry path coming to this function is hardcoded for local machine
    $hive = [Microsoft.Win32.Registry]::LocalMachine

    $noteProperties = @{}

    try
    {
        $key = $hive.OpenSubKey($entry)
        
        $valueNames = $key.GetValueNames()
        if ($valueNames -inotcontains $Name)
        {
            return $null
        }
        
        [String] $value = Get-KeyValue -Name $Name -Key $key
        $noteProperties.Add($Name, $value)
    }
    finally
    {
        if ($key)
        {
            $key.Close()
        }
    }

    [System.Management.Automation.PSObject] $propertyResults = New-Object -TypeName System.Management.Automation.PSObject -Property $noteProperties

    return $propertyResults
}

<#
    .SYNOPSIS
        Wrapper function to get the value of the environment variable with the given name
        from the specified registry key.
          
    .PARAMETER Name
        The name of the environment variable to retrieve the value of.

    .PARAMETER Key
        The key to retrieve the environment variable from.
#>
function Get-KeyValue
{
    [OutputType([String])]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [String]
        $Name,

        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [Microsoft.Win32.RegistryKey]
        $Key
    )

    return $Key.GetValue($Name, $null, [Microsoft.Win32.RegistryValueOptions]::DoNotExpandEnvironmentNames)
}
