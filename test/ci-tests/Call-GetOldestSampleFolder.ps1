# This allows calling Get-OldestSampleFolder locally for debug.
# TODO: Turn this into a test.
$ENV:BUILD_SOURCESDIRECTORY = (Resolve-Path "$PSScriptRoot/../..").ToString()
$ENV:SAMPLE_FOLDER = "."
$ENV:SAMPLE_NAME = Split-Path -Leaf $PSScriptRoot
$ENV:STORAGE_ACCOUNT_NAME = "azureqsbicep" # TODO
$ENV:RESULT_BEST_PRACTICE = "FAIL"
$ENV:RESULT_CREDSCAN = "PASS"
$ENV:BUILD_REASON = "PullRequest"
$ENV:AGENT_JOBSTATUS = "Succeeded"
$ENV:VALIDATION_TYPE = ""
$ENV:SUPPORTED_ENVIRONMENTS = "['AzureUSGovernment','AzureCloud']"
$ENV:RESULT_DEPLOYMENT_PARAMETER = "PublicDeployment"
$ENV:RESULT_DEPLOYMENT_LAST_TEST_DATE_PARAMETER = "PublicLastTestDate"
$ENV:RESULT_DEPLOYMENT = "True"
$ENV:BICEP_VERSION = "0.3.1"
$StorageAccountKey = "$ENV:STORAGE_ACCOUNT_KEY"
$ENV:SYSTEM_PULLREQUEST_PULLREQUESTNUMBER = "123"
$ENV:BUILD_BUILDNUMBER = "1234.56"

if (($StorageAccountKey -eq "") -or ($null -eq $StorageAccountKey)) {
    Write-Error "Missing StorageAccountKey"
}

& "$PSScriptRoot/../ci-scripts/Get-OldestSampleFolder" `
    -StorageAccountKey $StorageAccountKey `
    -TableName "QuickStartsMetadataService" `
    -PurgeOldRows $false #TODO REMOVE
