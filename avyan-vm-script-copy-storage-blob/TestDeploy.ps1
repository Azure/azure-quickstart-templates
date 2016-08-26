$path = ".\DONOTCHECKIN-LoggedInServicePrincipal.json"

# To login to Azure Resource Manager
if(![System.IO.File]::Exists($path)){
    # file with path $path doesn't exist

    Add-AzureRmAccount
    
    Save-AzureRmProfile -Path $path
}

Select-AzureRmProfile -Path $path


# To select a default subscription for your current session
#Get-AzureRmSubscription –SubscriptionName “Cloudly Dev (Visual Studio Ultimate)” | Select-AzureRmSubscription
Get-AzureRmSubscription –SubscriptionName “ProDirect Azure Support Team Subscription” | Select-AzureRmSubscription


#----------- PARAMETERS--------
#------------------------------
$resourceGroup = "ignitecopyblob15" 
$deploymentName = "ignite2016test-copyblob" + [System.DateTime]::Now.ToString("dd-MMMM-yyyy")


#Create Resource Group
New-AzureRmResourceGroup -Name $resourceGroup -Location "West US"

# deploy the template to the resource group
New-AzureRmResourceGroupDeployment -Name $deploymentName `
                                   -TemplateFile .\azuredeploy.json `
                                   -Mode Incremental `
                                   -ResourceGroupName $resourceGroup `
                                   -TemplateParameterFile .\azuredeploy.parameters.json `
                                   -Force -Verbose `
                                   -DeploymentDebugLogLevel All















$operations = Get-AzureRmResourceGroupDeploymentOperation –DeploymentName $deploymentName –ResourceGroupName $resourceGroup 

foreach($operation in $operations)
{
    Write-Host $operation.id
    Write-Host "Request:" -ForegroundColor Green
    $operation.Properties.Request | ConvertTo-Json -Depth 10
    Write-Host "Response:" -ForegroundColor Green
    $operation.Properties.Response | ConvertTo-Json -Depth 10
}


#.\ImageTransfer.ps1 -SourceImage 'https://avyanignite201611.blob.core.windows.net/datameersamples/Log Format.xlsx' -SourceSAKey ZG6vKKtB6AgaK5KPX0DAR5CzBmXhgeU8anTOq0J1czh0UqyApUCHvUfF3Evh3Ms7gY99b2a6NBphRR0eKzmWVw== -DestinationURI https://dwnu3zwa6gknm.blob.core.windows.net/datameersamples -DestinationSAKey 58jOWEl6/nwJb2NxIb6O6IivkBpbVSnSfyJKmhpEmm/epY4/AefovWtluFF2g9kfNR5Vp6nBwT/SfmNzZn/3Mg==

#Get-Help about_Quoting_Rules

#Update-Help