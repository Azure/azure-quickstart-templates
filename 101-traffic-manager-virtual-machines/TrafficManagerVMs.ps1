# parameters 
$rgName = "TrafficManagerVMExample"

#  set ARM mode
Switch-AzureMode AzureResourceManager

#  login and select subscription context
Add-AzureAccount

# create the resource from the template - pass names as parameters
$scriptDir = Split-Path $MyInvocation.MyCommand.Path
New-AzureResourceGroup -Verbose -Force -Name $rgName -Location "northeurope" -TemplateFile "$scriptDir\azuredeploy.json" -TemplateParameterFile "$scriptDir\azuredeploy-parameters.json"

#  display the end result
$x = Get-AzureTrafficManagerProfile -ResourceGroupName $rgName
$x
$x.Endpoints