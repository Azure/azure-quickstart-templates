param(
        [string] $storageAccountName,
        [string] $resourceGroupName,
        [string] $container,
        [string] $blob
    )

    ## Function to upload blob contents  
Function UploadBlobContent  
{  
    $storageAccount = Get-AzStorageAccount -ResourceGroupName $resourceGroupName -Name $storageAccountName      
    ## Get the storage account context
    $context = $storageAccount.Context
    ## Upload a file
    Set-AzStorageBlobContent -Container $container -File $blob -Blob $blob -Context $context -Force      
}   
  
UploadBlobContent