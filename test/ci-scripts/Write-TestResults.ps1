<#

This script is used to update the table where the test results for each sample are stored.
Typical scenario is that results will be passed in for only one cloud Public or Fairfax - so the 

#>

param(
    [string]$SampleFolder = $ENV:SAMPLE_FOLDER, # this is the full absolute path to the sample
    [string]$SampleName = $ENV:SAMPLE_NAME, # the name of the sample or folder path from the root of the repo (i.e. relative path) e.g. "sample-type/sample-name"
    [string]$StorageAccountResourceGroupName = "azure-quickstarts-service-storage",
    [string]$StorageAccountName = "azurequickstartsservice",
    [string]$TableName = "QuickStartsMetadataService",
    [string]$TableNamePRs = "QuickStartsMetadataServicePRs",
    [Parameter(mandatory = $true)]$StorageAccountKey, 
    [string]$BestPracticeResult = "$ENV:RESULT_BEST_PRACTICE",
    [string]$CredScanResult = "$ENV:RESULT_CREDSCAN",
    [string]$BuildReason = "$ENV:BUILD_REASON",
    [string]$AgentJobStatus = "$ENV:AGENT_JOBSTATUS",
    [string]$ValidationType = "$ENV:VALIDATION_TYPE",
    [string]$supportedEnvironmentsJson = "$ENV:SUPPORTED_ENVIRONMENTS", # the minified json array from metadata.json
    [string]$ResultDeploymentParameter = "$ENV:RESULT_DEPLOYMENT_PARAMETER", #also cloud specific
    [string]$FairfaxDeployment = "",
    [string]$FairfaxLastTestDate = (Get-Date -Format "yyyy-MM-dd").ToString(),
    [string]$PublicDeployment = "",
    [string]$PublicLastTestDate = (Get-Date -Format "yyyy-MM-dd").ToString()
)


# Get the storage table that contains the "status" for the deployment/test results
$ctx = New-AzStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $StorageAccountKey -Environment AzureCloud

if ($BuildReason -eq "PullRequest") {
    $t = $TableNamePRs
}
else {
    $t = $TableName
}

$cloudTable = (Get-AzStorageTable –Name $t –Context $ctx).CloudTable

#Get the type of Sample from metadata.json, needed for the partition key lookup
$PathToMetadata = "$SampleFolder\metadata.json"
Write-Host "PathToMetadata: $PathToMetadata"

$RowKey = $SampleName.Replace("\", "@").Replace("/", "@")
Write-Host "RowKey: $RowKey"

$Metadata = Get-Content $PathToMetadata -Raw | ConvertFrom-Json
$PartitionKey = $Metadata.Type # if the type changes we'll have an orphaned row, this is removed in Get-OldestSampleFolder.ps1

#Get the row to update
$r = Get-AzTableRow -table $cloudTable -PartitionKey $PartitionKey -RowKey $RowKey

# if the build was cancelled and this was a scheduled build, we need to set the metadata status back to "Live"
if ($r -ne $null -and $AgentJobStatus -eq "Canceled" -and $BuildReason -ne "PullRequest") {
    if ($r.status -eq $null) {
        Add-Member -InputObject $r -NotePropertyName "status" -NotePropertyValue "Live"
    }
    else {
        $r.status = "Live"
    }
    Write-Host "Build Canceled, setting status back to Live"
    $r | Update-AzTableRow -table $cloudTable
    exit
}

$BestPracticeResult = $BestPracticeResult -ireplace [regex]::Escape("true"), "PASS"
$BestPracticeResult = $BestPracticeResult -ireplace [regex]::Escape("false"), "FAIL"
$CredScanResult = $CredScanResult -ireplace [regex]::Escape("true"), "PASS"
$CredScanResult = $CredScanResult -ireplace [regex]::Escape("false"), "FAIL"
$FairfaxDeployment = $FairfaxDeployment -ireplace [regex]::Escape("true"), "PASS"
$FairfaxDeployment = $FairfaxDeployment -ireplace [regex]::Escape("false"), "FAIL"
$PublicDeployment = $PublicDeployment -ireplace [regex]::Escape("true"), "PASS"
$PublicDeployment = $PublicDeployment -ireplace [regex]::Escape("false"), "FAIL"

Write-Host "Supported Environments Found: $supportedEnvironmentsJson"
$supportedEnvironments = ($supportedEnvironmentsJson | ConvertFrom-JSON -AsHashTable)

if($ValidationType -eq "Manual") { # otherwise this is already set to "Not Supported"
    if($supportedEnvironments.Contains("AzureUSGovernment")){
        $FairfaxDeployment = "Manual Test" 
    }
    if($supportedEnvironments.Contains("AzureCloud")){
        $PublicDeployment = "Manual Test"
    }
}

# if the record doesn't exist, this is probably a new sample and needs to be added (or we just cleaned the table)
if ($r -eq $null) {

    Write-Host "No record found, adding a new one..."
    $results = New-Object -TypeName hashtable
    Write-Host "BP Result: $BestPracticeResult"
    if (![string]::IsNullOrWhiteSpace($BestPracticeResult)) {
        Write-Host "Adding BP results to hashtable..."
        $results.Add("BestPracticeResult", $BestPracticeResult)
    }
    Write-Host "CredScan Result: $CredScanResult"
    if (![string]::IsNullOrWhiteSpace($CredScanResult)) {
        $results.Add("CredScanResult", $CredScanResult)
    }
    # set the values for Fairfax only if a result was passed
    Write-Host "FF Result"
    if (![string]::IsNullOrWhiteSpace($FairfaxDeployment)) { 
        $results.Add("FairfaxDeployment", $FairfaxDeployment) 
        $results.Add("FairfaxLastTestDate", $FairfaxLastTestDate) 
    }
    # set the values for MAC only if a result was passed
    Write-Host "Mac Result"
    if (![string]::IsNullOrWhiteSpace($PublicDeployment)) {
        $results.Add("PublicDeployment", $PublicDeployment) 
        $results.Add("PublicLastTestDate", $PublicLastTestDate) 
    }
    # add metadata columns
    Write-Host "New Record: adding metadata"
    $results.Add("itemDisplayName", $Metadata.itemDisplayName)
    $results.Add("description", $Metadata.description)
    $results.Add("summary", $Metadata.summary)
    $results.Add("githubUsername", $Metadata.githubUsername)
    $results.Add("dateUpdated", $Metadata.dateUpdated)

    if ($BuildReason -eq "PullRequest") {
        $results.Add("status", $BuildReason)
        $results.Add($($ResultDeploymentParameter + "BuildNumber"), $ENV:BUILD_BUILDNUMBER)
        $results.Add("pr", $ENV:SYSTEM_PULLREQUEST_PULLREQUESTNUMBER)
    }

    Write-Host "New Record: Dump results variable"

    $results | fl *
    Write-Host "New Record: Add-AzTableRow"

    Add-AzTableRow -table $cloudTable `
        -partitionKey $PartitionKey `
        -rowKey $RowKey `
        -property $results `
        -Verbose
}
else {
    # Update the existing row - need to check to make sure the columns exist
    Write-Host "Updating the existing record from:"
    $r | fl *

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

    if ($BuildReason -eq "PullRequest") {
        if ($r.status -eq $null) {
            Add-Member -InputObject $r -NotePropertyName "status" -NotePropertyValue $BuildReason            
        }
        else {
            $r.status = $BuildReason
        }
        # set the pr number only if the column isn't present (should be true only for older prs before this column was added)
        if ($r.pr -eq $null) {
            Add-Member -InputObject $r -NotePropertyName "pr" -NotePropertyValue $ENV:SYSTEM_PULLREQUEST_PULLREQUESTNUMBER            
        }
        
        # if it's a PR, set the build number, since it's not set before this outside of a scheduled build
        if ($r.($ResultDeploymentParameter + "BuildNumber") -eq $null) {
            Add-Member -InputObject $r -NotePropertyName ($ResultDeploymentParameter + "BuildNumber") -NotePropertyValue $ENV:BUILD_BUILDNUMBER           
        }
        else {
            $r.($ResultDeploymentParameter + "BuildNumber") = $ENV:BUILD_BUILDNUMBER
        }
        if ($r.pr -eq $null) {
            Add-Member -InputObject $r -NotePropertyName "pr" -NotePropertyValue $ENV:SYSTEM_PULLREQUEST_PULLREQUESTNUMBER
        }
        else {
            $r.pr = $ENV:SYSTEM_PULLREQUEST_PULLREQUESTNUMBER
        }   
    
    }
    else {
        # if this isn't a PR, then it's a scheduled build so set the status back to "live" as the test is complete
        if ($r.status -eq $null) {
            Add-Member -InputObject $r -NotePropertyName "status" -NotePropertyValue "Live"
        }
        else {
            $r.status = "Live"
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
    $r | fl *
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
    # TODO can be removed when table is updated to string
    $FairfaxDeployment = ($r.FairfaxDeployment).ToString().ToLower().Replace("true", "PASS").Replace("false", "FAIL")
}
switch ($FairfaxDeployment) {
    "PASS" { $FairfaxDeploymentColor = "brightgreen" }
    "FAIL" { $FairfaxDeploymentColor = "red" }
    "Not Supported" { $FairfaxDeploymentColor = "yellow" }
    "Manual Test" { $FairfaxDeploymentColor = "blue" }
    default {
        $FairfaxDeployment = $na
        $FairfaxDeploymentColor = "inactive"    
    }
}

if ($r.PublicDeployment -ne $null) {
    # TODO can be removed when table is updated to string
    $PublicDeployment = ($r.PublicDeployment).ToString().ToLower().Replace("true", "PASS").Replace("false", "FAIL")
}
switch ($PublicDeployment) {
    "PASS" { $PublicDeploymentColor = "brightgreen" }
    "FAIL" { $PublicDeploymentColor = "red" }
    "Not Supported" { $PublicDeploymentColor = "yellow" }
    "Manual Test" { $PublicDeploymentColor = "blue" }
    default {
        $PublicDeployment = $na
        $PublicDeploymentColor = "inactive"    
    }
}

if ($r.BestPracticeResult -ne $null) {
    # TODO can be removed when table is updated to string
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
    # TODO can be removed when table is updated to string
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

Write-Host "Uploading Badges..."
foreach ($badge in $badges) {
    (Invoke-WebRequest -Uri $($badge.url)).Content | Set-Content -Path $badge.filename -Force
    <#
        if this is just a PR, we don't want to overwrite the live badges until it's merged
        just create the badges in the "pr" folder and they will be copied over by a CI build when merged
        scheduled builds should be put into the "live" container (i.e. badges)
    #>
    if ($BuildReason -eq "PullRequest") {
        $containerName = "prs"
    }
    else {
        $containerName = "badges"
    }

    $badgePath = $RowKey.Replace("@", "/")

    Set-AzStorageBlobContent -Container $containerName `
        -File $badge.filename `
        -Blob "$badgePath/$($badge.filename)" `
        -Context $ctx `
        -Properties @{"ContentType" = "image/svg+xml"; "CacheControl" = "no-cache" } `
        -Force -Verbose
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