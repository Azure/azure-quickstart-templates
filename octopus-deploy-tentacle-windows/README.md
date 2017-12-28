# Octopus Deploy Tentacle Agent (Windows) 

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-octopus-deploy-tentacle-windows%2Fazuredeploy.json" target="_blank">
<img src="images/deploytoazure.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-octopus-deploy-tentacle-windows%2Fazuredeploy.json" target="_blank">
<img src="images/visualizebutton.png"/>
</a>

To deploy this template using the scripts from the root of this repo:

```PowerShell
.\Deploy-AzureResourceGroup.ps1 -ResourceGroupLocation 'eastus' -ArtifactsStagingDirectory '101-octopus-deploy-tentacle-windows'
```

```bash
azure-group-deploy.sh -a 101-octopus-deploy-tentacle-windows -l eastus -u
```

This template deploys a Virtual Machine with an Octopus Deploy Tentacle. The Tentacle is an agent which accepts commands from your Octopus Server, allowing you to deploy applications, update configuration files, create IIS web sites and application pools, install windows services, and a whole lot more.

`Tags: OctopusDeploy, Deployment, Tentacle`

## Solution overview and deployed resources

This is an overview of the solution

The following resources are deployed as part of the solution

- 1 Storage account, Standard_LRS
- 1 Network Security Group, allowing RDP traffic
- 1 Public IP Address, using dynamic ip allocation
- 1 Virtual Network + subnet
- 1 Virtual machine, Standard_D2_v2
- the Octopus Deploy Tentacle Agent extension


## Prerequisites

You will need an Octopus Deploy server, contactable from Azure. If you do not yet have one, you can use create one in Azure via [the marketplace](https://azuremarketplace.microsoft.com/en-us/marketplace/apps/octopus.octopusdeploy?tab=Overview).

## Deployment steps

You can click the "deploy to Azure" button at the beginning of this document or follow the instructions for command line deployment using the scripts in the root of this repo.

## Usage

### Connect

Once the extension has installed, your Tentacle will be available in the Environments page of your Octopus Server, and you will be able to deploy projects to it.
