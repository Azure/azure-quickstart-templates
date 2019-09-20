<#

This script is used to update the table where the test results for each sample are stored.
Typical scenario is that results will be passed in for only one cloud Public or Fairfax - so the 

#>

param(
    [string][Parameter(Mandatory = $true)]$SampleFolder, #this is the path to the sample, relative to BuildSourcesDirectory
    [string][Parameter(Mandatory = $true)]$BuildSourcesDirectory, #this is the path to the root of the repo on disk
    [string]$StorageAccountResourceGroupName = "ttk-gen-artifacts-storage",
    [string]$StorageAccountName = "azbotstorage",
    [string]$TableName = "QuickStartDeploymentStatus",
    [string]$BestPracticeResult = "",
    [string]$CredScanResult = "",
    [string]$FairfaxDeployment = "",
    [string]$FairfaxLastTestDate = (Get-Date -Format "yyyy-MM-dd").ToString(),
    [string]$PublicDeployment = "",
    [string]$PublicLastTestDate = (Get-Date -Format "yyyy-MM-dd").ToString()
)

$SampleFolder = $SampleFolder.TrimEnd("/").TrimEnd("\")
$BuildSourcesDirectory = $BuildSourcesDirectory.TrimEnd("/").TrimEnd("\")

# Get the storage table that contains the "status" for the deployment/test results
$ctx = (Get-AzStorageAccount -Name $StorageAccountName -ResourceGroupName $StorageAccountResourceGroupName).Context
$cloudTable = (Get-AzStorageTable –Name $tableName –Context $ctx).CloudTable

#Get the type of Sample from metadata.json, needed for the partition key lookup
$PathToMetadata = "$SampleFolder\metadata.json"
Write-Host "PathToMetadata: $PathToMetadata"

$RowKey = $SampleFolder.Replace("$BuildSourcesDirectory\", "").Replace("\", "@").Replace("/", "@")
Write-Host "RowKey: $RowKey"

$Metadata = Get-Content $PathToMetadata -Raw | ConvertFrom-Json
$PartitionKey = $Metadata.Type

#Get the row to update
$r = Get-AzTableRow -table $cloudTable -PartitionKey $PartitionKey -RowKey $RowKey

# if the record doesn't exist, this is probably a new sample and needs to be added (or we just cleaned the table)
if ($r -eq $null) {

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

    Add-AzTableRow -table $cloudTable `
        -partitionKey $PartitionKey `
        -rowKey $RowKey `
        -property $results
}
else {
    # Update the existing row
    if (![string]::IsNullOrWhiteSpace($BestPracticeResult)) {
        $r.BestPracticeResult = $BestPracticeResult
    }
    if (![string]::IsNullOrWhiteSpace($CredScanResult)) {
        $r.CredScanResult = $CredScanResult
    }
    # set the values for FF only if a result was passed
    if (![string]::IsNullOrWhiteSpace($FairfaxDeployment)) { 
        $r.FairfaxDeployment = $FairfaxDeployment
        $r.FairfaxLastTestDate = $FairfaxLastTestDate 
    }
    # set the values for MAC only if a result was passed
    if (![string]::IsNullOrWhiteSpace($PublicDeployment)) {
        $r.PublicDeployment = $PublicDeployment 
        $r.PublicLastTestDate = $PublicLastTestDate 
    }
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
    if ($FairfaxDeployment -eq "PASS") { $FairfaxDeploymentColor = "brightgreen" }else { $FairfaxDeploymentColor = "red" }

}
else {
    $FairfaxDeployment = $na
    $FairfaxDeploymentColor = "inactive"
}

if ($r.PublicDeployment -ne $null) {
    $PublicDeployment = ($r.PublicDeployment).ToString().ToLower().Replace("true", "PASS").Replace("false", "FAIL")
    if ($PublicDeployment -eq "PASS") { $PublicDeploymentColor = "brightgreen" }else { $PublicDeploymentColor = "red" }
}
else {
    $PublicDeployment = $na
    $PublicDeploymentColor = "inactive"
}

if ($r.BestPracticeResult -ne $null) {
    $BestPracticeResult = ($r.BestPracticeResult).ToString().ToLower().Replace("true", "PASS").Replace("false", "FAIL")
    if ($BestPracticeResult -eq "PASS") { $BestPracticeResultColor = "brightgreen" }else { $BestPracticeResultColor = "red" }
}
else {
    $BestPracticeResult = $na
    $BestPracticeResultColor = "inactive"
}

if ($r.CredScanResult -ne $null) {
    $CredScanResult = ($r.CredScanResult).ToString().ToLower().Replace("true", "PASS").Replace("false", "FAIL")
    if ($CredScanResult -eq "PASS") { $CredScanResultColor = "brightgreen" }else { $CredScanResultColor = "red" }
}
else {
    $CredScanResult = $na
    $CredScanResultColor = "inactive"
}

$blobUri = "$($ctx.BlobEndPoint)/badges/"

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
    Set-AzStorageBlobContent -Container "badges" -File $badge.filename -Blob "$RowKey/$($badge.filename)" -Context $ctx -Force -Properties @{"ContentType"="image/svg+xml"}
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

<IMG SRC="https://azbotstorage.blob.core.windows.net/badges/100-blank-template/PublicLastTestDate.svg" />&nbsp;
<IMG SRC="https://azbotstorage.blob.core.windows.net/badges/100-blank-template/PublicDeployment.svg" />&nbsp;

<IMG SRC="https://azbotstorage.blob.core.windows.net/badges/100-blank-template/FairfaxLastTestDate.svg" />&nbsp;
<IMG SRC="https://azbotstorage.blob.core.windows.net/badges/100-blank-template/FairfaxDeployment.svg" />&nbsp;

<IMG SRC="https://azbotstorage.blob.core.windows.net/badges/100-blank-template/BestPracticeResult.svg" />&nbsp;
<IMG SRC="https://azbotstorage.blob.core.windows.net/badges/100-blank-template/CredScanResult.svg" />&nbsp;

#>