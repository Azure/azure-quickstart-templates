# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

Write-Output "Updating settings.json file..."
Write-Output "  Storage account: $env:storageAccountName"
Write-Output "  Container: $env:containerName"

$validateScopes = { $_.Length -gt 45 }

# Initialize variables
$fileName = 'settings.json'
$filePath = Join-Path -Path . -ChildPath $fileName
$newScopes = $env:exportScopes.Split('|') | Where-Object $validateScopes | ForEach-Object { @{ scope = $_ } }

# Get storage context
$storageContext = @{
    Context   = New-AzStorageContext -StorageAccountName $env:storageAccountName -UseConnectedAccount
    Container = $env:containerName
}

# Download existing settings, if they exist
$blob = Get-AzStorageBlobContent @storageContext -Blob $fileName -Destination $filePath -Force
if ($blob) {
    Write-Output "Existing settings.json file found. Updating..."
    $text = Get-Content $filePath -Raw
    Write-Output "---------"
    Write-Output $text
    Write-Output "---------"
    $json = $text | ConvertFrom-Json

    # Rename exportScopes to scopes + convert to object array
    if ($json.exportScopes) {
        Write-Output "  Updating exportScopes..."
        if ($json.exportScopes[0] -is [string]) {
            Write-Output "    Converting string array to object array..."
            $json.exportScopes = $json.exportScopes | Where-Object $validateScopes | ForEach-Object { @{ scope = $_ } }
            if (-not ($json.exportScopes -is [array])) {
                Write-Output "    Converting single object to object array..."
                $json.exportScopes = @($json.exportScopes)
            }
        }

        Write-Output "    Renaming to 'scopes'..."
        $json | Add-Member -MemberType NoteProperty -Name scopes -Value $json.exportScopes
        $json.PSObject.Properties.Remove('exportScopes')
    }
}

# Set default if not found
if (!$json) {
    Write-Output "No existing settings.json file found. Creating new file..."
    $json = [ordered]@{
        '$schema' = 'https://aka.ms/finops/hubs/settings-schema'
        type      = 'HubInstance'
        version   = ''
        learnMore = 'https://aka.ms/finops/hubs'
        scopes    = @()
    }
}

# Updating settings
Write-Output "Updating version to $env:ftkVersion..."
$json.version = $env:ftkVersion
if ($newScopes) {
    Write-Output "Merging $($newScopes.Count) scopes..."
    $json.scopes = Compare-Object -ReferenceObject $json.scopes -DifferenceObject $newScopes -Property scope -PassThru -IncludeEqual
    
    # Remove the SideIndicator property from the Compare-Object output
    $json.scopes | ForEach-Object { $_.PSObject.Properties.Remove('SideIndicator') } | ConvertTo-Json

    if (-not ($json.scopes -is [array])) {
        $json.scopes = @($json.scopes)
    }
    Write-Output "$($json.scopes.Count) scopes found."
}
$text = $json | ConvertTo-Json
Write-Output "---------"
Write-Output $text
Write-Output "---------"
$text | Out-File $filePath

# Upload new/updated settings
Write-Output "Uploading settings.json file..."
Set-AzStorageBlobContent @storageContext -File $filePath -Force
