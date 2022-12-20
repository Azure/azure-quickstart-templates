# Front Door Premium (Preview) with Azure Storage blob container origin and Private Link

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/front-door-premium-storage-blobs-private-link/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/front-door-premium-storage-blobs-private-link/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/front-door-premium-storage-blobs-private-link/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/front-door-premium-storage-blobs-private-link/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/front-door-premium-storage-blobs-private-link/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/front-door-premium-storage-blobs-private-link/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/front-door-premium-storage-blobs-private-link/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.network%2Ffront-door-premium-storage-blobs-private-link%2Fazuredeploy.json)  [![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.network%2Ffront-door-premium-storage-blobs-private-link%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.network%2Ffront-door-premium-storage-blobs-private-link%2Fazuredeploy.json)

This template deploys a Front Door Premium (Preview) with an Azure Storage blob container origin, using a private endpoint to access the storage account.

## Sample overview and deployed resources

This sample template creates an Azure Storage blob container and a Front Door profile, and uses a private endpoint (also known as Private Link) to access the storage account.

The following resources are deployed as part of the solution:

### Azure Storage
- Storage account, which is configured not to accept any traffic from the internet.
- Blob container.

### Front Door Premium (Preview)
- Front Door profile, endpoint, origin group, origin, and route to direct traffic to the Azure Storage blob container.
  - This sample must be deployed using the premium Front Door SKU, since this is required for Private Link integration.

The following diagram illustrates the components of this sample.

![Architecture diagram showing traffic inspected by the Azure Storage firewall.](images/diagram.png)

## Deployment steps

You can click the "deploy to Azure" button at the beginning of this document or follow the instructions for command line deployment using the scripts in the root of this repo.

## Usage

### Connect

Once you have deployed the Azure Resource Manager template, you need to approve the private endpoint connection. This step is necessary because the private endpoint created by Front Door is deployed into a Microsoft-owned Azure subscription, and cross-subscription private endpoint connections require explicit approval. To approve the private endpoint:
1. Open the Azure portal and navigate to the storage account.
2. Click the **Networking** tab, and then click the **Private endpoint connections** tab.
3. Select the private endpoint that is awaiting approval, and click the **Approve** button. This can take a couple of minutes to complete.

After approving the private endpoint, wait a few minutes before you attempt to access your Front Door endpoint to allow time for Front Door to propagate the settings throughout its network.

You can then access the Front Door endpoint. The hostname is emitted as an output from the deployment - the output is named `frontDoorEndpointHostName`. You should see a page saying _The specified resource does not exist_. This is returned by Azure Storage because no files have been uploaded to the blob container and therefore there is no content to show yet. If you see a different error page, wait a few minutes and try again.

You can also attempt to access the Azure Storage blob hostname directly. The hostname is also emitted as an output from the deployment - the output is named `blobEndpointHostName`. You should see an error saying _This request is not authorized to perform this operation_ error, since your storage account is configured to not accepts requests that come from the internet.

## Notes

- Front Door Premium is currently in preview.
- When using Private Link origins with Front Door Premium during the preview period, [there is a limited set of regions available for use](https://docs.microsoft.com/en-us/azure/frontdoor/standard-premium/concept-private-link#limitations). These have been enforced in the template. Once the service is generally available this restriction will likely be removed.
- Front Door Premium is not currently available in the US Government regions.
