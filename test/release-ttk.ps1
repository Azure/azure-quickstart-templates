
param(
    [string]$StorageAccountResourceGroupName = "azure-quickstarts-service-storage",
    [string]$StorageAccountName = "azurequickstartsservice",
    [string]$containerName = "ttk",
    [string]$folderName = "latest",
    [string]$ttkFileName = "arm-template-toolkit.zip",
    [switch]$Publish
)

# this must be run from the "test" folder
$releaseFiles = ".\ci-scripts", "template-tests", "..\Deploy-AzTemplate.ps1"

Compress-Archive -DestinationPath $ttkFileName -Path $releaseFiles -Force

if ($Publish) {
    $ctx = (Get-AzStorageAccount -Name $StorageAccountName -ResourceGroupName $StorageAccountResourceGroupName).Context
    Set-AzStorageBlobContent -Container $containerName `
        -File $ttkFileName `
        -Blob "$folderName/$ttkFileName" `
        -Context $ctx `
        -Force `
        -Properties @{"ContentType" = "application/x-zip-compressed"; "CacheControl" = "no-cache" }
}