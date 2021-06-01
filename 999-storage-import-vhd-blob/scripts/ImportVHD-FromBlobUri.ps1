param(
    [string] $Source,
    [string] $Destination,

  # Set default url to fetch azcopy
  ## get latest: curl -s -D- https://aka.ms/downloadazcopy-v10-linux | grep ^Location
  ## 10.10.0: sporadic vhd corruption issue / fatal error lifecyleMgr.go:38 (https://azcopyvnext.azureedge.net/release20210415/azcopy_linux_amd64_10.10.0.tar.gz)
  ## 10.9.0: sporadic vhd corruption issue https://azcopyvnext.azureedge.net/release20210226/azcopy_linux_amd64_10.9.0.tar.gz
  ## 10.8.0: validated https://azcopyvnext.azureedge.net/release20201211/azcopy_linux_amd64_10.8.0.tar.gz
  [string] $azcopyArchiveUrl = 'https://azcopyvnext.azureedge.net/release20201211/azcopy_linux_amd64_10.8.0.tar.gz'
)

##### Validate Parameters

if (! ([System.Uri]::IsWellFormedUriString($Source,[System.UriKind]::Absolute))) {
    Throw 'The Source URL parameter is probably not well formatted. Please check and retry.'
}

if (! ([System.Uri]::IsWellFormedUriString($Destination,[System.UriKind]::Absolute))) {
    Throw 'The Destination URI parameter is probably not well formatted. Please check and retry.'
}

##### Parameters

$uriVhdBlob = $Source
$uriWritableStorageAccountBlobContainerSasToken = $Destination

$ResourceGroupName = ${Env:ResourceGroupName}

##### Variables

$base_path='/mnt/azscripts'
$temp_path='{0}/temp' -f $base_path
New-Item -Type Directory -ErrorAction SilentlyContinue $temp_path

##### Fetch prerequisites

Invoke-WebRequest -Uri $azcopyArchiveUrl -Outfile azcopy-linux.tar.gz
tar xf azcopy-linux.tar.gz
Move-Item azcopy_linux_*/azcopy . -Force

##### Upload to Azure Storage account

Write-Output 'Copy Blob'
./azcopy copy "$uriVhdBlob" "$uriWritableStorageAccountBlobContainerSasToken"

if (! $?) {
    Throw 'Error during upload into the Storage Account Container. Please check source and destination parameters and retry'
}

##### Output

$DeploymentScriptOutputs = @{}
$VhdBlobName = $uriVhdBlob -replace '.*/(?<name>.*.VHD).*','${name}'
$DeploymentScriptOutputs['vhdBlobName'] = $VhdBlobName
$StorageAccountContainerUri = ($uriWritableStorageAccountBlobContainerSasToken -split [Regex]::Escape('?'))[0]
$DeploymentScriptOutputs['vhdBlobUri'] = '{0}/{1}' -f $StorageAccountContainerUri,$VhdBlobName
