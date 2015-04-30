Param(

)

Switch-AzureMode AzureServiceManagement

$ErrorActionPreference = "stop"

$currentStorageAccount = (Get-AzureSubscription -Current).CurrentStorageAccountName
$StorageAccountContext = New-AzureStorageContext $currentStorageAccount (Get-AzureStorageKey $currentStorageAccount).Primary
$DropLocationSasToken = New-AzureStorageContainerSASToken -Container 'windows-powershell-dsc' -Context $StorageAccountContext -Permission r 
$DropLocation = $StorageAccountContext.BlobEndPoint + 'windows-powershell-dsc'

Publish-AzureVMDscConfiguration -ConfigurationPath '.\ConfigureWebServer.ps1' -Force

$ModuleURL = "https://$currentStorageAccount.blob.core.windows.net/windows-powershell-dsc/ConfigureWebServer.ps1.zip"

$additionalParameters = New-Object -TypeName Hashtable

$additionalParameters["sasToken"]=$DropLocationSasToken
$additionalParameters["modulesUrl"]=$ModuleURL

Switch-AzureMode AzureResourceManager
New-AzureResourceGroup -Name "cawadscrg1107" `
                       -Location "westus" `
                       -TemplateFile '.\azuredeploy.json' `
                       -TemplateParameterFile '.\azuredeploy-parameters.json' `
                       @additionalParameters
 
