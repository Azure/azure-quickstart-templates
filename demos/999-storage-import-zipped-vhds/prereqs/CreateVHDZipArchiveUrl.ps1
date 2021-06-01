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

##### Create a VHD archive zip

$timestamp = (Get-Date -Format 'yyMMddhhmmss')
$vhdZipArchive = 'fake-vhd-disk-archive-{0}.zip' -f $timestamp

New-Item -Force -Type File -Name ('fake-vhd-disk1-{0}.vhd' -f $timestamp) 
New-Item -Force -Type File -Name ('fake-vhd-disk2-{0}.vhd' -f $timestamp)
New-Item -Force -Type File -Name ('fake-vhd-disk3-{0}.vhd' -f $timestamp)
New-Item -Force -Type File -Name ('fake-readme-{0}.md' -f $timestamp)

Compress-Archive -Force -Path 'fake*' -DestinationPath $vhdZipArchive             

##### Storage account

$StorageAccount = Get-AzStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccountName
$Blob = Set-AzStorageBlobContent -File $vhdZipArchive -Container $BlobContainerName -blob $vhdZipArchive -context $StorageAccount.Context
$urlVHDZipArchive = New-AzStorageBlobSASToken -FullUri -Context $StorageAccount.Context -Container $BlobContainerName -Blob $vhdZipArchive -Permission r -StartTime $StartTime -ExpiryTime $EndTime

##### Output
$DeploymentScriptOutputs = @{}
$DeploymentScriptOutputs['urlVHDZipArchive'] = $urlVHDZipArchive