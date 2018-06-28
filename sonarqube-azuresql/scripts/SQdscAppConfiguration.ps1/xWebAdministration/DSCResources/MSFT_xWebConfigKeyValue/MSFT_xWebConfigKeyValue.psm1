
# Localized messages
data LocalizedData
{
    # culture="en-US"
    ConvertFrom-StringData -StringData @'
    VerboseGetTargetCheckingTarget  = Checking for the existance of key "{0}" in ConfigSection "{1}" located at "{2}"
    VerboseGetTargetAttributeCheck  = Checking if key "{0}" is an Attribute
    VerboseGetTargetKeyNotFound     = Key "{0}" has not been found.
    VerboseGetTargetKeyFound        = Key "{0}" has been found
    VerboseSetTargetCheckingKey     = Checking for existance of key "{0}"
    VerboseSetTargetAddItem         = Key "{0}" does not exist, adding key
    VerboseSetTargetEditItem        = Key "{0}" exists, editing key
    VerboseSetTargetRemoveItem      = Key "{0}" exists, removing key
    VerboseTestTargetCheckingTarget = Checking for the existance of key "{0}" in ConfigSection "{1}" located at "{2}"
    VerboseTestTargetKeyNotFound    = Key "{0}" has not been found.
    VerboseTestTargetKeyWasFound    = Key "{0}" has been found.
'@
}

<#
    .SYNOPSIS
        Gets the value of the specified key in the config file
#>
function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String] $WebsitePath,

        [parameter(Mandatory = $true)]
        [ValidateSet('AppSettings')]
        [System.String] $ConfigSection,

        [parameter(Mandatory = $true)]
        [String] $Key
    )

    Write-Verbose `
        -Message ($LocalizedData.VerboseGetTargetCheckingTarget -f $Key, $ConfigSection, $WebsitePath )

    $existingValue = Get-ItemValue `
                        -Key $Key `
                        -IsAttribute $false `
                        -WebsitePath $WebsitePath `
                        -ConfigSection $ConfigSection

    if ( $null -eq $existingValue )
    {
        Write-Verbose `
            -Message ($LocalizedData.VerboseGetTargetAttributeCheck -f $Key )

        $existingValue = Get-ItemValue `
                            -Key $Key `
                            -IsAttribute $true `
                            -WebsitePath $WebsitePath `
                            -ConfigSection $ConfigSection
    }

    if ( $existingValue.Length -eq 0 )
    {
        Write-Verbose `
            -Message ($LocalizedData.VerboseGetTargetKeyNotFound -f $Key )

         return @{
             Ensure = 'Absent'
             Key = $Key
             Value = $existingValue
        }
    }

    Write-Verbose `
        -Message ($LocalizedData.VerboseGetTargetKeyFound -f $Key )

    return @{
        Ensure = 'Present'
        Key = $Key
        Value = $existingValue
    }
}

<#
    .SYNOPSIS
        Sets the value of the specified key in the config file
#>
function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String] $WebsitePath,

        [parameter(Mandatory = $true)]
        [ValidateSet('AppSettings')]
        [System.String] $ConfigSection,

        [parameter(Mandatory = $true)]
        [String] $Key,

        [ValidateSet('Present','Absent')]
        [System.String] $Ensure = 'Present',

        [String] $Value,

        [System.Boolean] $IsAttribute
    )

    if ($Ensure -eq 'Present')
    {
        Write-Verbose `
            -Message ($LocalizedData.VerboseSetTargetCheckingKey -f $Key )

        $existingValue = Get-ItemValue `
                            -Key $Key `
                            -IsAttribute $IsAttribute `
                            -WebsitePath $WebsitePath `
                            -ConfigSection $ConfigSection

        if ( (-not $IsAttribute -and ($null -eq $existingValue) ) `
                -or ( $IsAttribute -and ($existingValue.Length -eq 0) ) )
        {
            Write-Verbose `
                -Message ($LocalizedData.VerboseSetTargetAddItem -f $Key )

            Add-Item `
                -Key $Key `
                -Value $Value `
                -IsAttribute $IsAttribute `
                -WebsitePath $WebsitePath `
                -ConfigSection $ConfigSection
        }
        else
        {
            $propertyName = 'value'

            if ( $IsAttribute )
            {
                $propertyName = $Key
            }

            Write-Verbose `
                -Message ($LocalizedData.VerboseSetTargetEditItem -f $Key )

            Edit-Item `
                -PropertyName $propertyName `
                -OldValue $Key `
                -NewValue $Value `
                -IsAttribute $IsAttribute `
                -WebsitePath $WebsitePath `
                -ConfigSection $ConfigSection
        }
    }
    else
    {
        Write-Verbose `
            -Message ($LocalizedData.VerboseSetTargetRemoveItem -f $Key )

        Remove-Item `
            -Key $Key `
            -IsAttribute $IsAttribute `
            -WebsitePath $WebsitePath `
            -ConfigSection $ConfigSection
    }
}

<#
    .SYNOPSIS
        Tests the value of the specified key in the config file
#>
function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String] $WebsitePath,

        [parameter(Mandatory = $true)]
        [ValidateSet('AppSettings')]
        [System.String] $ConfigSection,

        [parameter(Mandatory = $true)]
        [String] $Key,

        [String] $Value,

        [ValidateSet('Present','Absent')]
        [System.String] $Ensure = 'Present',

        [System.Boolean] $IsAttribute
    )

    if ( -not $PSBoundParameters.ContainsKey('IsAttribute') )
    {
        $IsAttribute = $false
    }

   Write-Verbose `
        -Message ($LocalizedData.VerboseTestTargetCheckingTarget -f $Key, $ConfigSection, $WebsitePath )

    $existingValue = Get-ItemValue `
                        -Key $Key `
                        -IsAttribute $IsAttribute `
                        -WebsitePath $WebsitePath `
                        -ConfigSection $ConfigSection

    if ( $Ensure -eq 'Present' )
    {
        if ( ( $null -eq $existingValue ) -or ( $existingValue -ne $Value ) `
                -or ($existingValue.Length -eq 0) )
        {
            Write-Verbose `
                -Message ($LocalizedData.VerboseTestTargetKeyNotFound -f $Key )
            return $false
        }
    }
    else
    {
        if ( ( $null -ne $existingValue ) -or ( $existingValue.Length -ne 0 ) )
        {
             Write-Verbose `
                -Message ($LocalizedData.VerboseTestTargetKeyNotFound -f $Key )

            return $false
        }
    }

    Write-Verbose `
            -Message ($LocalizedData.VerboseTestTargetKeyWasFound -f $Key)

    return $true
}

# region Helper Functions

function Add-Item
{
    param
    (
        [string] $Key,

        [string] $Value,

        [Boolean] $isAttribute,

        [string] $WebsitePath,

        [string] $ConfigSection
    )

    $itemCollection = @{
        Key   = $Key;
        Value = $Value;
    }

    if ( -not $isAttribute )
    {
        Add-WebConfigurationProperty `
            -Filter $ConfigSection `
            -Name '.' `
            -Value $itemCollection `
            -PSPath $WebsitePath
    }
    else
    {
        Set-WebConfigurationProperty `
            -Filter $ConfigSection `
            -PSPath $WebsitePath `
            -Name $Key `
            -Value $Value `
            -WarningAction Stop
    }
}

function Edit-Item
{
    param
    (
        [string] $PropertyName,        

        [string] $OldValue,

        [string] $NewValue,

        [Boolean] $IsAttribute,

        [string] $WebsitePath,

        [string] $ConfigSection
    )

    if ( -not $IsAttribute )
    {
        $filter = "$ConfigSection/add[@key=`'$OldValue`']"

        Set-WebConfigurationProperty -Filter $filter `
            -PSPath $WebsitePath `
            -Name $PropertyName `
            -Value $NewValue `
            -WarningAction Stop
    }
    else
    {
        Set-WebConfigurationProperty `
            -Filter $ConfigSection `
            -PSPath $WebsitePath `
            -Name $PropertyName `
            -Value $NewValue `
            -WarningAction Stop
    }
}

function Remove-Item
{
    param
    (
        [string] $Key,

        [Boolean] $IsAttribute,

        [string] $WebsitePath,

        [string] $ConfigSection
    )

    if ( -not $isAttribute )
    {
        $filter = "$ConfigSection/add[@key=`'$key`']"
        Clear-WebConfiguration `
            -Filter $filter `
            -PSPath $WebsitePath `
            -WarningAction Stop
    }
    else
    {
        $filter = "$ConfigSection/@$key"

        <#
            This is a workaround to ensure if appSettings has no collection
            and we try to delete the only attribute, the entire node is not deleted.
            if we try removing the only attribute even if there is one collection item,
            the node is preserved.
        #>
        Add-Item `
            -Key 'dummyKey' `
            -Value 'dummyValue' `
            -IsAttribute $false `
            -WebsitePath $WebsitePath `
            -ConfigSection $ConfigSection

        Clear-WebConfiguration `
            -Filter $filter `
            -PSPath $WebsitePath `
            -WarningAction Stop

        Remove-Item `
            -Key 'dummyKey' `
            -IsAttribute $false `
            -WebsitePath $WebsitePath `
            -ConfigSection $ConfigSection
    }
}

function Get-ItemValue
{
    param
    (
        [string] $Key,

        [Boolean] $isAttribute,

        [string] $WebsitePath,

        # If this is null $value.Value will be null
        [string] $ConfigSection
    )

    if (-not $isAttribute)
    {
        $filter = "$ConfigSection/add[@key=`'$key`']"
        $value = Get-WebConfigurationProperty `
                    -Filter $filter `
                    -Name 'value' `
                    -PSPath $WebsitePath
    }
    else
    {
        $value = Get-WebConfigurationProperty `
                    -Filter $ConfigSection `
                    -Name "$Key" `
                    -PSPath $WebsitePath
    }

    return $value.Value
}

# endregion

Export-ModuleMember -Function *-TargetResource
