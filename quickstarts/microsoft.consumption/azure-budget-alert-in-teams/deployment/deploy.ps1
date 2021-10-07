$RGname="Azure-Budget"
$region="northeurope"
$params = @{
    rgName = $RGname
    rgLocation = $region
    recipient = "john.doe@contoso.com"
    resourcePrefix = "AzBudget"
}
$deployName=("deploy-" + (Get-date -Format "yymmdd-hhmmss"))

New-AzResourceGroup -Name $RGName -Location $region -Force
New-AzDeployment -Name $deployName -Location $region -TemplateFile ./azuredeploy.json -TemplateParameterObject $params
