# copy the file to the local disk
Invoke-WebRequest -Uri "${env:contentUri}" -OutFile "${env:csvFileName}"

# get storageAccount context using the key
$ctx = New-AzStorageContext -StorageAccountName "${Env:storageAccountName}" -StorageAccountKey "${Env:storageAccountKey}"

New-AzStorageContainer -Context $ctx -Name "${env:containerName}" -Verbose

# copy blob
Set-AzStorageBlobContent -Context $ctx `
                         -Container "${Env:containerName}" `
                         -Blob "${env:csvFileName}" `
                         -StandardBlobTier 'Hot' `
                         -File "${env:csvFileName}"
