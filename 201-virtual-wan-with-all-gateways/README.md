# Azure Virtual WAN (vWAN) Multi-Hub Deployment

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/201-virtual-wan-with-all-gateways/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/201-virtual-wan-with-all-gateways/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/201-virtual-wan-with-all-gateways/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/201-virtual-wan-with-all-gateways/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/201-virtual-wan-with-all-gateways/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/201-virtual-wan-with-all-gateways/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-virtual-wan-with-all-gateways%2Fazuredeploy.json)

[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-virtual-wan-with-all-gateways%2Fazuredeploy.json)

## Solution Overview

This template creates a fully functional Azure Virtual WAN (vWAN) environment with the following resources:

- Two distinct hubs in different regions
- Four Azure Virtual Networks (VNET)
- Two VNET connections for each vWAN hub
- One Point-to-Site (P2S) VPN gateway in each hub
- One Site-to-Site (S2S) VPN gateway in each hub
- One Express Route gateway in each hub

## Architecture

vWAN resource deployed is of type "Standard" with default full mesh connectivity.
The scenario implemented is exactly the one referenced in the Azure Virtual WAN documentation article below:

[Azure vWAN Routing Scenario: any-to-Any](https://docs.microsoft.com/azure/virtual-wan/scenario-any-to-any)

:::image type="content" source="images/azurevirtualwanarchitecturefigure1.jpg" alt-text="vWAN Architecture":::

List of input parameters has been kept at the very minimum, for each one a default value has been provided to expedite sample creation.
IP addressing scheme can be changed modifying the variables inside the template, default values have been provided based on the architecture diagram above.

> [!NOTE]
> This template will create all the vWAN resources listed above, but will not create the customer side resources required for hybrid connectivity. After template deployment will be completed, user will need to create P2S VPN clients, VPN branches (Local Sites) and connect Express Route circuits.

> [!WARNING]
> Default values for parameters ***Hub1_PublicCertificateDataForP2S*** and ***Hub2_PublicCertificateDataForP2S***  (Point-to-Site (P2S) configuration) have been provided only as a sample to complete quickly the vWAN deployment procedure. After the deployment is completed, you should generate your own certificates and change each Point-to-Site (P2S) Gateway configuration to use your own.

## Deployment Instructions

Azure vWAN presents an interesting challenge when deploying using ARM template: after each hub is created, the Routing Service inside will take some time to be fully operational, even if the resource deployment status will be reported as successfully completed from an ARM perspective. This may cause errors using the template if you don't manage the resource deployment dependency chain appropriately. This ARM template has been created to solve this problem and to successfully deploy all intended resources in the template. All resource creations have been carefully chained and made serial, inside the same hub, in order to avoid deployment errors.

Users are encouraged to test and modify the template, but it is recommended to keep VPN resource dependent on the hub, and all additional resources should be dependent on VPN itself: since VPN gateway will require some time to be fully deployed, additional resource deployment will succeed since vWAN Routing Service will have already reached a ready state. A possible alternative is to submit a second time the same deployment, once the error will cause first attempt to fail.

:::image type="content" source="images/azurevirtualwanroutingservicestatefigure2.jpg" alt-text="Routing Service State":::

First attempt of template deployment should fail after 5-6 minutes, then 10-15 minutes will be required for the Routing Services to be in ready state. The second attempt will take longer due to the number of gateways and complexity of configuration. A sample PowerShell script has been provided to automatically manage this retry process in a consistent way, you can find it below. During tests, an average duration of 80-90 minutes has been observed for completion of the entire template deployment, please note that it can varies in your environment.

:::image type="content" source="images/deploymentcompleteinazureportal.jpg" alt-text="Template Deployment State":::

## PowerShell Helper Script

It is possible to manage template deployment retry in order to solve the vWAN possible first run failure issue.
The sample script ***Deploy_vWAN.ps1*** provided will submit the deployment a first time, then will wait for completion and check for Routing Service state in each hub: once both of them will be in ready state, the same deployment will be retried.

> [!CAUTION]
> This script is only a sample, it is provided "*as is*", should not be used in production without proper testing.

## Successful Deployment

Once the ARM deployment of the template will be completed, you should see something similar to the image below in your Azure Portal:

:::image type="content" source="images/vwanresourcesinazureportal.jpg" alt-text="vWAN Resources in the Azure Portal":::

`Tags: Virtual WAN, vWAN, Hub, ExpressRoute, VPN, S2S, P2S, Routing`
