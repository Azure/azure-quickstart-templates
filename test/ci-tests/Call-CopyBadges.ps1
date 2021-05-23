# This allows calling Copy-Badges locally for debugging.
# TODO: Turn this into a test.

Import-Module "$PSScriptRoot/../ci-scripts/Local.psm1" -force

$StorageAccountName = "azureqsbicep" # TODO
$StorageAccountKey = "$ENV:STORAGE_ACCOUNT_KEY"

if (($StorageAccountKey -eq "") -or ($null -eq $StorageAccountKey)) {
    Write-Error "Missing StorageAccountKey"
    return
}

$ENV:BUILD_REASON = "IndividualCI"
$ENV:BUILD_SOURCEVERSIONMESSAGE = "Add francecentral in azAppInsightsLocationMap (#9498)"
$ENV:BUILD_REPOSITORY_NAME = "Azure/azure-quickstart-templates"
$ENV:BUILD_REPOSITORY_LOCALPATH = Get-SampleRootPath
$ENV:BUILD_SOURCESDIRECTORY = Get-SampleRootPath

$getSampleFolderHost = & "$PSScriptRoot/../ci-scripts/Get-SampleFolder.ps1"`
    6>&1
Write-Output $getSampleFolderHost
$vars = Find-VarsFromWriteHostOutput $getSampleFolderHost
# $sampleFolder = $vars["SAMPLE_FOLDER"]
$SampleName = $vars["SAMPLE_NAME"]

$script = "$PSScriptRoot/../ci-scripts/Copy-Badges"
& $script `
    -SampleName $SampleName `
    -StorageAccountName $StorageAccountName `
    -TableName "QuickStartsMetadataService" `
    -TableNamePRs "QuickStartsMetadataServicePRs" `
    -StorageAccountKey $StorageAccountKey `
