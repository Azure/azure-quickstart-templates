<#

This script is used to copy the badges from the "prs" container to the "badges" container.  
The badges are created in the "prs" container when the pipleline test is executed on the PR, but we don't want to copy those results until approved
Then, when the PR is merged, the CI pipeline copies the badges to the "badges" folder to reflect the live/current results

#>

param(
    [string]$SampleName = $ENV:SAMPLE_NAME, # the name of the sample or folder path from the root of the repo e.g. "sample-type/sample-name"
    [string]$StorageAccountResourceGroupName = "azure-quickstarts-service-storage",
    [string]$StorageAccountName = "azurequickstartsservice",
    [Parameter(mandatory=$true)]$StorageAccountKey
)

if($SampleName = ""){
    Write-Error "SampleName is empty"
}

$storageFolder = $SampleName.Replace("\", "@").Replace("/", "@")

# Get the storage table that contains the "status" for the deployment/test results
$ctx = New-AzStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $StorageAccountKey -Environment AzureCloud

#Get All Files from "prs" container and copy to the "badges" container
$blobs = Get-AzStorageBlob -Context $ctx -Container "prs" -Prefix $storageFolder 

$blobs | Start-AzStorageBlobCopy -DestContainer "badges" -Verbose -Force

$blobs | Remove-AzStorageBlob -Verbose -Force
