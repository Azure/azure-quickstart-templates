# To make sure the Azure PowerShell module is available after you install
Get-Module –ListAvailable 

# To login to Azure Resource Manager
Login-AzureRmAccount

# You can also use a specific Tenant if you would like a faster login experience
# Login-AzureRmAccount -TenantId xxxx

# To view all subscriptions for your account
Get-AzureRmSubscription

# To select a default subscription for your current session
Get-AzureRmSubscription –SubscriptionName “Cloudly Dev (Visual Studio Ultimate)” | Select-AzureRmSubscription

# View your current Azure PowerShell session context
# This session state is only applicable to the current session and will not affect other sessions
Get-AzureRmContext

# To select the default storage context for your current session
#Set-AzureRmCurrentStorageAccount –ResourceGroupName “1-datameer-trend-chef” –StorageAccountName “your storage account name”

# View your current Azure PowerShell session context
# Note: the CurrentStorageAccount is now set in your session context
##Get-AzureRmContext

# To list all of the blobs in all of your containers in all of your accounts
##Get-AzureRmStorageAccount | Get-AzureStorageContainer | Get-AzureStorageBlob


#Create Resource Group
New-AzureRmResourceGroup -Name datameer-trend-chef -Location "West US"

# deploy the template to the resource group
New-AzureRmResourceGroupDeployment -Name ExampleDeployment -ResourceGroupName datameer-trend-chef -TemplateFile ./azuredeploy.json
