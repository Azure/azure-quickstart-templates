#region Initialize

function Initialize
{
    # Load Assembly to use HttpClient
    try
    {
        Add-Type -AssemblyName System.Net.Http
    }
    catch
    {
    }

    # cache Location Variable
    # MSFT using this path, but this always clear when LCM runs. It means whenever you run "Get" you can't refer cache. 
    # => need to change to persistence path to match with cache.
    # $script:cacheLocation = "$env:ProgramData\Microsoft\Windows\PowerShell\Configuration\BuiltinProvCache\Grani_Download"
    $script:cacheLocation = "$env:ProgramData\Microsoft\Windows\PowerShell\Configuration\CustomProvCache\Grani_GitHubApiContent"

    # GitHub API template string : RepositoryOwner / Repository / ContentPath / Branch
    $script:githubApiString = "https://api.github.com/repos/{0}/{1}/contents/{2}?ref={3}"

    # Enum for Item Type
    Add-Type -TypeDefinition @"
        public enum GraniDonwloadItemTypeEx
        {
            FileInfo,
            DirectoryInfo,
            Other,
            NotExists
        }
"@
}

Initialize

#endregion

#region Message Definition

$debugMessage = DATA {
    ConvertFrom-StringData -StringData "
        AddRequestHeader = Adding Request Header. Key : '{0}', Value : '{1}'
        AddContentType = Adding ContentType : '{0}'
        AddKeepAliveToRequestHeader = Adding Keep-Alive as true to the Request Header.
        AddOAuth2Token = Adding OAuth2Token for Basic Authentication.
        AddUserAgent = Adding UserAgent : '{0}'
        ContentTypeDetectedAsJson = ContentType passed to Request header as '{0}'. Treat response as JSON, content encoded as base64.
        ContentTypeDetectedAsRaw = ContentType passed to Request header as '{0}'. Treat response as RAW, content directly pick from result.
        ContentTypeDetectedAsHtml = ContentType passed to Request header as '{0}'. Treat response as HTML, content directly pick from result.
        ConvertBase64String = Convert base64 string to UTF8 string.
        ConvertstringToJsonAndGetContent = Convert json string to PSCustomObject, then picking up base64 encoded string from content property.
        DownloadComplete = Download content complete.
        GetRawContent = Getting raw content from response result
        IsDestinationPathExist = Checking Destination Path is existing and Valid as a FileInfo
        IsDestinationPathAlreadyUpToDate = Matching FileHash to verify file is already exist/Up-To-Date or not.
        IsFileAlreadyUpToDate = CurrentFileHash : CachedFileHash -> {0} : {1}
        IsFileExists = File found from DestinationPath. Checking already up-to-date.
        ItemTypeWasFile = Destination Path found as File : '{0}'
        ItemTypeWasDirectory = Destination Path found but was Directory : '{0}'
        ItemTypeWasOther = Destination Path found but was neither File nor Directory: '{0}'
        ItemTypeWasNotExists = Destination Path not found : '{0}'
        SetCacheLocationPath = CacheLocation Value detected. Setting Custom CacheLocation Path : '{0}'
        TestUriConnection = Testing connection to the URI : {0}
        UpdateFileHashCache = Updating cache path '{1}' for current File hash SHA256 '{0}'.
        ValidateUri = Cast URI string '{0}' to System.Uri.
        ValidateFilePath = Check DestinationPath '{0}' is FileInfo and Parent Directory already exist.
        WriteStream = Start writing downloaded string to File Path : '{0}'
    "
}

$verboseMessage = DATA {
    ConvertFrom-StringData -StringData "
        alreadyUpToDate = Current DestinationPath FileHash and Cache FileHash matched. File already Up-To-Date.
        DownloadStream = Status Code returns '{0}'. Start download stream from URI : '{1}'
        DownloadString = Status Code returns '{0}'. Start download string from URI : '{1}'
        notUpToDate = Current DestinationPath FileHash and Cache FileHash not matched. Need to download latest file.
    "
}
$exceptionMessage = DATA {
    ConvertFrom-StringData -StringData "
        ContentNotFoundFromResponce = Content not exist in GitHub API response json string.
        ResultNotFountFromResponce = Result not exist in GitHub API response raw string.
        InvalidCastURI = Uri : '{0}' casted to [System.Uri] but was invalid string for URI. Make sure you have passed valid URI string.
        InvalidUriSchema = Specified URI is not valid: '{0}'. Only https is accepted.
        InvalidResponce = Status Code returns '{0}'. Stop download content from URI : '{1}'
        DestinationPathAlreadyExistAsNotFile = Destination Path '{0}' already exist but not a file. Found itemType is {1}. Windows not allowed exist same name item.
    "
}

#endregion

#region *-TargetResource

function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]$DestinationPath,

        [parameter(Mandatory = $true)]
        [System.String]$Repository,

        [parameter(Mandatory = $true)]
        [System.String]$RepositoryOwner,

        [parameter(Mandatory = $true)]
        [System.String]$ContentPath,

        [parameter(Mandatory = $false)]
        [System.String]$Branch = "master",

        [parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]$OAuth2Token = [PSCredential]::Empty,

        [parameter(Mandatory = $false)]
        [Microsoft.Management.Infrastructure.CimInstance[]]$Header = $null,

        [parameter(Mandatory = $false)]
        [ValidateSet("application/json","application/vnd.github+json","application/vnd.github.v3.raw","application/vnd.github.v3.html")]
        [System.String]$ContentType = "application/json",

        [parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [System.String]$UserAgent = [Microsoft.PowerShell.Commands.PSUserAgent]::InternetExplorer,

        [parameter(Mandatory = $false)]
        [System.Boolean]$AllowRedirect = $true,

        [parameter(Mandatory = $false)]
        [System.String]$CacheLocation = [string]::Empty
    )

    # Set Custom Cache Location
    if ($CacheLocation -ne [string]::Empty)
    {
        Write-Debug -Message ($debugMessage.SetCacheLocationPath -f $CacheLocation)
        $script:cacheLocation = $CacheLocation
    }

    # Setup GitHub API Uri string from GitHub parameters
    $uri = ParseGitHubApiUri -RepositoryOwner $RepositoryOwner -Repository $Repository -ContentPath $ContentPath -Branch $Branch

    # validate Uri can be parse to [URI] and Schema is http|https|file
    $validUri = ValidateUri -Uri $uri

    # Initialize return values
    # Header and OAuth2Token will never return as TypeConversion problem
    $returnHash = 
    @{
        DestinationPath = $DestinationPath
        Repository = $Repository
        RepositoryOwner = $RepositoryOwner
        ContentPath = $ContentPath
        Branch = $Branch
        ContentType = $ContentType
        UserAgent = $UserAgent
        AllowRedirect = $AllowRedirect
        OAuth2Token = New-CimInstance -ClassName MSFT_Credential -Property @{Username=[string]$OAuth2Token.UserName; Password=[string]$null} -Namespace root/microsoft/windows/desiredstateconfiguration -ClientOnly
        CacheLocation = $CacheLocation
        Ensure = "Absent"
    }

    # Destination Path check
    Write-Debug -Message $debugMessage.IsDestinationPathExist
    $itemType = GetPathItemType -Path $DestinationPath

    $fileExists = $false
    switch ($itemType.ToString())
    {
        ([GraniDonwloadItemTypeEx]::FileInfo.ToString())
        {
            Write-Debug -Message ($debugMessage.ItemTypeWasFile -f $DestinationPath)
            $fileExists = $true
        }
        ([GraniDonwloadItemTypeEx]::DirectoryInfo.ToString())
        {
            Write-Debug -Message ($debugMessage.ItemTypeWasDirectory -f $DestinationPath)
        }
        ([GraniDonwloadItemTypeEx]::Other.ToString())
        {
            Write-Debug -Message ($debugMessage.ItemTypeWasOther -f $DestinationPath)
        }
        ([GraniDonwloadItemTypeEx]::NotExists.ToString())
        {
            Write-Debug -Message ($debugMessage.ItemTypeWasNotExists -f $DestinationPath)
        }
    }

    # Already Up-to-date Check
    Write-Debug -Message $debugMessage.IsDestinationPathAlreadyUpToDate
    if ($fileExists -eq $true)
    {
        Write-Debug -Message $debugMessage.IsFileExists
        $currentFileHash = GetFileHash -Path $DestinationPath
        $cachedFileHash = GetCache -DestinationPath $DestinationPath -Uri $validUri

        Write-Debug -Message ($debugMessage.IsFileAlreadyUpToDate -f $currentFileHash, $cachedFileHash)
        if ($currentFileHash -eq $cachedFileHash)
        {
            Write-Verbose -Message $verboseMessage.alreadyUpToDate
            $returnHash.Ensure = "Present"
        }
        else
        {
            Write-Verbose -Message $verboseMessage.notUpToDate
        }
    }

    return $returnHash
}


function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]$DestinationPath,

        [parameter(Mandatory = $true)]
        [System.String]$Repository,

        [parameter(Mandatory = $true)]
        [System.String]$RepositoryOwner,

        [parameter(Mandatory = $true)]
        [System.String]$ContentPath,

        [parameter(Mandatory = $false)]
        [System.String]$Branch = "master",

        [parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]$OAuth2Token = [PSCredential]::Empty,

        [parameter(Mandatory = $false)]
        [Microsoft.Management.Infrastructure.CimInstance[]]$Header = $null,

        [parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet("application/json","application/vnd.github+json","application/vnd.github.v3.raw","application/vnd.github.v3.html")]
        [System.String]$ContentType = "application/json",

        [parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [System.String]$UserAgent = [Microsoft.PowerShell.Commands.PSUserAgent]::InternetExplorer,

        [parameter(Mandatory = $false)]
        [System.Boolean]$AllowRedirect = $true,

        [parameter(Mandatory = $false)]
        [System.String]$CacheLocation = [string]::Empty
    )

    # Set Custom Cache Location
    if ($CacheLocation -ne [string]::Empty)
    {
        Write-Debug -Message ($debugMessage.SetCacheLocationPath -f $CacheLocation)
        $script:cacheLocation = $CacheLocation
    }

    # Setup GitHub API Uri string from GitHub parameters
    $uri = ParseGitHubApiUri -Repository $Repository -RepositoryOwner $RepositoryOwner -ContentPath $ContentPath -Branch $Branch

    # validate Uri can be parse to [URI] and Schema is http|https|file
    $validUri = ValidateUri -Uri $Uri

    # validate DestinationPath is valid
    ValidateFilePath -Path $DestinationPath

    # Convert CimInstance to HashTable
    $headerHashtable = ConvertKCimInstanceToHashtable -CimInstance $Header

    # Start Download
    Invoke-HttpClient -Uri $validUri -Path $DestinationPath -Header $headerHashtable -ContentType $ContentType -UserAgent $UserAgent -OAuth2Token $OAuth2Token -AllowRedirect $AllowRedirect

    # Update Cache for FileHash
    UpdateCache -DestinationPath $DestinationPath -Uri $validUri
}


function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]$DestinationPath,

        [parameter(Mandatory = $true)]
        [System.String]$Repository,

        [parameter(Mandatory = $true)]
        [System.String]$RepositoryOwner,

        [parameter(Mandatory = $true)]
        [System.String]$ContentPath,

        [parameter(Mandatory = $false)]
        [System.String]$Branch = "master",

        [parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]$OAuth2Token = [PSCredential]::Empty,

        [parameter(Mandatory = $false)]
        [Microsoft.Management.Infrastructure.CimInstance[]]$Header = $null,

        [parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet("application/json","application/vnd.github+json","application/vnd.github.v3.raw","application/vnd.github.v3.html")]
        [System.String]$ContentType = "application/json",

        [parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [System.String]$UserAgent = [Microsoft.PowerShell.Commands.PSUserAgent]::InternetExplorer,

        [parameter(Mandatory = $false)]
        [System.Boolean]$AllowRedirect = $true,

        [parameter(Mandatory = $false)]
        [System.String]$CacheLocation = [string]::Empty
    )

    $param = @{
        DestinationPath = $DestinationPath
        RepositoryOwner = $RepositoryOwner
        Repository = $Repository
        ContentPath = $ContentPath
        Branch = $Branch
        OAuth2Token = $OAuth2Token
        Header = $Header
        ContentType = $ContentType
        UserAgent = $UserAgent
        AllowRedirect = $AllowRedirect
        CacheLocation = $CacheLocation
    }
    return (Get-TargetResource @param).Ensure -eq "Present"
}


#endregion

#region HttpClient Helper

function Invoke-HttpClient
{
    [OutputType([void])]
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [uri]$Uri,

        [parameter(Mandatory = $true)]
        [string]$Path,

        [parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]$OAuth2Token = [PSCredential]::Empty,

        [parameter(Mandatory = $false)]
        [System.Collections.Hashtable]$Header = @{},

        [parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet("application/json","application/vnd.github+json","application/vnd.github.v3.raw","application/vnd.github.v3.html")]
        [System.String]$ContentType = "application/json",

        [parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [System.String]$UserAgent = [Microsoft.PowerShell.Commands.PSUserAgent]::InternetExplorer,

        [parameter(Mandatory = $false)]
        [System.Boolean]$AllowRedirect = $true
    )

    begin
    {
        #region Initialize

        # Should support Timeout? : Default -> 1:40 min
        # Should support MaxResponseContentBufferSize? : Default -> 2147483647

        $httpClientHandler = New-Object System.Net.Http.HttpClientHandler
        $httpClientHandler.AllowAutoRedirect = $AllowRedirect
        
        $httpClient = New-Object System.Net.Http.HttpClient ($httpClientHandler)

        # Request Header
        if ($Header.Keys.Count -ne 0)
        {
            foreach ($item in $Header.GetEnumerator())
            {
                Write-Debug -Message ($debugMessage.AddRequestHeader -f $item.Key, $item.Value)
                $httpClient.DefaultRequestHeaders.Add($item.Key, $item.Value)
            }   
        }

        # Request Header : Keep-Alive
        if (($httpClient.DefaultRequestHeaders.GetEnumerator() | where Key -eq "Keep-Alive" | measure).Count -eq 0)
        {
            Write-Debug -Message ($debugMessage.AddKeepAliveToRequestHeader)
            $httpClient.DefaultRequestHeaders.Add("Keep-Alive", "true")
        }

        # ContentType
        if ($ContentType -ne [string]::Empty)
        {
            Write-Debug -Message ($debugMessage.AddContentType -f $ContentType)
            $private:mediaType = New-Object System.Net.Http.Headers.MediaTypeWithQualityHeaderValue($ContentType)
            $httpClient.DefaultRequestHeaders.Accept.Add($mediaType)
        }

        # UserAgent
        if ($UserAgent -ne [string]::Empty)
        {
            Write-Debug -Message ($debugMessage.AddUserAgent -f $UserAgent)
            $httpClient.DefaultRequestHeaders.UserAgent.ParseAdd($UserAgent)
        }

        # Credential
        if ($OAuth2Token.GetNetworkCredential().Password -ne [string]::Empty)
        {
            # Credential on Handler does not work with Basic Authentication : http://stackoverflow.com/questions/25761214/why-would-my-rest-service-net-clients-send-every-request-without-authentication
            # $httpClientHandler.Credential = $Credential

            $private:authorizationHeaderKey = "Authorization"
            $private:authorizationHeaderValue = "token {0}" -f $OAuth2Token.GetNetworkCredential().Password

            Write-Debug -Message ($debugMessage.AddOAuth2Token)
            $httpClient.DefaultRequestHeaders.Add($private:authorizationHeaderKey, $private:authorizationHeaderValue) # Basic Authentication Only
        }

        #endregion
    }

    end
    {
        try
        {
            #region Test Connection

            Write-Debug -Message ($debugMessage.TestUriConnection -f $Uri.ToString())
            $res = $httpClient.GetAsync($Uri)
            $res.ConfigureAwait($false) > $null
            if ($res.Exception -ne $null){ throw $res.Exception }
            if ($res.Result.StatusCode -ne [System.Net.HttpStatusCode]::OK){ throw ($exceptionMessage.InvalidResponce -f $res.Result.StatusCode.value__, $Uri) }
            
            #endregion

            #region Execute Download

            switch ($ContentType)
            {
                "application/json"
                {
                    Write-Verbose -Message ($verboseMessage.DownloadString -f $res.Result.StatusCode.value__, $Uri)
                    [System.Threading.Tasks.Task`1[string]]$requestResult = GetStringAsync -Uri $Uri

                    Write-Debug -Message $debugMessage.ContentTypeDetectedAsJson
                    WriteJson -Path $Path -RequestResult $requestResult
                }
                "application/vnd.github+json"
                {
                    Write-Verbose -Message ($verboseMessage.DownloadString -f $res.Result.StatusCode.value__, $Uri)
                    [System.Threading.Tasks.Task`1[string]]$requestResult = GetStringAsync -Uri $Uri
                    
                    Write-Debug -Message $debugMessage.ContentTypeDetectedAsJson
                    WriteJson -Path $Path -RequestResult $requestResult
                }
                "application/vnd.github.v3.raw"
                {
                    Write-Verbose -Message ($verboseMessage.DownloadStream -f $res.Result.StatusCode.value__, $Uri)
                    [System.Threading.Tasks.Task`1[System.IO.Stream]]$stream = GetStreamAsync -Uri $Uri

                    Write-Debug -Message $debugMessage.ContentTypeDetectedAsRaw
                    WriteStream -Path $Path -Stream $stream
                }
                "application/vnd.github.v3.html"
                {
                    Write-Verbose -Message ($verboseMessage.DownloadStream -f $res.Result.StatusCode.value__, $Uri)
                    [System.Threading.Tasks.Task`1[System.IO.Stream]]$stream = GetStreamAsync -Uri $Uri

                    Write-Debug -Message $debugMessage.ContentTypeDetectedAsHtml
                    WriteStream -Path $Path -Stream $stream
                }
            }
                        
            #endregion
            
            Write-Verbose -Message ($debugMessage.DownloadComplete)
        }
        catch [System.Exception]
        {
            throw $_
        }
        finally
        {
            if (($null -ne $res) -and ($res.IsCompleted -eq $true)){ $res.Dispose() }
            if ($null -ne $httpClient){ $httpClient.Dispose() }
            if ($null -ne $httpClientHandler){ $httpClientHandler.Dispose() }
        }
    }
}

function GetStringAsync
{
    [OutputType([System.Threading.Tasks.Task`1[string]])]
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [uri]$Uri
    )

    [System.Threading.Tasks.Task`1[string]]$requestResult = $httpClient.GetStringAsync($Uri)
    $requestResult.ConfigureAwait($false) > $null
    if ($requestResult.Exception -ne $null){ throw $requestResult.Exception }
    return $requestResult
}

function GetStreamAsync
{
    [OutputType([System.Threading.Tasks.Task`1[System.IO.Stream]])]
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [uri]$Uri
    )

    [System.Threading.Tasks.Task`1[System.IO.Stream]]$stream = $httpClient.GetStreamAsync($Uri)
    $stream.ConfigureAwait($false) > $null
    if ($stream.Exception -ne $null){ throw $stream.Exception }
    return $stream
}

function WriteJson
{
    [OutputType([void])]
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [string]$Path,

        [parameter(Mandatory = $true)]
        [System.Threading.Tasks.Task`1[string]]$RequestResult
    )

    begin
    {
        function GetContentBase64String
        {
            [OutputType([string])]
            [CmdletBinding()]
            param
            (
                [parameter(Mandatory = $true)]
                [System.Threading.Tasks.Task`1[string]]$RequestResult
            )

            # Get Content base64 string
            Write-Debug -Message $debugMessage.ConvertstringToJsonAndGetContent
            $content = ($RequestResult.Result | ConvertFrom-Json).Content

            if ($content -eq [string]::Empty){ throw New-Object System.NullReferenceException $exceptionMessage.ContentNotFoundFromResponce }
            return $content
        }

        function ConvertFromBase64ToUTF8
        {
            [OutputType([string])]
            [CmdletBinding()]
            param
            (
                [parameter(Mandatory = $true)]
                [string]$String
            )

            try
            {
                # convert bse64 to UTF8
                Write-Debug -Message $debugMessage.ConvertBase64String
                $utf8String = [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($String))
                return $utf8String
            }
            catch
            {
                throw $_
            }
        }
    }

    process
    {
        try
        {
            # Get base64 string from Content Property of response json
            $content = GetContentBase64String -RequestResult $RequestResult
        
            # decode base64 to utf8 string
            $decodedString = ConvertFromBase64ToUTF8 -String $Content

            # Write content to the file.
            [System.IO.File]::WriteAllText($Path, $decodedString, [System.Text.Encoding]::UTF8)
            
        }
        finally
        {
            if (($null -ne $RequestResult) -and ($RequestResult.IsCompleted -eq $true)){ $RequestResult.Dispose() }
        }
    }
}

function WriteStream
{
    [OutputType([void])]
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [string]$Path,

        [parameter(Mandatory = $true)]
        [System.Threading.Tasks.Task`1[System.IO.Stream]]$Stream
    )

    try
    {
        # Write stream to the File
        Write-Debug -Message ($debugMessage.WriteStream -f $Path)
        $fileStream = [System.IO.File]::Create($Path)
        $Stream.Result.CopyTo($fileStream)
    }
    finally
    {
        if ($null -ne $fileStream){ $fileStream.Dispose() }
        if (($null -ne $Stream) -and ($Stream.IsCompleted -eq $true)){ $Stream.Dispose() }
    }
}

#endregion

#region Parse Helper

function ParseGitHubApiUri
{
    [OutputType([string])]
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]$RepositoryOwner,

        [parameter(Mandatory = $true)]
        [System.String]$Repository,

        [parameter(Mandatory = $true)]
        [System.String]$ContentPath,

        [parameter(Mandatory = $false)]
        [System.String]$Branch = "master"
    )

    $uriString = $script:githubApiString -f $RepositoryOwner, $Repository, $ContentPath, $Branch
    return $uriString
}

#endregion

#region Validation Helper

function ValidateUri
{
    [OutputType([uri])]
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [string]$Uri
    )
    
    Write-Debug -Message ($debugMessage.ValidateUri -f $Uri)
    [uri]$result = $Uri -as [uri]
    if ($result.AbsolutePath -eq $null){ throw New-Object System.NullReferenceException ($exceptionMessage.InvalidCastURI -f $Uri)}
    if ($result.Scheme -ne "https")
    {
        $errorId = "UriValidationFailure";
        $errorMessage = $exceptionMessage.InvalidUriSchema -f ${Uri}
        ThrowInvalidDataException -ErrorId $errorId -ErrorMessage $errorMessage
    }
    return $result
}

function ValidateFilePath
{
    [OutputType([Void])]
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [string]$Path
    )
    
    Write-Debug -Message ($debugMessage.ValidateFilePath -f $Path)
    $itemType = GetPathItemType -Path $Path
    switch ($itemType.ToString())
    {
        ([GraniDonwloadItemTypeEx]::FileInfo.ToString())
        {
            return;
        }
        ([GraniDonwloadItemTypeEx]::NotExists.ToString())
        {
            # Create Parent Directory check
            $parentPath = Split-Path $Path -Parent
            if (-not (Test-Path -Path $parentPath))
            {
                [System.IO.Directory]::CreateDirectory($parentPath) > $null
            }
        }
        Default
        {
            $errorId = "FileValidationFailure"
            $errorMessage = $exceptionMessage.DestinationPathAlreadyExistAsNotFile -f $Path, $itemType.ToString()
            ThrowInvalidDataException -ErrorId $errorId -ErrorMessage $errorMessage
        }
    }

}

#endregion

#region Cache Helper

function GetFileHash
{
    [OutputType([string])]
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [string]$Path
    )

    return (Get-FileHash -Path $Path -Algorithm SHA256).Hash
}

function GetCacheKey
{
    [OutputType([string])]
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [string]$DestinationPath,

        [parameter(Mandatory = $true)]
        [uri]$Uri
    )

    $key = [string]::Join("", @($DestinationPath, $Uri.AbsoluteUri.ToString())).GetHashCode().ToString()
    return $key
}

function GetCache
{
    [OutputType([string])]
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [string]$DestinationPath,

        [parameter(Mandatory = $true)]
        [uri]$Uri
    )

    $cacheKey = GetCacheKey -DestinationPath $DestinationPath -Uri $Uri
    $path = Join-Path $script:cacheLocation $cacheKey
    
    # Test Cache Path is exist
    if (-not (Test-Path -Path $path)){ return [string]::Empty }

    # Get FileHash from Cache File
    $fileHash = (Import-CliXml -Path $path).FileHash
    return $fileHash    
}

function UpdateCache
{
    [OutputType([void])]
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [string]$DestinationPath,

        [parameter(Mandatory = $true)]
        [uri]$Uri
    )

    $cacheKey = GetCacheKey -DestinationPath $DestinationPath -Uri $Uri
    $path = Join-Path $script:cacheLocation $cacheKey

    # create cacheLocaltion Directory
    if (-not (Test-Path -Path $script:cacheLocation))
    {
        [System.IO.Directory]::CreateDirectory($script:cacheLocation) > $null
    }

    # Create Cache Object
    $fileHash = GetFileHash -Path $DestinationPath
    $obj = NewXmlObject -DestinationPath $DestinationPath -Uri $Uri -FileHash $fileHash

    # export cache to CliXML
    Write-Debug ($debugMessage.UpdateFileHashCache -f $fileHash, $Path)
    $obj | Export-CliXml -Path $path -Force
}

function NewXmlObject
{
    [OutputType([PSCustomObject])]
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [string]$DestinationPath,

        [parameter(Mandatory = $true)]
        [uri]$Uri,

        [parameter(Mandatory = $true)]
        [string]$FileHash
    )
    
    $obj = @{}
    $obj.FileHash = $FileHash
    $obj.WriteTime = [System.IO.File]::GetLastWriteTimeUtc($DestinationPath)
    $obj.Path = $DestinationPath
    $obj.Uri = $Uri.AbsoluteUri.ToString()
    return [PSCustomObject]$obj
}

#endregion

#region ItemType Helper

function GetPathItemType
{
    [OutputType([GraniDonwloadItemTypeEx])]
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias("FullName", "LiteralPath", "PSPath")]
        [System.String]$Path = [string]::Empty
    )

    $type = [string]::Empty

    # Check type of the Path Item
    if (-not (Test-Path -Path $Path))
    {
        return [GraniDonwloadItemTypeEx]::NotExists
    }
    
    $pathItem = Get-Item -Path $path
    $pathItemType = $pathItem.GetType().FullName
    $type = switch ($pathItemType)
    {
        "System.IO.FileInfo"
        {
            [GraniDonwloadItemTypeEx]::FileInfo
        }
        "System.IO.DirectoryInfo"
        {
            [GraniDonwloadItemTypeEx]::DirectoryInfo
        }
        Default
        {
            [GraniDonwloadItemTypeEx]::Other
        }
    }

    return $type
}

#endregion

#region Converter from Microsoft.Management.Infrastructure.CimInstance[] (KeyValuePair) to HashTable

function ConvertKCimInstanceToHashtable
{
    [OutputType([hashtable[]])]
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $false)]
        [AllowNull()]
        [Microsoft.Management.Infrastructure.CimInstance[]]$CimInstance
    )

    if ($null -eq $CimInstance)
    {
        return @{}
    }

    $hashtable = New-Object System.Collections.Generic.List[hashtable]
    foreach($item in $CimInstance.GetEnumerator())
    {
        $hashtable.Add(@{$item.Key = $item.Value})
    }

    return $hashtable
}

#endregion

#region Exception Helper

function ThrowInvalidDataException
{
    [OutputType([Void])]
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]$ErrorId,

        [parameter(Mandatory = $true)]
        [System.String]$ErrorMessage
    )
    
    $errorCategory = [System.Management.Automation.ErrorCategory]::InvalidData
    $exception = New-Object System.InvalidOperationException $ErrorMessage 
    $errorRecord = New-Object System.Management.Automation.ErrorRecord $exception, $ErrorId, $errorCategory, $null
    throw $errorRecord
}

#endregion

Export-ModuleMember -Function *-TargetResource