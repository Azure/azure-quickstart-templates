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

3) Deploy this template using the command below

New-AzureResourceGroupDeployment -Name testvmdeploy -ResourceGroupName testvmrg -TemplateUri "https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/resource-loop-vms-vnet-aset/azuredeploy.json"


# Parameters for the template

| Name   | Description    |
|:--- |:---|
| newStorageAccountName  | Unique DNS Name for the Storage Account where the Virtual Machine's disks will be placed. |
| adminUsername  | Username for the Virtual Machines  |
| adminPassword  | Password for the Virtual Machine  |
| numberOfInstances  | Number of Virtual Machine instances to create  |
| region | Region where the resources will be deployed |
| vmSize | Size of the Virtual Machine |
| imagePublisher | Name of Image Publisher |
| imageOffer | Name of Image Publisher offer |
| imageSKU | Name of SKU for the selected offer |
