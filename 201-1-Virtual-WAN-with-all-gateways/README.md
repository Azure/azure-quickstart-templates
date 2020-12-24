# Azure Virtual WAN (vWAN) Multi-Hub Deployment

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-1-Virtual-WAN-with-all-gateways%2Fazuredeploy.json)

## Solution Overview

This template creates a fully functional Azure Virtual WAN (vWAN) environment with the following resources:

- Two distinct hubs in different regions
- Four Azure Virtual Networks (VNET)
- Two VNET connections to each vWAN hub
- One Point-to-Site (P2S) VPN gateway in each hub
- One Site-to-Site (S2S) VPN gateway in each hub
- One Express Route gateway in each hub

## Architecture

vWAN resource deployed is of type "Standard" with default full mesh connectivity.
The scenario implemented is exactly the one referenced in the Azure Virtual WAN documentation article below:

[Azure vWAN Routing Scenario: any-to-Any](https://docs.microsoft.com/azure/virtual-wan/scenario-any-to-any)

:::image type="content" source="Images/AzureVirtualWANArchitectureFigure1.jpg" alt-text="vWAN Architecture":::

List of input parameters has been kept at the very minimum, for each one a default value has been provided to expedite sample creation.
IP addressing scheme can be changed modifying the variables inside the template, default values have been provided based on the architecture diagram above.

> [!NOTE]
> This template will crete all the vWAN resources listed above, but will not create the customer side resources required for hybrid connectivity. After template deployment will be completed, user will need to create VPN clients, VPN branches and connect Express Route circuits.

> [!WARNING]
> Default values for parameters ***Hub1_PublicCertificateDataForP2S*** and ***Hub2_PublicCertificateDataForP2S***  (Point-to-Site (P2S) configuration) have been provided only as a sample to complete quickly the vWAN deployment procedure. After the deployment is completed, you should generate your own certificates and change each Point-to-Site (P2S) Gateway configuration to use your own.

## Deployment Instructions

Due to how vWAN deployment works, the first attempt to run this template is expected to fail.
It is sufficient to retry the same deployment, but before doing this the Routing Service in each vWAN hub need to be in the deployment state, as shown in the figure below.

:::image type="content" source="Images/AzureVirtualWANRoutingServiceStateFigure2.jpg" alt-text="Routing Service State":::

First attempt of template deployment should fail after 5-6 minutes, then 10-15 minutes will be required for the Routing Services to be in ready state. The second attempt will take longer due to the number of gateways and complexity of configuration. During tests, an average duration of 80-90 minutes has been observed, please note that it can vary in your environment.

:::image type="content" source="Images/DeploymentCompleteInAzurePortal.jpg" alt-text="Template Deployment State":::

## PowerShell Helper Script

It is possible to manage template deployment in order to solve the vWAN first run expected failure issue. Using the sample script ***Deploy_vWAN.ps1*** it is possible to automate end-to-end vWAN deployment without any interruption or exception.
> [!CAUTION]
> This script is only a sample, it is provided "*as is*", should not be used in production without proper testing.

## Successful Deployment

Once the second deployment of the template will be completed, you should see something similar to the image below in your Azure Portal:

:::image type="content" source="Images/vWANResourcesInAzurePortal.jpg" alt-text="vWAN Resources in the Azure Portal":::
