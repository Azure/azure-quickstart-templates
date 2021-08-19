$ErrorActionPreference = 'Stop'

# Enable the static website feature on the storage account.
$storageAccount = Get-AzStorageAccount -ResourceGroupName $env:ResourceGroupName -AccountName $env:StorageAccountName
$ctx = $storageAccount.Context
Enable-AzStorageStaticWebsite -Context $ctx -IndexDocument $env:IndexDocumentPath -ErrorDocument404Path $env:ErrorDocument404Path

# Create a blob for the index page, and add it to the $web blob container.
New-Item $env:IndexDocumentPath -Force
Set-Content $env:IndexDocumentPath $env:IndexDocumentContents
Set-AzStorageBlobContent -Context $ctx -Container '$web' -File $env:IndexDocumentPath -Blob $env:IndexDocumentPath -Properties @{'ContentType' = 'text/html'}

# Create a blob for the error document page, and add it to the $web blob container.
New-Item $env:ErrorDocument404Path -Force
Set-Content $env:ErrorDocument404Path $env:ErrorDocument404Contents
Set-AzStorageBlobContent -Context $ctx -Container '$web' -File $env:ErrorDocument404Path -Blob $env:ErrorDocument404Path -Properties @{'ContentType' = 'text/html'}
