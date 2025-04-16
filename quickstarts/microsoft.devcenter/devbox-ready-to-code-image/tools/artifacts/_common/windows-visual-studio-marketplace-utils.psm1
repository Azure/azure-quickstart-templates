$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest
$ProgressPreference = 'SilentlyContinue'

Import-Module -Force (Join-Path $(Split-Path -Parent $PSScriptRoot) '_common/windows-retry-utils.psm1')

# Function: Get-VisualStudioExtension
# Description: Downloads a specified extension and all dependencies (Visual Studio or VS Code) from
# the Marketplace and returns a list of local paths.
function Get-VisualStudioExtension {
    param (
        [Parameter(Mandatory = $true)] [string]$ExtensionReference,
        [Parameter(Mandatory = $false)] [string]$VersionNumber,
        [Parameter(Mandatory = $true)] [string]$DownloadLocation,
        [Parameter(Mandatory = $false)] [bool]$DownloadDependencies = $true,
        [Parameter(Mandatory = $false)] [bool]$DownloadPreRelease = $false
    )
    $localPaths = [System.Collections.ArrayList]@()
    $targetPlatform = Get-CurrentPlatform

    try {
        Get-ExtensionMetadataDependencyTree -ExtensionReference $ExtensionReference `
            -VersionNumber $VersionNumber `
            -TargetPlatform $targetPlatform `
            -DownloadDependencies $DownloadDependencies `
            -DownloadPreRelease $DownloadPreRelease | ForEach-Object {
            $localPaths.Add((Import-ExtensionByMetadata -ExtensionMetadata $_ -DownloadLocation $DownloadLocation)) | Out-Null
        }

        return $localPaths
    }
    catch {
        throw "Failed to retrieve or save VSIX file for extension '$ExtensionReference' or its dependencies: $_"
    }
}

# Function: Get-ApiHeaders
# Description: Constructs the headers required for the Marketplace API request.
function Get-ApiHeaders {
    return @{
        "Accept"       = "application/json;api-version=3.0-preview.1"
        "Content-Type" = "application/json"
    }
}

# Function: Get-ApiFlags
# Description: Constructs the flags for the Marketplace API request.
# Flags:
#   - 2: Include Extension Metadata
#   - 16: Include Extension Properties
#   - 128: Include Asset URI
#   - 256: Include Files in the Response
function Get-ApiFlags {
    $flags = 2 -bor 16 -bor 128 -bor 256  # Base flags using bitwise
    return $flags
}

# Function: Get-RequestBody
# Description: Constructs the request body for the Marketplace API.
function Get-RequestBody {
    param (
        [Parameter(Mandatory = $true)] [string]$ExtensionReference,
        [Parameter(Mandatory = $true)] [int]$Flags
    )
    return @{
        filters = @(@{
                criteria = @(@{
                        filterType = 7  # Filter type 7: Search by extension id
                        value      = $ExtensionReference
                    })
            })
        flags   = $Flags
    } | ConvertTo-Json -Depth 10
}

# Function: Invoke-MarketplaceApi
# Description: Sends a POST request to the Marketplace API and returns the response.
function Invoke-MarketplaceApi {
    param (
        [Parameter(Mandatory = $true)] [string]$ApiUrl,
        [Parameter(Mandatory = $true)] [hashtable]$Headers,
        [Parameter(Mandatory = $true)] [string]$Body
    )
    return RunWithRetries -runBlock {
        return Invoke-RestMethod -Uri $ApiUrl -Method Post -Headers $Headers -Body $Body -MaximumRedirection 10
    } -retryAttempts 3 -waitBeforeRetrySeconds 5 -exponentialBackoff        
}

# Function: Get-ExtensionMetadataDependencyTree
# Description: Provided with a VSIX name and version, find all metadata for the extension and its dependencies.
function Get-ExtensionMetadataDependencyTree {
    param (
        [Parameter(Mandatory = $true)] [string]$ExtensionReference,
        [Parameter(Mandatory = $false)] [string]$VersionNumber,
        [Parameter(Mandatory = $true)] [string]$TargetPlatform,
        [Parameter(Mandatory = $false)] [bool]$DownloadDependencies = $false,
        [Parameter(Mandatory = $false)] [bool]$DownloadPreRelease = $false
    )
    $processedDependencies = @{}
    $toProcess = @($ExtensionReference)
    $extensionMetadataList = [System.Collections.ArrayList]@()

    while ($toProcess.Count -gt 0) {
        # Dequeue the next extension reference
        $currentDependency = $toProcess[0]
        $toProcess = if ($toProcess.Count -gt 1) { , @($toProcess[1..($toProcess.Count - 1)]) } else { , @() }

        # Skip if already processed
        if ($processedDependencies.ContainsKey($currentDependency)) {
            continue
        }

        # Mark as processed
        $processedDependencies[$currentDependency] = $true

        # Fetch extension metadata
        $extensionMetadata = Get-ExtensionMetadata -ExtensionReference $currentDependency `
            -VersionNumber $VersionNumber `
            -TargetPlatform $TargetPlatform `
            -DownloadPreRelease $DownloadPreRelease

        if ($extensionMetadata) {
            $extensionMetadataList += $extensionMetadata
        }

        if (-not $DownloadDependencies) {
            break;
        }

        # Add dependencies to the processing queue
        if ($extensionMetadata) {
            foreach ($dependency in $extensionMetadata.dependencies) {
                if ($dependency -and (-not $processedDependencies.ContainsKey($dependency))) {
                    $toProcess += $dependency
                }
            }
        }
    }

    return $extensionMetadataList
}

# Function: Import-RemoteVisualStudioPackageToPath
# Description: Download a remote VSIX to the local machine.
function Import-RemoteVisualStudioPackageToPath {
    param (
        [Parameter(Mandatory = $true)] [string]$VsixUrl,
        [Parameter(Mandatory = $true)] [string]$LocalFilePath
    )
    Write-Host "Downloading VSIX from URL: $vsixUrl"
    Invoke-WebRequest -Uri $VsixUrl -OutFile $LocalFilePath -MaximumRedirection 10
    Write-Host "Downloaded VSIX to: $localFilePath"

    # Validate the downloaded file
    if (-not (Test-Path $LocalFilePath)) {
        throw "The file was not downloaded. Ensure the URL is correct and accessible: $VsixUrl"
    }

    $fileInfo = Get-Item -Path $LocalFilePath
    $fileSizeBytes = $fileInfo.Length

    if ($fileSizeBytes -le 0) {
        throw "The downloaded file is empty or corrupt (size: 0 bytes): $LocalFilePath"
    }

    $fileSizeKB = [math]::Round($fileSizeBytes / 1KB, 2)
    Write-Host "Downloaded file size: $fileSizeKB KB"
}

# Function: Get-CurrentPlatform
# Determine the target platform of the current machine
function Get-CurrentPlatform {
    $processorArch = $null
    
    try {
        $processorArch = (Get-CimInstance -ClassName Win32_Processor).Architecture
    }
    catch {
        Write-Host "Processor architecture could not be determined, assuming x64."
    }

    if ($processorArch -eq 12) {
        $targetPlatform = "win32-arm64"
    }
    else {
        $targetPlatform = "win32-x64"
    }

    Write-Host "Current machine target platform: $targetPlatform"
    return $targetPlatform
}

# Function: Get-ExtensionMetadata
# Description: Fetches extension metadata for a given extension.
function Get-ExtensionMetadata {
    param (
        [Parameter(Mandatory = $true)] [string]$ExtensionReference,
        [Parameter(Mandatory = $false)] [string]$VersionNumber,
        [Parameter(Mandatory = $true)] [string]$TargetPlatform,
        [Parameter(Mandatory = $false)] [bool]$DownloadPreRelease = $false
    )
    # Define base API URL (same for both Visual Studio and VS Code)
    $baseApiUrl = "https://marketplace.visualstudio.com/_apis/public/gallery/extensionquery"

    # Call helper methods to construct headers and request body
    $headers = Get-ApiHeaders
    $flags = Get-ApiFlags
    $body = Get-RequestBody -ExtensionReference $ExtensionReference -Flags $flags
    $response = Invoke-MarketplaceApi -ApiUrl $baseApiUrl -Headers $headers -Body $body

    if ((!($response.results)) -or (!$response.results[0].extensions)) {
        Write-Host "Skipping presumably built-in extension $ExtensionReference"
        return $null
    }

    if ($response.results.Count -gt 1) {
        throw "Expected to receive only a single result in the metadata for '$ExtensionReference'."
    }

    $extensionVersions = @()
    try {
        # Extract versions of the extension from the response
        $extensionVersions = @($response.results[0].extensions[0].versions)

        if (-not $extensionVersions) {
            throw "No versions found for extension '$ExtensionReference'."
        }
    }
    catch {
        throw "Property 'versions' is missing or inaccessible in the Marketplace API response. Ensure you have provided a valid extension id. $_"
    }

    # Filter for the versions matching the current machine's platform (e.g. x64 or ARM64)
    # Empty or missing target platforms are considered "Universal" versions
    $extensionVersions = $extensionVersions | Where-Object {
        # Check if 'targetPlatform' exists dynamically
        $hasTargetPlatform = $_.PSObject.Properties.Name -contains 'targetPlatform'

        # If 'targetPlatform' exists, evaluate it; otherwise, treat as "Universal"
        (-not $hasTargetPlatform) -or
        ($_.targetPlatform -eq $TargetPlatform) -or
        [string]::IsNullOrWhiteSpace($_.targetPlatform)
    }

    # Filter by version number if provided, else use the latest version
    $versionInfos = if ($VersionNumber) {
        $extensionVersions | Where-Object { $_.version -eq $VersionNumber }
    }
    else {
        $extensionVersions
    }

    $foundVersionInfo = $null;
    
    foreach ($versionInfo in $versionInfos) {
        # Find the Vsix file URL in the response
        try {
            $vsixUrl = ($versionInfo.files |
                Where-Object { $_.assetType -eq "Microsoft.VisualStudio.Services.VSIXPackage" } |
                Select-Object -First 1).source
        }
        catch {
            throw "No VSIXPackage was found in the file list for the extension metadata. Verify the extension and version specified are correct. $_"
        }

        if ([string]::IsNullOrWhiteSpace($VersionNumber)) {
            $VersionNumber = "Not specified"
        }
        
        if (-not $vsixUrl) {
            throw "VSIX download URL not found for extension '$ExtensionReference' version '$VersionNumber'. Please validate this is a VS Code extension."
        }

        $isPreReleaseRef = ($versionInfo.properties |
            Where-Object { $_.key -eq "Microsoft.VisualStudio.Code.PreRelease" } |
            Select-Object -First 1)
        $isPreRelease = if ($isPreReleaseRef) { $isPreReleaseRef.value -eq "true" } else { $false }

        if ($isPreRelease -and (-not $DownloadPreRelease)) {
            continue;
        }

        $vsixDependenciesRef = ($versionInfo.properties |
            Where-Object { $_.key -eq "Microsoft.VisualStudio.Code.ExtensionDependencies" } |
            Select-Object -First 1)
        $vsixDependencies = if ($vsixDependenciesRef) { $vsixDependenciesRef.value -split ',' } else { @() }
        
        $vsixExtensionPackRef = ($versionInfo.properties |
            Where-Object { $_.key -eq "Microsoft.VisualStudio.Code.ExtensionPack" } |
            Select-Object -First 1)
        $vsixExtensionPack = if ($vsixExtensionPackRef) { $vsixExtensionPackRef.value -split ',' } else { @() }

        $allDependencies = ($vsixDependencies + $vsixExtensionPack) | Select-Object -Unique

        $foundVersionInfo = $versionInfo;
        break;
    }

    if (-not $foundVersionInfo) {
        $foundVersions = ($extensionVersions | Select-Object -First 10 | ForEach-Object { '({0})' -f $_.version }) -join ", "
        throw "Extension '$ExtensionReference' version '$VersionNumber' not found for '$TargetPlatform'. Latest 10 versions found: $foundVersions"
    }

    # Log the version being used
    $foundVersion = $foundVersionInfo.version
    $foundTargetPlatform = if ($foundVersionInfo.PSObject.Properties.Match("targetPlatform").Count -gt 0) { $foundVersionInfo.targetPlatform -join "," } else { "universal" }
    Write-Host "Found $ExtensionReference version $foundVersion, target platform: $foundTargetPlatform"

    return @{
        name         = $ExtensionReference;
        vsixUrl      = $vsixUrl;
        dependencies = $allDependencies;
    }
}

# Function: Import-ExtensionByMetadata
# Description: Processes the Marketplace API response returns a local path for the downloaded file.
function Import-ExtensionByMetadata {
    param (
        [Parameter(Mandatory = $true)] [object]$ExtensionMetadata,
        [Parameter(Mandatory = $true)] [string]$DownloadLocation
    )
    $tempFolder = [IO.Path]::GetTempPath()

    # Rename the file during the copy process to ensure its extension is `.vsix`.
    # For example, files downloaded from the Visual Studio Marketplace often have a `.VSIXPackage` extension,
    # which must be renamed to `.vsix` for the VS Code bootstrapper to recognize them correctly.
    $localFileName = $ExtensionMetadata.name + ".vsix"
    $localFilePath = Join-Path $tempFolder $localFileName
    $destinationFile = Join-Path -Path $DownloadLocation -ChildPath $localFileName

    if (-not (Test-Path $destinationFile)) {
        RunWithRetries -runBlock {
            Import-RemoteVisualStudioPackageToPath -VsixUrl $ExtensionMetadata.vsixUrl -LocalFilePath $localFilePath
        } -retryAttempts 3 -waitBeforeRetrySeconds 5 -exponentialBackoff

        # Copy to the final location
        RunWithRetries -runBlock {
            Write-Host "Copying $localFilePath to $destinationFile"
            Copy-Item -Path $localFilePath -Destination $destinationFile -Force
        } -retryAttempts 3 -waitBeforeRetrySeconds 5 -exponentialBackoff
    }
    else {
        Write-Host "VSIX already exists: $destinationFile"
    }

    return $destinationFile
}

if ((Test-Path variable:global:IsUnderTest) -and $global:IsUnderTest) {
    Export-ModuleMember -Function *
}
else {
    Export-ModuleMember -Function Get-VisualStudioExtension
    Export-ModuleMember -Function Import-RemoteVisualStudioPackageToPath
}
