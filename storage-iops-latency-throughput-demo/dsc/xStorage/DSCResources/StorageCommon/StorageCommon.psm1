Import-Module -Name (Join-Path -Path (Split-Path $PSScriptRoot -Parent) `
                               -ChildPath 'CommonResourceHelper.psm1')

# Localized messages for Write-Verbose statements in this resource
$script:localizedData = Get-LocalizedData -ResourceName 'StorageCommon'

<#
    .SYNOPSIS
    Validates a Drive Letter, removing or adding the trailing colon if required.

    .PARAMETER DriveLetter
    The Drive Letter string to validate.

    .PARAMETER Colon
    Will ensure the returned string will include or exclude a colon.
#>
function Assert-DriveLetterValid
{
    [CmdletBinding()]
    [OutputType([String])]
    param
    (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $DriveLetter,

        [Switch]
        $Colon
    )

    $Matches = @([regex]::matches($DriveLetter, '^([A-Za-z]):?$', 'IgnoreCase'))
    if (-not $Matches)
    {
        # DriveLetter format is invalid
        New-InvalidArgumentException `
            -Message $($LocalizedData.InvalidDriveLetterFormatError -f $DriveLetter) `
            -ArgumentName 'DriveLetter'
    }
    # This is the drive letter without a colon
    $DriveLetter = $Matches.Groups[1].Value
    if ($Colon)
    {
        $DriveLetter = $DriveLetter + ':'
    } # if
    return $DriveLetter
} # end function Assert-DriveLetterValid

<#
    .SYNOPSIS
    Validates an Access Path, removing or adding the trailing slash if required.
    If the Access Path does not exist or is not a folder then an exception will
    be thrown.

    .PARAMETER AccessPath
    The Access Path string to validate.

    .PARAMETER Slash
    Will ensure the returned path will include or exclude a slash.
#>
function Assert-AccessPathValid
{
    [CmdletBinding()]
    [OutputType([String])]
    param
    (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $AccessPath,

        [Switch]
        $Slash
    )

    if (-not (Test-Path -Path $AccessPath -PathType Container))
    {
        # AccessPath is invalid
        New-InvalidArgumentException `
            -Message $($LocalizedData.InvalidAccessPathError -f $AccessPath) `
            -ArgumentName 'AccessPath'
    } # if

    # Remove or Add the trailing slash
    if($AccessPath.EndsWith('\'))
    {
        if (-not $Slash)
        {
            $AccessPath = $AccessPath.TrimEnd('\')
        } # if
    }
    else
    {
        if ($Slash)
        {
            $AccessPath = "$AccessPath\"
        } # if
    } # if

    return $AccessPath
} # end function Assert-AccessPathValid

Export-ModuleMember -Function @( 'Assert-DriveLetterValid', 'Assert-AccessPathValid' )
