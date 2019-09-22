<#

This script is used to copy the badges from the "prs" container to the "badges" container.  
The badges are created in the "prs" container when the pipleline test is executed on the PR, but we don't want to copy those results until approved
Then, when the PR is merged, the CI pipeline copies the badges to the "badges" folder to reflect the live/current results

#>

param(
    [string][Parameter(Mandatory = $true)]$SampleFolder, #this is the path to the sample, relative to BuildSourcesDirectory
    [string][Parameter(Mandatory = $true)]$BuildSourcesDirectory, #this is the path to the root of the repo on disk
    [string]$StorageAccountResourceGroupName = "ttk-gen-artifacts-storage",
    [string]$StorageAccountName = "azbotstorage"
)

$SampleFolder = $SampleFolder.TrimEnd("/").TrimEnd("\")
$BuildSourcesDirectory = $BuildSourcesDirectory.TrimEnd("/").TrimEnd("\")

$storageFolder = $SampleFolder.Replace("$BuildSourcesDirectory\", "").Replace("\", "@").Replace("/", "@")

# Get the storage table that contains the "status" for the deployment/test results
$ctx = (Get-AzStorageAccount -Name $StorageAccountName -ResourceGroupName $StorageAccountResourceGroupName).Context

#Get All Files from "prs" container and copy to the "badges" container
Get-AzStorageBlob -Context $ctx -Container "prs" -Prefix $storageFolder | Start-AzStorageBlobCopy -DestContainer "badges" -Verbose
