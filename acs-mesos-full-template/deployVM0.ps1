$VerbosePreference="Continue"
$deployName="anhowe0104e"
$RGName=$deployName
#$locName="Japan East"
$locName="North Europe"
#$templateFile= "azuredeploy.windowsjumpbox.json"
#$templateFile= "azuredeploy.nojumpbox.json"
$templateFile= "azuredeploy.linuxjumpbox.json"
$templateParameterFile= "azuredeploy.parameters.json"
New-AzureRmResourceGroup -Name $RGName -Location $locName -Force

echo New-AzureRmResourceGroupDeployment -Name $deployName -ResourceGroupName $RGName -TemplateFile $templateFile
New-AzureRmResourceGroupDeployment -Name $deployName -ResourceGroupName $RGName -TemplateParameterFile $templateParameterFile -TemplateFile $templateFile
