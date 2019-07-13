# Deploy Azure Bastion in an Azure Virtual Network

This template will deploy Azure Bastion in a new or existing Azure Virtual Network, along with dependent resources such as the AzureBastionSubnet, Public Ip Address for Azure Bastion, and Network Security Group rules.

This template deploys resources in the same Resource Group and Azure region as the Virtual Network.

Note that Azure Bastion is currently in Public Preview status.  As a result, please reference the <a href="https://docs.microsoft.com/en-us/azure/bastion/bastion-overview" target="_blank">Azure Bastion</a> documentation to confirm that you are deploying to an enabled Azure region and that you have onboarded to participating in the Public Preview.

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-azure-bastion%2Fazuredeploy.json" target="_blank"><img src="http://azuredeploy.net/deploybutton.png"/>
</a>

## Deploying Sample Templates

You can deploy these samples directly through the Azure Portal or by using scripts.

To deploy a sample using the Azure Portal, click the **Deploy to Azure** button.

To deploy the sample via the command line (using [Azure PowerShell or the Azure CLI](https://azure.microsoft.com/en-us/downloads/)) you can use scripts.
```
Tags: ``bastion``
