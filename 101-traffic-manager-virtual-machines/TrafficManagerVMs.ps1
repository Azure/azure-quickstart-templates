# parameters 
$rgName = "TrafficManagerVMExample"

# import the AzureRM modules
Import-Module AzureRM.TrafficManager
Import-Module AzureRM.Resources

#  login
Login-AzureRmAccount

# create the resource from the template - pass names as parameters
$scriptDir = Split-Path $MyInvocation.MyCommand.Path
New-AzureRmResourceGroup -Location "northeurope" -Name $rgName
New-AzureRmResourceGroupDeployment -Verbose -Force -ResourceGroupName $rgName -TemplateFile "$scriptDir\azuredeploy.json" -TemplateParameterFile "$scriptDir\azuredeploy.parameters.json"

#  display the end result
$x = Get-AzureRmTrafficManagerProfile -ResourceGroupName $rgName
$x
$x.Endpoints