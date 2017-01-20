#
# azuredeploy.ps1
#
<# deploy an Azure RM template #>

#####################################Azure-Connect###########################################################################################
#check connectvity to microscoft online
Invoke-WebRequest -Uri https://adminwebservice.microsoftonline.com/ProvisioningService.svc

#Create a PSCredential object: you have to use an Azure AD user not the live ID one
$cred = Get-Credential -UserName "yourazureusername@????.onmicrosoft.com" -Message " Login AzureRM"
#Now you can login using that credential object:
Login-AzureRmAccount -Credential $cred

$subscriptionName ="YourAzureSubscriptionName"
# To view all subscriptions for your account # Add the AD user as owner of the subscription Before 
Get-AzureRmSubscription
Select-AzureRmSubscription -SubscriptionName $subscriptionName 


# Deploy using with preconfigured parameters to avoid prompts#######################################################################
$random=Get-Random -minimum 1000 -maximum 9999
$ResourceGroupName = "sfblab1"
$TemplateUri = "https://raw.githubusercontent.com/ibenbouzid/Azure_sfb2015_lab/master/azuredeploy.json"

$StartTime = Get-Date
Write-Host "Starting deployment of resource group : '$ResourceGroupName' on '$StartTime'"  

# create the resource group
New-AzureRmResourceGroup -Name $ResourceGroupName -Location "West Europe" -force

$parameters = @{ `
    storageAccountType= "Standard_LRS"
    adminUsername = "azureuser"
    adminPassword= "@Passw0rd123"
    domainName="mydomain.local"
    dnsPrefix = "sfblab"+$random
    _artifactsLocation = "https://raw.githubusercontent.com/ibenbouzid/Azure_sfb2015_lab/master"
    _SfBshareLocation= "your storage account name (not the path) that contains skype executable files"
    _SfBshareSasToken = "the token to access that share"
    }

New-AzureRmResourceGroupDeployment -Name DeploySfBlab `
                           -ResourceGroupName $ResourceGroupName `
                           -TemplateUri $TemplateUri `
                           -TemplateParameterObject $parameters  `
                           -Force -Verbose

$EndTime = Get-Date
$Duration=(($StartTime) - ($EndTime)).tostring()
Write-Host "Elapsed Deployment Time for '$ResourceGroupName' :'$Duration' " 

<#
# Deploy the lab using the parameterfile##############################################################################
$random=Get-Random -minimum 1000 -maximum 9999
$ResourceGroupName = "sfblab2"
$TemplateUri = "https://raw.githubusercontent.com/ibenbouzid/Azure_sfb2015_lab/master/azuredeploy.json"
$TemplateParametersUri = "https://raw.githubusercontent.com/ibenbouzid/Azure_sfb2015_lab/master/azuredeploy.parameters.json"

$StartTime = Get-Date
Write-Host "Starting deployment of resource group : '$ResourceGroupName' on '$StartTime'"  

# create the resource group
New-AzureRmResourceGroup -Name $ResourceGroupName -Location "West Europe" -force
 
# deploy the template to the resource group
New-AzureRmResourceGroupDeployment -Name DeploySfBlab `
                           -ResourceGroupName $ResourceGroupName `
                           -TemplateUri $TemplateUri `
                           -TemplateParameterUri $TemplateParametersUri `
                           -Force -Verbose

$EndTime = Get-Date
$Duration=(($StartTime) - ($EndTime)).tostring()
Write-Host "Elapsed Deployment Time for '$ResourceGroupName' :'$Duration' " 
#>