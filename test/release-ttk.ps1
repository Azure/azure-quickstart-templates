
param(
    [string]$StorageAccountResourceGroupName = "azure-quickstarts-service-storage",
    [string]$StorageAccountName = "azurequickstartsservice",
    [string]$containerName = "ttk",
    [string]$folderName = "latest",
    [string]$ttkFileName = "arm-template-toolkit.zip",
    [switch]$Staging,
    [switch]$Publish
)

if ($Staging) {
    # Publish to staging folder instead of default ("latest") folder
    $folderName = 'staging'
}

# this must be run from the "test" folder

$releaseFiles = "..\..\arm-ttk\arm-ttk", ".\ci-scripts", "..\Deploy-AzTemplate.ps1"

Compress-Archive -DestinationPath $ttkFileName -Path $releaseFiles -Force

### Temp step for AMP backward compat
Copy-Item "..\..\arm-ttk\arm-ttk" -Destination ".\template-tests" -Recurse
$releaseFiles += ".\template-tests"
$releaseFiles = $releaseFiles -ne "..\..\arm-ttk/arm-ttk"
Compress-Archive -DestinationPath "AzTemplateToolkit.zip" -Path $releaseFiles -Force
Remove-Item ".\template-tests" -Recurse -Force
### End Temp step

$Target = "Target: storage account $StorageAccountName, container $containerName, folder $folderName"

if ($Publish) {
    Write-Host "Publishing to $Target"
    $ctx = (Get-AzStorageAccount -Name $StorageAccountName -ResourceGroupName $StorageAccountResourceGroupName).Context
    Set-AzStorageBlobContent -Container $containerName `
        -File $ttkFileName `
        -Blob "$folderName/$ttkFileName" `
        -Context $ctx `
        -Force -Verbose `
        -Properties @{"ContentType" = "application/x-zip-compressed"; "CacheControl" = "no-cache" }
    Write-Host "Published"
}
else {
    Write-Host "If -Publish flag had been set, this would have published to $Target"
}
