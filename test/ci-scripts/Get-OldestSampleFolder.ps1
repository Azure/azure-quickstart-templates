param(
    $BuildSourcesDirectory = "$ENV:BUILD_SOURCESDIRECTORY",
    [string]$StorageAccountName = $ENV:STORAGE_ACCOUNT_NAME,
    $TableName = "QuickStartsMetadataService",
    [Parameter(mandatory = $true)]$StorageAccountKey, 
    $ResultDeploymentLastTestDateParameter = "$ENV:RESULT_DEPLOYMENT_LAST_TEST_DATE_PARAMETER", # sort based on the cloud we're testing FF or Public
    $ResultDeploymentParameter = "$ENV:RESULT_DEPLOYMENT_PARAMETER", #also cloud specific
    $PurgeOldRows = $true
)
<#

Get all metadata files in the repo
Get entire table since is has to be sorted client side

For each file in the repo, check to make sure it's in the table
- if not add it with the date found in metadata.json

sort the table by date

Get the oldest LastTestDate, i.e. the sample that hasn't had a test in the longest time

If that metadata file doesn't exist, remove the table row

Else set the sample folder to run the test

#>

# Get the storage table that contains the "status" for the deployment/test results
$ctx = New-AzStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $StorageAccountKey -Environment AzureCloud
$cloudTable = (Get-AzStorageTable –Name $tableName –Context $ctx).CloudTable
$t = Get-AzTableRow -table $cloudTable
Write-Host "Retrieved $($t.Length) rows"

# Get all the samples
Write-Host "Searching all sample folders in '$BuildSourcesDirectory'..."
$ArtifactFilePaths = Get-ChildItem $BuildSourcesDirectory\metadata.json -Recurse -File | ForEach-Object -Process { $_.FullName }
Write-Host "Found $($ArtifactFilePaths.Length) samples"

# if this is empty, then everything would be removed from the table which is probably not the intent, so throw and get out
if ($ArtifactFilePaths.Count -eq 0) {
    Write-Error "No metadata.json files found in $BuildSourcesDirectory"
    throw
}

#For each sample, make sure it's in the table before we check for the oldest
Write-Host "Checking table to see if this is a new sample (does the row exist?)"
foreach ($SourcePath in $ArtifactFilePaths) {
    
    if ($SourcePath -like "*\test\*") {
        Write-host "Skipping..."
        continue
    }

    Write-Host "Reading: $SourcePath"
    $MetadataJson = Get-Content $SourcePath -Raw | ConvertFrom-Json

    # Get the sample's path off of the root, replace any path chars with "@" since the rowkey for table storage does not allow / or \ (among other things)
    $SamplePath = Split-Path ([System.IO.Path]::GetRelativePath($BuildSourcesDirectory, $SourcePath).toString()) -Parent
    $RowKey = $SamplePath.Replace("\", "@").Replace("/", "@")

    Write-Host "RowKey from path: $RowKey"

    $r = $t | Where-Object { $_.RowKey -eq $RowKey }

    Write-Host "Row from Where-Object:"
    $r | Out-String
    Write-Host "END (Row from Where-Object)"

    # if the row isn't found in the table, it could be a new sample, add it with the data found in metadata.json
    If ($r -eq $null) {

        Write-Host "Adding: $Rowkey"

        $p = New-Object -TypeName hashtable
        
        $MetadataJson | Out-String

        #$p.Add("$ResultDeploymentParameter", $false) - don't add this since we don't know what the result was, badge will still have it
        $p.Add("PublicLastTestDate", $MetadataJson.dateUpdated)
        $p.Add("FairfaxLastTestDate", $MetadataJson.dateUpdated)
    
        $p.Add("itemDisplayName", $MetadataJson.itemDisplayName)
        $p.Add("description", $MetadataJson.description)
        $p.Add("summary", $MetadataJson.summary)
        $p.Add("githubUsername", $MetadataJson.githubUsername)
        $p.Add("dateUpdated", $MetadataJson.dateUpdated)

        $p.Add("status", "Live") # if it's in master, it's live
        $p.Add($($ResultDeploymentParameter + "BuildNumber"), $ENV:BUILD_BUILDNUMBER)

        Write-Host "Adding new row for $Rowkey..."
        $p | Format-Table
        Add-AzTableRow -table $cloudTable `
            -partitionKey $MetadataJson.type `
            -rowKey $RowKey `
            -property $p
    }
}

#Get the updated table
$t = Get-AzTableRow -table $cloudTable

# for each row in the table - purge those that don't exist in the samples folder anymore
# note that if this build sources directory is wrong this will remove every row in the table (which would be bad)
if ($PurgeOldRows) {
    Write-Host "Purging Old Rows..."
    foreach ($r in $t) {

        $PathToSample = ("$BuildSourcesDirectory\$($r.RowKey)\metadata.json").Replace("@", "\")

        $SampleFound = (Test-Path -Path $PathToSample)
        Write-Host "Metadata path: $PathToSample > Found: $SampleFound"

        if ($SampleFound) {
            $MetadataJson = Get-Content $PathToSample -Raw | ConvertFrom-Json
        }

        # If the sample isn't found in the repo (and it's not a new sample, still in PR (i.e. it's live))
        # or the Type of sample has changed (which changes the partitionKey) and it's not null, then we want to remove the row from the table
        If (!$SampleFound -and $r.status -eq "Live") {
            
            Write-Host "Sample Not Found - removing... $PathToSample"
            $r | Out-String
            $r | Remove-AzTableRow -Table $cloudTable # TODO This seems to be causing failures, need more testing on it

        }
        elseif (($r.PartitionKey -ne $MetadataJson.type -and ![string]::IsNullOrWhiteSpace($MetadataJson.type))) {
            
            #if the type has changed, update the type - this will create a new row since we use the partition key we so need to delete the old row
            Write-Host "Metadata type has changed from `'$($r.PartitionKey)`' to `'$($MetadataJson.type)`' on $PathToSample"
            $oldRowKey = $r.RowKey
            $oldPartitionKey = $r.PartitionKey
            $r.PartitionKey = $MetadataJson.Type
            $r | Update-AzTableRow -table $cloudTable
            Get-AzTableRow -table $cloudTable -PartitionKey $oldPartitionKey -RowKey $oldRowKey | Remove-AzTableRow -Table $cloudTable 
            
        }
    }
}

$t = Get-AzTableRow -table $cloudTable -ColumnName "status" -Value "Live" -Operator Equal | Sort-Object -Property $ResultDeploymentLastTestDateParameter # sort based on the last test date for the could being tested

$t[0].Status = "Testing" # Set the status to "Testing" in case the build takes more than an hour, so the next scheduled build doesn't pick up the same sample
if ($t[0].($ResultDeploymentParameter + "BuildNumber") -eq $null) {
    Add-Member -InputObject $t[0] -NotePropertyName ($ResultDeploymentParameter + "BuildNumber") -NotePropertyValue $ENV:BUILD_BUILDNUMBER
}
else {
    $t[0].($ResultDeploymentParameter + "BuildNumber") = $ENV:BUILD_BUILDNUMBER
}

Write-Host "Setting Testing Status..."
$t[0] | fl *
$t[0] | Update-AzTableRow -Table $cloudTable

$t | ft RowKey, Status, dateUpdated, PublicLastTestDate, PublicDeployment, FairfaxLastTestDate, FairfaxDeployment, dateUpdated

$samplePath = $($t[0].RowKey).Replace("@", "\")

# Write the pipeline variable
$FolderString = "$BuildSourcesDirectory\$samplePath"
Write-Output "Using sample folder: $FolderString"
Write-Host "##vso[task.setvariable variable=sample.folder]$FolderString"

# Not sure we need this in the scheduled build but here it is:

$sampleName = $FolderString.Replace("$ENV:BUILD_SOURCESDIRECTORY\", "") # sampleName is actually a relative path, could be for instance "demos/100-my-sample"
Write-Output "Using sample name: $sampleName"
Write-Host "##vso[task.setvariable variable=sample.name]$sampleName"
