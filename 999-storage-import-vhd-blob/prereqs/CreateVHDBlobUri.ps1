param(
    [string] $StorageAccountName,
    [string] $BlobContainerName
)

##### Parameters

$StorageAccountName
$BlobContainerName

$ResourceGroupName = ${Env:ResourceGroupName}

##### Variables

$StartTime = Get-Date
$EndTime = $startTime.AddHours(2.0)

##### Create a file with VHD extension

$timestamp = (Get-Date -Format 'yyMMddhhmmss')
$vhdBlobName = 'fake-vhd-disk-{0}.vhd' -f $timestamp
New-Item -Force -Type File -Name $vhdBlobName

##### Storage account

$StorageAccount = Get-AzStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccountName
$Blob = Set-AzStorageBlobContent -File $vhdBlobName -Container $BlobContainerName -blob $vhdZipArchive -context $StorageAccount.Context
$urlVHDBlob = New-AzStorageBlobSASToken -FullUri -Context $StorageAccount.Context -Container $BlobContainerName -Blob $vhdBlobName -Permission r -StartTime $StartTime -ExpiryTime $EndTime

##### Output
$DeploymentScriptOutputs = @{}
$DeploymentScriptOutputs['uriVHDBlobSasToken'] = $urlVHDBlob