Set-Location ".\"
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

#Get-AzureRmSubscription –SubscriptionName “ProDirect Azure Support Team Subscription” | Select-AzureRmSubscription

# View your current Azure PowerShell session context
# This session state is only applicable to the current session and will not affect other sessions
#Get-AzureRmContext


#----------- PARAMETERS--------
#------------------------------
$resourceGroup = "datameer-hdi-chef-trendmicro-12" 
$deploymentName = "datameer-hdideploy--" + [System.DateTime]::Now.ToString("dd-MMMM-yyyy")


#Create Resource Group
New-AzureRmResourceGroup -Name $resourceGroup -Location "West US"

# deploy the template to the resource group
New-AzureRmResourceGroupDeployment -Name $deploymentName -ResourceGroupName $resourceGroup -TemplateFile .\azuredeploy.json -TemplateParameterFile .\azuredeploy.parameters.json -Force -Verbose -DeploymentDebugLogLevel All

#Standalonee Datameer-HDInsight Deploy
#New-AzureRmResourceGroupDeployment -Name $deploymentName -ResourceGroupName $resourceGroup -TemplateFile ..\nested\datameer-hdinsight.json -TemplateParameterFile ..\nested\datameer-hdinsight.parameters.json -Force -Verbose


$operations = Get-AzureRmResourceGroupDeploymentOperation –DeploymentName $deploymentName –ResourceGroupName $resourceGroup 

foreach($operation in $operations)
{
    Write-Host $operation.id
    Write-Host "Request:" -ForegroundColor Green
    $operation.Properties.Request | ConvertTo-Json -Depth 15
    Write-Host "Response:" -ForegroundColor Green
    $operation.Properties.Response | ConvertTo-Json -Depth 15
}
