# Solution name

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-container-registry%2Fazuredeploy.json" target="_blank">
<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-container-registry%2Fazuredeploy.json" target="_blank">
<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.png"/>
</a>

To deploy this template using the scripts from the root of this repo:

```PowerShell
.\Deploy-AzureResourceGroup.ps1 -ResourceGroupLocation 'eastus' -ArtifactsStagingDirectory '101-container-registry'
```
```bash
azure-group-deploy.sh -a '101-container-registry' -l eastus -u
```

This template deploys an Azure Container Registry with its storage account. Azure Container Registry is a PaaS offer for creating your own Docker image registry.

`Tags: Azure Container Registry, Docker`

## Solution overview and deployed resources

This is an overview of the solution

The following resources are deployed as part of the solution

+ **Storage Account**: Storage account used by Container Registry for storing its data
+ **Azure Container Registry**: Docker image registry

## Deployment steps

You can click the "deploy to Azure" button at the beginning of this document or follow the instructions for command line deployment using the scripts in the root of this repo.

## Usage

## Login to your registry

Follow [this documentation](https://docs.microsoft.com/en-us/azure/container-registry/container-registry-authentication) for authenticate your docker client to your container registry.

#### Push images to your registry

For pushing docker images on your registry, follow [this documentation](https://docs.microsoft.com/en-us/azure/container-registry/container-registry-get-started-docker-cli)


