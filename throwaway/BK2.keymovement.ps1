param(
                [Parameter(Mandatory=$True)]
                [string]$TransferSA,
                [Parameter(Mandatory=$True)]
                [string]$TransferKey,
                [Parameter(Mandatory=$True)]
                [string]$DataSA,
                [Parameter(Mandatory=$True)]
                [string]$DataKey
)
 
$DataKey > ".\$DataSA.sa"
 
$context = New-AzureStorageContext -StorageAccountName $TransferSA -StorageAccountKey $TransferKey
New-AzureStorageContainer -Name "sas" -Context $context
Set-AzureStorageBlobContent -Container "sas" -File ".\$DataSA.sa" -Blob "$DataSA.sa" -Context $context -Force

$context = New-AzureStorageContext -StorageAccountName $DataSA -StorageAccountKey $DataKey
New-AzureStorageContainer -Name "vhds" -Context $context
