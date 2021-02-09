<#
    .SYNOPSIS
    Downloads and installs Chocolatey on the local machine.

    .DESCRIPTION
    Retrieves the Chocolatey nupkg for the latest or a specified version, and
    downloads and installs the application to the local machine.

    .NOTES
    =====================================================================
    Copyright 2017 - 2020 Chocolatey Software, Inc, and the
    original authors/contributors from ChocolateyGallery
    Copyright 2011 - 2017 RealDimensions Software, LLC, and the
    original authors/contributors from ChocolateyGallery
    at https://github.com/chocolatey/chocolatey.org

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
    =====================================================================

    Environment Variables, specified as $env:NAME in PowerShell.exe and %NAME% in cmd.exe.
    For explicit proxy, please set $env:chocolateyProxyLocation and optionally $env:chocolateyProxyUser and $env:chocolateyProxyPassword
    For an explicit version of Chocolatey, please set $env:chocolateyVersion = 'versionnumber'
    To target a different url for chocolatey.nupkg, please set $env:chocolateyDownloadUrl = 'full url to nupkg file'
    NOTE: $env:chocolateyDownloadUrl does not work with $env:chocolateyVersion.
    To use built-in compression instead of 7zip (requires additional download), please set $env:chocolateyUseWindowsCompression = 'true'
    To bypass the use of any proxy, please set $env:chocolateyIgnoreProxy = 'true'

    .LINK
    For organizational deployments of Chocolatey, please see https://docs.chocolatey.org/en-us/guides/organizations/organizational-deployment-guide

#>
[CmdletBinding(DefaultParameterSetName = 'Default')]
param(
    # The URL to download Chocolatey from. This defaults to the value of
    # $env:chocolateyDownloadUrl, if it is set, and otherwise falls back to the
    # official Chocolatey community repository to download the Chocolatey package.
    [Parameter(Mandatory = $false)]
    [string]
    $ChocolateyDownloadUrl = $env:chocolateyDownloadUrl,

    # Specifies a target version of Chocolatey to install. By default, the latest
    # stable version is installed. This will use the value in
    # $env:chocolateyVersion by default, if that environment variable is present.
    # This parameter is ignored if -ChocolateyDownloadUrl is set.
    [Parameter(Mandatory = $false)]
    [string]
    $ChocolateyVersion = $env:chocolateyVersion,

    # If set, uses built-in Windows decompression tools instead of 7zip when
    # unpacking the downloaded nupkg. This will be set by default if
    # $env:chocolateyUseWindowsCompression is set to a value other than 'false' or '0'.
    #
    # This parameter will be ignored in PS 5+ in favour of using the
    # Expand-Archive built in PowerShell cmdlet directly.
    [Parameter(Mandatory = $false)]
    [switch]
    $UseNativeUnzip = $(
        $envVar = "$env:chocolateyUseWindowsCompression".Trim()
        $value = $null
        if ([bool]::TryParse($envVar, [ref] $value)) {
            $value
        } elseif ([int]::TryParse($envVar, [ref] $value)) {
            [bool]$value
        } else {
            [bool]$envVar
        }
    ),

    # If set, ignores any configured proxy. This will override any proxy
    # environment variables or parameters. This will be set by default if
    # $env:chocolateyIgnoreProxy is set to a value other than 'false' or '0'.
    [Parameter(Mandatory = $false)]
    [switch]
    $IgnoreProxy = $(
        $envVar = "$env:chocolateyIgnoreProxy".Trim()
        $value = $null
        if ([bool]::TryParse($envVar, [ref] $value)) {
            $value
        }
        elseif ([int]::TryParse($envVar, [ref] $value)) {
            [bool]$value
        }
        else {
            [bool]$envVar
        }
    ),

    # Specifies the proxy URL to use during the download. This will default to
    # the value of $env:chocolateyProxyLocation, if any is set.
    [Parameter(ParameterSetName = 'Proxy', Mandatory = $false)]
    [string]
    $ProxyUrl = $env:chocolateyProxyLocation,

    # Specifies the credential to use for an authenticated proxy. By default, a
    # proxy credential will be constructed from the $env:chocolateyProxyUser and
    # $env:chocolateyProxyPassword environment variables, if both are set.
    [Parameter(ParameterSetName = 'Proxy', Mandatory = $false)]
    [System.Management.Automation.PSCredential]
    $ProxyCredential
)

#region Functions

function Get-Downloader {
    <#
    .SYNOPSIS
    Gets a System.Net.WebClient that respects relevant proxies to be used for
    downloading data.

    .DESCRIPTION
    Retrieves a WebClient object that is pre-configured according to specified
    environment variables for any proxy and authentication for the proxy.
    Proxy information may be omitted if the target URL is considered to be
    bypassed by the proxy (originates from the local network.)

    .PARAMETER Url
    Target URL that the WebClient will be querying. This URL is not queried by
    the function, it is only a reference to determine if a proxy is needed.

    .EXAMPLE
    Get-Downloader -Url $fileUrl

    Verifies whether any proxy configuration is needed, and/or whether $fileUrl
    is a URL that would need to bypass the proxy, and then outputs the
    already-configured WebClient object.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [string]
        $Url,

        [Parameter(Mandatory = $false)]
        [string]
        $ProxyUrl,

        [Parameter(Mandatory = $false)]
        [System.Management.Automation.PSCredential]
        $ProxyCredential
    )

    $downloader = New-Object System.Net.WebClient

    $defaultCreds = [System.Net.CredentialCache]::DefaultCredentials
    if ($defaultCreds) {
        $downloader.Credentials = $defaultCreds
    }

    if (-not ($ProxyUrl -and $ProxyCredential)) {
        Write-Host "Not using proxy."
        $downloader.Proxy = $null
    }
    elseif ($ProxyUrl) {
        # Use explicitly set proxy.
        Write-Host "Using explicit proxy server '$ProxyUrl'."
        $proxy = New-Object System.Net.WebProxy -ArgumentList $ProxyUrl, <# bypassOnLocal: #> $true

        $proxy.Credentials = if ($ProxyCredential) {
            $ProxyCredential.GetNetworkCredential()
        } elseif ($defaultCreds) {
            $defaultCreds
        } else {
            Write-Warning "Default credentials were null, and no explicitly set proxy credentials were found. Attempting backup method."
            (Get-Credential).GetNetworkCredential()
        }

        if (-not $proxy.IsBypassed($Url)) {
            $downloader.Proxy = $proxy
        }
    } else {
        Write-Host "Not using a proxy for the download."
    }

    $downloader
}

function Request-String {
    <#
    .SYNOPSIS
    Downloads content from a remote server as a string.

    .DESCRIPTION
    Downloads target string content from a URL and outputs the resulting string.
    Any existing proxy that may be in use will be utilised.

    .PARAMETER Url
    URL to download string data from.

    .PARAMETER ProxyConfiguration
    A hashtable containing proxy parameters (ProxyUrl and ProxyCredential)

    .EXAMPLE
    Request-String https://chocolatey.org/install.ps1

    Retrieves the contents of the string data at the targeted URL and outputs
    it to the pipeline.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]
        $Url,

        [Parameter(Mandatory = $false)]
        [hashtable]
        $ProxyConfiguration
    )

    (Get-Downloader $url @ProxyConfiguration).DownloadString($url)
}

function Request-File {
    <#
    .SYNOPSIS
    Downloads a file from a given URL.

    .DESCRIPTION
    Downloads a target file from a URL to the specified local path.
    Any existing proxy that may be in use will be utilised.

    .PARAMETER Url
    URL of the file to download from the remote host.

    .PARAMETER File
    Local path for the file to be downloaded to.

    .PARAMETER ProxyConfiguration
    A hashtable containing proxy parameters (ProxyUrl and ProxyCredential)

    .EXAMPLE
    Request-File -Url https://chocolatey.org/install.ps1 -File $targetFile

    Downloads the install.ps1 script to the path specified in $targetFile.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [string]
        $Url,

        [Parameter(Mandatory = $false)]
        [string]
        $File,

        [Parameter(Mandatory = $false)]
        [hashtable]
        $ProxyConfiguration
    )

    Write-Host "Downloading $url to $file"
    (Get-Downloader $url @ProxyConfiguration).DownloadFile($url, $file)
}

function Set-PSConsoleWriter {
    <#
    .SYNOPSIS
    Workaround for a bug in output stream handling PS v2 or v3.

    .DESCRIPTION
    PowerShell v2/3 caches the output stream. Then it throws errors due to the
    FileStream not being what is expected. Fixes "The OS handle's position is
    not what FileStream expected. Do not use a handle simultaneously in one
    FileStream and in Win32 code or another FileStream." error.

    .EXAMPLE
    Set-PSConsoleWriter

    .NOTES
    General notes
    #>

    [CmdletBinding()]
    param()
    if ($PSVersionTable.PSVersion.Major -gt 3) {
        return
    }

    try {
        # http://www.leeholmes.com/blog/2008/07/30/workaround-the-os-handles-position-is-not-what-filestream-expected/ plus comments
        $bindingFlags = [Reflection.BindingFlags] "Instance,NonPublic,GetField"
        $objectRef = $host.GetType().GetField("externalHostRef", $bindingFlags).GetValue($host)

        $bindingFlags = [Reflection.BindingFlags] "Instance,NonPublic,GetProperty"
        $consoleHost = $objectRef.GetType().GetProperty("Value", $bindingFlags).GetValue($objectRef, @())
        [void] $consoleHost.GetType().GetProperty("IsStandardOutputRedirected", $bindingFlags).GetValue($consoleHost, @())

        $bindingFlags = [Reflection.BindingFlags] "Instance,NonPublic,GetField"
        $field = $consoleHost.GetType().GetField("standardOutputWriter", $bindingFlags)
        $field.SetValue($consoleHost, [Console]::Out)

        [void] $consoleHost.GetType().GetProperty("IsStandardErrorRedirected", $bindingFlags).GetValue($consoleHost, @())
        $field2 = $consoleHost.GetType().GetField("standardErrorWriter", $bindingFlags)
        $field2.SetValue($consoleHost, [Console]::Error)
    } catch {
        Write-Warning "Unable to apply redirection fix."
    }
}

function Test-ChocolateyInstalled {
    [CmdletBinding()]
    param()

    $checkPath = if ($env:ChocolateyInstall) { $env:ChocolateyInstall } else { 'C:\ProgramData\chocolatey' }

    if (Get-Command choco -CommandType Application -ErrorAction Ignore) {
        # choco is on the PATH, assume it's installed
        $true
    }
    elseif (-not (Test-Path $checkPath)) {
        # Install folder doesn't exist
        $false
    }
    elseif (-not ((Get-ChildItem -Path $checkPath).Count -gt 1)) {
        # Install folder exists but is empty
        $false
    }
    else {
        # Install folder exists and is not empty
        $true
    }
}

function Install-7zip {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]
        $Path,

        [Parameter(Mandatory = $false)]
        [hashtable]
        $ProxyConfiguration
    )

    if (-not (Test-Path ($Path))) {
        Write-Host "Downloading 7-Zip commandline tool prior to extraction."
        Request-File -Url 'https://chocolatey.org/7za.exe' -File $Path -ProxyConfiguration $ProxyConfiguration

    }
    else {
        Write-Host "7zip already present, skipping installation."
    }
}

#endregion Functions

#region Pre-check

# Ensure we have all our streams setup correctly, needed for older PSVersions.
Set-PSConsoleWriter

if (Test-ChocolateyInstalled) {
    $message = @(
        "An existing Chocolatey installation was detected. Installation will not continue."
        "For security reasons, this script will not overwrite existing installations."
        ""
        "Please use `choco upgrade chocolatey` to handle upgrades of Chocolatey itself."
    ) -join [Environment]::NewLine

    Write-Warning $message

    return
}

#endregion Pre-check

#region Setup

$proxyConfig = if ($IgnoreProxy -or -not $ProxyUrl) {
    @{}
} else {
    $config = @{
        ProxyUrl = $ProxyUrl
    }

    if ($ProxyCredential) {
        $config['ProxyCredential'] = $ProxyCredential
    } elseif ($env:chocolateyProxyUser -and $env:chocolateyProxyPassword) {
        $securePass = ConvertTo-SecureString $env:chocolateyProxyPassword -AsPlainText -Force
        $config['ProxyCredential'] = [System.Management.Automation.PSCredential]::new($env:chocolateyProxyUser, $securePass)
    }

    $config
}

# Attempt to set highest encryption available for SecurityProtocol.
# PowerShell will not set this by default (until maybe .NET 4.6.x). This
# will typically produce a message for PowerShell v2 (just an info
# message though)
try {
    # Set TLS 1.2 (3072) as that is the minimum required by Chocolatey.org.
    # Use integers because the enumeration value for TLS 1.2 won't exist
    # in .NET 4.0, even though they are addressable if .NET 4.5+ is
    # installed (.NET 4.5 is an in-place upgrade).
    Write-Host "Forcing web requests to allow TLS v1.2 (Required for requests to Chocolatey.org)"
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
}
catch {
    $errorMessage = @(
        'Unable to set PowerShell to use TLS 1.2. This is required for contacting Chocolatey as of 03 FEB 2020.'
        'https://chocolatey.org/blog/remove-support-for-old-tls-versions.'
        'If you see underlying connection closed or trust errors, you may need to do one or more of the following:'
        '(1) upgrade to .NET Framework 4.5+ and PowerShell v3+,'
        '(2) Call [System.Net.ServicePointManager]::SecurityProtocol = 3072; in PowerShell prior to attempting installation,'
        '(3) specify internal Chocolatey package location (set $env:chocolateyDownloadUrl prior to install or host the package internally),'
        '(4) use the Download + PowerShell method of install.'
        'See https://chocolatey.org/docs/installation for all install options.'
    ) -join [Environment]::NewLine
    Write-Warning $errorMessage
}

if ($ChocolateyDownloadUrl) {
    if ($ChocolateyVersion) {
        Write-Warning "Ignoring -ChocolateyVersion parameter ($ChocolateyVersion) because -ChocolateyDownloadUrl is set."
    }

    Write-Host "Downloading Chocolatey from: $ChocolateyDownloadUrl"
} elseif ($ChocolateyVersion) {
    Write-Host "Downloading specific version of Chocolatey: $ChocolateyVersion"
    $ChocolateyDownloadUrl = "https://chocolatey.org/api/v2/package/chocolatey/$ChocolateyVersion"
} else {
    Write-Host "Getting latest version of the Chocolatey package for download."
    $queryString = [uri]::EscapeUriString("((Id eq 'chocolatey') and (not IsPrerelease)) and IsLatestVersion")
    $queryUrl = 'https://chocolatey.org/api/v2/Packages()?$filter={0}' -f $queryString

    [xml]$result = Request-String -Url $queryUrl -ProxyConfiguration $proxyConfig
    $ChocolateyDownloadUrl = $result.feed.entry.content.src
}

if (-not $env:TEMP) {
    $env:TEMP = Join-Path $env:SystemDrive -ChildPath 'temp'
}

$chocoTempDir = Join-Path $env:TEMP -ChildPath "chocolatey"
$tempDir = Join-Path $chocoTempDir -ChildPath "chocoInstall"

if (-not (Test-Path $tempDir -PathType Container)) {
    $null = New-Item -Path $tempDir -ItemType Directory
}

$file = Join-Path $tempDir "chocolatey.zip"

#endregion Setup

#region Download & Extract Chocolatey

Write-Host "Getting Chocolatey from $ChocolateyDownloadUrl."
Request-File -Url $ChocolateyDownloadUrl -File $file -ProxyConfiguration $proxyConfig

Write-Host "Extracting $file to $tempDir"
if ($PSVersionTable.PSVersion.Major -lt 5) {
    # Determine unzipping method
    # 7zip is the most compatible pre-PSv5.1 so use it unless asked to use builtin
    if ($UseNativeUnzip) {
        Write-Host 'Using built-in compression to unzip'

        try {
            $shellApplication = New-Object -ComObject Shell.Application
            $zipPackage = $shellApplication.NameSpace($file)
            $destinationFolder = $shellApplication.NameSpace($tempDir)
            $destinationFolder.CopyHere($zipPackage.Items(), 0x10)
        } catch {
            Write-Warning "Unable to unzip package using built-in compression. Set `$env:chocolateyUseWindowsCompression = ''` or omit -UseNativeUnzip and retry to use 7zip to unzip."
            throw $_
        }
    } else {
        $7zaExe = Join-Path $tempDir -ChildPath '7za.exe'
        Install-7zip -Path $7zaExe -ProxyConfiguration $proxyConfig

        $params = 'x -o"{0}" -bd -y "{1}"' -f $tempDir, $file

        # use more robust Process as compared to Start-Process -Wait (which doesn't
        # wait for the process to finish in PowerShell v3)
        $process = New-Object System.Diagnostics.Process

        try {
            $process.StartInfo = New-Object System.Diagnostics.ProcessStartInfo -ArgumentList $7zaExe, $params
            $process.StartInfo.RedirectStandardOutput = $true
            $process.StartInfo.UseShellExecute = $false
            $process.StartInfo.WindowStyle = [System.Diagnostics.ProcessWindowStyle]::Hidden

            $null = $process.Start()
            $process.BeginOutputReadLine()
            $process.WaitForExit()

            $exitCode = $process.ExitCode
        }
        finally {
            $process.Dispose()
        }

        $errorMessage = "Unable to unzip package using 7zip. Perhaps try setting `$env:chocolateyUseWindowsCompression = 'true' and call install again. Error:"
        if ($exitCode -ne 0) {
            $errorDetails = switch ($exitCode) {
                1 { "Some files could not be extracted" }
                2 { "7-Zip encountered a fatal error while extracting the files" }
                7 { "7-Zip command line error" }
                8 { "7-Zip out of memory" }
                255 { "Extraction cancelled by the user" }
                default { "7-Zip signalled an unknown error (code $exitCode)" }
            }

            throw ($errorMessage, $errorDetails -join [Environment]::NewLine)
        }
    }
} else {
    Microsoft.PowerShell.Archive\Expand-Archive -Path $file -DestinationPath $tempDir -Force
}

#endregion Download & Extract Chocolatey

#region Install Chocolatey

Write-Host "Installing Chocolatey on the local machine"
$toolsFolder = Join-Path $tempDir -ChildPath "tools"
$chocoInstallPS1 = Join-Path $toolsFolder -ChildPath "chocolateyInstall.ps1"

& $chocoInstallPS1

Write-Host 'Ensuring Chocolatey commands are on the path'
$chocoInstallVariableName = "ChocolateyInstall"
$chocoPath = [Environment]::GetEnvironmentVariable($chocoInstallVariableName)

if (-not $chocoPath) {
    $chocoPath = "$env:ALLUSERSPROFILE\Chocolatey"
}

if (-not (Test-Path ($chocoPath))) {
    $chocoPath = "$env:SYSTEMDRIVE\ProgramData\Chocolatey"
}

$chocoExePath = Join-Path $chocoPath -ChildPath 'bin'

# Update current process PATH environment variable if it needs updating.
if ($env:Path -notlike "*$chocoExePath*") {
    $env:Path = [Environment]::GetEnvironmentVariable('Path', [System.EnvironmentVariableTarget]::Machine);
}

Write-Host 'Ensuring chocolatey.nupkg is in the lib folder'
$chocoPkgDir = Join-Path $chocoPath -ChildPath 'lib\chocolatey'
$nupkg = Join-Path $chocoPkgDir -ChildPath 'chocolatey.nupkg'

if (-not (Test-Path $chocoPkgDir -PathType Container)) {
    $null = New-Item -ItemType Directory -Path $chocoPkgDir
}

Copy-Item -Path $file -Destination $nupkg -Force -ErrorAction SilentlyContinue

#endregion Install Chocolatey

