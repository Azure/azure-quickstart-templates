# Front Door Standard/Premium (Preview) with Azure Container Instances origin

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/front-door-standard-premium-container-instances-public/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/front-door-standard-premium-container-instances-public/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/front-door-standard-premium-container-instances-public/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/front-door-standard-premium-container-instances-public/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/front-door-standard-premium-container-instances-public/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/front-door-standard-premium-container-instances-public/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/front-door-standard-premium-container-instances-public/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.network%2Ffront-door-standard-premium-container-instances-public%2Fazuredeploy.json)  [![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.network%2Ffront-door-standard-premium-container-instances-public%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.network%2Ffront-door-standard-premium-container-instances-public%2Fazuredeploy.json)

This template deploys a Front Door Standard/Premium (Preview) with an Azure Container Instances origin, using a public IP address for the container group.

## Sample overview and deployed resources

This sample template creates an Azure Container Instances container group and a Front Door profile. The container group has a public IP address associated with it.

The following resources are deployed as part of the solution:

## Container Instances
- Container group, with a single container deployed from the Hello World image.

### Front Door Standard/Premium (Preview)
- A Front Door profile with an endpoint, which is configured with an origin group, origin, and route to direct traffic to the container group.
  - Note that you can use either the standard or premium Front Door SKU for this sample. By default, the standard SKU is used.

In this sample, traffic can flow directly to the container group. There is no mechanism to ensure the traffic has passed through Front Door. To restrict access, [consider deploying the container group with virtual network integration and deploy an Application Gateway instance to restrict traffic](https://docs.microsoft.com/azure/container-instances/container-instances-application-gateway). The [Front Door Standard/Premium (Preview) with Container Instances and Application Gateway origin](https://github.com/Azure/azure-quickstart-templates/tree/master/quickstarts/microsoft.network/front-door-standard-premium-container-instances-application-gateway-public) sample illustrates this scenario.

The following diagram illustrates the components of this sample.

![Architecture diagram showing container group and Front Door profile.](images/diagram.png)

## Deployment steps

You can click the "deploy to Azure" button at the beginning of this document or follow the instructions for command line deployment using the scripts in the root of this repo.

## Usage

### Connect

Once you have deployed the Azure Resource Manager template, wait a few minutes before you attempt to access your Front Door endpoint to allow time for Front Door to propagate the settings throughout its network.

You can then access the Front Door endpoint. The hostname is emitted as an output from the deployment - the output is named `frontDoorEndpointHostName`. If you access the base hostname you should see a page saying _Welcome to Azure Container Instances!_. If you see a different error page, wait a few minutes and try again.

## Notes

- Front Door Standard/Premium is currently in preview.
- Front Door Standard/Premium is not currently available in the US Government regions.
