
param(
    [string]$StorageAccountResourceGroupName = "azure-quickstarts-service-storage",
    [string]$StorageAccountName = "azurequickstartsservice",
    [string]$containerName = "ttk",
    [string]$folderName = "latest",
    [string]$ttkFileName = "arm-template-toolkit.zip",
    [switch]$Publish,
    [switch]$amp # temporary switch for AMP backward compatibility
)

# this must be run from the "test" folder

$releaseFiles = ".\arm-ttk", ".\ci-scripts", "..\Deploy-AzTemplate.ps1"

Compress-Archive -DestinationPath $ttkFileName -Path $releaseFiles -Force

# Temp step for AMP backward compat
if ($amp) {
    Copy-Item ".\arm-ttk" -Destination ".\template-tests" -Recurse
    $releaseFiles += ".\template-tests"
    $releaseFiles = $releaseFiles -ne ".\arm-ttk"
    Compress-Archive -DestinationPath "AzTemplateToolkit.zip" -Path $releaseFiles -Force
    Remove-Item ".\template-tests" -Recurse
}
    # End Temp step

if ($Publish) {
    $ctx = (Get-AzStorageAccount -Name $StorageAccountName -ResourceGroupName $StorageAccountResourceGroupName).Context
    Set-AzStorageBlobContent -Container $containerName `
        -File $ttkFileName `
        -Blob "$folderName/$ttkFileName" `
        -Context $ctx `
        -Force -Verbose `
        -Properties @{"ContentType" = "application/x-zip-compressed"; "CacheControl" = "no-cache" }
}