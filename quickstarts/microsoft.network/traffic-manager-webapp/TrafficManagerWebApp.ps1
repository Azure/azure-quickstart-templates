#
#  This PowerShell script shows how to create a sample traffic manager profile from the accompanying template.
#  As DNS names need to be unique, please edit azuredeploy.parameters.json and replace the values marked with '#####'
#

# parameters 
$rgName = "TrafficManagerWebAppExample"

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
