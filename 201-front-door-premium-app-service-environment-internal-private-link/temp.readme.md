# Front Door Standard/Premium (Preview) with App Service environment (ILB ASE) origin and private endpoint

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/201-front-door-premium-app-service-environment-internal-private-link/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/201-front-door-premium-app-service-environment-internal-private-link/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/201-front-door-premium-app-service-environment-internal-private-link/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/201-front-door-premium-app-service-environment-internal-private-link/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/201-front-door-premium-app-service-environment-internal-private-link/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/201-front-door-premium-app-service-environment-internal-private-link/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-front-door-premium-app-service-environment-internal-private-link%2Fazuredeploy.json)  [![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-front-door-premium-app-service-environment-internal-private-link%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-front-door-premium-app-service-environment-internal-private-link%2Fazuredeploy.json)

This template deploys a Front Door Standard/Premium (Preview) with an App Service environment, and an App Service application origin, using a private endpoint to access the App Service application.

## Sample overview and deployed resources

This sample template creates an App Service environment with an internal load balancer (ILB ASE), app, and a Front Door profile, and uses a private endpoint (also known as Private Link) to access the App Service.

The following resources are deployed as part of the solution:

### Network
- Virtual network.
- Subnet for App Service environment to be deployed into.
- Network security group for the App Service environment's subnet, [configured as required to allow the App Service environment to deploy and operate correctly](https://docs.microsoft.com/azure/app-service/environment/network-info).

### App Service
- App Service environment (v2) configured with an internal load balancer (i.e. an ILB ASE).
- App Service plan and application.
  - The App Service plan must be deployed using an _Isolated_ SKU, since this is required for an App Service environment.

### Front Door Standard/Premium (Preview)
- Front Door profile, endpoint, origin group, origin, and route to direct traffic to the App Service application.
  - This sample must be deployed using the premium Front Door SKU, since this is required for Private Link integration.
  - The Front Door origin is configured to use Private Link. The behaviour of App Service (as of February 2021) is that, once a private endpoint is configured on an App Service instance, [that App Service application will no longer accept connections directly from the internet](https://docs.microsoft.com/azure/app-service/networking/private-endpoint). Traffic must flow through Front Door for it to be accepted by App Service.

The following diagram illustrates the components of this sample.

![Architecture diagram showing traffic inspected by App Service access restrictions.](images/diagram.png)

## Deployment steps

You can click the "deploy to Azure" button at the beginning of this document or follow the instructions for command line deployment using the scripts in the root of this repo.

## Usage

### Connect

Once you have deployed the Azure Resource Manager template, you need to approve the private endpoint connection. This step is necessary because the private endpoint created by Front Door is deployed into a Microsoft-owned Azure subscription, and cross-subscription private endpoint connections require explicit approval. To approve the private endpoint:
1. Open the Azure portal and navigate to the App Service application.
2. Click the **Networking** tab, and then click **Configure your private endpoint connections**.
3. Select the private endpoint that is awaiting approval, and click the **Approve** button. This can take a couple of minutes to complete.

After approving the private endpoint, wait a few minutes before you attempt to access your Front Door endpoint to allow time for Front Door to propagate the settings throughout its network.

You can then access the Front Door endpoint. The hostname is emitted as an output from the deployment - the output is named `frontDoorEndpointHostName`. You should see an App Service welcome page. If you see an error page, wait a few minutes and try again.

You can also attempt to access the App Service hostname directly. The hostname is also emitted as an output from the deployment - the output is named `appServiceHostName`. However, you should not be able to access the host since it is not internet-routable.

## Notes

- Front Door Standard/Premium is currently in preview.
- When using Private Link origins with Front Door Premium during the preview period, [there is a limited set of regions available for use](https://docs.microsoft.com/azure/frontdoor/standard-premium/concept-private-link#limitations). These have been enforced in the template. Once the service is generally available this restriction will likely be removed.
- Front Door Standard/Premium is not currently available in the US Government regions.
- App Service environments, including ILB ASEs, have special requirements for deployment. See [Create an ASE by using an Azure Resource Manager template](https://docs.microsoft.com/azure/app-service/environment/create-from-template) and [Create and use an Internal Load Balancer App Service Environment](https://docs.microsoft.com/azure/app-service/environment/create-ilb-ase).
