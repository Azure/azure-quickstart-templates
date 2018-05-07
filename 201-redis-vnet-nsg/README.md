# Add an NSG with security rules to an existing subnet
<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-redis-vnet-nsg%2Fazuredeploy.json" target="_blank">
<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-redis-vnet-nsg%2Fazuredeploy.json" target="_blank">
<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.png"/>
</a>

First, modify the parameter file found in this folder. Then from the root of this template folder, run the following Azure PowerShell or CLI command:
```PowerShell
New-AzureRmResourceGroupDeployment -ResourceGroupName my-resource-group -TemplateFile .\azuredeploy.json -TemplateParameterFile .\azuredeploy.parameters.json
```
```bash
az group deployment create --resource-group my-resource-group --template-file azuredeploy.json --parameters @azuredeploy.parameters.json
```

`Tags: redis, cache, vnet, nsg`

## Solution overview and deployed resources
This template deploys a Network Security Group. The NSG is preconfigured with security rules to allow Azure Redis Cache to operate within an existing Virtual Network.

The following resources are deployed as part of the solution

#### Network Security Groups
This template deployes a Network Security Group

+ **Microsoft.Network/networkSecurityGroups**: the new Network Security Group with preconfigured Azure Redis Cache rules

#### Virtual Networks
This template associates the new NSG with an existing subnet within an existng Virtual Network

+ **Microsoft.Network/virtualNetworks**: an existing Virtual Network and subnet


## Prerequisites
An existing Virtual Network and subnet is required before deploying this template. Learn more about the VNet requirements for Azure Redis Cache [here](https://docs.microsoft.com/en-us/azure/redis-cache/cache-how-to-premium-vnet).

The provided prerequisite templates may be used to deploy the required VNet. First, modify the parameter file found in the prereqs folder. Then from the root of this template folder, run the following commands:
```PowerShell
cd .\prereqs\
New-AzureRmResourceGroupDeployment -ResourceGroupName my-resource-group -TemplateFile .\prereq.azuredeploy.json -TemplateParameterFile .\prereq.azuredeploy.parameters.json
```
```bash
cd prereqs/
az group deployment create --resource-group my-resource-group --template-file prereq.azuredeploy.json --parameters @prereq.azuredeploy.parameters.json
```

## Deployment steps
You can click the "deploy to Azure" button at the beginning of this document, use the command line deployment instructions in this document, or follow the instructions for command line deployment using the scripts in the root of this repo.

## Notes
If an NSG with the same name and resource group already exists, it will be replaced with the new NSG. All existing security rules in the old NSG will be lost. If other subnets are associated with the NSG, they will remain associated with the new NSG and its security rules.
