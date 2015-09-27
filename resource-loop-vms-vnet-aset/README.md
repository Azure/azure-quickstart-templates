# Create Virtual Machines using Resource Loops

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fresource-loop-vms-vnet-aset%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

This template allows you to create 'N' number of Virtual Machines in an availability set based on the 'numberOfInstances' parameter specified during the template deployment. This template also deploys a Storage Account, Virtual Network, 'N' number of Public IP addresses/Network Inerfaces/Virtual Machines.

Note: The Recommended limit of number of disks per Storage Account is 40.

# PowerShell Commands to deploy the template:

1) Download the Latest PowerShell from here and install - http://azure.microsoft.com/en-us/downloads/

2) Run PowerShell and switch to Azure Ressource Manager mode using the command the following command

Switch-AzureMode -Name AzureResourceManager

3) Create the Resource Group

New-AzureResourceGroup -ResourceGroupName testvmrg -Location "West US"

4) Deploy this template using the command below

New-AzureResourceGroupDeployment -Name testvmdeploy -ResourceGroupName testvmrg -TemplateUri "https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/resource-loop-vms-vnet-aset/azuredeploy.json"
