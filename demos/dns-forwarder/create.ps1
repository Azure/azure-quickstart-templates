#
#  This PowerShell script shows how to deploy the "DNS forwarder" resource template.
#  As storage account names need to be unique, please edit storageAccName to a value that's available.
#


# parameters 
$rgname = "DnsForwardExample"

$params = @{
    "vmName" = "dnsproxy1";
    "adminUsername"="mradmin";
    "adminPassword"="Admin123!";
    "storageAccName"="$($rgname)stor".ToLower();
}

#  script folder
$scriptDir = Split-Path $MyInvocation.MyCommand.Path

# import the AzureRM modules
Import-Module AzureRM.Resources

#  login
Login-AzureRmAccount

# create the resource from the template
New-AzureRmResourceGroup -Name $rgname -Location "northeurope"
New-AzureRmResourceGroupDeployment -Name $rgname -ResourceGroupName $rgname -TemplateFile "$scriptDir\azuredeploy.json" -TemplateParameterObject $params

# create a second forwarder vm 
$params.vmName = "dnsproxy2"
New-AzureRmResourceGroupDeployment -Name $rgname -ResourceGroupName $rgname -TemplateFile "$scriptDir\azuredeploy.json" -TemplateParameterObject $params

