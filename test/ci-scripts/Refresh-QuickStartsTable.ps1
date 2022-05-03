param(
    $BuildSourcesDirectory = "$ENV:BUILD_SOURCESDIRECTORY", # absolute path to the clone
    [string]$StorageAccountName = $ENV:STORAGE_ACCOUNT_NAME,
    $TableName = "QuickStartsMetadataService",
    [Parameter(mandatory = $true)]$StorageAccountKey
)
<#

Get all metadata files in the repo
Get all the badges (if found) for the status
Update the table's LIVE or null records to reflect badge status and metadata contents
Remove old row and create new table row (i.e. update if exists)

#>

# trim the trailing slashes otherwise the replace statement below won't work correctly
while($BuildSourcesDirectory.EndsWith("/")){
    $BuildSourcesDirectory = $BuildSourcesDirectory.TrimEnd("/")
}
while($BuildSourcesDirectory.EndsWith("\")){
    $BuildSourcesDirectory = $BuildSourcesDirectory.TrimEnd("\")
}

$badges = @{
    PublicLastTestDate  = "https://$StorageAccountName.blob.core.windows.net/badges/%sample.folder%/PublicLastTestDate.svg";
    PublicDeployment    = "https://$StorageAccountName.blob.core.windows.net/badges/%sample.folder%/PublicDeployment.svg";
    FairfaxLastTestDate = "https://$StorageAccountName.blob.core.windows.net/badges/%sample.folder%/FairfaxLastTestDate.svg";
    FairfaxDeployment   = "https://$StorageAccountName.blob.core.windows.net/badges/%sample.folder%/FairfaxDeployment.svg";
    BestPracticeResult  = "https://$StorageAccountName.blob.core.windows.net/badges/%sample.folder%/BestPracticeResult.svg";
    CredScanResult      = "https://$StorageAccountName.blob.core.windows.net/badges/%sample.folder%/CredScanResult.svg";
    BicepVersion        = "https://$StorageAccountName.blob.core.windows.net/badges/%sample.folder%/BicepVersion.svg"
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
#$t | fl *

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

    $p = @{ }

    Write-Host "Status: $($r.status)"

    # if the row isn't found in the table, it could be a new sample, add it with the data found in metadata.json
    Write-Host "Updating: $Rowkey"
        
    $p.Add("itemDisplayName", $MetadataJson.itemDisplayName)
    $p.Add("description", $MetadataJson.description)
    $p.Add("summary", $MetadataJson.summary)
    $p.Add("githubUsername", $MetadataJson.githubUsername)
    $p.Add("dateUpdated", $MetadataJson.dateUpdated)

    $p.Add("status", "Live") # if it's in master, it's live
    # $p.Add($($ResultDeploymentParameter + "BuildNumber"), "0)

    #update the row if it's live or no status
    #if ($r.status -eq "Live" -or $r.status -eq $null) {

        #add status from badges

        $badges.GetEnumerator() | ForEach-Object {
            $uri = $($_.Value).replace("%sample.folder%", $RowKey.Replace("@", "/"))
            #Write-Host $uri
            $svg = $null
            try { $svg = (Invoke-WebRequest -Uri $uri -ErrorAction SilentlyContinue) } catch { }
            if ($svg) {
                $xml = $svg.content.replace('xmlns="http://www.w3.org/2000/svg"', '')
                #Write-Host $xml
                $t = Select-XML -Content $xml -XPath "//text"
                #$t | Out-string                
                #$v = $($t[$t.length - 1])
                #Write-Host "$($_.Key) = $v"
            
                $v = $($t[$t.length - 1]).ToString()

                # set the value in the table based on the value in the badge
                switch ($v) {
                    "PASS" {
                        $v = "PASS"
                    }
                    "FAIL" {
                        $v = "FAIL"
                    }
                    "Not Supported" {
                        $v = "Not Supported"
                    }
                    "Not Tested" {
                        $v = "Not Tested"
                    }
                    "Bicep Version" {
                        $v = "n/a" # this is a temp hack as bicep badges were created with no value
                    }
                    default {
                        # must be a date or bicep version, fix that below
                        #$v = $v.Replace(".", "-")
                    }
                }
                if ($_.Key -like "*Date") { 
                    # $v = $MetadataJson.dateUpdated
                    $v = $v.Replace(".", "-")
                }
                if ($v -ne $null) {
                    $p.Add($_.Key, $v)
                }
                Write-Host "$($_.Key) = $v"
            }
        }
    #}

    #$p | out-string
    #Read-Host "Cont?"
    
    # if we didn't get the date from the badge, then add it from metadata.json
    if ([string]::IsNullOrWhiteSpace($p.FairfaxLastTestDate)) { 
        $p.Add("FairfaxLastTestDate", $MetadataJson.dateUpdated) 
    }
    if ([string]::IsNullOrWhiteSpace($p.PublicLastTestDate)) { 
        $p.Add("PublicLastTestDate", $MetadataJson.dateUpdated) 
    }

    # preserve the build number if possible
    if ([string]::IsNullOrWhiteSpace($r.FairfaxDeploymentBuildNumber)) { 
        $p.Add("FairfaxDeploymentBuildNumber", "0") 
    }
    else {
        $p.Add("FairfaxDeploymentBuildNumber", $r.FairfaxDeploymentBuildNumber) 
    }
    if ([string]::IsNullOrWhiteSpace($r.PublicDeploymentBuildNumber)) { 
        $p.Add("PublicDeploymentBuildNumber", "0") 
    }
    else {
        $p.Add("PublicDeploymentBuildNumber", $r.PublicDeploymentBuildNumber) 
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
# $t = Get-AzTableRow -table $cloudTable
# $t | fl *
