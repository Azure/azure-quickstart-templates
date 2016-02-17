$VerbosePreference="Continue"
$deployName="anhowe0216d"
$RGName=$deployName
#$locName="Japan West"
#$locName="Japan East"

#$locName="SouthEast Asia"
#$locName="East Asia"

# bad regions
#$locName="North Europe"
#$locName="West Europe"
$locName="NorthCentral US"
#$locName="Central US"
#$locName="Australia Southeast"
#$locName="SouthCentral US"
#$locName="Australia East"

#$templateFile= "azuredeploy.windowsjumpbox.json"
#$templateFile= "azuredeploy.nojumpbox.json"
#$templateFile= "azuredeploy.linuxjumpbox.json"
#$templateFile= "opendcos.json"
#$templateFile= "swarmpreview.json"
$templateFile= "acs.json"
$templateParameterFile= "azuredeploy.parameters.json"
New-AzureRmResourceGroup -Name $RGName -Location $locName -Force

echo New-AzureRmResourceGroupDeployment -Name $deployName -ResourceGroupName $RGName -TemplateFile $templateFile
New-AzureRmResourceGroupDeployment -Name $deployName -ResourceGroupName $RGName -TemplateParameterFile $templateParameterFile -TemplateFile $templateFile
