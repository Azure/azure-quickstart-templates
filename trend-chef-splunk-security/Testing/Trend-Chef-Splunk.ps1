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
#Get-AzureRmContext


#----------- PARAMETERS--------
#------------------------------
$resourceGroup = "datameer-hdinsight" 
$deploymentName = "datameer-hdinsight-deploy--" + [System.DateTime]::Now.ToString("dd-MMMM-yyyy")


#Create Resource Group
New-AzureRmResourceGroup -Name $resourceGroup -Location "West US"

# deploy the template to the resource group
New-AzureRmResourceGroupDeployment -Name $deploymentName -ResourceGroupName $resourceGroup -TemplateFile .\azuredeploy.json -TemplateParameterFile .\azuredeploy.parameters.json -Force -Verbose
