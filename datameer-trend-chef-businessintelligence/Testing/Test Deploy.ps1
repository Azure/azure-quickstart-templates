# To make sure the Azure PowerShell module is available after you install
Get-Module –ListAvailable 

$path = ".\DONOTCHECKIN-LoggedInServicePrincipal.json"

# To login to Azure Resource Manager
if(![System.IO.File]::Exists($path)){
    # file with path $path doesn't exist

    Add-AzureRmAccount
    
    Save-AzureRmProfile -Path $path
}

Select-AzureRmProfile -Path $path


# To select a default subscription for your current session
Get-AzureRmSubscription –SubscriptionName “Cloudly Dev (Visual Studio Ultimate)” | Select-AzureRmSubscription

# View your current Azure PowerShell session context
# This session state is only applicable to the current session and will not affect other sessions
Get-AzureRmContext


#----------- PARAMETERS--------
#------------------------------
$resourceGroup = "datameer-hdinsight-1"
$deploymentName = "datameer-trend-chef"

#Create Resource Group
New-AzureRmResourceGroup -Name $resourceGroup -Location "West US"

# deploy the template to the resource group
#New-AzureRmResourceGroupDeployment -Name datameer-trend-chef -ResourceGroupName $resourceGroup -TemplateFile ..\azuredeploy.json -TemplateParameterFile ..\azuredeploy.parameters.json

#Standalonee Datameer-HDInsight Deploy
New-AzureRmResourceGroupDeployment -Name $deploymentName -ResourceGroupName $resourceGroup -TemplateFile ..\nested\datameer-hdinsight.json -TemplateParameterFile ..\nested\datameer-hdinsight.parameters.json







# -------------- TRIALS --------------------------
# To select the default storage context for your current session
#Set-AzureRmCurrentStorageAccount –ResourceGroupName “1-datameer-trend-chef” –StorageAccountName “your storage account name”

# View your current Azure PowerShell session context
# Note: the CurrentStorageAccount is now set in your session context
##Get-AzureRmContext

# To list all of the blobs in all of your containers in all of your accounts
##Get-AzureRmStorageAccount | Get-AzureStorageContainer | Get-AzureStorageBlob
