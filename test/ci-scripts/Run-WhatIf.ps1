param(
    $url,
    $ttkFolder = $ENV:TTK_FOLDER,
    $sampleFolder = $ENV:SAMPLE_FOLDER,
    $sampleName = $ENV:SAMPLE_NAME,
    $paramFileName = $ENV:GEN_PARAMETERS_FILENAME,
    $resourceGroupName = $ENV:RESOURCEGROUP_NAME,
    $filename = "PSWhatIf.zip",
    $StorageAccountKey, 
    $txtFileName = "results.txt",
    $jsonFileName = "results.json",
    [switch]$uploadResults
)

if (!$uploadResults) {

    Invoke-WebRequest -uri "$url" -OutFile "$ttkFolder/$filename" -Verbose
    Get-ChildItem "$ttkFolder/$filename"

    # Unzip Module
    Write-Host "Expanding files..."
    Expand-Archive -Path "$ttkFolder/$filename" -DestinationPath "$ttkFolder/modules" -Verbose -Force

    Write-Host "Expanded files found:"
    #Get-ChildItem "$ttkFolder/modules" -Recurse

    # Import Module
    Import-Module "$ttkFolder/modules/Az.Accounts/Az.Accounts.psd1" -Verbose -Scope Local
    Import-Module "$ttkFolder/modules/Az.Resources/Az.Resources.psd1" -Verbose -Scope Local

    # Run What-If to file
    $results = New-AzDeploymentWhatIf -ScopeType ResourceGroup `
        -Name mainTemplate `
        -TemplateFile "$sampleFolder\azuredeploy.json" `
        -TemplateParameterFile "$sampleFolder\$paramFileName" `
        -ResourceGroupName $resourceGroupName `
        -Verbose

    # Upload files to storage container

    $results | Out-String | Set-Content -Path "$ttkFolder/modules/$txtFileName"
    $results | ConvertTo-Json | Set-Content -Path "$ttkFolder/modules/$jsonFileName"
}
else { # these need to be done in separate runs due to compatibility problems with the modules

    $ctx = New-AzStorageContext -StorageAccountName "azurequickstartsservice" -StorageAccountKey $StorageAccountKey -Environment AzureCloud
    $RowKey = $SampleName.Replace("\", "@").Replace("/", "@")
    Write-Host "RowKey: $RowKey"

    Set-AzStorageBlobContent -Container "whatif" `
        -File "$ttkFolder/modules/$txtFileName" `
        -Blob "$RowKey@$txtFileName" `
        -Context $ctx -Force -Verbose `
        -Properties @{"CacheControl" = "no-cache" }

    Set-AzStorageBlobContent -Container "whatif" `
        -File "$ttkFolder/modules/$jsonFileName" `
        -Blob "$RowKey@$jsonFileName" `
        -Context $ctx -Force -Verbose `
        -Properties @{"CacheControl" = "no-cache" }

}