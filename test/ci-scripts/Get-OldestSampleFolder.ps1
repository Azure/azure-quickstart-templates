param(
    [Parameter(Mandatory = $true)]$BuildSourcesDirectory = ".",
    $StorageAccountResourceGroupName = "ttk-gen-artifacts-storage",
    $StorageAccountName = "azbotstorage",
    $TableName = "QuickStartDeploymentStatus",
    $TableSortKey = "PublicLastTestDate", # sort based on the cloud we're testing FF or Public
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
$ctx = (Get-AzStorageAccount -Name $StorageAccountName -ResourceGroupName $StorageAccountResourceGroupName).Context
$cloudTable = (Get-AzStorageTable –Name $tableName –Context $ctx).CloudTable
$t = Get-AzTableRow -table $cloudTable #| Sort-Object -Property $TableSortKey 

# Get all the samples
$ArtifactFilePaths = Get-ChildItem $BuildSourcesDirectory\metadata.json -Recurse -File | ForEach-Object -Process { $_.FullName }

#For each sample, make sure it's in the table before we check for the oldest
foreach ($SourcePath in $ArtifactFilePaths) {
    
    #write-host $SourcePath

    if ($SourcePath -like "*\test\*") {
        Write-host "Skipping..."
        continue
    }

    $MetadataJson = Get-Content $SourcePath -Raw | ConvertFrom-Json

    # Get the sample's path off of the root, replace any path chars with "@" since the rowkey for table storage does not allow / or \ (among other things)
    $RowKey = (Split-Path $SourcePath -Parent).Replace("$(Resolve-Path $BuildSourcesDirectory)\", "").Replace("\", "@").Replace("/", "@")

    $r = $t | Where-Object { $_.RowKey -eq $RowKey }

    # if the row isn't found in the table, it could be a new sample, add it with the data found in metadata.json
    If ($r -eq $null) {

        Write-Host "Adding: $Rowkey"
        Add-AzTableRow -table $cloudTable `
            -partitionKey $MetadataJson.type `
            -rowKey $RowKey `
            -property @{
                "PublicDeployment"           = $false; `
                "PublicLastTestDate"         = "$($MetadataJson.dateUpdated)"; 
        }
    }
}

#Get the updated table
$t = Get-AzTableRow -table $cloudTable #| Sort-Object -Property $TableSortKey 

# for each row in the table - purge those that don't exist in the samples folder anymore
if ($PurgeOldRows) {
    foreach ($r in $t) {

        $PathToSample = ("$BuildSourcesDirectory\$($r.RowKey)\metadata.json").Replace("@", "\")

        If (!(Test-Path -Path $PathToSample)) {
            Write-Host "Sample Not Found - removing... $PathToSample"
            $r | Remove-AzTableRow -Table $cloudTable
        }
    }
}

$t = Get-AzTableRow -table $cloudTable | Sort-Object -Property $TableSortKey 
$t | ft

# Write the pipeline variable
$FolderString = "$BuildSourcesDirectory\$($t[0].RowKey)"
Write-Output "Using sample folder: $FolderString"
Write-Host "##vso[task.setvariable variable=sample.folder]$FolderString"

# Not sure we need this in the scheduled build but here it is:
$sampleName = $FolderString.Replace("$ENV:BUILD_SOURCESDIRECTORY\", "")
Write-Output "Using sample name: $sampleName"
Write-Host "##vso[task.setvariable variable=sample.name]$sampleName"
