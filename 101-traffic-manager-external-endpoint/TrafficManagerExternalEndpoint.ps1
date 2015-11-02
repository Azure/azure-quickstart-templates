# parameters 
$rgName = "TrafficManagerExternalEndpointExample"

#  set ARM mode
Switch-AzureMode AzureResourceManager

#  login and select subscription context
Add-AzureAccount

# create the resource from the template - pass names as parameters
$scriptDir = Split-Path $MyInvocation.MyCommand.Path
$params = @{"dnsname"="myexample"}
New-AzureResourceGroup -Verbose -Force -Name $rgName -Location "northeurope" -TemplateFile "$scriptDir\azuredeploy.json" -TemplateParameterObject $params

#  display the end result
Get-AzureTrafficManagerProfile -ResourceGroupName $rgName