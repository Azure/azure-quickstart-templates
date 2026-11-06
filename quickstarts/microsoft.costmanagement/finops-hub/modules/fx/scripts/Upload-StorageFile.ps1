# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

# Get storage context
$storageContext = @{
    Context   = New-AzStorageContext -StorageAccountName $env:storageAccountName -UseConnectedAccount
    Container = $env:containerName
}

# Uploading files
$files = $env:files | ConvertFrom-Json -Depth 10
Write-Output "Uploading ${$files.PSObject.Properties.Count} files..."
$files.PSObject.Properties | ForEach-Object {
    $filePath = $_.Name
    $tempPath = "./$($filePath -replace "/", "_")"
    Write-Output "  Uploading $filePath..."
    $_.Value | Out-File $tempPath
    Set-AzStorageBlobContent @storageContext -File $tempPath -Blob $filePath -Force | Out-Null
}
