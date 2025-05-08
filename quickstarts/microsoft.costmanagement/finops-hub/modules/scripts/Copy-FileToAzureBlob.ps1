# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

Write-Output "Updating settings.json file..."
Write-Output "  Storage account: $env:storageAccountName"
Write-Output "  Container: $env:containerName"

$validateScopes = { $_.Length -gt 45 }

# Initialize variables
$fileName = 'settings.json'
$filePath = Join-Path -Path . -ChildPath $fileName
$newScopes = $env:scopes.Split('|') | Where-Object $validateScopes | ForEach-Object { @{ scope = $_ } }

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

# Set or update msexports retention
if (!($json.retention.msexports))
{
    $json.retention | Add-Member -Name msexports -Value (ConvertFrom-Json "{""days"":$($env:msexportRetentionInDays)}") -MemberType NoteProperty
}
else
{
    $json.retention.msexports.days = [Int32]::Parse($env:msexportRetentionInDays)
}

# Set or update ingestion retention
if (!($json.retention.ingestion))
{
    $json.retention | Add-Member -Name ingestion -Value (ConvertFrom-Json "{""months"":$($env:ingestionRetentionInMonths)}") -MemberType NoteProperty
}
else
{
    $json.retention.ingestion.months = [Int32]::Parse($env:ingestionRetentionInMonths)
}

# Set or update raw retention
if (!($json.retention.raw))
{
    $json.retention | Add-Member -Name raw -Value (ConvertFrom-Json "{""days"":$($env:rawRetentionInDays)}") -MemberType NoteProperty
}
else
{
    $json.retention.raw.days = [Int32]::Parse($env:rawRetentionInDays)
}

# Set or update final retention
if (!($json.retention.final))
{
    $json.retention | Add-Member -Name final -Value (ConvertFrom-Json "{""months"":$($env:finalRetentionInMonths)}") -MemberType NoteProperty
}
else
{
    $json.retention.final.months = [Int32]::Parse($env:finalRetentionInMonths)
}

# Updating settings
Write-Output "Updating version to $env:ftkVersion..."
$json.version = $env:ftkVersion
$json.scopes = (@() + $json.scopes + $newScopes) | Select-Object -Unique
if ($null -eq $json.scopes) { $json.scopes = @() }
$text = $json | ConvertTo-Json
Write-Output "---------"
Write-Output $text
Write-Output "---------"
$text | Out-File $filePath

# Upload new/updated settings
Write-Output "Uploading settings.json file..."
Set-AzStorageBlobContent @storageContext -File $filePath -Force | Out-Null
