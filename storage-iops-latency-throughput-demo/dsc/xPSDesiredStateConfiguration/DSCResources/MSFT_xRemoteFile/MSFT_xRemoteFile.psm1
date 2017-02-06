$moduleRoot = Split-Path `
    -Path $MyInvocation.MyCommand.Path `
    -Parent

#region LocalizedData
$Culture = 'en-us'
if (Test-Path -Path (Join-Path -Path $moduleRoot -ChildPath $PSUICulture))
{
    $Culture = $PSUICulture
}
Import-LocalizedData `
    -BindingVariable LocalizedData `
    -Filename MSFT_xRemoteFile.psd1 `
    -BaseDirectory $moduleRoot `
    -UICulture $Culture
#endregion

# Path where cache will be stored. It's cleared whenever LCM gets new configuration.
$script:cacheLocation = "$env:ProgramData\Microsoft\Windows\PowerShell\Configuration\BuiltinProvCache\MSFT_xRemoteFile"

<#
.Synopsis
The Get-TargetResource function is used to fetch the status of file specified in DestinationPath on the target machine.
#>
function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $DestinationPath,

        [parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Uri
    )

    # Check whether DestinationPath is existing file
    $ensure = "Absent"
    $pathItemType = Get-PathItemType -path $DestinationPath
    switch($pathItemType)
    {
        "File"
        {
            Write-Verbose -Message $($LocalizedData.DestinationPathIsExistingFile `
                -f ${DestinationPath})
            $ensure = "Present"
        }

        "Directory"
        {
            Write-Verbose -Message $($LocalizedData.DestinationPathIsExistingPath `
                -f ${DestinationPath})

            # If it's existing directory, let's check whether expectedDestinationPath exists
            $uriFileName = Split-Path $Uri -Leaf
            $expectedDestinationPath = Join-Path $DestinationPath $uriFileName
            if (Test-Path $expectedDestinationPath)
            {
                Write-Verbose -Message $($LocalizedData.FileExistsInDestinationPath `
                    -f ${uriFileName})
                $ensure = "Present"
            }
        }

        "Other"
        {
            Write-Verbose -Message  $($LocalizedData.DestinationPathUnknownType `
                -f ${DestinationPath},${pathItemType})
        }

        "NotExists"
        {
            Write-Verbose -Message  $($LocalizedData.DestinationPathDoesNotExist `
                -f ${DestinationPath})
        }
    }

    $returnValue = @{
        DestinationPath = $DestinationPath
        Uri = $Uri
        Ensure = $ensure
    }

    $returnValue
}

<#
.Synopsis
The Set-TargetResource function is used to download file found under Uri location to DestinationPath
Additional parameters can be specified to configure web request
#>
function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $DestinationPath,

        [parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Uri,

        [System.String]
        $UserAgent,

        [Microsoft.Management.Infrastructure.CimInstance[]]
        $Headers,

        [System.Management.Automation.PSCredential]
        $Credential,

        [parameter(Mandatory = $false)]
        [System.Boolean]
        $MatchSource = $true,

        [Uint32]
        $TimeoutSec,

        [System.String]
        $Proxy,

        [System.Management.Automation.PSCredential]
        $ProxyCredential
    )

    # Validate Uri
    if (-not (Test-UriScheme -uri $Uri -scheme "http|https|file"))
    {
        $errorMessage = $($LocalizedData.InvalidWebUriError) `
            -f ${Uri}
        New-InvalidDataException `
            -errorId "UriValidationFailure" `
            -errorMessage $errorMessage
    }

    # Validate DestinationPath scheme
    if (-not (Test-UriScheme -uri $DestinationPath -scheme "file"))
    {
        $errorMessage = $($LocalizedData.InvalidDestinationPathSchemeError `
            -f ${DestinationPath})
        New-InvalidDataException `
            -errorId "DestinationPathSchemeValidationFailure" `
            -errorMessage $errorMessage
    }

    # Validate DestinationPath is not UNC path
    if ($DestinationPath.StartsWith("\\"))
    { 
        $errorMessage = $($LocalizedData.DestinationPathIsUncError `
            -f ${DestinationPath})
        New-InvalidDataException `
            -errorId "DestinationPathIsUncFailure" `
            -errorMessage $errorMessage
    }

    # Validate DestinationPath does not contain invalid characters
    @('*','?','"','<','>','|') | % { 
        if ($DestinationPath.Contains($_) ){
            $errorMessage = $($LocalizedData.DestinationPathHasInvalidCharactersError `
                -f ${DestinationPath})
            New-InvalidDataException `
                -errorId "DestinationPathHasInvalidCharactersError" `
                -errorMessage $errorMessage
        }
    }

    # Validate DestinationPath does not end with / or \ (Invoke-WebRequest requirement)
    if ($DestinationPath.EndsWith('/') -or $DestinationPath.EndsWith('\')){
        $errorMessage = $($LocalizedData.DestinationPathEndsWithInvalidCharacterError `
            -f ${DestinationPath})
        New-InvalidDataException `
            -errorId "DestinationPathEndsWithInvalidCharacterError" `
            -errorMessage $errorMessage
    }

    # Check whether DestinationPath's parent directory exists. Create if it doesn't.
    $destinationPathParent = Split-Path $DestinationPath -Parent
    if (-not (Test-Path $destinationPathParent))
    {
        $null = New-Item -ItemType Directory -Path $destinationPathParent -Force
    }

    # Check whether DestinationPath's leaf is an existing folder
    $uriFileName = Split-Path $Uri -Leaf
    if (Test-Path $DestinationPath -PathType Container)
    {
        $DestinationPath = Join-Path $DestinationPath $uriFileName
    }

    # Remove DestinationPath and MatchSource from parameters as they are not parameters of Invoke-WebRequest
    $null = $PSBoundParameters.Remove("DestinationPath")
    $null = $PSBoundParameters.Remove("MatchSource")

    # Convert headers to hashtable
    $null = $PSBoundParameters.Remove("Headers")
    $headersHashtable = $null

    if ($Headers -ne $null)
    {
        $headersHashtable = Convert-KeyValuePairArrayToHashtable -array $Headers
    }

    # Invoke web request
    try
    {
        Write-Verbose -Message $($LocalizedData.DownloadingURI `
            -f ${DestinationPath},${URI})
        Invoke-WebRequest @PSBoundParameters -Headers $headersHashtable -outFile $DestinationPath
    }
    catch [System.OutOfMemoryException]
    {
        $errorMessage = $($LocalizedData.DownloadOutOfMemoryException `
            -f $_)
        New-InvalidDataException `
            -errorId "SystemOutOfMemoryException" `
            -errorMessage $errorMessage
    }
    catch [System.Exception]
    {
        $errorMessage = $($LocalizedData.DownloadException `
            -f $_)
        New-InvalidDataException `
            -errorId "SystemException" `
            -errorMessage $errorMessage
    }

    # Update cache
    if (Test-Path -Path $DestinationPath)
    {
        $downloadedFile = Get-Item -Path $DestinationPath
        $lastWriteTime = $downloadedFile.LastWriteTimeUtc
        $filesize = $downloadedFile.Length
        $inputObject = @{}
        $inputObject["LastWriteTime"] = $lastWriteTime
        $inputObject["FileSize"] = $filesize
        Update-Cache -DestinationPath $DestinationPath -Uri $Uri -InputObject $inputObject
    }
}

<#
.Synopsis
The Test-TargetResource function is used to validate if the DestinationPath exists on the machine.
#>
function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $DestinationPath,

        [parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Uri,

        [System.String]
        $UserAgent,

        [Microsoft.Management.Infrastructure.CimInstance[]]
        $Headers,

        [System.Management.Automation.PSCredential]
        $Credential,

        [parameter(Mandatory = $false)]
        [System.Boolean]
        $MatchSource = $true,

        [Uint32]
        $TimeoutSec,

        [System.String]
        $Proxy,

        [System.Management.Automation.PSCredential]
        $ProxyCredential
    )

    # Check whether DestinationPath points to existing file or directory
    $fileExists = $false
    $uriFileName = Split-Path $Uri -Leaf
    $pathItemType = Get-PathItemType -Path $DestinationPath
    switch($pathItemType)
    {
        "File"
        {
            Write-Verbose -Message $($LocalizedData.DestinationPathIsExistingFile `
                -f ${DestinationPath})

            if ($MatchSource) {
                $file = Get-Item -Path $DestinationPath
                # Getting cache. It's cleared every time user runs Start-DscConfiguration
                $cache = Get-Cache -DestinationPath $DestinationPath -Uri $Uri

                if ($cache -ne $null `
                    -and ($cache.LastWriteTime -eq $file.LastWriteTimeUtc) `
                    -and ($cache.FileSize -eq $file.Length))
                {
                    Write-Verbose -Message $($LocalizedData.CacheReflectsCurrentState)
                    $fileExists = $true
                }
                else
                {
                    Write-Verbose -Message $($LocalizedData.CacheIsEmptyOrNotMatchCurrentState)
                }
            }
            else
            {
                Write-Verbose -Message $($LocalizedData.MatchSourceFalse)
                $fileExists = $true
            }
        }

        "Directory"
        {
            Write-Verbose -Message $($LocalizedData.DestinationPathIsExistingPath `
                -f ${DestinationPath})

            $expectedDestinationPath = Join-Path -Path $DestinationPath -ChildPath $uriFileName

            if (Test-Path -Path $expectedDestinationPath)
            {
                if ($MatchSource)
                {
                    $file = Get-Item -Path $expectedDestinationPath
                    $cache = Get-Cache -DestinationPath $expectedDestinationPath -Uri $Uri
                    if ($cache -ne $null -and ($cache.LastWriteTime -eq $file.LastWriteTimeUtc))
                    {
                        Write-Verbose -Message $($LocalizedData.CacheReflectsCurrentState)
                        $fileExists = $true
                    }
                    else
                    {
                        Write-Verbose -Message $($LocalizedData.CacheIsEmptyOrNotMatchCurrentState)
                    }
                }
                else
                {
                    Write-Verbose -Message $($LocalizedData.MatchSourceFalse)
                    $fileExists = $true
                }
            }
        }

        "Other"
        {
            Write-Verbose -Message  $($LocalizedData.DestinationPathUnknownType `
                -f ${DestinationPath},${pathItemType})
        }

        "NotExists"
        {
            Write-Verbose -Message  $($LocalizedData.DestinationPathDoesNotExist `
                -f ${DestinationPath})
        }
    }

    $result = $fileExists

    $result
}

<#
.Synopsis
Throws terminating error of category InvalidData with specified errorId and errorMessage
#>
function New-InvalidDataException
{
    param(
        [parameter(Mandatory = $true)]
        [System.String]
        $errorId,

        [parameter(Mandatory = $true)]
        [System.String]
        $errorMessage
    )
    
    $errorCategory = [System.Management.Automation.ErrorCategory]::InvalidData
    $exception = New-Object `
        -TypeName System.InvalidOperationException `
        -ArgumentList $errorMessage 
    $errorRecord = New-Object `
        -TypeName System.Management.Automation.ErrorRecord `
        -ArgumentList $exception, $errorId, $errorCategory, $null
    throw $errorRecord
}

<#
.Synopsis
Checks whether given URI represents specific scheme
.Description
Most common schemes: file, http, https, ftp
We can also specify logical expressions like: [http|https]
#>
function Test-UriScheme
{
    param (
        [parameter(Mandatory = $true)]
        [System.String]
        $uri,

        [parameter(Mandatory = $true)]
        [System.String]
        $scheme
    )
    $newUri = $uri -as [System.URI]
    $newUri.AbsoluteURI -ne $null -and $newUri.Scheme -match $scheme
}

<#
.Synopsis
Gets type of the item which path points to. 
.Outputs
File, Directory, Other or NotExists
#>
function Get-PathItemType
{
    param (
        [parameter(Mandatory = $true)]
        [System.String]
        $path
    )

    $type = $null

    # Check whether path exists
    if (Test-Path $path)
    {
        # Check type of the path
        $pathItem = Get-Item -Path $path
        $pathItemType = $pathItem.GetType().Name
        if ($pathItemType -eq "FileInfo")
        {
            $type = "File"
        }
        elseif ($pathItemType -eq "DirectoryInfo")
        {
            $type = "Directory"
        }
        else
        {
            $type = "Other"
        }
    }
    else
    {
        $type = "NotExists"
    }

    return $type
}

<#
.Synopsis
Converts CimInstance array of type KeyValuePair to hashtable
#>
function Convert-KeyValuePairArrayToHashtable
{
    param (
        [parameter(Mandatory = $true)]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $array
    )

    $hashtable = @{}
    foreach($item in $array)
    {
        $hashtable += @{$item.Key = $item.Value}
    }

    return $hashtable
}

<#
.Synopsis
Gets cache for specific DestinationPath and Uri
#>
function Get-Cache
{
    param (
        [parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $DestinationPath,

        [parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Uri
    )

    $cacheContent = $null
    $key = Get-CacheKey -DestinationPath $DestinationPath -Uri $Uri
    $path = Join-Path -Path $script:cacheLocation -ChildPath $key

    Write-Verbose -Message $($LocalizedData.CacheLookingForPath `
        -f ${Path})

    if(-not (Test-Path -Path $path))
    {
        Write-Verbose -Message $($LocalizedData.CacheNotFoundForPath `
            -f ${DestinationPath},${Uri},${Key})

        $cacheContent = $null
    }
    else
    {
        $cacheContent = Import-CliXml -Path $path
        Write-Verbose -Message $($LocalizedData.CacheFoundForPath `
            -f ${DestinationPath},${Uri},${Key})
    }

    return $cacheContent
}

<#
.Synopsis
Creates or updates cache for specific DestinationPath and Uri
#>
function Update-Cache
{
    param (
        [parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $DestinationPath,

        [parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Uri,
        
        [parameter(Mandatory = $true)]
        [Object]
        $InputObject
    )

    $key = Get-CacheKey -DestinationPath $DestinationPath -Uri $Uri
    $path = Join-Path -Path $script:cacheLocation -ChildPath $key

    if(-not (Test-Path -Path $script:cacheLocation))
    {
        $null = New-Item -ItemType Directory -Path $script:cacheLocation
    }

    Write-Verbose -Message $($LocalizedData.UpdatingCache `
        -f ${DestinationPath},${Uri},${Key})

    Export-CliXml -Path $path -InputObject $InputObject -Force
}

<#
.Synopsis
Returns cache key for given parameters
#>
function Get-CacheKey
{
    param (
        [parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $DestinationPath,

        [parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Uri
    )
    return [string]::Join("", @($DestinationPath, $Uri)).GetHashCode().ToString()
}

Export-ModuleMember -Function *-TargetResource
