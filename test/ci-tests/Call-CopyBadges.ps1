# This allows calling Copy-Badges locally for debugging.
# TODO: Turn this into a test.
$SampleName = Split-Path (Resolve-Path ".") -Leaf
$StorageAccountName = "azureqsbicep"
$StorageAccountKey = "$ENV:STORAGE_ACCOUNT_KEY"

if (($StorageAccountKey -eq "") -or ($null -eq $StorageAccountKey)) {
    Write-Error "Missing StorageAccountKey"
    return
}

$script = "$PSScriptRoot/../ci-scripts/Copy-Badges"
& $script `
    -SampleName $SampleName `
    -StorageAccountName $StorageAccountName `
    -TableName "QuickStartsMetadataServiceTest" `
    -TableNamePRs "QuickStartsMetadataServiceTestPRs" `
    -StorageAccountKey $StorageAccountKey `
