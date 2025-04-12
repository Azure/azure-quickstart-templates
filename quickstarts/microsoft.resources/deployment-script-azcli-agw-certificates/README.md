---
description: This template shows how to generate Key Vault self-signed certificates, then reference from Application Gateway.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: deployment-script-azcli-agw-certificates
languages:
- bicep
- json
---
# Create Application Gateway with Certificates

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.resources/deployment-script-azcli-agw-certificates/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.resources/deployment-script-azcli-agw-certificates/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.resources/deployment-script-azcli-agw-certificates/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.resources/deployment-script-azcli-agw-certificates/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.resources/deployment-script-azcli-agw-certificates/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.resources/deployment-script-azcli-agw-certificates/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.resources/deployment-script-azcli-agw-certificates/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.resources%2Fdeployment-script-azcli-agw-certificates%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.resources%2Fdeployment-script-azcli-agw-certificates%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.resources%2Fdeployment-script-azcli-agw-certificates%2Fazuredeploy.json)   

## Sample overview

This template leverages the KeyVault Certificate module from the bicep registry to create a self-signed certificate which is then added to an Azure Application Gateway.
This demonstrates SSL termination, Key Vault - Application Gateway integration and the Key Vault capability of generating self-signed certificates.

A new Azure Application Gateway and Azure KeyVault are created, as well as a **private** DNS zone.

See the [Create-Kv-Certificate](https://github.com/Azure/bicep-registry-modules/tree/main/modules/deployment-scripts/create-kv-certificate) module in the Bicep Registry for more information.
See the [docs](https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/deployment-script-template?tabs=CLI) for more information on the deployment script resource.

## Deployment steps

You can click the "deploy to Azure" button at the beginning of this document or follow the instructions for command line deployment using the scripts in the root of this repo.

`Tags: ApplicationGateway, Certificate, AzureCli`

## Notes

After deploying the template, access the sample application from your browser using either
- https://[application-gateway-public-ip]
- Using the `ApplicationGatewayPublicIp` and `FrontendPrivateDnsFqdn` deployment outputs to configure your local host file with the private dns address.

Here is what you can expect when accessing the sample application.
![accessing via public ip](browser-screengrab.png)

> To mitigate deployment errors due to RBAC propagation, a resource named `DeployDelay` is created that causes a pause in the deployment for 60 seconds. This allows time for RBAC changes to propagate.
