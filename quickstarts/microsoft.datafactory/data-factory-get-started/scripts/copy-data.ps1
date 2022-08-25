
$localFileName = "${env:contentUri}" | Split-Path -Leaf

Invoke-WebRequest -Uri "${env:contentUri}" -OutFile $localFileName

$storageAccount = Get-AzStorageAccount -ResourceGroupName "${Env:RGName}" -Name "${Env:SAName}" 

$ctx = $storageAccount.Context

Set-AzStorageBlobContent -Container "${Env:ContainerName}" -Blob "input/$localFileName" -Context $ctx -StandardBlobTier 'Hot' -File $localFileName
