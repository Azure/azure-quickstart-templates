#
#  This PowerShell script shows how to create a sample budget from the accompanying template.
#  As budget name need to be unique, please edit azuredeploy.parameters.json and replace the values marked with '#####', 'YYYY-MM-DD' and other sample data
#

# parameters 
$rgName = "BudgetExample"

#  login
Login-AzureRmAccount

# create the budget from the template - pass names as parameters
$scriptDir = Split-Path $MyInvocation.MyCommand.Path
New-AzureRmResourceGroup -Location "West US" -Name $rgName
New-AzureRmResourceGroupDeployment -Verbose -Force -ResourceGroupName $rgName -TemplateFile "$scriptDir\azuredeploy.json" -TemplateParameterFile "$scriptDir\azuredeploy.parameters.json"
