<#
.DESCRIPTION
    Utilities used by artifacts that facilitate packages restore and running a command in the initialized development environment.
#>

function Get-EndpointCredential([string]$NugetPackagesSourceUrl, [string]$NugetPackagesSourceSecret) {
    return "{`"endpoint`":`"$NugetPackagesSourceUrl`", `"username`":`"notused`", `"password`":`"$NugetPackagesSourceSecret`"}"
}

function Clear-RepoChanges() {
    if ($userNpmrc) {
        Write-Host "Removing temporary file $userNpmrc"
        Remove-Item $userNpmrc -Force -ErrorAction SilentlyContinue
    }

    Write-Host "Revert temporary changes to .npmrc files"
    Set-Location $RepoRoot

    # Cleaning a repo, even it fails, should not affect the artifact's execution. Therefore redirect stderr to stdout and reset LASTEXITCODE on failure.
    $gitResetOutput = & cmd.exe /c "git reset --hard 2>>&1"
    $gitResetOutputTrimmed = $gitResetOutput.Split([Environment]::NewLine) | Select-Object -Last 100
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Failed to reset the repo with exit code $LASTEXITCODE : $gitResetOutputTrimmed"
        & cmd.exe /c "echo Reset last exit code to 0"
    }
    else {
        Write-Host "Repo reset successfully."
    }
}

enum RepoKind {
    MSBuild
    Custom
}

function Get-CanUseManagedIdentityForPackagesFeed {
    param(
        [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][String] $PackagesFeedUrl
    )

    return ($PackagesFeedUrl -Match '^https://[a-zA-Z][\w\-_]*\.pkgs\.visualstudio\.com/.*' -or $PackagesFeedUrl -Match '^https://pkgs\.dev\.azure\.com/.*')
}

function SetPackagesRestoreEnvironmentAndRunScript {
    param(
        # Full path to the repo's root directory.
        [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][String] $RepoRoot,
        # Kind of the repo to restore
        [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][RepoKind] $RepoKind,
        # Passed to 'cmd.exe /c' for execution after the environment for restoring packages is configured.
        [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][String] $Script,
        # When provided, used for getting packages from repo's packaging feed which is expected to be in the same Azure DevOps org as the git repo.
        [Parameter(Mandatory = $false)][String] $RepoPackagesFeed,
        # Optional comma separated list of feeds to use during repo setup/build that won't be discovered automatically by the logic below. All feeds in the list are expected to belong to same Azure DeOps org.
        [Parameter(Mandatory = $false)][String] $AdditionalRepoFeeds,
        # Environment variables to set temporarily during the script execution
        [Parameter(Mandatory = $false)][Array] $AdditionalEnvVars
    )

    if ($RepoKind -ne [RepoKind]::Custom) {
        Write-Host "Attempting to discover repo's packaging feed from nuget.config" 
        $nugetConfigPath = Join-Path $RepoRoot "nuget.config"
        if (-not (Test-Path -Path $nugetConfigPath -PathType Leaf)) {
            throw "nuget.config for repository is not found at $nugetConfigPath"
        }
    
        $nugetConfigSources = @(Select-Xml -Path $nugetConfigPath -XPath "/configuration/packageSources/add" | ForEach-Object { $_.Node.Value } | Select-Object -Unique)
        if ($nugetConfigSources.Count -eq 0) {
            throw "No nuget package sources were detected in $nugetConfigPath with content $(Get-Content $nugetConfigPath)"
        }
    
        if ($nugetConfigSources.Count -ne 1) {
            throw "More than 1 nuget package source is detected in $nugetConfigPath with content $(Get-Content $nugetConfigPath)"
        }
    
        $RepoPackagesFeed = $nugetConfigSources[0]
        Write-Host "Configuring access for nuget package source $RepoPackagesFeed detected in $nugetConfigPath"
    }

    $useManagedIdentity = $RepoPackagesFeed -and (Get-CanUseManagedIdentityForPackagesFeed -PackagesFeedUrl $RepoPackagesFeed)
    if ($useManagedIdentity) {
        Import-Module -Force (Join-Path $PSScriptRoot 'windows-azure-managed-identity-utils.psm1')
        $azDevOpsAccessToken = Get-AzureDevOpsAccessToken

        $endpointCredentials = @($(Get-EndpointCredential $RepoPackagesFeed $azDevOpsAccessToken))
        if (-not [string]::IsNullOrEmpty($AdditionalRepoFeeds)) {
            $endpointCredentials += ($AdditionalRepoFeeds -Split ',') | ForEach-Object { (Get-EndpointCredential $_ $effectiveAdditionalRepoFeedsPAT) }
        }

        $env:VSS_NUGET_EXTERNAL_FEED_ENDPOINTS = "{`"endpointCredentials`": [$($endpointCredentials -join ',')]}"

        Write-Host "Configured VSS_NUGET_EXTERNAL_FEED_ENDPOINTS environment variable for feeds:"
        ($env:VSS_NUGET_EXTERNAL_FEED_ENDPOINTS | ConvertFrom-Json).endpointCredentials | ForEach-Object { "    '$($_.endpoint)'" }

        # Set up this older env var as well for older credential providers and for other cases that a repo might it.
        $env:VSS_NUGET_ACCESSTOKEN = $azDevOpsAccessToken

        # In case this repo uses NPM, search through all .npmrc files for names of feeds from the same org as the repo Nuget packages source. Feeds from other ADO orgs are ignored at the moment.
        # Feed urls could have the following prefixes: https://pkgs.dev.azure.com/{org_name}/..., https://{org_name}.pkgs.visualstudio.com/...
        $feedProjectNames = @()
        $repoPackagesSourceUrl = [System.Uri] $RepoPackagesFeed
        if ($repoPackagesSourceUrl.Host -eq "pkgs.dev.azure.com") {
            # Sample resulting value: pkgs.dev.azure.com/{org_name}
            $feedsOrgUrlPrefix = "$($repoPackagesSourceUrl.Host)/$($repoPackagesSourceUrl.Segments[1])".Trim('/')
        }
        else {
            # Sample resulting value: {org_name}.pkgs.visualstudio.com
            $feedsOrgUrlPrefix = $repoPackagesSourceUrl.Host
        }

        Write-Host "Looking for feeds in .npmrc files from $feedsOrgUrlPrefix ADO org. Feeds from other orgs or in different formats will be ignored ..."
        $npmRegistryMatches = @(Get-ChildItem -Recurse -File -Path (Join-Path $RepoRoot '.npmrc') | Select-String -Pattern "registry=https://$feedsOrgUrlPrefix/(?<ProjectNameOrGuid>([\w\d-]+/)?)_packaging/(?<FeedName>[^\/]*)/")

        # Flatten found matches into a single array and get only unique feed names
        @(@($npmRegistryMatches | ForEach-Object { $_.Matches }) | ForEach-Object {
                $feedProjectNames += 
            (@{
                    FeedName    = $_.Groups['FeedName'].Value
                    ProjectName = $_.Groups['ProjectNameOrGuid'].Value
                });
            })

        $feedProjectNames = $feedProjectNames | Sort-Object -Property { $_.FeedName } -Unique
        $userNpmrc = Join-Path $env:USERPROFILE ".npmrc"
        if ($feedProjectNames.Length -gt 0) {
            # Create a temporary NPM configuration file contaning the access token that allows node.exe to authenticate to repo's packages source.
            Write-Host "Configuring '$userNpmrc' with ADO org '$feedsOrgUrlPrefix' and project/feed pair(s) '$(($feedProjectNames | ForEach-Object {$_.ProjectName + $_.FeedName}) -join ',')'"
            $feedProjectNames | ForEach-Object { (
                    "//$feedsOrgUrlPrefix/$($_.ProjectName)_packaging/$($_.FeedName)/npm/registry/:username=notused",
                    "//$feedsOrgUrlPrefix/$($_.ProjectName)_packaging/$($_.FeedName)/npm/registry/:_authToken=$azDevOpsAccessToken",
                    "//$feedsOrgUrlPrefix/$($_.ProjectName)_packaging/$($_.FeedName)/npm/registry/:email=notused"
                ) } | Set-Content $userNpmrc -Encoding Ascii
        }
    }
    
    try {
        foreach ($additionalEnvVar in $AdditionalEnvVars) {
            Write-Host "Temporarily setting environment variable $($additionalEnvVar.Name)"
            Set-Item "env:$($additionalEnvVar.Name)" $additionalEnvVar.Value
        }

        # Simply invoking '& cmd.exe /c ...' doesn't set $LASTEXITCODE to the exit code of cmd.exe. Use Start-Process instead
        Write-Host "Executing command: $Script"
        $scriptExitCode = (Start-Process -FilePath "cmd.exe" -ArgumentList "/c $Script" -Wait -Passthru -NoNewWindow).ExitCode
        if ($scriptExitCode -ne 0) {
            throw "Failed with exit code $scriptExitCode : $scriptLine"
        }
    }
    catch {
        Clear-RepoChanges
        Throw
    }

    Clear-RepoChanges
}