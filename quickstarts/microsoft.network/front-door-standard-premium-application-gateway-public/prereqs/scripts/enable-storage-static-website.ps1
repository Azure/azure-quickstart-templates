param (
    [string] $ResourceGroupName,
    [string] $StorageAccountName,
    [string] $IndexDocument,
    [string] $ErrorDocument404Path
)

$ErrorActionPreference = 'Stop'

$storageAccount = Get-AzStorageAccount -ResourceGroupName $ResourceGroupName -AccountName $StorageAccountName
$ctx = $storageAccount.Context
Enable-AzStorageStaticWebsite -Context $ctx -IndexDocument $IndexDocument -ErrorDocument404Path $ErrorDocument404Path

New-Item $IndexDocument -Force
Set-Content $IndexDocument '<h1>Welcome</h1>'
Set-AzStorageBlobContent -Context $ctx -Container '$web' -File $IndexDocument -Blob $IndexDocument -Properties @{'ContentType' = 'text/html'}

New-Item $ErrorDocument404Path -Force
Set-Content $ErrorDocument404Path '<h1>Error: 404 Not Found</h1>'
Set-AzStorageBlobContent -Context $ctx -Container '$web' -File $ErrorDocument404Path -Blob $ErrorDocument404Path -Properties @{'ContentType' = 'text/html'}
