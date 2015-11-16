param(
    [Parameter(Mandatory=$true)]
    [string]$location,
    [Parameter(Mandatory=$true)]
    [string]$resourceGroupName,
    [string]$customImageStorageAccountName='sdaviesarmne',
    [string]$customImageContainer='images',
    [string]$customImageBlobName='IISBase-osDisk.vhd',
    [Parameter(Mandatory=$true)]
    [string]$newStorageAccountName,
    [string]$newStorageAccountType='"Premium_LRS',
    [string]$newImageContainer='images',
    [string]$newImageBlobName='IISBase-osDisk.vhd',
    [string]$repoUri='https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/201-vmss-windows-customimage/',
    [string]$storageAccountTemplate='templates/storageaccount.json',
    [Parameter(Mandatory=$true)]
    [string]$scaleSetName,
    [int]$scaleSetInstanceCount=2,
    [Parameter(Mandatory=$true)]
    [string]$scaleSetVMSize,
    [Parameter(Mandatory=$true)]
    [string]$scaleSetDNSPrefix,
    [PSCredential]$scaleSetVMCredentials=(Get-Credential -Message 'Enter Credentials for new scale set VMs'),
    [string]$scaleSetTemplate='azuredeploy.json'
    
)

function Switch-AzureResourceManagement
{
    if ($switchMode)
    {
        Switch-AzureMode AzureResourceManager -WarningAction SilentlyContinue
    }
}

function Switch-AzureServiceManagement
{
    if ($switchMode)
    {
        Switch-AzureMode AzureServiceManagement -WarningAction SilentlyContinue
    }
}

# Check that Azure Module is available

$azureModule=import-module -Name Azure
if ($azureModule)
{
    if ($azureModule.Version.Major -eq 0)
    {  
        $switchMode=$true
        Switch-AzureResourceManagement        
    }
    else
    {
        $switchMode=$false
        # TODO - Deal with Azure PS v1
    }
}
else
{
    throw 'Azure Module not available'
}
try
{
    # Create a new Resource Group

    New-AzureResourceGroup -ResourceGroupName $resourceGroupName -Location $location

    # Create a new Storage Account for the image
    
    $parameters=@{"location"="$location";"newStorageAccountName"="$newStorageAccountName";"storageAccountType"="$newStorageAccountType"}
    $templateUri="$repoUri$storageAccountTemplate"

    New-AzureResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateUri $templateUri -TemplateParameterObject $parameters -Name 'createstorageaccount'

    # Copy the blob from the source to the new storage account

    $destkey=(Get-AzureStorageAccountKey -Name $newStorageAccountName -ResourceGroupName $resourceGroupName).Key1
    
    Switch-AzureServiceManagement

    $destcontext= New-AzureStorageContext -StorageAccountName $newStorageAccountName -StorageAccountKey $destkey -Protocol Https
    $srccontext= New-AzureStorageContext -StorageAccountName $customImageStorageAccountName -Anonymous -Protocol Https

    $destcontainer=Get-AzureStorageContainer -Context $destcontext -Name $newImageContainer -ErrorAction SilentlyContinue
    if ($destcontainer -eq $null){
	    New-AzureStorageContainer -Context $destcontext -Name $newImageContainer
    }

    $copystate = Get-AzureStorageBlob -Container $customImageContainer -Context $srccontext -Blob $customImageBlobName|Start-CopyAzureStorageBlob -DestContext $destContext -DestContainer $newImageContainer -DestBlob $newImageBlobName
    $copystate|Get-AzureStorageBlobCopyState -WaitForComplete

    # Deploy the scale set using the new custom image as the target

    $imageSource=(Get-AzureStorageBlob -Container $newImageContainer -Context $destContext -Blob $newImageBlobName).ICloudBlob.StorageUri.PrimaryUri.AbsoluteUri

    $parameters=@{"vmSSName"="$scaleSetName";"instanceCount"="$scaleSetInstanceCount";"vmSize"="$scaleSetVMSize";"dnsNamePrefix"="$scaleSetDNSPrefix";"adminUsername"="$scaleSetVMCredentials.UserName";"adminPassword"="$scaleSetVMCredentials.GetNetworkCredential().Password";"location"="$location";"imageSource"="$imageSource"}
    $templateUri="$repoUri$scaleSetTemplate"

    New-AzureResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateUri $templateUri -TemplateParameterObject $parameters -Name 'createscaleset'
}
catch
{
    Write-Error $_
}
