param(
  [string] $Source,
  [string] $Destination
)

##### Validate Parameters

if (! ([System.Uri]::IsWellFormedUriString($Source,[System.UriKind]::Absolute))) {
  Throw 'The Source URL parameter is probably not well formatted. Please check and retry.'
}

if (! ([System.Uri]::IsWellFormedUriString($Destination,[System.UriKind]::Absolute))) {
  Throw 'The Destination URI parameter is probably not well formatted. The URI of a Storage Account Container with a SAS Token is expected. Please check and retry.'
}

##### Parameters

$urlVHDZipArchive = $Source
$uriWritableStorageAccountBlobContainerSasToken = $Destination

$ResourceGroupName = ${Env:ResourceGroupName}

##### Variables

$base_path='/mnt/azscripts'
$temp_path='{0}/temp' -f $base_path
New-Item -Type Directory -ErrorAction SilentlyContinue $temp_path

$timestamp = Get-Date -Format 'yyMMddHHmmss'

##### Prereqs

Write-Output 'Increase file share quota to 4TB instead of 2GB before downloading and expanding'
$QuotaGiB = '4096'
Get-AzStorageAccount -ResourceGroupName $ResourceGroupName | Where-Object { $_.StorageAccountName -like '*azscripts' } | ForEach-Object {
  $StorageAccount = $_
  Get-AzStorageShare -Context $StorageAccount.Context | ForEach-Object { 
    $Share = $_
    Set-AzStorageShareQuota -ShareName $Share.Name -Context $StorageAccount.Context -Quota $QuotaGiB
  }
}

##### Fetch and process

Write-Output 'Download the ZIP archive'
$archive_path='{0}/archive-{1}.zip' -f $temp_path,$timestamp
# Accelerate file download (initially using Invoke-WebRequest)
(New-Object System.Net.WebClient).DownloadFile($urlVHDZipArchive, $archive_path)

Write-Output 'Expand locally'
$expanded_archive_path ='{0}/expanded-{1}' -f $temp_path,$timestamp
New-Item -Type Directory -ErrorAction SilentlyContinue $expanded_archive_path
Expand-Archive -Path $archive_path -DestinationPath $expanded_archive_path -Force

##### Upload to Azure Storage account

Write-Output 'Upload extracted VHD file(s)'

$DeploymentScriptOutputs = @{}
$DeploymentScriptOutputs['vhdBlobUriList'] = @{}
$DeploymentScriptOutputs['vhdBlobSHA256List'] = @{}

$StorageAccountContainerUri = ($uriWritableStorageAccountBlobContainerSasToken -split [Regex]::Escape('?'))[0]
$StorageAccountName = (([System.Uri]$uriWritableStorageAccountBlobContainerSasToken).Host -split [Regex]::Escape('.'))[0]
$ContainerName = ($StorageAccountContainerUri -split '/')[-1]  # Last element
$StorageAccountContainerSASToken = ($uriWritableStorageAccountBlobContainerSasToken -split [Regex]::Escape('?'))[1]
$StorageAccountContext = New-AzStorageContext -StorageAccountName $StorageAccountName -SasToken $StorageAccountContainerSASToken

$vhd_filepath='{0}/*.vhd' -f  $expanded_archive_path

Get-Item $vhd_filepath | ForEach-Object {
  $localFilePath = $_
  $vhdBlobName = $localFilePath.Name
  $vhdBlobUri = '{0}/{1}' -f $StorageAccountContainerUri,$vhdBlobName

  $hash = (Get-FileHash -Algorithm SHA256 -Path $localFilePath).Hash
  $metadata = @{'SHA256' = $hash; }

  Write-Output 'Uploading ' + $vhdBlobName
  Set-AzStorageBlobContent -File $localFilePath -Context $StorageAccountContext -Container $ContainerName -Blob $vhdBlobName -BlobType Page -Metadata $metadata -Force
  $DeploymentScriptOutputs['vhdBlobUriList'][$vhdBlobName] = $vhdBlobUri
  $DeploymentScriptOutputs['vhdBlobSHA256List'][$vhdBlobName] = $hash
}
