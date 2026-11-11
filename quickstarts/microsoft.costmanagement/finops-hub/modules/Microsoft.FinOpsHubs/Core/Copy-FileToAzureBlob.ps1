# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

Write-Output "Updating settings.json file..."
Write-Output "  Storage account: $env:storageAccountName"
Write-Output "  Container: $env:containerName"

$validateScopes = { $_.scope.Length -gt 45 }

# Initialize variables
$fileName = 'settings.json'
$filePath = Join-Path -Path . -ChildPath $fileName
$newScopes = $env:scopes.Split('|') | ForEach-Object { [PSCustomObject]@{ scope = $_ } } | Where-Object $validateScopes

# Get storage context
$storageContext = @{
    Context   = New-AzStorageContext -StorageAccountName $env:storageAccountName -UseConnectedAccount
    Container = $env:containerName
}

# Download existing settings, if they exist
$blob = Get-AzStorageBlobContent @storageContext -Blob $fileName -Destination $filePath -Force
if ($blob)
{
    $text = Get-Content $filePath -Raw
    Write-Output "---------"
    Write-Output $text
    Write-Output "---------"
    $json = $text | ConvertFrom-Json
    Write-Output "Existing settings.json file found. Updating..."

    # Rename exportScopes to scopes + convert to object array
    if ($json.exportScopes)
    {
        Write-Output "  Updating exportScopes..."
        if ($json.exportScopes[0] -is [string])
        {
            Write-Output "    Converting string array to object array..."
            $json.exportScopes = @($json.exportScopes | Where-Object $validateScopes | ForEach-Object { @{ scope = $_ } })
            if (-not ($json.exportScopes -is [array]))
            {
                Write-Output "    Converting single object to object array..."
                $json.exportScopes = @($json.exportScopes)
            }
        }

        Write-Output "    Renaming to 'scopes'..."
        $json | Add-Member -MemberType NoteProperty -Name scopes -Value $json.exportScopes
        $json.PSObject.Properties.Remove('exportScopes')
    }

    # Force string array to object array with unique values
    if ($json.scopes)
    {
        Write-Output "  Converting string array to object array..."
        $scopeArray = @()
        $json.scopes | Where-Object $validateScopes | ForEach-Object { $scopeArray += $_ } | Select-Object -Unique
        $json.scopes = @() + $scopeArray
    }
}

# Set default if not found
if (!$json)
{
    Write-Output "No existing settings.json file found. Creating new file..."
    $json = [ordered]@{
        '$schema' = 'https://aka.ms/finops/hubs/settings-schema'
        type      = 'HubInstance'
        version   = ''
        learnMore = 'https://aka.ms/finops/hubs'
        scopes    = @()
        retention = @{
            'msexports' = @{
                days = 0
            }
            'ingestion' = @{
                months = 13
            }
            'raw'       = @{
                days = 0
            }
            'final'     = @{
                months = 13
            }
        }
    }

    $text = $json | ConvertTo-Json
    Write-Output "---------"
    Write-Output $text
    Write-Output "---------"
}

# Set default retention
if (!($json.retention))
{
    # In case the retention object is not present in the settings.json file (versions before 0.4), add it with default values
    $retention = @"
    {
        "msexports": {
            "days": 0
        },
        "ingestion": {
            "months": 13
        },
        "raw": {
            "days": 0
        },
        "final": {
            "months": 13
        }
    }
"@
    $json | Add-Member -Name retention -Value (ConvertFrom-Json $retention) -MemberType NoteProperty
}

# Set retention
# NOTE: The template only passes retention values the deployment specifies. When a value isn't passed, keep the stored
# value (or the default for new hubs) so a redeploy or upgrade never resets retention (#2206, #2348).
function Set-Retention([string] $Name, [string] $Unit, [int] $Default, [string] $Requested)
{
    if (!($json.retention.$Name))
    {
        $json.retention | Add-Member -Name $Name -Value ([PSCustomObject]@{ $Unit = $Default }) -MemberType NoteProperty -Force
    }
    if (-not [string]::IsNullOrWhiteSpace($Requested))
    {
        Write-Output "  Setting $Name retention to $Requested $Unit..."
        $json.retention.$Name.$Unit = [Int32]::Parse($Requested)
    }
    else
    {
        Write-Output "  Keeping $Name retention at $($json.retention.$Name.$Unit) $Unit..."
    }
}
Set-Retention -Name msexports -Unit days   -Default 0  -Requested $env:msexportRetentionInDays
Set-Retention -Name ingestion -Unit months -Default 13 -Requested $env:ingestionRetentionInMonths
Set-Retention -Name raw       -Unit days   -Default 0  -Requested $env:rawRetentionInDays
Set-Retention -Name final     -Unit months -Default 13 -Requested $env:finalRetentionInMonths

# Updating settings
Write-Output "Updating version to $env:ftkVersion..."
$json.version = $env:ftkVersion
$json.scopes = ($json.scopes + $newScopes) | Sort-Object scope -Unique
if ($null -eq $json.scopes) { $json.scopes = @() }
$text = $json | ConvertTo-Json
Write-Output "---------"
Write-Output $text
Write-Output "---------"
$text | Out-File $filePath

# Upload new/updated settings
Write-Output "Uploading settings.json file..."
Set-AzStorageBlobContent @storageContext -File $filePath -Force | Out-Null

# Return the effective raw retention so the Data Explorer setup applies the stored value
$DeploymentScriptOutputs = @{
    rawRetentionInDays = [Int32]$json.retention.raw.days
}
