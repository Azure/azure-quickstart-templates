<#

This script is used to update the table where the test results for each sample are stored.
Typical scenario is that results will be passed in for only one cloud Public or Fairfax - so the 

#>

param(
    [Parameter(Mandatory = $true)]$SampleFolder,
    [Parameter(Mandatory = $true)]$BuildSourcesDirectory,
    [Parameter(Mandatory = $false)]$StorageAccountResourceGroupName = "ttk-gen-artifacts-storage",
    [Parameter(Mandatory = $false)]$StorageAccountName = "azbotstorage",
    [Parameter(Mandatory = $false)]$TableName = "QuickStartDeploymentStatus",
    [Parameter(Mandatory = $false)]$BestPracticeResult = $null,
    [Parameter(Mandatory = $false)]$CredScanResult = $null,
    [Parameter(Mandatory = $false)]$FairfaxDeployment = $null,
    [Parameter(Mandatory = $false)]$FairfaxLastTestDate = (Get-Date -Format "yyyy-MM-dd").ToString(),
    [Parameter(Mandatory = $false)]$PublicDeployment = $null,
    [Parameter(Mandatory = $false)]$PublicLastTestDate = (Get-Date -Format "yyyy-MM-dd").ToString()
)

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
    $results.Add("BestPracticeResult", $BestPracticeResult)
    $results.Add("CredScanResult", $CredScanResult)
    # set the values for Fairfax only if a result was passed
    if ($FairfaxDeployment -ne $null) { 
        $results.Add("FairfaxDeployment", $FairfaxDeployment) 
        $results.Add("FairfaxLastTestDate", $FairfaxLastTestDate) 
    }
    # set the values for MAC only if a result was passed
    if ($PublicDeployment -ne $null) {
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
    $r.BestPracticeResult = $BestPracticeResult
    $r.CredScanResult = $CredScanResult
    # set the values for FF only if a result was passed
    if ($FairfaxDeployment -ne $null) { 
        $r.FairfaxDeployment = $FairfaxDeployment
        $r.FairfaxLastTestDate = $FairfaxLastTestDate 
    }
    # set the values for MAC only if a result was passed
    if ($PublicDeployment -ne $null) {
        $r.PublicDeployment = $PublicDeployment 
        $r.PublicLastTestDate = $PublicLastTestDate 
    }
    $r | Update-AzTableRow -table $cloudTable
}
