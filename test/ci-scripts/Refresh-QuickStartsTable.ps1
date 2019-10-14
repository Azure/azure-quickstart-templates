param(
    $BuildSourcesDirectory = "$ENV:BUILD_SOURCESDIRECTORY",
    $StorageAccountResourceGroupName = "azure-quickstarts-service-storage",
    $StorageAccountName = "azurequickstartsservice",
    $TableName = "QuickStartsMetadataService",
    [Parameter(mandatory = $true)]$StorageAccountKey, 
    $ResultDeploymentLastTestDateParameter = "$ENV:RESULT_DEPLOYMENT_LAST_TEST_DATE_PARAMETER", # sort based on the cloud we're testing FF or Public
    $ResultDeploymentParameter = "$ENV:RESULT_DEPLOYMENT_PARAMETER" #also cloud specific
)
<#

Get all metadata files in the repo
Get all the badges (if found) for the status
Update the table's LIVE or null records to reflect badge status and metadata contents
Remove old row and create new table row (i.e. update if exists)

#>

$badges = @{
    PublicLastTestDate  = "https://azurequickstartsservice.blob.core.windows.net/badges/%sample.folder%/PublicLastTestDate.svg";
    PublicDeployment    = "https://azurequickstartsservice.blob.core.windows.net/badges/%sample.folder%/PublicDeployment.svg";
    FairfaxLastTestDate = "https://azurequickstartsservice.blob.core.windows.net/badges/%sample.folder%/FairfaxLastTestDate.svg";
    FairfaxDeployment   = "https://azurequickstartsservice.blob.core.windows.net/badges/%sample.folder%/FairfaxDeployment.svg";
    BestPracticeResult  = "https://azurequickstartsservice.blob.core.windows.net/badges/%sample.folder%/BestPracticeResult.svg";
    CredScanResult      = "https://azurequickstartsservice.blob.core.windows.net/badges/%sample.folder%/CredScanResult.svg";
}

# Get all the samples
$ArtifactFilePaths = Get-ChildItem $BuildSourcesDirectory\metadata.json -Recurse -File | ForEach-Object -Process { $_.FullName }
# if this is empty, then everything would be removed from the table which is probably not the intent, so throw and get out
if ($ArtifactFilePaths.Count -eq 0) {
    Write-Error "No metadata.json files found in $BuildSourcesDirectory"
    throw
}

# Get the storage table that contains the "status" for the deployment/test results
$ctx = New-AzStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $StorageAccountKey -Environment AzureCloud
$cloudTable = (Get-AzStorageTable –Name $tableName –Context $ctx).CloudTable

# Dump table rows before the update
$t = Get-AzTableRow -table $cloudTable
$t | ft

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
    $RowKey = (Split-Path $SourcePath -Parent).Replace("$(Resolve-Path $BuildSourcesDirectory)\", "").Replace("\", "@").Replace("/", "@")

    Write-Host "RowKey from path: $RowKey"

    $r = Get-AzTableRow -table $cloudTable -ColumnName "RowKey" -Value $RowKey -Operator Equal

    #update the row if it's live or no status
    if ($r.status -eq "Live" -or $r.status -eq $null) {

        Write-Host "Status: $($r.status)"

        # if the row isn't found in the table, it could be a new sample, add it with the data found in metadata.json
        Write-Host "Updating: $Rowkey"

        $p = New-Object -TypeName hashtable
        
        $p.Add("itemDisplayName", $MetadataJson.itemDisplayName)
        $p.Add("description", $MetadataJson.description)
        $p.Add("summary", $MetadataJson.summary)
        $p.Add("githubUsername", $MetadataJson.githubUsername)
        $p.Add("dateUpdated", $MetadataJson.dateUpdated)

        $p.Add("status", "Live") # if it's in master, it's live

        #add status from badges

        $badges.GetEnumerator() | ForEach-Object {
            $uri = $($_.Value).replace("%sample.folder%", $RowKey.Replace("@", "/"))
            #Write-Host $uri
            try { $svg = (Invoke-WebRequest -Uri $uri -ErrorAction SilentlyContinue) } catch { }
            if ($svg) {
                $xml = $svg.content.replace('xmlns="http://www.w3.org/2000/svg"', '')
                Write-Host $xml
                $t = Select-XML -Content $xml -XPath "//text"
                $v = $($t[$t.length - 1])
                Write-Host "$($_.Key) = $v"
            
                $v = $($t[$t.length - 1]).ToString()
            
                # set the value in the table based on the value in the badge
                switch ($v) {
                    "PASS" {
                        $v = $true
                    }
                    "FAIL" {
                        $v = $false
                    }
                    "Not Tested" {
                    }
                    default {
                        # must be a date
                        $v = $v.Replace(".", "-")
                    }
                }
                if ($_.Key -like "*Date") { $v = $MetadataJson.dateUpdated }
                Write-Host "$($_.Key) = $v"
                $p.Add($_.Key, $v)
            }
        }
    }

    if ([string]::IsNullOrWhiteSpace($p.FairfaxLastTestDate)) { 
        $p.Add("FairfaxLastTestDate", $MetadataJson.dateUpdated) 
    }
    if ([string]::IsNullOrWhiteSpace($p.PublicLastTestDate)) { 
        $p.Add("PublicLastTestDate", $MetadataJson.dateUpdated) 
    }
    
    Write-Host "Removing... $($r.RowKey)"
    $r | Remove-AzTableRow -Table $cloudTable
    Write-Host "Adding... $RowKey"
    Add-AzTableRow -table $cloudTable `
        -partitionKey $MetadataJson.type `
        -rowKey $RowKey `
        -property $p

} #foreach

#Get the updated table
$t = Get-AzTableRow -table $cloudTable
$t | ft
