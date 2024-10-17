$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest
$ProgressPreference = 'SilentlyContinue'

Connect-AzAccount -Identity

$logsFile = 'customization.log'
Write-Host "=== Looking for storage account in staging RG: ${env:imageBuildStagingResourceGroupName}"
$stagingStorageAccountName = (Get-AzResource -ResourceGroupName ${env:imageBuildStagingResourceGroupName} -ResourceType "Microsoft.Storage/storageAccounts")[0].Name

$stagingStorageAccountKey = $(Get-AzStorageAccountKey -StorageAccountName $stagingStorageAccountName -ResourceGroupName ${env:imageBuildStagingResourceGroupName})[0].value
$ctx = New-AzStorageContext -StorageAccountName $stagingStorageAccountName -StorageAccountKey $stagingStorageAccountKey
$logsBlob = Get-AzStorageBlob -Context $ctx -Container packerlogs | Where-Object { $_.Name -like "*/$logsFile" }
if (-not $logsBlob) {
    Write-Host "Could not find customization.log in storage account: $stagingStorageAccountName"
    return
}

Write-Host "=== Downloading $logsFile in storage account: $stagingStorageAccountName"
Get-AzStorageBlobContent -Context $ctx -CloudBlob $logsBlob.ICloudBlob -Destination $logsFile -Force

# $logLinesCount = 1000
# Write-Host "=== Last $logLinesCount lines of $logsFile :"
# Get-Content $logsFile -Tail $logLinesCount

Write-Host "=== Uploading $logsFile to storage account: ${env:logsStorageAccountName}"
$ctx = New-AzStorageContext -StorageAccountName "${env:logsStorageAccountName}"
New-AzStorageContainer -Context $ctx -Name logs -Permission 'Blob'
Set-AzStorageBlobContent -Context $ctx -Container logs -Blob $logsFile -StandardBlobTier 'Hot' -File $logsFile

Write-Host "=== Waiting to allow for the logs to be accessed for troubleshooting"
Start-Sleep -Seconds (15 * 60)  # Wait 15 minutes to allow for the logs to be downloaded
