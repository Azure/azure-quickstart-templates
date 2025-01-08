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
    [Parameter(Mandatory=$true)]
    [string]$newStorageAccountType,
    [string]$newImageContainer='images',
    [string]$newImageBlobName='IISBase-osDisk.vhd',
    [string]$repoUri='https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/quickstarts/microsoft.compute/vmss-windows-customimage/',
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

Import-Module -Name Azure
$azureModule=Get-Module -Name Azure

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
        throw 'Azure PS v1 or greater not supported'
    }
}
else
{
    throw 'Azure Module not available'
}
try
{
     # Create a new Resource Group

    New-AzureResourceGroup -ResourceGroupName $resourceGroupName -Location $location -Force

    # Test names for validity

    $newStorageAccountName=$newStorageAccountName.ToLowerInvariant()
    if (-not (Get-AzureStorageAccount -ResourceGroupName $resourceGroupName -Name $newStorageAccountName -ErrorAction SilentlyContinue))
    {
        if (Test-AzureName -Storage -Name $newStorageAccountName -ErrorAction Stop)
        {
            throw "Storage Account Name in use "
        }
    }

    $scaleSetDNSPrefix=$scaleSetDNSPrefix.ToLowerInvariant()

    if (-not (Get-AzurePublicIpAddress  -ResourceGroupName $resourceGroupName|where Location -eq $location).DnsSettings.DomainNameLabel -eq  $scaleSetDNSPrefix)
    {
        if (-not (Test-AzureDnsAvailability -DomainQualifiedName $scaleSetDNSPrefix -Location $location -ErrorAction Stop))
        {
            throw "Scale Set DNS Name in use "
        }
    }

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
    
    Get-AzureStorageBlob -Container $customImageContainer -Context $srccontext -Blob $customImageBlobName|Start-CopyAzureStorageBlob -DestContext $destContext -DestContainer $newImageContainer -DestBlob $newImageBlobName -ErrorVariable $copyerror -ErrorAction Continue|Get-AzureStorageBlobCopyState -WaitForComplete

    # Deploy the scale set using the new custom image as the target

    $sourceImageVhdUri=(Get-AzureStorageBlob -Container $newImageContainer -Context $destContext -Blob $newImageBlobName).ICloudBlob.StorageUri.PrimaryUri.AbsoluteUri

    Switch-AzureResourceManagement

    $parameters=@{"vmSSName"="$scaleSetName";"instanceCount"=$scaleSetInstanceCount;"vmSize"="$scaleSetVMSize";"dnsNamePrefix"="$scaleSetDNSPrefix";"adminUsername"=$scaleSetVMCredentials.UserName;"adminPassword"=$scaleSetVMCredentials.GetNetworkCredential().Password;"location"="$location";"sourceImageVhdUri"="$sourceImageVhdUri"}
    $templateUri="$repoUri$scaleSetTemplate"

    New-AzureResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateUri $templateUri -TemplateParameterObject $parameters -Name 'createscaleset'
}
catch
{
    Write-Error $_
}
