$RGname="Azure-Budget5"
$region="northeurope"
$params = @{
    rgName = $RGname
    rgLocation = $region
    recipient = "aleki@microsoft.com"
    resourcePrefix = "AzBudget5"
}
$deployName=("deploy-" + (Get-date -Format "yymmdd-hhmmss"))

New-AzResourceGroup -Name $RGName -Location $region -Force
New-AzDeployment -Name $deployName -Location $region -TemplateFile ./azuredeploy.json -TemplateParameterObject $params
