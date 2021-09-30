<#

This script is used to update the table where the test results for each sample are stored.
Typical scenario is that results will be passed in for only one cloud Public or Fairfax - so the 

#>

param(
    [string]$SampleFolder = $ENV:SAMPLE_FOLDER, # this is the full absolute path to the sample
    [string]$SampleName = $ENV:SAMPLE_NAME, # the name of the sample or folder path from the root of the repo (i.e. relative path) e.g. "sample-type/sample-name"
    [string]$StorageAccountName = $ENV:STORAGE_ACCOUNT_NAME,
    [string]$TableName = "QuickStartsMetadataService",
    [string]$TableNamePRs = "QuickStartsMetadataServicePRs",
    [string]$BadgesContainerName = "badges",
    [string]$PRsContainerName = "prs",
    [string]$RegressionsTableName = "Regressions",
    [Parameter(mandatory = $true)][string]$StorageAccountKey, 
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
    [string]$PublicLastTestDate = (Get-Date -Format "yyyy-MM-dd").ToString(),
    [string]$BicepVersion = $ENV:BICEP_VERSION, # empty if bicep not supported by the sample
    [string]$TemplateAnalyzerResult = "$ENV:TEMPLATE_ANALYZER_RESULT",
    [string]$TemplateAnalyzerOutputFilePath = "$ENV:TEMPLATE_ANALYZER_OUTPUT_FILEPATH",
    [string]$TemplateAnalyzerLogsContainerName = "$ENV:TEMPLATE_ANALYZER_LOGS_CONTAINER_NAME"
)

function Get-Regression(
    [object] $oldRow,
    [object] $newRow,
    [string] $propertyName
) {
    $oldValue = $oldRow.$propertyName
    $newValue = $newRow.$propertyName

    Write-Host "Comparison results for ${propertyName}: '$oldValue' -> '$newValue'"

    if (![string]::IsNullOrWhiteSpace($newValue)) { 
        $oldResultPassed = $oldValue -eq "PASS"
        $newResultPassed = $newValue -eq "PASS"

        if ($oldResultPassed -and !$newResultPassed) {
            Write-Warning "REGRESSION: $propertyName changed from '$oldValue' to '$newValue'"
            return $true
        }
    }

    return $false
}

function Convert-EntityToHashtable([PSCustomObject] $entity) {
    $hashtable = New-Object -Type Hashtable
    $entity | Get-Member -MemberType NoteProperty | ForEach-Object {
        $name = $_.Name
        if ($name -ne "PartitionKey" -and $name -ne "RowKey" -and $name -ne "Etag" -and $name -ne "TableTimestamp") {
            $hashtable[$name] = $entity.$Name
        }
    }
        
    return $hashtable
}

# Get the storage table that contains the "status" for the deployment/test results
Write-Host "Storage account name: $StorageAccountName"
$ctx = New-AzStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $StorageAccountKey -Environment AzureCloud

$isPullRequest = $false
if ($BuildReason -eq "PullRequest") {
    $isPullRequest = $true
    $t = $TableNamePRs
}
else {
    $t = $TableName
}
Write-Host "Writing to table $t"

if (($BicepVersion -ne "") -and !($BicepVersion -match "^[0-9]+\.[-0-9a-z.]+$")) {
    Write-Error "Unexpected bicep version format: $BicepVersion.  This may be caused by a previous error in the pipeline"
}

$cloudTable = (Get-AzStorageTable –Name $t –Context $ctx).CloudTable

#Get the type of Sample from metadata.json, needed for the partition key lookup
$PathToMetadata = "$SampleFolder\metadata.json"
Write-Host "PathToMetadata: $PathToMetadata"

$RowKey = $SampleName.Replace("\", "@").Replace("/", "@")
Write-Host "RowKey: $RowKey"

$Metadata = Get-Content $PathToMetadata -Raw | ConvertFrom-Json
$PartitionKey = $Metadata.Type # if the type changes we'll have an orphaned row, this is removed in Get-OldestSampleFolder.ps1

#Get the row to update (from either the main table or the PR table, depending on $isPullRequest)
$r = Get-AzTableRow -table $cloudTable -PartitionKey $PartitionKey -RowKey $RowKey

#Get the row to compare for regressions (always from the main table)
$comparisonCloudTable = (Get-AzStorageTable –Name $TableName –Context $ctx).CloudTable
$comparisonResults = Get-AzTableRow -table $comparisonCloudTable -PartitionKey $PartitionKey -RowKey $RowKey
Write-Host "Comparison table for previous results: $TableName"
Write-Host "Comparison table current results: $comparisonResults"

if ($isPullRequest) {
    # For pull requests, we want to check for regressions against the main table, not the PR table
}

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
$TemplateAnalyzerResult = $TemplateAnalyzerResult -ireplace [regex]::Escape("true"), "PASS"
$TemplateAnalyzerResult = $TemplateAnalyzerResult -ireplace [regex]::Escape("false"), "FAIL"

Write-Host "Supported Environments Found: $supportedEnvironmentsJson"
$supportedEnvironments = ($supportedEnvironmentsJson | ConvertFrom-JSON -AsHashTable)

# otherwise this is already set to "Not Supported"
if ($ValidationType -eq "Manual") {
    if ($supportedEnvironments.Contains("AzureUSGovernment")) {
        $FairfaxDeployment = "Manual Test" 
    }
    if ($supportedEnvironments.Contains("AzureCloud")) {
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
    Write-Host "Adding Bicep version to hashtable..."
    $results.Add("BicepVersion", $BicepVersion)
    Write-Host "CredScan Result: $CredScanResult"
    if (![string]::IsNullOrWhiteSpace($CredScanResult)) {
        $results.Add("CredScanResult", $CredScanResult)
    }
    Write-Host "TemplateAnalyzer result: $TemplateAnalyzerResult"
    if (![string]::IsNullOrWhiteSpace($TemplateAnalyzerResult)) {
        $results.Add("TemplateAnalyzerResult", $TemplateAnalyzerResult)
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
    $newResults = $results.PSObject.copy()
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
    if (![string]::IsNullOrWhiteSpace($TemplateAnalyzerResult)) {
        if ($r.TemplateAnalyzerResult -eq $null) {
            Add-Member -InputObject $r -NotePropertyName 'TemplateAnalyzerResult' -NotePropertyValue $TemplateAnalyzerResult
        }
        else {
            $r.TemplateAnalyzerResult = $TemplateAnalyzerResult
        }
    }
    if (![string]::IsNullOrWhiteSpace($BicepVersion)) {
        if ($r.BicepVersion -eq $null) {
            Add-Member -InputObject $r -NotePropertyName 'BicepVersion' -NotePropertyValue $BicepVersion
        }
        else {
            $r.BicepVersion = $BicepVersion
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

    $newResults = $r.PSObject.copy()
}

# Check for regressions with latest non-PR run
$BPRegressed = Get-Regression $comparisonResults $newResults "BestPracticeResult"
$FairfaxRegressed = Get-Regression $comparisonResults $newResults "FairfaxDeployment"
$PublicRegressed = Get-Regression $comparisonResults $newResults "PublicDeployment"
$TemplateAnalyzerRegressed = Get-Regression $comparisonResults $newResults "TemplateAnalyzerResult"

$AnyRegressed = $BPRegressed -or $FairfaxRegressed -or $PublicRegresse

if (!$isPullRequest) {
    Write-Host "Writing regression info to table '$RegressionsTableName'"
    $regressionsTable = (Get-AzStorageTable –Name $RegressionsTableName –Context $ctx).CloudTable
    $regressionsKey = Get-Date -Format "o"
    $regressionsRow = $newResults.PSObject.copy()
    $regressionsRow | Add-Member "Sample" $RowKey
    $regressionsRow | Add-Member "AnyRegressed" $AnyRegressed
    $regressionsRow | Add-Member "BPRegressed" $BPRegressed
    $regressionsRow | Add-Member "FairfaxRegressed" $FairfaxRegressed
    $regressionsRow | Add-Member "PublicRegressed" $PublicRegressed
    $regressionsRow | Add-Member "TemplateAnalyzerRegressed" $TemplateAnalyzerRegressed
    $regressionsRow | Add-Member "BuildNumber" $ENV:BUILD_BUILDNUMBER
    $regressionsRow | Add-Member "BuildId" $ENV:BUILD_BUILDID
    $regressionsRow | Add-Member "Build" "https://dev.azure.com/azurequickstarts/azure-quickstart-templates/_build/results?buildId=$($ENV:BUILD_BUILDID)"
    Add-AzTableRow -table $regressionsTable `
        -partitionKey $PartitionKey `
        -rowKey $regressionsKey `
        -property (Convert-EntityToHashtable $regressionsRow) `
        -Verbose
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
        $BestPracticeResultColor = "inactive"    
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

switch ($TemplateAnalyzerResult) {
    "PASS" { $TemplateAnalyzerResultColor = "brightgreen" }
    "FAIL" { $TemplateAnalyzerResultColor = "red" }
    default {
        $TemplateAnalyzerResult = $na
        $TemplateAnalyzerResultColor = "inactive"    
    }
}

$BicepVersionColor = "brightgreen";
if ($BicepVersion -eq "") { $BicepVersion = "n/a" } # make sure the badge value is not empty

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
    },
    @{
        "url"      = "https://img.shields.io/badge/Bicep%20Version-$BicepVersion-/?color=$BicepVersionColor";
        "filename" = "BicepVersion.svg"
    },
    @{
        "url"      = "https://img.shields.io/badge/Template%20Analyzer%20Check-$TemplateAnalyzerResult-/?color=$TemplateAnalyzerResultColor";
        "filename" = "TemplateAnalyzerResult.svg"
    }
)

Write-Host "Uploading Badges..."
$tempFolder = [System.IO.Path]::GetTempPath();
foreach ($badge in $badges) {
    $badgeTempPath = Join-Path $tempFolder $badge.filename
    (Invoke-WebRequest -Uri $($badge.url)).Content | Set-Content -Path $badgeTempPath -Force
    <#
        if this is just a PR, we don't want to overwrite the live badges until it's merged
        just create the badges in the "pr" folder and they will be copied over by a CI build when merged
        scheduled builds should be put into the "live" container (i.e. badges)
    #>
    if ($BuildReason -eq "PullRequest") {
        $containerName = $PRsContainerName
    }
    else {
        $containerName = $BadgesContainerName
    }

    $badgePath = $RowKey.Replace("@", "/")

    $blobName = "$badgePath/$($badge.filename)"
    Write-Output "Uploading badge to storage account '$($StorageAccountName)', container '$($containerName)', name '$($blobName)':"
    $badge | fl | Write-Output
    Set-AzStorageBlobContent -Container $containerName `
        -File $badgeTempPath `
        -Blob $blobName `
        -Context $ctx `
        -Properties @{"ContentType" = "image/svg+xml"; "CacheControl" = "no-cache" } `
        -Force -Verbose
}

# Upload BPA results file:
$templateAnalyzerLogFileName = "$($ENV:BUILD_BUILDNUMBER)_$RowKey"
Write-Host "Uploading TemplateAnalyzer log file: $templateAnalyzerLogFileName"
try {
    Set-AzStorageBlobContent -Container $TemplateAnalyzerLogsContainerName `
        -File $TemplateAnalyzerOutputFilePath `
        -Blob $templateAnalyzerLogFileName `
        -Context $ctx `
        -Properties @{ "ContentType" = "text/plain" } `
        -Force -Verbose
}
catch {
    Write-Host "===================================================="
    Write-Host " Failed to upload $TemplateAnalyzerOutputFilePath   "
    Write-Host "===================================================="
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