<#

This script is used to update the table where the test results for each sample are stored.

#>

param(
    [Parameter(Mandatory = $true)]$SourceDirectory = ".",
    [Parameter(Mandatory = $true)]$StorageAccountResourceGroupName = "ttk-gen-artifacts-storage",
    [Parameter(Mandatory = $true)]$StorageAccountName = "azbotstorage",
    [Parameter(Mandatory = $true)]$TableName = "QuickStartDeploymentStatus",
    [Parameter(Mandatory = $true)]$RowKey = "100-blank-template",
    [Parameter(Mandatory = $false)]$BestPracticeResult = $false,
    [Parameter(Mandatory = $false)]$CredScanResult = $false,
    [Parameter(Mandatory = $false)]$FairfaxDeployment = $false,
    [Parameter(Mandatory = $false)]$FairfaxLastTestDate = (Get-Date -Format "yyyy-MM-dd").ToString(),
    [Parameter(Mandatory = $false)]$PublicDeployment = $false,
    [Parameter(Mandatory = $false)]$PublicLastTestDate = (Get-Date -Format "yyyy-MM-dd").ToString()
)

# Get the storage table that contains the "status" for the deployment/test results
$ctx = (Get-AzStorageAccount -Name $StorageAccountName -ResourceGroupName $StorageAccountResourceGroupName).Context
$cloudTable = (Get-AzStorageTable –Name $tableName –Context $ctx).CloudTable

#Get the type of Sample from metadata.json, needed for the partition key lookup
$PathToSample = ("$SourceDirectory\$RowKey\metadata.json").Replace("@", "\")
$Metadata = Get-Content $PathToSample -Raw | ConvertFrom-Json
$PartitionKey = $Metadata.Type

#Get the row to update
$r = Get-AzTableRow -table $cloudTable -PartitionKey $PartitionKey -RowKey $RowKey

# if the record doesn't exist, probably a new sample and needs to be added
if ($r -eq $null) {

    Add-AzTableRow -table $cloudTable `
        -partitionKey $PartitionKey `
        -rowKey $RowKey `
        -property @{"BestPracticeResult" = $BestPracticeResult; `
            "CredScanResult"             = $CredScanResult; `
            "FairfaxDeployment"          = $FairfaxDeployment; `
            "FairfaxLastTestDate"        = $FairfaxLastTestDate; `
            "PublicDeployment"           = $PublicDeployment; `
            "PublicLastTestDate"         = $PublicLastTestDate; 
    }
}
else { # Update the existing row

    $r.BestPracticeResult = $BestPracticeResult
    $r.CredScanResult = $CredScanResult
    $r.FairfaxDeployment = $FairfaxDeployment
    $r.FairfaxLastTestDate = $FairfaxLastTestDate
    $r.PublicDeployment = $PublicDeployment
    $r.PublicLastTestDate = $PublicLastTestDate

    $r | Update-AzTableRow -table $cloudTable
}

#$t = Get-AzTableRow -table $cloudTable | Sort-Object -Property $TableSortKey 
#$t | ft