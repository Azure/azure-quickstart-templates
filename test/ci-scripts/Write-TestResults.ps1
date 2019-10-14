<#

This script is used to update the table where the test results for each sample are stored.
Typical scenario is that results will be passed in for only one cloud Public or Fairfax - so the 

#>

param(
    [string]$SampleFolder = $ENV:SAMPLE_FOLDER, # this is the path to the sample
    [string]$SampleName = $ENV:SAMPLE_NAME, # the name of the sample or folder path from the root of the repo e.g. "sample-type/sample-name"
    [string]$StorageAccountResourceGroupName = "azure-quickstarts-service-storage",
    [string]$StorageAccountName = "azurequickstartsservice",
    [string]$TableName = "QuickStartsMetadataService",
    [Parameter(mandatory = $true)]$StorageAccountKey, 
    [string]$BestPracticeResult = "$ENV:RESULT_BEST_PRACTICE",
    [string]$CredScanResult = "$ENV:RESULT_CREDSCAN",
    [string]$BuildReason = "$ENV:BUILD_REASON",
    [string]$FairfaxDeployment = "",
    [string]$FairfaxLastTestDate = (Get-Date -Format "yyyy-MM-dd").ToString(),
    [string]$PublicDeployment = "",
    [string]$PublicLastTestDate = (Get-Date -Format "yyyy-MM-dd").ToString()
)


# Get the storage table that contains the "status" for the deployment/test results
$ctx = New-AzStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $StorageAccountKey -Environment AzureCloud
$cloudTable = (Get-AzStorageTable –Name $tableName –Context $ctx).CloudTable

#Get the type of Sample from metadata.json, needed for the partition key lookup
$PathToMetadata = "$SampleFolder\metadata.json"
Write-Host "PathToMetadata: $PathToMetadata"

$RowKey = $SampleName.Replace("\", "@").Replace("/", "@")
Write-Host "RowKey: $RowKey"

$Metadata = Get-Content $PathToMetadata -Raw | ConvertFrom-Json
$PartitionKey = $Metadata.Type # if the type changes we'll have an orphaned row, this is removed in Get-OldestSampleFolder.ps1

#Get the row to update
$r = Get-AzTableRow -table $cloudTable -PartitionKey $PartitionKey -RowKey $RowKey

# if the record doesn't exist, this is probably a new sample and needs to be added (or we just cleaned the table)
if ($r -eq $null) {

    Write-Host "No record found, adding a new one..."
    $results = New-Object -TypeName hashtable
    if (![string]::IsNullOrWhiteSpace($BestPracticeResult)) {
        $results.Add("BestPracticeResult", $BestPracticeResult)
    }
    if (![string]::IsNullOrWhiteSpace($CredScanResult)) {
        $results.Add("CredScanResult", $CredScanResult)
    }
    # set the values for Fairfax only if a result was passed
    if (![string]::IsNullOrWhiteSpace($FairfaxDeployment)) { 
        $results.Add("FairfaxDeployment", $FairfaxDeployment) 
        $results.Add("FairfaxLastTestDate", $FairfaxLastTestDate) 
    }
    # set the values for MAC only if a result was passed
    if (![string]::IsNullOrWhiteSpace($PublicDeployment)) {
        $results.Add("PublicDeployment", $PublicDeployment) 
        $results.Add("PublicLastTestDate", $PublicLastTestDate) 
    }
    # add metadata columns
    $results.Add("itemDisplayName", $Metadata.itemDisplayName)
    $results.Add("description", $Metadata.description)
    $results.Add("summary", $Metadata.summary)
    $results.Add("githubUsername", $Metadata.githubUsername)
    $results.Add("dateUpdated", $Metadata.dateUpdated)

    if ($ENV:BUILD_REASON -eq "PullRequest") {
        $results.Add("status", $ENV:BUILD_REASON)
    }

    $results | ft

    Add-AzTableRow -table $cloudTable `
        -partitionKey $PartitionKey `
        -rowKey $RowKey `
        -property $results
}
else {
    # Update the existing row - need to check to make sure the columns exist
    Write-Host "Updating the existing record from:"
    $r | ft

    if (![string]::IsNullOrWhiteSpace($BestPracticeResult)) {
        if ($r.BestPracticeResult -eq $null) {
            Add-Member -InputObject $r -NotePropertyName 'BestPracticeResult' -NotePropertyValue $BestPracticeResult
        }
        else {
            $r.BestPracticeResult = $BestPracticeResult
        }
    }
    if (![string]::IsNullOrWhiteSpace($CredScanResult)) {
        if ($r.CredScanResult -eq $null) {
            Add-Member -InputObject $r -NotePropertyName "CredScanResult" -NotePropertyValue $CredScanResult
        }
        else {
            $r.CredScanResult = $CredScanResult 
        }
    }
    # set the values for FF only if a result was passed
    if (![string]::IsNullOrWhiteSpace($FairfaxDeployment)) { 
        if ($r.FairfaxDeployment -eq $null) {
            Add-Member -InputObject $r -NotePropertyName "FairfaxDeployment" -NotePropertyValue $FairfaxDeployment
            Add-Member -InputObject $r -NotePropertyName "FairfaxLastTestDate" -NotePropertyValue $FairfaxLastTestDate -Force
        }
        else {
            $r.FairfaxDeployment = $FairfaxDeployment
            $r.FairfaxLastTestDate = $FairfaxLastTestDate 
        }
    }
    # set the values for MAC only if a result was passed
    if (![string]::IsNullOrWhiteSpace($PublicDeployment)) {
        if ($r.PublicDeployment -eq $null) {
            Add-Member -InputObject $r -NotePropertyName "PublicDeployment" -NotePropertyValue $PublicDeployment
            Add-Member -InputObject $r -NotePropertyName "PublicLastTestDate" -NotePropertyValue $PublicLastTestDate -Force
        }
        else {
            $r.PublicDeployment = $PublicDeployment 
            $r.PublicLastTestDate = $PublicLastTestDate 
        }
    }

    if ($ENV:BUILD_REASON -eq "PullRequest") {
        if ($r.status -eq $null) {
            Add-Member -InputObject $r -NotePropertyName "status" -NotePropertyValue $ENV:BUILD_REASON            
        }
        else {
            $r.status = $ENV:BUILD_REASON
        }
    }

    # update metadata columns
    if ($r.itemDisplayName -eq $null) { 
        Add-Member -InputObject $r -NotePropertyName "itemDisplayName" -NotePropertyValue $Metadata.itemDisplayName
    }
    else {
        $r.itemDisplayName = $Metadata.itemDisplayName
    }

    if ($r.description -eq $null) {
        Add-Member -InputObject $r -NotePropertyName "description" -NotePropertyValue $Metadata.description
    }
    else {
        $r.description = $Metadata.description
    }

    if ($r.summary -eq $null) {
        Add-Member -InputObject $r -NotePropertyName "summary" -NotePropertyValue $Metadata.summary
    }
    else {
        $r.summary = $Metadata.summary
    }

    if ($r.githubUsername -eq $null) {
        Add-Member -InputObject $r -NotePropertyName "githubUsername" -NotePropertyValue $Metadata.githubUsername
    }
    else {
        $r.githubUsername = $Metadata.githubUsername
    }   
    
    if ($r.dateUpdated -eq $null) {
        Add-Member -InputObject $r -NotePropertyName "dateUpdated" -NotePropertyValue $Metadata.dateUpdated
    }
    else {
        $r.dateUpdated = $Metadata.dateUpdated
    }

    Write-Host "Updating to new results:"
    $r | ft
    $r | Update-AzTableRow -table $cloudTable
}

<#

Now write the badges to storage for the README.md files

#>

$r = Get-AzTableRow -table $cloudTable -PartitionKey $PartitionKey -RowKey $RowKey

$Badges = @{ }

$na = "Not%20Tested"
$naColor = "black"

if ($r.PublicLastTestDate -ne $null) {
    $PublicLastTestDate = $r.PublicLastTestDate.Replace("-", ".")
    $PublicLastTestDateColor = "black"
}
else {
    $PublicLastTestDate = $na
    $PublicLastTestDateColor = "inactive"
}

if ($r.FairfaxLastTestDate -ne $null) {
    $FairfaxLastTestDate = $r.FairfaxLastTestDate.Replace("-", ".")
    $FairfaxLastTestDateColor = "black"
}
else {
    $FairfaxLastTestDate = $na
    $FairfaxLastTestDateColor = "inactive"
}

if ($r.FairfaxDeployment -ne $null) {
    $FairfaxDeployment = ($r.FairfaxDeployment).ToString().ToLower().Replace("true", "PASS").Replace("false", "FAIL")
}
switch ($FairfaxDeployment) {
    "PASS" { $FairfaxDeploymentColor = "brightgreen" }
    "FAIL" { $FairfaxDeploymentColor = "red" }
    default {
        $FairfaxDeployment = $na
        $FairfaxDeploymentColor = "inactive"    
    }
}

if ($r.PublicDeployment -ne $null) {
    $PublicDeployment = ($r.PublicDeployment).ToString().ToLower().Replace("true", "PASS").Replace("false", "FAIL")
}
switch ($PublicDeployment) {
    "PASS" { $PublicDeploymentColor = "brightgreen" }
    "FAIL" { $PublicDeploymentColor = "red" }
    default {
        $PublicDeployment = $na
        $PublicDeploymentColor = "inactive"    
    }
}

if ($r.BestPracticeResult -ne $null) {
    $BestPracticeResult = ($r.BestPracticeResult).ToString().ToLower().Replace("true", "PASS").Replace("false", "FAIL")
}
switch ($BestPracticeResult) {
    "PASS" { $BestPracticeResultColor = "brightgreen" }
    "FAIL" { $BestPracticeResultColor = "red" }
    default {
        $BestPracticeResult = $na
        $CredScanResultColor = "inactive"    
    }
}

if ($r.CredScanResult -ne $null) {
    $CredScanResult = ($r.CredScanResult).ToString().ToLower().Replace("true", "PASS").Replace("false", "FAIL")
}
switch ($CredScanResult) {
    "PASS" { $CredScanResultColor = "brightgreen" }
    "FAIL" { $CredScanResultColor = "red" }
    default {
        $CredScanResult = $na
        $CredScanResultColor = "inactive"    
    }
}

$badges = @(
    @{
        "url"      = "https://img.shields.io/badge/Azure%20Public%20Test%20Date-$PublicLastTestDate-/?color=$PublicLastTestDateColor";
        "filename" = "PublicLastTestDate.svg";
    },
    @{
        "url"      = "https://img.shields.io/badge/Azure%20Public%20Test%20Result-$PublicDeployment-/?color=$PublicDeploymentColor";
        "filename" = "PublicDeployment.svg"

    },
    @{ 
        "url"      = "https://img.shields.io/badge/Azure%20US%20Gov%20Test%20Date-$FairfaxLastTestDate-/?color=$FairfaxLastTestDateColor";
        "filename" = "FairfaxLastTestDate.svg"
    },
    @{
        "url"      = "https://img.shields.io/badge/Azure%20US%20Gov%20Test%20Result-$FairfaxDeployment-/?color=$FairfaxDeploymentColor";
        "filename" = "FairfaxDeployment.svg"
    },
    @{
        "url"      = "https://img.shields.io/badge/Best%20Practice%20Check-$BestPracticeResult-/?color=$BestPracticeResultColor";
        "filename" = "BestPracticeResult.svg"
    },
    @{
        "url"      = "https://img.shields.io/badge/CredScan%20Check-$CredScanResult-/?color=$CredScanResultColor";
        "filename" = "CredScanResult.svg"
    }
)

foreach ($badge in $badges) {
    (Invoke-WebRequest -Uri $($badge.url)).Content | Set-Content -Path $badge.filename -Force
    <#
        if this is just a PR, we don't want to overwrite the live badges until it's merged
        just create the badges in the "pr" folder and they will be copied over by a CI build when merged
        scheduled builds should be put into the "live" container (i.e. badges)
    #>
    if ($ENV:BUILD_REASON -eq "PullRequest") {
        $containerName = "prs"
    }
    else {
        $containerName = "badges"
    }
    Set-AzStorageBlobContent -Container $containerName -File $badge.filename -Blob "$RowKey/$($badge.filename)" -Context $ctx -Force -Properties @{"ContentType" = "image/svg+xml"; "CacheControl" = "no-cache" }
}

<#Debugging only

$HTML = "<HTML>"
foreach ($badge in $badges) {
    $HTML += "<IMG SRC=`"$($badge.url)`" />&nbsp;"
}
$HTML += "</HTML>"
$HTML | Set-Content -path "test.html"

<#

Snippet that will be placed in the README.md files

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/100-blank-template/PublicLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/100-blank-template/PublicDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/100-blank-template/FairfaxLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/100-blank-template/FairfaxDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/100-blank-template/BestPracticeResult.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/100-blank-template/CredScanResult.svg" />&nbsp;

#>