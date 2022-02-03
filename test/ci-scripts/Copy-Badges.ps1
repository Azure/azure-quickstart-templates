<#

This script is used to copy the badges from the "prs" container to the "badges" container.  
The badges are created in the "prs" container when the pipleline test is executed on the PR, but we don't want to copy those results until approved
Then, when the PR is merged, the CI pipeline copies the badges to the "badges" folder to reflect the live/current results

#>

param(
    [string]$SampleName = $ENV:SAMPLE_NAME, # the name of the sample or folder path from the root of the repo e.g. "sample-type/sample-name"
    [string]$StorageAccountName = $ENV:STORAGE_ACCOUNT_NAME,
    [string]$TableName = "QuickStartsMetadataService",
    [string]$TableNamePRs = "QuickStartsMetadataServicePRs",
    [Parameter(mandatory = $true)]$StorageAccountKey
)

if ([string]::IsNullOrWhiteSpace($SampleName)) {
    Write-Error "SampleName is empty"
}
else {
    Write-Host "SampleName: $SampleName"
}

$storageFolder = $SampleName.Replace("\", "@").Replace("/", "@")
$RowKey = $storageFolder
Write-Host "RowKey: $RowKey"

# Get the storage table that contains the "status" for the deployment/test results
$ctx = New-AzStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $StorageAccountKey -Environment AzureCloud
$cloudTable = (Get-AzStorageTable –Name $tableName –Context $ctx).CloudTable
$cloudTablePRs = (Get-AzStorageTable –Name $tableNamePRs –Context $ctx).CloudTable

#Get All Files from "prs" container and copy to the "badges" container
$blobs = Get-AzStorageBlob -Context $ctx -Container "prs" -Prefix $storageFolder.Replace("@", "/") 
$blobs | Start-AzStorageBlobCopy -DestContainer "badges" -Verbose -Force
$blobs | Remove-AzStorageBlob -Verbose -Force

# Get the row to update - can't search by rowkey only since we don't know the partition key, but row key is guaranteed unique in our scenario
# TODO if there is no row in the PR table, this won't end well...
Write-Host "Fetching row for: $RowKey in Table: $cloudTablePRs"
$r = Get-AzTableRow -table $cloudTablePRs -ColumnName "RowKey" -Value $RowKey -Operator Equal
if ($null -eq $r) {
    Write-Error "Could not find row with key $RowKey in table $cloudTablePRs"
    Return
}
Write-Host "Result from Table: $r"

# change the status before copying the row/data to the "Live" table
if ($r.status -eq $null) {
    Write-Host "Adding status column..."
    Add-Member -InputObject $r -NotePropertyName "status" -NotePropertyValue "Live"
}
else {
    $r.status = "Live"
}

Write-Host "Updating LIVE table with..."
$r | Format-List *

$p = @{ }
foreach ($i in $r.PSObject.Properties) {
    if ($i.Name -ne "Etag") {
        if ($i.value -eq "true") {
            $newValue = "PASS"
        }
        elseif ($i.value -eq "false") {
            $newValue = "FAIL"
        }
        else { 
            $newValue = $i.Value
        }
        $p.Add($i.Name, $newValue)
    }
}

Write-Host "New properties..."
$p | out-string

# TODO if there is no row in the PR table, this won't end well...
Write-Host "Add/Update Row in live table..."
Add-AzTableRow -table $cloudTable `
    -partitionKey $r.partitionKey `
    -rowKey $r.rowKey `
    -property $p `
    -UpdateExisting
               
Write-Host "Removing row from PR table..."
$r | Remove-AzTableRow -Table $cloudTablePRs

