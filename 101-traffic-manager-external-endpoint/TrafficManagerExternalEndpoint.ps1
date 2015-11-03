# parameters 
$rgName = "TrafficManagerExternalEndpointExample"

# import the AzureRM modules
Import-Module AzureRM.TrafficManager
Import-Module AzureRM.Resources

#  login
Login-AzureRmAccount

# create the resource from the template - pass names as parameters
$scriptDir = Split-Path $MyInvocation.MyCommand.Path
$params = @{"dnsname"="myexample"}
New-AzureRmResourceGroup -Location "northeurope" -Name $rgName
New-AzureRmResourceGroupDeployment -Verbose -Force -ResourceGroupName $rgName -TemplateFile "$scriptDir\azuredeploy.json" -TemplateParameterObject $params

#  display the end result
$x = Get-AzureRmTrafficManagerProfile -ResourceGroupName $rgName
$x
$x.Endpoints