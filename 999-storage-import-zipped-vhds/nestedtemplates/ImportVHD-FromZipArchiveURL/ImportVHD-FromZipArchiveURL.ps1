param(
  [string] $Source,
  [string] $Destination,
  [string] $azcopyZipArchiveUrl = 'https://aka.ms/downloadazcopy-v10-linux'
)

##### Validate Parameters

if (! ([System.Uri]::IsWellFormedUriString($Source,[System.UriKind]::Absolute))) {
  Throw 'The Source URL parameter is probably not well formatted. Please check and retry.'
}

if (! ([System.Uri]::IsWellFormedUriString($Destination,[System.UriKind]::Absolute))) {
  Throw 'The Destination URI parameter is probably not well formatted. Please check and retry.'
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

##### Fetch prerequisites

Invoke-WebRequest -Uri $azcopyZipArchiveUrl -Outfile azcopy-linux.tar
tar xf azcopy-linux.tar
Move-Item azcopy_linux_*/azcopy . -Force

##### Check destination is actually writable or fail

$testFileName = 'Test-{0}' -f $timestamp
New-Item -Force -Type File -Name $testFileName
./azcopy copy $testFileName "$uriWritableStorageAccountBlobContainerSasToken"
if (! $?) {
  Throw 'Cannot upload into the Storage Account Container. Please check the Destination parameter contains the URI of Storage Account Container with the SAS Token'
}

##### Download for processing

Write-Output 'Increase file share quota to 4TB instead of 2GB before downloading and expanding'
$QuotaGiB = '4096'
Get-AzStorageAccount -ResourceGroupName $ResourceGroupName | Where-Object { $_.StorageAccountName -like '*azscripts' } | ForEach-Object {
  $StorageAccount = $_
  Get-AzStorageShare -Context $StorageAccount.Context | ForEach-Object { 
    $Share = $_
    Set-AzStorageShareQuota -ShareName $Share.Name -Context $StorageAccount.Context -Quota $QuotaGiB
  }
}


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
$vhd_filepath='{0}/*.vhd' -f  $expanded_archive_path
./azcopy copy "$vhd_filepath" "$uriWritableStorageAccountBlobContainerSasToken" --put-md5

##### Output

$DeploymentScriptOutputs = @{}
$DeploymentScriptOutputs['vhdBlobUriList'] = @{}
$DeploymentScriptOutputs['vhdBlobSHA256List'] = @{}

$StorageAccountContainerUri = ($uriWritableStorageAccountBlobContainerSasToken -split [Regex]::Escape('?'))[0]
Get-Item $vhd_filepath | % {
  $VHDBlobName = $_.Name
  $vhdBlobUri = "$StorageAccountContainerUri/$VHDBlobName"
  $hash = (Get-FileHash -Algorithm SHA256 -Path $_).Hash
  $DeploymentScriptOutputs['vhdBlobUriList'][$_.Name] = $vhdBlobUri
  $DeploymentScriptOutputs['vhdBlobSHA256List'][$_.Name] = $hash
}